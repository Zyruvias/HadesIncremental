-- HandleUpgradeChoiceSelection for poms
ModUtil.Path.Wrap("HandleUpgradeChoiceSelection", function (baseFunc, screen, button)
  if button.LootData.Name == "StackUpgrade" then
    local traitName = button.Data.Name
    local levelCount  = GetTraitNameCount(CurrentRun.Hero, traitName)
    for i = levelCount, levelCount + button.LootData.StackNum - 1 do
      -- DebugPrint { Text = i }
      ZyruIncremental.TrackDrop(button.LootData.Name, math.floor(150 / math.pow(2, (i - 1) / 2)))
    end
  end

  return baseFunc(screen, button)
end, ZyruIncremental)

-- this is Eury/pomslice/nectar
ModUtil.Path.Wrap("AddStackToTraits", function (baseFunc, source, args)
  if args and args.Thread then
    -- this calls itself again, wait for those changes to resolve before doing anything 
    return baseFunc(source, args)
  end
  ZyruIncremental.TrackDrop("StackUpgrade", (source.NumTraits or 1) * (source.NumStacks or 1) * 75 )
  return baseFunc(source, args)
end, ZyruIncremental)

function ZyruIncremental.TrackDrop(source, amount)
  if source == nil or amount == nil then
    DebugPrint { Text = "drop source or amount nil"}
    return
  end
  
  -- DebugPrint { Text = "Drop Tracked: " .. source .. " for " .. tostring(amount) }
  local dropData = ZyruIncremental.Data.DropData[source]
  dropData.Count = dropData.Count + 1
  dropData.Amount = dropData.Amount + amount
  dropData.Experience = dropData.Experience + ZyruIncremental.DropExperienceFactor[source] * amount
  -- if level-up: 
  if ZyruIncremental.GetExperienceForNextBoonLevel(dropData.Level) <= dropData.Experience then
    dropData.Level = dropData.Level + 1
    local voiceLine = GetRandomValue(ZyruIncremental.DropLevelUpVoiceLines[source])
    if voiceLine ~= nil then
      thread(PlayVoiceLine, voiceLine)
    end
  end
end

ModUtil.Path.Wrap("GetRarityChances", function (baseFunc, args )
  -- TODO: override? only calling baseFunc to preserve side effects for mod compatibility
  baseFunc(args)
	local name = args.Name
	local ignoreTempRarityBonus = args.IgnoreTempRarityBonus
	local referencedTable = "BoonData"
  local baseRarity = 0
	if name == "StackUpgrade" then
		referencedTable = "StackData"
	elseif name == "WeaponUpgrade" then
		referencedTable = "WeaponData"
	elseif name == "HermesUpgrade" then
		referencedTable = "HermesData"
  else
    local godNameFromUpgrade = string.sub(name, 1, string.len(name) - 7)
    if godNameFromUpgrade == "Trial" then
      godNameFromUpgrade = "Chaos"
    end
    local godData = ZyruIncremental.Data.GodData[godNameFromUpgrade]
    baseRarity = baseRarity + (godData.RarityBonus or 0) + (ModUtil.Path.Get("TransientState[" ..godNameFromUpgrade .. "RarityBonus]", ZyruIncremental) or 0)
	end

	local legendaryRoll = CurrentRun.Hero[referencedTable].LegendaryChance or 0

	if CurrentRun.CurrentRoom.BoonRaritiesOverride then
		legendaryRoll = CurrentRun.CurrentRoom.BoonRaritiesOverride.LegendaryChance or legendaryRoll
		baseRarity = baseRarity + 100 * CurrentRun.CurrentRoom.BoonRaritiesOverride.RareChance or 0
	elseif args.BoonRaritiesOverride then
		legendaryRoll = args.BoonRaritiesOverride.LegendaryChance or legendaryRoll
		baseRarity = baseRarity + 100 * args.BoonRaritiesOverride.RareChance or 0
	end
  -- NOTE: Rare roll mirror upgrade is now resource generation
	-- local metaupgradeRareBoost = 100 * GetNumMetaUpgrades( "RareBoonDropMetaUpgrade" ) * ( MetaUpgradeData.RareBoonDropMetaUpgrade.ChangeValue - 1 )
	local metaupgradeEpicBoost = 100 * GetNumMetaUpgrades( "EpicBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
    + GetNumMetaUpgrades( "EpicHeroicBoonMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	baseRarity = baseRarity + metaupgradeEpicBoost
  local metaupgradeLegendaryBoost = GetNumMetaUpgrades( "DuoRarityBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	legendaryRoll = legendaryRoll + metaupgradeLegendaryBoost

	local rarityTraits = GetHeroTraitValues("RarityBonus", { UnlimitedOnly = ignoreTempRarityBonus })
	for i, rarityTraitData in pairs(rarityTraits) do
		if rarityTraitData.RequiredGod == nil or rarityTraitData.RequiredGod == name then
			if rarityTraitData.RareBonus then
				baseRarity = baseRarity + 100 * rarityTraitData.RareBonus
      end
      
      -- Exclusive Access and other new boons
      if rarityTraitData.ZyruRarityBonus then
				baseRarity = baseRarity + 100 * rarityTraitData.ZyruRarityBonus
			end
			if rarityTraitData.LegendaryBonus then
				legendaryRoll = legendaryRoll + rarityTraitData.LegendaryBonus
			end
		end
	end

  local chances = ZyruIncremental.ComputeRarityDistribution( baseRarity )
	chances.Legendary = legendaryRoll
  return chances
end, ZyruIncremental)


ModUtil.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
  -- Calculate normal rarity for the sake of Duos / Legendaries, I like the current system.
  -- DebugPrint { Text = ModUtil.ToString.Shallow(lootData)}
  baseFunc(lootData, args)
  -- ZyruIncremental.DebugLoot = DeepCopyTable(lootData)
  -- ZyruIncremental.DebugArgs = DeepCopyTable(args)
  if lootData.ForceCommon then
    -- respect common forces from first run or other sources. hammer  / pom later?
    return
  end


  local upgradeOptions = lootData.UpgradeOptions

  -- reconstruct TraitData Rarity Table locally, copied from Combat.lua
  local rarityTable = {
    Common = {},
    Rare = {},
    Epic = {},
    Heroic = {},
		Supreme = {},
		Ultimate = {},
		Transcendental = {},
		Mythic = {},
		Olympic = {},
  }

  -- make sure rarity levels exist in boon data
  for i, upgradeData in pairs(upgradeOptions) do
    local rarityLevels = nil
    if upgradeData.Type == "Trait" then
      rarityLevels = TraitData[upgradeData.ItemName].RarityLevels
    end
    if upgradeData.Type == "Consumable" then
      rarityLevels = ConsumableData[upgradeData.ItemName].RarityLevels
    end

    if rarityLevels == nil then
      rarityLevels = { Common = true }
    end

    for key, table in pairs( rarityTable ) do
      if rarityLevels[key] ~= nil then
        table[upgradeData.ItemName] = upgradeData
      end
    end
  end

  local god = string.sub(lootData.Name, 1, string.len(lootData.Name) - 7)
  if god == "Trial" then
    god = "Chaos" -- TrialUpgrade -> Chaos boons... I am not reusing that naming convention
  elseif god == "Stack" or god == "Weapon" then
    god = nil
  end
  
  for i, upgradeData in ipairs(upgradeOptions) do
    if
      -- preserve legendary / duo system
      god ~= nil and upgradeData.Rarity ~= "Legendary"
      -- respect replace system / rarity
      and not upgradeData.OldRarity
    then
      local chosenRarity = "Common"
      local chances = lootData.RarityChances
      local cumulativeChance = 0
      
      local rarityArray = { "Common", "Rare", "Epic", "Heroic", "Supreme", "Ultimate", "Transcendental", "Mythic", "Olympic" }
      local roll = RandomNumber()
      for i, rarity in ipairs(rarityArray) do
        if roll < (chances[rarity] + cumulativeChance) then
          chosenRarity = rarity
          break
        end
        cumulativeChance = cumulativeChance + chances[rarity]
      end
      
      if rarityTable[chosenRarity] ~= nil and rarityTable[chosenRarity][upgradeData.ItemName] then
        upgradeData.Rarity = chosenRarity
      end
		end
  end

end, ZyruIncremental)

-- TODO: override?
ModUtil.Path.Wrap("GetUpgradedRarity", function (base, baseRarity)
  local rarityTable = {
      Common = "Rare",
      Rare = "Epic",
      Epic = "Heroic",
      Heroic = "Supreme",
      Supreme = "Ultimate",
      Ultimate = "Transcendental",
      Transcendental = "Mythic",
      Mythic = "Olympic",
  }
  return rarityTable[baseRarity]
end, ZyruIncremental)

ModUtil.Path.Wrap("GetRarityValue", function (base, rarity)
	local rarityOrdering = { "Common", "Rare", "Epic", "Heroic", "Supreme", "Ultimate", "Transcendental", "Mythic", "Olympic", "Legendary" }
	return GetKey(rarityOrdering, rarity) or 1
end, ZyruIncremental)

local ignoreDamageSourceTraitMap = {
  -- Mirror
  HighHealthDamageMetaUpgrade = true,
  GodEnhancementMetaUpgrade = true,
  BackstabMetaUpgrade = true,
  StoredAmmoVulnerabilityMetaUpgrade = true,
  VulnerabilityEffectBonusMetaUpgrade = true,
  FirstStrikeMetaUpgrade = true,
  PerfectDashEmpowerApplicator = true,
  -- Aspects
  SwordBaseUpgradeTrait = true,
  SwordCriticalParryTrait = true,
  DislodgeAmmoTrait = true,
  SwordConsecrationTrait = true,
  SpearBaseUpgradeTrait = true,
  SpearTeleportTrait = true,
  SpearWeaveTrait = true,
  SpearSpinTravel = true,     
  ShieldBaseUpgradeTrait = true,
  ShieldRushBonusProjectileTrait = true,
  ShieldTwoShieldTrait = true,
  ShieldLoadAmmoTrait = true,
  BowBaseUpgradeTrait = true,
  BowMarkHomingTrait = true,
  BowLoadAmmoTrait = true,
  BowBondTrait = true,
  FistBaseUpgradeTrait = true,
  FistVacuumTrait = true,
  FistWeaveTrait = true,
  FistDetonateTrait = true,
  GunBaseUpgradeTrait = true,
  GunGrenadeSelfEmpowerTrait = true,
  GunManualReloadTrait = true,
  GunLoadedGrenadeTrait = true,
  -- Patty cyclops jerky (for now)
  TemporaryImprovedWeaponTrait_Patroclus = true,
}

-- hammers
ModUtil.Table.Merge(ignoreDamageSourceTraitMap, ToLookup(LootData.WeaponUpgrade.Traits))
-- Well items
ModUtil.Table.Merge(ignoreDamageSourceTraitMap, ToLookup(StoreData.RoomShop.Traits))
-- keepsakes
ModUtil.Table.Merge(
  ignoreDamageSourceTraitMap,
  ToLookup(
    GameData.AchievementData.AchLeveledKeepsakes.CompleteGameStateRequirements.RequiresMaxKeepsakes
  )
)

-- TODO: reinvestigate post crash-fixes
--[[
  Outline for cleaner implementation
  ModUtil.Path.Context.Env ("Damage")
    ModUtil.Path.Wrap ("CalculateDamageMultipliers")
    ModUtil.Path.Wrap ("DamageEnemy")
    ModUtil.Path.Wrap ("DamageHero")
]]--

--[[
  - Args:
    - victim
      - HealthBuffer
      - ActiveEffectsAtDamageStart.CritVulnerability
    - triggerArgs
      - EffectName
      - AttackerWeaponData
        - Name
      - SourceWeapon
      - AttackerIsObstacle
      - ProjectileDeflected
      - IsCrit

]]

--[[
  It was not determined to be possible to track down source of deflect for any
  particular projectile, so similar to crit mappings, we apply experience across all
  boons can deflect.
]]
local deflectBoons = {
  "AthenaWeaponTrait", "AthenaSecondaryTrait", "AthenaRushTrait", "AthenaRangedTrait",
  "AthenaShoutTrait", "AthenaRetaliateTrait"
}
function ZyruIncremental.ComputeDeflectExp(damageResult, boonsUsed)
  local boonsWithDeflect = 0
  local deflectBoonsUsed = {}
  -- gather all deflect sources
  for i, boon in ipairs(deflectBoons) do
    if HeroHasTrait(boon) then
      boonsWithDeflect = boonsWithDeflect + 1
      deflectBoonsUsed[boon] = damageResult.ResultingDamage
    end
  end
  
  -- reflect their use in experience map, share damage
  for boonName, exp in pairs(deflectBoonsUsed) do
      boonsUsed[boonName] = exp / boonsWithDeflect
  end
end

function ZyruIncremental.ProcessDamageEnemyValues (damageResult, args)
  local victim = args.Victim
  local armorBeforeAttack = victim.HealthBuffer or 0
  local triggerArgs = args.TriggerArgs
  -- and victim.Name ~= "TrainingMelee" while testing

  if RequiredKillEnemies[victim.ObjectId] == nil and victim.Name ~= "TrainingMelee" then
    return
  end
  if damageResult == nil then
    DebugPrint { Text = " NULL DAMAGE RESULT FOUND"}
    return
  end
  
  local sourceWeaponData = triggerArgs.AttackerWeaponData
  local weapon = nil
  local sourceName = nil
  local boonsUsed = {}

  -- ZyruIncremental.Debug = args

  if triggerArgs.EffectName ~= nil then
    local traitUsed = ZyruIncremental.EffectToBoonMap[triggerArgs.EffectName]
    if traitUsed ~= nil then
      if type(traitUsed) == "table" then
        traitUsed = traitUsed[triggerArgs[traitUsed.MapSource]]          
        -- if not defined, it's coming from a source that isn't meant to be tracked
        if traitUsed == nil then
          return
        end
      end
      boonsUsed[traitUsed] = damageResult.BaseDamage
      sourceName = triggerArgs.EffectName
      weapon = sourceName
    end
  elseif sourceWeaponData ~= nil then
    weapon = sourceWeaponData
    sourceName = weapon.Name
    -- Actual source can vary within sourceWeaponData
    if weapon.Name == "RushWeapon" then
      for k, trait in pairs(CurrentRun.Hero.Traits) do
        if trait.Slot == "Rush" then
          boonsUsed[trait.Name] = damageResult.BaseDamage
          sourceName = trait.Name
        end
      end
    elseif weapon.Name == "RangedWeapon" then
      for k, trait in pairs(CurrentRun.Hero.Traits) do
        if trait.Slot == "Ranged" then
          boonsUsed[trait.Name] = damageResult.BaseDamage
          sourceName = trait.Name
        end
      end
    elseif ZyruIncremental.WeaponToBoonMap[weapon.Name] ~= nil then
      sourceName = weapon.Name
      boonsUsed[ZyruIncremental.WeaponToBoonMap[weapon.Name]] = damageResult.BaseDamage
    end
    -- end sourceWeaponData variance check
  elseif ProjectileData[triggerArgs.SourceWeapon] ~= nil then
    weapon = ProjectileData[triggerArgs.SourceWeapon]
    local traitUsed = ZyruIncremental.ProjectileToBoonMap[weapon.Name]
    if traitUsed ~= nil then
      boonsUsed[traitUsed] = damageResult.BaseDamage
    end

    sourceName = weapon.Name
  elseif ZyruIncremental.ProjectileToBoonMap[triggerArgs.SourceWeapon] ~= nil then
    local traitUsed = ZyruIncremental.ProjectileToBoonMap[triggerArgs.SourceWeapon]
    boonsUsed[traitUsed] = damageResult.BaseDamage
    sourceName = triggerArgs.SourceWeapon
  elseif ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon] ~= nil then
    weapon = ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]
    sourceName = weapon
    boonsUsed[ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]] = damageResult.BaseDamage
  elseif triggerArgs.AttackerIsObstacle then
    if HeroHasTrait("BonusCollisionTrait") then
      boonsUsed["BonusCollisionTrait"] = damageResult.BaseDamage
    end
  end

  if triggerArgs.ProjectileDeflected then
    ZyruIncremental.ComputeDeflectExp(damageResult, boonsUsed)
  end
  
  -- { Base Damage: int, Multipliers: {}, ResultingDamage}
  for name, multiplier in pairs(damageResult.Multipliers) do
    local damageProportion = damageResult.BaseDamage * (multiplier - 1)
    local trait = HeroHasTrait(name) and name or ZyruIncremental.DamageModifiersToBoonMap[name]
    if trait ~= nil then
      boonsUsed[trait] = (boonsUsed[trait] or 0) + damageProportion
    end
  end
  -- some boons have strict engine properties, not detectable lua changes:
  -- hydraulic might, blood frenzy
  if HeroHasTrait("LastStandDamageBonusTrait") then end
  if HeroHasTrait("LastStandDamageBonusTrait") then end

  -- -- START DEBUG
  -- ZyruIncremental.Weapon = weapon
  -- ZyruIncremental.BoonsUsed = boonsUsed
  -- END DEBUG

  if triggerArgs.IsCrit then
    local critChanceTotal = 0
    local critDamageTotal = 0
    local critChanceMap = {}
    local critDamageMap = {}

    -- get base crit info from weapon and map it
    local critWeapon = GetEquippedWeapon()
    local weaponCritChance = GetProjectileProperty{ Id = CurrentRun.Hero.ObjectId, WeaponName = critWeapon, Property = "CriticalHitChance" }
    local weaponCritDamage = GetProjectileProperty{ Id = CurrentRun.Hero.ObjectId, WeaponName = critWeapon, Property = "CriticalHitMultiplier" }
    critChanceTotal = critChanceTotal + weaponCritChance
    critDamageTotal = weaponCritDamage + weaponCritDamage

    -- OnEffectApply version???
    if victim.ActiveEffectsAtDamageStart ~= nil and victim.ActiveEffectsAtDamageStart.CritVulnerability then
      -- TODO: I cannot fucking find this goddamn value in engine calls so it's just going to get the base EXP always
      critChanceMap["CritVulnerabilityTrait"] = 0.30
      critChanceTotal = critChanceTotal + 0.30
      --[[
        GetEffectDataValue{ Id = 420928, EffectName = "CritVulnerability", Property = "CritVulnerabilityAddition", WeaponName = "CritVulnerabilityWeapon" }
      ]]
    end
    if HeroHasTrait("CritBonusTrait") then
      -- Pressure Points Critical Chace
      local critChance = GetUnitDataValue { Id = CurrentRun.Hero.ObjectId, Property = "CritAddition" }
      critChanceMap["CritBonusTrait"] = critChance
      critChanceTotal = critChanceTotal + critChance
    end
    -- Has Deadly Reversal AND its active
    -- TODO: GetEffectTimeRemaining
    -- if HeroHasTrait("ArtemisReflectBuffTrait") and GetEffectTimeRemaining{ WeaponName = "ArtemisReflectBuff", EffectName = "ReflectCritChance", Property = "Duration" } then
    if HeroHasTrait("ArtemisReflectBuffTrait") and GetEffectDataValue{ WeaponName = "ArtemisReflectBuff", EffectName = "ReflectCritChance", Property = "Duration" } then
      local critChance = GetEffectDataValue{ WeaponName = "ArtemisReflectBuff", EffectName = "ReflectCritChance", Property = "CritAddition" } or 0
      critChanceMap["ArtemisReflectBuffTrait"] = critChance
      critChanceTotal = critChanceTotal + critChance
    end

    -- CleanKill
    if HeroHasTrait("ArtemisCriticalTrait") then
      local critDamage = GetUnitDataValue{ Id = 40000, WeaponName = GetEquippedWeapon(), Property = "CritMultiplierAddition" } or 0
      critDamageMap["ArtemisCriticalTrait"] = critDamage
      critDamageTotal = critDamageTotal + critDamage
    end
    -- Hide Breaker
    if armorBeforeAttack > 0 and HeroHasTrait("CriticalBufferMultiplierTrait") then
      local critDamage = GetTotalHeroTraitValue("CriticalHealthBufferMultiplier") - 1 -- SourceIsMultiplier shenanigans
      critDamageMap["CriticalBufferMultiplierTrait"] = critDamage
      critDamageTotal = critDamageTotal + critDamage
    end
    -- HeartRend? --later

    for key, val in pairs(critDamageMap) do
      boonsUsed[key] = val / critDamageTotal * damageResult.ResultingDamage
    end
    for key, val in pairs(critChanceMap) do
      boonsUsed[key] = val / critChanceTotal * damageResult.ResultingDamage
    end


  end



  -- Do this instead of intercepting engine trait changes, last resort :(
  if ZyruIncremental.HailMaryMap[sourceName] ~= nil then
    for k, trait in pairs(ZyruIncremental.HailMaryMap[sourceName]) do
      if HeroHasTrait(trait) then
        boonsUsed[trait] = damageResult.BaseDamage
      end
    end
  end

  -- Apply all boons tracked in this damage source computation
  for k,v in pairs(boonsUsed) do
    ZyruIncremental.TrackBoonEffect(k, v, victim)
  end
end

function ZyruIncremental.ProcessDamageHeroValues (damageResult, victim, args)
  local boonsUsed = {}
  if damageResult == nil or damageResult.BaseDamage == nil then
    -- PureDamage?
    -- DebugPrint { Text = "BaseDamage to Zag nil: " .. ModUtil.ToString.Shallow(args)}
    return
  end
  local endRatio = (damageResult.BaseDamage  - damageResult.ResultingDamage) / damageResult.BaseDamage

  for name, multiplier in pairs(damageResult.Multipliers) do
    local multiplierContribution = math.log(multiplier) / math.log(1 - endRatio)
    local boonExpProportion = damageResult.BaseDamage * multiplierContribution
    local trait = HeroHasTrait(name) and name or ZyruIncremental.DamageModifiersToBoonMap[name]
    if trait ~= nil then
      boonsUsed[trait] = (boonsUsed[trait] or 0) + boonExpProportion
    end
  end

  for k,v in pairs(boonsUsed) do
    ZyruIncremental.TrackBoonEffect(k, v, victim)
  end
end

ModUtil.Path.Context.Wrap("Damage", function ()

  local damageMultiplierMap = {}
  local damageResult = {}

  -- From Scripts/Combat.lua line
  ModUtil.Path.Override("CalculateDamageMultipliers", function (attacker, victim, weaponData, triggerArgs)
      local damageReductionMultipliers = 1
      local damageMultipliers = 1.0
      local lastAddedMultiplierName = ""

      -- CHANGES
      local baseDamage = triggerArgs.DamageAmount
      local enemyDamageSources = {}
      -- END CHANGES
    
      if ConfigOptionCache.LogCombatMultipliers then
        DebugPrint({Text = " SourceWeapon : " .. tostring( triggerArgs.SourceWeapon )})
      end

      local addDamageMultiplier = function( data, multiplier )
        -- CHANGES
        -- DebugPrint { Text = tostring(data.Name) .. " " .. tostring(multiplier) }
        if ignoreDamageSourceTraitMap[data.Name] == nil then
          if data ~= nil and data.Name ~= nil and multiplier ~= nil then
            damageMultiplierMap[data.Name] = (damageMultiplierMap[data.Name] or 1) + multiplier - 1
          end
        end
        -- END CHANGES
        if multiplier >= 1.0 then
          if data.Multiplicative then
            damageReductionMultipliers = damageReductionMultipliers * multiplier
          else
            damageMultipliers = damageMultipliers + multiplier - 1
          end
          if ConfigOptionCache.LogCombatMultipliers then
            lastAddedMultiplierName = data.Name or "Unknown"
            DebugPrint({Text = " Additive Damage Multiplier (" .. lastAddedMultiplierName .. "):" .. multiplier })
          end
        else
          if data.Additive then
            damageMultipliers = damageMultipliers + multiplier - 1
          else
            damageReductionMultipliers = damageReductionMultipliers * multiplier
          end
          if ConfigOptionCache.LogCombatMultipliers then
            lastAddedMultiplierName = data.Name or "Unknown"
            DebugPrint({Text = " Multiplicative Damage Reduction (" .. lastAddedMultiplierName .. "):" .. multiplier })
          end
        end
      end
    
      if triggerArgs.ProjectileAdditiveDamageMultiplier then
        damageMultipliers = damageMultipliers + triggerArgs.ProjectileAdditiveDamageMultiplier
      end
    
      if victim.IncomingDamageModifiers ~= nil then
        for i, modifierData in pairs(victim.IncomingDamageModifiers) do
          if modifierData.GlobalMultiplier ~= nil then
            addDamageMultiplier( modifierData, modifierData.GlobalMultiplier)
          end
          
          local validWeapon = modifierData.ValidWeaponsLookup == nil or ( modifierData.ValidWeaponsLookup[ triggerArgs.SourceWeapon ] ~= nil and triggerArgs.EffectName == nil )
    
          if validWeapon and ( not triggerArgs.AttackerIsObstacle and ( attacker and attacker.DamageType ~= "Neutral" ) or modifierData.IncludeObstacleDamage or modifierData.TrapDamageTakenMultiplier ) then
            if modifierData.ZeroRangedWeaponAmmoMultiplier and RunWeaponMethod({ Id = victim.ObjectId, Weapon = "RangedWeapon", Method = "GetAmmo" }) == 0 then
              addDamageMultiplier( modifierData, modifierData.ZeroRangedWeaponAmmoMultiplier)
            end
            if modifierData.ValidWeaponMultiplier then
              addDamageMultiplier( modifierData, modifierData.ValidWeaponMultiplier)
            end
            if modifierData.ProjectileDeflectedMultiplier and triggerArgs.ProjectileDeflected then
              addDamageMultiplier( modifierData, modifierData.ProjectileDeflectedMultiplier)
            end
    
            if modifierData.BossDamageMultiplier and attacker and ( attacker.IsBoss or attacker.IsBossDamage ) then
              addDamageMultiplier( modifierData, modifierData.BossDamageMultiplier)
            end
            if modifierData.LowHealthDamageTakenMultiplier ~= nil and (victim.Health / victim.MaxHealth) <= modifierData.LowHealthThreshold then
              addDamageMultiplier( modifierData, modifierData.LowHealthDamageTakenMultiplier)
            end
            if modifierData.TrapDamageTakenMultiplier ~= nil and (( attacker ~= nil and attacker.DamageType == "Neutral" ) or (attacker == nil and triggerArgs.AttackerName ~= nil and EnemyData[triggerArgs.AttackerName] ~= nil and EnemyData[triggerArgs.AttackerName].DamageType == "Neutral" )) then
              addDamageMultiplier( modifierData, modifierData.TrapDamageTakenMultiplier)
            end
            if modifierData.DistanceMultiplier and triggerArgs.DistanceSquared ~= nil and triggerArgs.DistanceSquared ~= -1 and ( modifierData.DistanceThreshold * modifierData.DistanceThreshold ) <= triggerArgs.DistanceSquared then
              addDamageMultiplier( modifierData, modifierData.DistanceMultiplier)
            end
            if modifierData.ProximityMultiplier and triggerArgs.DistanceSquared ~= nil and triggerArgs.DistanceSquared ~= -1 and ( modifierData.ProximityThreshold * modifierData.ProximityThreshold ) >= triggerArgs.DistanceSquared then
              addDamageMultiplier( modifierData, modifierData.ProximityMultiplier)
            end
            if modifierData.NonTrapDamageTakenMultiplier ~= nil and (( attacker ~= nil and attacker.DamageType ~= "Neutral" ) or (attacker == nil and triggerArgs.AttackerName ~= nil and EnemyData[triggerArgs.AttackerName] ~= nil and EnemyData[triggerArgs.AttackerName].DamageType ~= "Neutral" )) then
              addDamageMultiplier( modifierData, modifierData.NonTrapDamageTakenMultiplier)
            end
            if modifierData.HitVulnerabilityMultiplier and triggerArgs.HitVulnerability then
              addDamageMultiplier( modifierData, modifierData.HitVulnerabilityMultiplier )
            end
            if modifierData.HitArmorMultiplier and triggerArgs.HitArmor then
              addDamageMultiplier( modifierData, modifierData.HitArmorMultiplier )
            end
            if modifierData.NonPlayerMultiplier and attacker ~= CurrentRun.Hero and attacker ~= nil and not HeroData.DefaultHero.HeroAlliedUnits[attacker.Name] then
              addDamageMultiplier( modifierData, modifierData.NonPlayerMultiplier)
            end
            if modifierData.SelfMultiplier and attacker == victim then
              addDamageMultiplier( modifierData, modifierData.SelfMultiplier)
            end
            if modifierData.PlayerMultiplier and attacker == CurrentRun.Hero then
              addDamageMultiplier( modifierData, modifierData.PlayerMultiplier )
            end
          end
        end
      end
    
      if attacker ~= nil and attacker.OutgoingDamageModifiers ~= nil and ( not weaponData or not weaponData.IgnoreOutgoingDamageModifiers ) then
        local appliedEffectTable = {}
        for i, modifierData in pairs(attacker.OutgoingDamageModifiers) do
          if modifierData.GlobalMultiplier ~= nil then
            addDamageMultiplier( modifierData, modifierData.GlobalMultiplier)
          end
    
          local validEffect = modifierData.ValidEffects == nil or ( triggerArgs.EffectName ~= nil and Contains(modifierData.ValidEffects, triggerArgs.EffectName ))
          local validWeapon = modifierData.ValidWeaponsLookup == nil or ( modifierData.ValidWeaponsLookup[ triggerArgs.SourceWeapon ] ~= nil and triggerArgs.EffectName == nil )
          local validTrait = modifierData.RequiredTrait == nil or ( attacker == CurrentRun.Hero and HeroHasTrait( modifierData.RequiredTrait ) )
          local validUniqueness = modifierData.Unique == nil or not modifierData.Name or not appliedEffectTable[modifierData.Name]
          local validEnchantment = true
          if modifierData.ValidEnchantments and attacker == CurrentRun.Hero then
            validEnchantment = false
            if modifierData.ValidEnchantments.TraitDependentWeapons then
              for traitName, validWeapons in pairs( modifierData.ValidEnchantments.TraitDependentWeapons ) do
                if Contains( validWeapons, triggerArgs.SourceWeapon) and HeroHasTrait( traitName ) then
                  validEnchantment = true
                  break
                end
              end
            end
    
            if not validEnchantment and modifierData.ValidEnchantments.ValidWeapons and Contains( modifierData.ValidEnchantments.ValidWeapons, triggerArgs.SourceWeapon ) then
              validEnchantment = true
            end
          end
    
          if validUniqueness and validWeapon and validEffect and validTrait and validEnchantment then
            if modifierData.Name then
              appliedEffectTable[ modifierData.Name] = true
            end
            if modifierData.HighHealthSourceMultiplierData and attacker.Health / attacker.MaxHealth > modifierData.HighHealthSourceMultiplierData.Threshold then
              addDamageMultiplier( modifierData, modifierData.HighHealthSourceMultiplierData.Multiplier )
            end
            if modifierData.PerUniqueGodMultiplier and attacker == CurrentRun.Hero then
              addDamageMultiplier( modifierData, 1 + ( modifierData.PerUniqueGodMultiplier - 1 ) * GetHeroUniqueGodCount( attacker ))
            end
            if modifierData.BossDamageMultiplier and victim.IsBoss then
              addDamageMultiplier( modifierData, modifierData.BossDamageMultiplier)
            end
            if modifierData.ZeroRangedWeaponAmmoMultiplier and RunWeaponMethod({ Id = attacker.ObjectId, Weapon = "RangedWeapon", Method = "GetAmmo" }) == 0 then
              addDamageMultiplier( modifierData, modifierData.ZeroRangedWeaponAmmoMultiplier)
            end
            if modifierData.EffectThresholdDamageMultiplier and triggerArgs.MeetsEffectDamageMultiplier then
              addDamageMultiplier( modifierData, modifierData.EffectThresholdDamageMultiplier)
            end
            if modifierData.PerfectChargeMultiplier and triggerArgs.IsPerfectCharge then
              addDamageMultiplier( modifierData, modifierData.PerfectChargeMultiplier)
            end
    
            if modifierData.UseTraitValue and attacker == CurrentRun.Hero then
              addDamageMultiplier( modifierData, GetTotalHeroTraitValue( modifierData.UseTraitValue, { IsMultiplier = modifierData.IsMultiplier }))
            end
            if modifierData.HitVulnerabilityMultiplier and triggerArgs.HitVulnerability then
              addDamageMultiplier( modifierData, modifierData.HitVulnerabilityMultiplier )
            end
            if modifierData.HitMaxHealthMultiplier and victim.Health == victim.MaxHealth and (victim.MaxHealthBuffer == nil or victim.HealthBuffer == victim.MaxHealthBuffer ) then
              addDamageMultiplier( modifierData, modifierData.HitMaxHealthMultiplier )
            end
            if modifierData.MinRequiredVulnerabilityEffects and victim.VulnerabilityEffects and TableLength( victim.VulnerabilityEffects ) >= modifierData.MinRequiredVulnerabilityEffects then
              --DebugPrint({Text = " min required vulnerability " .. modifierData.PerVulnerabilityEffectAboveMinMultiplier})
              addDamageMultiplier( modifierData, modifierData.PerVulnerabilityEffectAboveMinMultiplier)
            end
            if modifierData.HealthBufferDamageMultiplier and victim.HealthBuffer ~= nil and victim.HealthBuffer > 0 then
              addDamageMultiplier( modifierData, modifierData.HealthBufferDamageMultiplier)
            end
            if modifierData.StoredAmmoMultiplier and victim.StoredAmmo ~= nil and not IsEmpty( victim.StoredAmmo ) then
              local hasExternalStoredAmmo = false
              for i, storedAmmo in pairs(victim.StoredAmmo) do
                if storedAmmo.WeaponName ~= "SelfLoadAmmoApplicator" then
                  hasExternalStoredAmmo = true
                end
              end
              if hasExternalStoredAmmo then
                addDamageMultiplier( modifierData, modifierData.StoredAmmoMultiplier)
              end
            end
            if modifierData.UnstoredAmmoMultiplier and IsEmpty( victim.StoredAmmo ) then
              addDamageMultiplier( modifierData, modifierData.UnstoredAmmoMultiplier)
            end
            if modifierData.ValidWeaponMultiplier then
              addDamageMultiplier( modifierData, modifierData.ValidWeaponMultiplier)
            end
            if modifierData.RequiredSelfEffectsMultiplier and not IsEmpty(attacker.ActiveEffects) then
              local hasAllEffects = true
              for _, effectName in pairs( modifierData.RequiredEffects ) do
                if not attacker.ActiveEffects[ effectName ] then
                  hasAllEffects = false
                end
              end
              if hasAllEffects then
                addDamageMultiplier( modifierData, modifierData.RequiredSelfEffectsMultiplier)
              end
            end
    
            if modifierData.RequiredEffectsMultiplier and victim and not IsEmpty(victim.ActiveEffects) then
              local hasAllEffects = true
              for _, effectName in pairs( modifierData.RequiredEffects ) do
                if not victim.ActiveEffects[ effectName ] then
                  hasAllEffects = false
                end
              end
              if hasAllEffects then
                addDamageMultiplier( modifierData, modifierData.RequiredEffectsMultiplier)
              end
            end
            if modifierData.DistanceMultiplier and triggerArgs.DistanceSquared ~= nil and triggerArgs.DistanceSquared ~= -1 and ( modifierData.DistanceThreshold * modifierData.DistanceThreshold ) <= triggerArgs.DistanceSquared then
              addDamageMultiplier( modifierData, modifierData.DistanceMultiplier)
            end
            if modifierData.ProximityMultiplier and triggerArgs.DistanceSquared ~= nil and triggerArgs.DistanceSquared ~= -1 and ( modifierData.ProximityThreshold * modifierData.ProximityThreshold ) >= triggerArgs.DistanceSquared then
              addDamageMultiplier( modifierData, modifierData.ProximityMultiplier)
            end
            if modifierData.LowHealthDamageOutputMultiplier ~= nil and attacker.Health ~= nil and (attacker.Health / attacker.MaxHealth) <= modifierData.LowHealthThreshold then
              addDamageMultiplier( modifierData, modifierData.LowHealthDamageOutputMultiplier)
            end
            if modifierData.TargetHighHealthDamageOutputMultiplier ~= nil and (victim.Health / victim.MaxHealth) < modifierData.TargetHighHealthThreshold then
              addDamageMultiplier( modifierData, modifierData.TargetHighHealthDamageOutputMultiplier)
            end
            if modifierData.FriendMultiplier and ( victim == attacker or ( attacker.Charmed and victim == CurrentRun.Hero ) or ( not attacker.Charmed and victim ~= CurrentRun.Hero and not HeroData.DefaultHero.HeroAlliedUnits[victim.Name] )) then
              addDamageMultiplier( modifierData, modifierData.FriendMultiplier )
            end
            if modifierData.PlayerMultiplier and victim == CurrentRun.Hero then
              addDamageMultiplier( modifierData, modifierData.PlayerMultiplier )
            end
            if modifierData.NonPlayerMultiplier and victim ~= CurrentRun.Hero and not HeroData.DefaultHero.HeroAlliedUnits[victim.Name] then
              addDamageMultiplier( modifierData, modifierData.NonPlayerMultiplier )
            end
            if modifierData.FinalShotMultiplier and CurrentRun.CurrentRoom.ZeroAmmoVolley and CurrentRun.CurrentRoom.ZeroAmmoVolley[ triggerArgs.ProjectileVolley ] then
              addDamageMultiplier( modifierData, modifierData.FinalShotMultiplier)
            end
            if modifierData.LoadedAmmoMultiplier and CurrentRun.CurrentRoom.LoadedAmmo and CurrentRun.CurrentRoom.LoadedAmmo > 0 then
              addDamageMultiplier( modifierData, modifierData.LoadedAmmoMultiplier)
            end
            if modifierData.SpeedDamageMultiplier then
              local baseSpeed = GetBaseDataValue({ Type = "Unit", Name = "_PlayerUnit", Property = "Speed" })
              local speedModifier = CurrentRun.CurrentRoom.SpeedModifier or 1
              local currentSpeed = GetUnitDataValue({ Id = CurrentRun.Hero.ObjectId, Property = "Speed" }) * speedModifier
              if currentSpeed > baseSpeed then
                addDamageMultiplier( modifierData, 1 + modifierData.SpeedDamageMultiplier * ( currentSpeed/baseSpeed - 1 ))
              end
            end
    
            if modifierData.ActiveDashWeaponMultiplier and triggerArgs.BlinkWeaponActive then
              addDamageMultiplier( modifierData, modifierData.ActiveDashWeaponMultiplier )
            end
    
            if modifierData.EmptySlotMultiplier and modifierData.EmptySlotValidData then
              local filledSlots = {}
    
              for i, traitData in pairs( attacker.Traits ) do
                if traitData.Slot then
                  filledSlots[traitData.Slot] = true
                end
              end
    
              for key, weaponList in pairs( modifierData.EmptySlotValidData ) do
                if not filledSlots[key] and Contains( weaponList, triggerArgs.SourceWeapon ) then
                  addDamageMultiplier( modifierData, modifierData.EmptySlotMultiplier )
                end
              end
            end
          end
        end
      end
    
      if weaponData ~= nil then
        if attacker == victim and weaponData.SelfMultiplier then
          addDamageMultiplier( { Name = weaponData.Name, Multiplicative = true }, weaponData.SelfMultiplier)
        end
    
        if weaponData.OutgoingDamageModifiers ~= nil and not weaponData.IgnoreOutgoingDamageModifiers then
          for i, modifierData in pairs(weaponData.OutgoingDamageModifiers) do
            if modifierData.NonPlayerMultiplier and victim ~= CurrentRun.Hero and not HeroData.DefaultHero.HeroAlliedUnits[victim.Name] then
              addDamageMultiplier( modifierData, modifierData.NonPlayerMultiplier)
            end
            if modifierData.PlayerMultiplier and ( victim == CurrentRun.Hero or HeroData.DefaultHero.HeroAlliedUnits[victim.Name] ) then
              addDamageMultiplier( modifierData, modifierData.PlayerMultiplier)
            end
            if modifierData.PlayerSummonMultiplier and HeroData.DefaultHero.HeroAlliedUnits[victim.Name] then
              addDamageMultiplier( modifierData, modifierData.PlayerSummonMultiplier)
            end
          end
        end
      end
    
      if ConfigOptionCache.LogCombatMultipliers and triggerArgs and triggerArgs.AttackerName and triggerArgs.DamageAmount then
        DebugPrint({Text = triggerArgs.AttackerName .. ": Base Damage : " .. triggerArgs.DamageAmount .. " Damage Bonus: " .. damageMultipliers .. ", Damage Reduction: " .. damageReductionMultipliers })
      end

      damageResult.BaseDamage = baseDamage
      damageResult.Multipliers = damageMultiplierMap
      damageResult.ResultingDamage = baseDamage * damageMultipliers * damageReductionMultipliers

      return damageMultipliers * damageReductionMultipliers
  end, ZyruIncremental)
  
  ModUtil.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
    local armorBeforeAttack = victim.HealthBuffer or 0
    local res = baseFunc( victim, triggerArgs )
    triggerArgs = triggerArgs or {}

    -- go away, than
    local attackerIsHero = triggerArgs.AttackerId == CurrentRun.Hero.ObjectId
    local selfDeflectDamage =  triggerArgs.ProjectileDeflected
    if not attackerIsHero and not selfDeflectDamage then
      return res
    end


    local args = {
      Victim = victim,
      TriggerArgs = {
        EffectName = triggerArgs.EffectName,
        -- NOTE: AttackerWeaponData must be defined if and only if it's on the args otherwise
        --       multiple boons' tracking fails
        AttackerWeaponData = triggerArgs.AttackerWeaponData and {
          Name = triggerArgs.AttackerWeaponData and triggerArgs.AttackerWeaponData.Name or nil
        } or nil,
        SourceWeapon = triggerArgs.SourceWeapon,
        AttackerIsObstacle = triggerArgs.AttackerIsObstacle,
        ProjectileDeflected = triggerArgs.ProjectileDeflected,
        IsCrit = triggerArgs.IsCrit,
      }
    }

    thread( ZyruIncremental.ProcessDamageEnemyValues, damageResult, args)

    return res
  
  end, ZyruIncremental)
  
  ModUtil.Path.Wrap("DamageHero", function(baseFunc, victim, args) 
    baseFunc(victim, args)
    thread ( ZyruIncremental.ProcessDamageHeroValues, damageResult, victim, args)
  end, ZyruIncremental)

end, ZyruIncremental)

function ZyruIncremental.CheckBoonDataLevelUp(traitName)
  local saveTraitData = ZyruIncremental.Data.BoonData[traitName]

  -- check for level-ups
  if ZyruIncremental.GetExperienceForNextBoonLevel(saveTraitData.Level) < saveTraitData.Experience then
    saveTraitData.Level = saveTraitData.Level + 1
    DebugPrint { Text = traitName .. " has reached level " .. tostring(saveTraitData.Level)}
    -- Add God Experience Levels
    AddGodExperience(ZyruIncremental.BoonToGod[traitName], saveTraitData.Level - 1)
    -- Add handle level-up message behavior
    local god = ZyruIncremental.BoonToGod[traitName] or TraitData[traitName].God
    thread(ZyruIncremental.HandleBoonLevelupBehavior, traitName, saveTraitData.Level, god)
  end
end

function ZyruIncremental.TrackBoonEffect ( traitName, damageValue, victim )
  if ZyruIncremental.Data == nil or traitName == nil then
    return
  end

  if type(traitName) == "table" then
    DebugPrint { Text = "table found as boon: " .. ModUtil.ToString.Shallow(traitName)}
    return
  end

  if ZyruIncremental.BoonsToIgnore[traitName] then
    DebugPrint { Text = "Found ignored trait " .. traitName }
    return
  end

  -- track save-file data
  if ZyruIncremental.Data.BoonData[traitName] == nil then
    ZyruIncremental.Data.BoonData[traitName] = {
      Count = 0,
      Value = 0,
      Experience = 0,
      Level = 1
    }
  end
  local saveTraitData = ZyruIncremental.Data.BoonData[traitName]

  -- track current run data
  CurrentRun.ZyruBoonData = CurrentRun.ZyruBoonData or {}
  if CurrentRun.ZyruBoonData[traitName] == nil then
    CurrentRun.ZyruBoonData[traitName] = {
      Count = 0,
      Value = 0,
      Experience = 0,
      Level =  saveTraitData.Level -- starting level
    }
  end
  local currentRunData = CurrentRun.ZyruBoonData[traitName]


  -- assign use count, damage, experience
  local expGained = 0
  if type(damageValue) == "number" then
    saveTraitData.Value = saveTraitData.Value + damageValue
    currentRunData.Value = currentRunData.Value + damageValue
    if (ZyruIncremental.BoonExperienceFactor[traitName] == nil) then
      DebugPrint { Text = traitName .. " not found in BoonExperienceFactor map"}
    end
    expGained = expGained + (ZyruIncremental.BoonExperienceFactor[traitName] or 1) * damageValue
  end

  saveTraitData.Count = saveTraitData.Count + 1
  currentRunData.Count = currentRunData.Count + 1
  expGained = expGained + (ZyruIncremental.BoonExperiencePerUse[traitName] or 0)

  local expFactor = ZyruIncremental.GetExperienceFactor(traitName, damageValue, victim)

  expGained = expGained * expFactor

  if expGained > 0  then
    saveTraitData.Experience = saveTraitData.Experience + expGained
    currentRunData.Experience = currentRunData.Experience + expGained
    ZyruIncremental.HandleExperiencePresentationBehavior(traitName, ZyruIncremental.BoonToGod[traitName], expGained, victim)
    thread(ZyruIncremental.CheckBoonDataLevelUp, traitName)
  end

end

function ZyruIncremental.IsExperienceEligible(traitName, contribution, victim)
  -- check for active encounter
  local encounter = ModUtil.Path.Get("CurrentRun.CurrentRoom.Encounter")
    or ModUtil.Path.Get("CurrentRun.CurrentRoom.ChallengeEncounter")

  if not IsCombatEncounterActive ( CurrentRun ) and not ZyruIncremental.BoonGrantExperienceOutCombat[traitName] then
    return false
  end
  return true
end

function ZyruIncremental.GetExperienceFactor(traitName, damageValue, victim)
  if not ZyruIncremental.IsExperienceEligible(traitName, damageValue, victim) then
    return 0
  end

  local multiplier = 1
  
  local encounter = ModUtil.Path.Get("CurrentRun.CurrentRoom.Encounter")
    or ModUtil.Path.Get("CurrentRun.CurrentRoom.ChallengeEncounter")

  -- shrink multiplier by kill amount in survival rooms
  if encounter.EncounterType == "SurvivalChallenge" then
    local currentRoom = CurrentRun.CurrentRoom
    -- TODO: figure out correct caching of this
    if currentRoom.ZyruExpMult ~= nil then
      multiplier = multiplier * math.max(0, 1 - 0.01 * currentKillCount)
    else
      local currentKillMap = currentRoom.Kills
      local currentKillCount = 0
      for name, count in pairs(currentKillMap) do
        currentKillCount = currentKillCount + count
      end
      multiplier = multiplier * math.max(0, 1 - 0.01 * currentKillCount)
    end
  end

  return multiplier
end

-------------------------------------------------------------------------------
------------------------------- ZEUS ------------------------------------------
-------------------------------------------------------------------------------


-- START CLOUDED JUDGEMENT, BOILING POINT DETECTION
ModUtil.Path.Context.Wrap("CalculateSuperGain", function()
  ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
    local res = baseFunc(traitName, args)
    if ZyruIncremental.SuperTraitMap[traitName] ~= nil then
      if res > 1 then
        DebugPrint { Text = "trying to track CalculateSuperGain for " .. traitName .. " " .. tostring(res)}
        ZyruIncremental.TrackBoonEffect(ZyruIncremental.SuperTraitMap[traitName])
      end
    end
    return res
  end, ZyruIncremental)
end, ZyruIncremental)
-- END CLOUDED JUDGEMENT, BOILING POINT DETECTION

ModUtil.Path.Wrap("CalculateSuperGain", function (base, triggerArgs, sourceWeaponData, victim)
	local damageAmount = triggerArgs.DamageAmount
  local meterAmount = 0
	if victim == CurrentRun.Hero then
		meterAmount = ( damageAmount / victim.MaxHealth ) * CurrentRun.Hero.Super.DamageTakenMultiplier
    local cloudedJudgementMult = GetTotalHeroTraitValue("SuperGainMultiplier", { IsMultiplier = true }) - 1
    local boilingPointMult = GetTotalHeroTraitValue("DefensiveSuperGainMultiplier", { IsMultiplier = true }) - 1
    local mult = 1 + cloudedJudgementMult + boilingPointMult
    if cloudedJudgementMult > 0 then
      ZyruIncremental.TrackBoonEffect("SuperGenerationTrait", cloudedJudgementMult * meterAmount)
    end
    if boilingPointMult > 0 then
      ZyruIncremental.TrackBoonEffect("DefensiveSuperGenerationTrait", boilingPointMult * meterAmount)
    end
		meterAmount = meterAmount * mult
	else
		local stepdownCutoff = 60
		if damageAmount > stepdownCutoff then
			damageAmount = stepdownCutoff + math.sqrt(damageAmount - stepdownCutoff)
		end

		meterAmount = damageAmount * CurrentRun.Hero.Super.DamageDealtMultiplier
		meterAmount = meterAmount * MetaUpgradeData.LimitMetaUpgrade.ChangeValue * (1 + GetNumMetaUpgrades("LimitMetaUpgrade"))
    local cloudedJudgementMult = GetTotalHeroTraitValue("SuperGainMultiplier", { IsMultiplier = true }) - 1
    local mult = 1 + cloudedJudgementMult
		meterAmount = meterAmount * cloudedJudgementMult
    
		if victim.MeterMultiplier then
			meterAmount = meterAmount * victim.MeterMultiplier
		end
    DebugPrint { Text = tostring(cloudedJudgementMult) .. " " .. tostring(cloudedJudgementMult * meterAmount) }
    if cloudedJudgementMult > 0 then
      ZyruIncremental.TrackBoonEffect("SuperGenerationTrait", 100 * cloudedJudgementMult * meterAmount)
    end
	end
  return base(triggerArgs, sourceWeaponData, victim)
end, ZyruIncremental)
--[[
  
	local damageAmount = triggerArgs.DamageAmount
	if triggerArgs.PureDamage then
		return 0
	end
	if victim ~= nil and victim.BlockWrathGain then
		return 0
	end
	if sourceWeaponData ~= nil and sourceWeaponData.BlockWrathGain then
		return 0
	end
	local meterAmount = 0
	if victim == CurrentRun.Hero then
		meterAmount = ( damageAmount / victim.MaxHealth ) * CurrentRun.Hero.Super.DamageTakenMultiplier
		meterAmount = meterAmount * (1 + GetTotalHeroTraitValue("SuperGainMultiplier", { IsMultiplier = true }) - 1 + GetTotalHeroTraitValue("DefensiveSuperGainMultiplier", { IsMultiplier = true }) - 1)
	else
		local stepdownCutoff = 60
		if damageAmount > stepdownCutoff then
			damageAmount = stepdownCutoff + math.sqrt(damageAmount - stepdownCutoff)
		end

		meterAmount = damageAmount * CurrentRun.Hero.Super.DamageDealtMultiplier
		meterAmount = meterAmount * MetaUpgradeData.LimitMetaUpgrade.ChangeValue * (1 + GetNumMetaUpgrades("LimitMetaUpgrade"))
		meterAmount = meterAmount * GetTotalHeroTraitValue("SuperGainMultiplier", { IsMultiplier = true })
		if victim.MeterMultiplier then
			thread( MarkObjectiveComplete, "BuildSuper" )
			meterAmount = meterAmount * victim.MeterMultiplier
		end
	end
	BuildSuperMeter( CurrentRun, meterAmount )
]]

-- SECOND WIND DETECTION
ModUtil.Path.Context.Wrap("CommenceSuperMove", function()
  ModUtil.Path.Wrap("GetHeroTraitValues", function (baseFunc, ...)
    local res = baseFunc(...)
    for key, trait in pairs(res) do
      if ZyruIncremental.SuperTraitMap[trait[1]] ~= nil then
        ZyruIncremental.TrackBoonEffect(ZyruIncremental.SuperTraitMap[trait[1]])
      end
    end
    return res
  end, ZyruIncremental)
end, ZyruIncremental)
-- END SECOND WIND DETECTION

-- DOUBLE STRIKE
  ModUtil.Path.Wrap("FireWeaponWithinRange", function(baseFunc, args)
    args.BonusChance = args.BonusChance or 0
    args.Count = args.Count or 1
    -- NOTE: this is an extra RNG increment. Do I care? idk yet.
    if RandomChance( args.BonusChance ) then
      ZyruIncremental.TrackBoonEffect("ZeusBonusBoltTrait")
      args.Count = args.Count + 1
    end
    args.BonusChance = 0
    baseFunc(args)
  end, ZyruIncremental)
-- END DOUBLE STRIKE


-------------------------------------------------------------------------------
------------------------------- DIONYSUS --------------------------------------
-------------------------------------------------------------------------------
-- LowHealthDefenseTrait (Positive Outlook)

-- DionysusMaxHealthTrait (Premium Vintage)
ModUtil.Path.Wrap("AddMaxHealth", function (baseFunc, amount, source)
  baseFunc(amount, source)
  if source == "DionysusMaxHealthTrait" then
    ZyruIncremental.TrackBoonEffect(source, amount)
  end
end, ZyruIncremental)

-------------------------------------------------------------------------------
------------------------------- APHRODITE -------------------------------------
-------------------------------------------------------------------------------

-- Life Affirmation
ModUtil.Path.Context.Wrap("ApplyConsumableItemResourceMultiplier", function ()
  ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
    "HealthRewardBonus",
    function (value) return value > 1 end,
    true
  )
end, ZyruIncremental)

-------------------------------------------------------------------------------
------------------------------- ATHENA ----------------------------------------
-------------------------------------------------------------------------------
-- Proud Bearing (annd well items???)
ModUtil.Path.Context.Wrap("StartEncounterEffects", function ()
  ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
    "StartingSuperAmount",
    function (value) return value > 0 end
  )
end, ZyruIncremental)

-- Athena Aid
ModUtil.Path.Wrap("AthenaShout", function (baseFunc)
  ZyruIncremental.TrackBoonEffect("AthenaShoutTrait")
  return baseFunc()
end, ZyruIncremental)

ModUtil.Path.Wrap("CheckLastStand", function (baseFunc, ...)
  ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
    "LastStandHealFraction",
    function (value) return value > 0 end
  )
  if HeroHasTrait("LastStandDurationTrait") then
    ZyruIncremental.TrackBoonEffect("LastStandDurationTrait")
  end
  return baseFunc(...)
end, ZyruIncremental)

OnEffectCleared { function (triggerArgs)
  if triggerArgs.EffectName == "AthenaDefenseEffect" and triggerArgs.triggeredById ~= nil then
    ZyruIncremental.TrackBoonEffect("ShieldHitTrait")
  end
end}



-------------------------------------------------------------------------------
------------------------------- DEMETER ---------------------------------------
-------------------------------------------------------------------------------

-- TODO: This shouldn't get tracked 2 times on selecting Nourished Soul
ModUtil.Path.Context.Wrap("CalculateHealingMultiplier", function ()
  ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
    "TraitHealingBonus",
    function (value) return value > 1 end
  )
end, ZyruIncremental)

-------------------------------------------------------------------------------
------------------------------- ARES ------------------------------------------
-------------------------------------------------------------------------------

-- Dire Misfortune, Empty Inside, Partial Broken Resolve Implementation
OnEffectApply{
  function( triggerArgs )
    if triggerArgs == nil or triggerArgs.EffectType == "GRIP" or triggerArgs.EffectType == "UNKNOWN" then
      return
    end
    if triggerArgs.EffectName == "DelayedDamage" and triggerArgs.Reapplied then
      if HeroHasTrait("AresLoadCurseTrait") then
        ZyruIncremental.TrackBoonEffect("AresLoadCurseTrait")
      end

    elseif triggerArgs.EffectName == "ReduceDamageOutput" then
      if not triggerArgs.Reapplied and HeroHasTrait("AphroditeDurationTrait") then
        ZyruIncremental.TrackBoonEffect("AphroditeDurationTrait")
      end
      if HeroHasTrait("AphroditePotencyTrait") then
        ZyruIncremental.TrackBoonEffect("AphroditePotencyTrait")
      end
    elseif triggerArgs.EffectName == "Charm" then
      if not triggerArgs.Reapplied and HeroHasTrait("CharmTrait") then
        ZyruIncremental.TrackBoonEffect("CharmTrait")
      end
    end
    -- TODO: Numbing Sensation should go here.
  end
}

OnEffectCleared {
  function (triggerArgs)
    if triggerArgs == nil or triggerArgs.EffectType == "GRIP" or triggerArgs.EffectType == "UNKNOWN" then
      return
    end
    if triggerArgs.EffectName == "KillDamageBonus" then
      if HeroHasTrait("OnEnemyDeathDamageInstanceBuffTrait") then
        ZyruIncremental.TrackBoonEffect("OnEnemyDeathDamageInstanceBuffTrait")
      end
    end
  end
}

-------------------------------------------------------------------------------
------------------------------- ARTEMIS ---------------------------------------
-------------------------------------------------------------------------------
ModUtil.Path.Context.Wrap("DamageEnemy", function ()
  ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
    "CriticalSuperGainAmount",
    function (value) return value > 0 end
  )
end, ZyruIncremental)

-------------------------------------------------------------------------------
------------------------------- POSEIDON --------------------------------------
-------------------------------------------------------------------------------
OnEffectDelayedKnockbackForce{
	function( triggerArgs )
		if triggerArgs.EffectName == "DelayedKnockback" then
			ZyruIncremental.TrackBoonEffect("DoubleCollisionTrait")
		end
	end
}

-------------------------------------------------------------------------------
------------------------------- HERMES ----------------------------------------
-------------------------------------------------------------------------------

-- Auto Reload
ModUtil.Path.Wrap("ReloadAmmoPresentation", function (baseFunc)
  baseFunc()
  if HeroHasTrait("AmmoReloadTrait") then
    ZyruIncremental.TrackBoonEffect("AmmoReloadTrait")
  end
end, ZyruIncremental)

-- FlurryCast
OnWeaponFired{ "RangedWeapon", 
  function ()
    if HeroHasTrait("RapidCastTrait") then
      ZyruIncremental.TrackBoonEffect("RapidCastTrait")
    end
    if HeroHasTrait("MoreAmmoTrait") then
      ZyruIncremental.TrackBoonEffect("MoreAmmoTrait")
    end
  end
}
-- AmmoReclaimTrait (Quick Reload)

-- Quick Recovery
-- After Party
ModUtil.Path.Wrap("Heal", function (baseFunc, victim, args)
  if args.SourceName == "RallyHeal" and HeroHasTrait("RushRallyTrait") then
    ZyruIncremental.TrackBoonEffect("RushRallyTrait", args.HealAmount)
  elseif args and args.Name == "EncounterHeal" and args.HealAmount > 0 then
    ZyruIncremental.TrackBoonEffect("DoorHealTrait", args.HealAmount)
  end
  return baseFunc(victim, args)
end, ZyruIncremental)

-- Greater Reflex
OnWeaponFired{ "RushWeapon",
  function ( triggerArgs )
    for k, v in ipairs({"BonusDashTrait", "RushSpeedBoostTrait" }) do
      if HeroHasTrait(v) then
        ZyruIncremental.TrackBoonEffect(v)
      end
    end
  end
}

-- Greater Evasion
OnDodge{ "_PlayerUnit",
	function( triggerArgs )
    if HeroHasTrait("DodgeChanceTrait") then
      ZyruIncremental.TrackBoonEffect("DodgeChanceTrait")
    end
	end
}

-- Quick Favor
ModUtil.Path.Context.Wrap("SuperRegeneration", function()
  ModUtil.Path.Wrap("BuildSuperMeter", function(baseFunc, ...)
    if HeroHasTrait("RegeneratingSuperTrait") then
      ZyruIncremental.TrackBoonEffect("RegeneratingSuperTrait")
    end
    return baseFunc(...)
  end, ZyruIncremental)
end, ZyruIncremental)

-- Greater Haste
local start = nil
local stop = nil
OnPlayerMoveStarted{
	function( triggerArgs )
    start = _screenTime
	end
}

OnPlayerMoveStopped{
	function( triggerArgs )
    stop = _screenTime
    local duration = stop - start
    if HeroHasTrait("MoveSpeedTrait") then
      ZyruIncremental.TrackBoonEffect("MoveSpeedTrait", duration)
    end
	end
}

-- Swift Strike
-- Swift Flourish
local attackWeapons = {}
local specialWeapons = {}
for i, weaponName in ipairs(WeaponSets.HeroPhysicalWeapons) do
  attackWeapons[weaponName] = true
  if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
    for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
      attackWeapons[w] = true
    end
  end
end

for i, weaponName in ipairs(WeaponSets.HeroSecondaryWeapons) do
  specialWeapons[weaponName] = true
  if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
    for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
      specialWeapons[w] = true
    end
  end

end

OnWeaponFired{ 
  function ( triggerArgs )
    if HeroHasTrait("HermesWeaponTrait") and attackWeapons[triggerArgs.name] then
      ZyruIncremental.TrackBoonEffect("HermesWeaponTrait")
    end
    
    if HeroHasTrait("HermesSecondaryTrait") and specialWeapons[triggerArgs.name]  then
      ZyruIncremental.TrackBoonEffect("HermesSecondaryTrait")
    end
  end
}

ModUtil.Path.Wrap("DropStoredAmmo", function (base, ...)
  
  if HeroHasTrait("AmmoReclaimTrait") then
    ZyruIncremental.TrackBoonEffect("AmmoReclaimTrait")
  end
  base(...)
end, ZyruIncremental)

---- DROP DATA SCALING
-- TODO - ApplyConsumableItemResourceMultiplier wrap
local getMaxHealthScalar = function ()
  local level = ZyruIncremental.Data.DropData.RoomRewardMaxHealthDrop.Level or 0
  return (1 + (level - 1) * 0.1)
end

local getCoinScalar = function ()
  local level = ZyruIncremental.Data.DropData.RoomRewardMoneyDrop.Level or 0
  return (1 + (level - 1) * 0.1)
end

-- GetTotalHeroTraitValue tracking / mapping
-- Life Affirmation
ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, source, args)
  if source == "MaxHealthMultiplier" then
    return baseFunc(source, args) * getMaxHealthScalar()
  elseif source == "MoneyMultiplier" then
    -- DebugPrint({ Text =  "applying modified coin" })
    return baseFunc(source, args) * getCoinScalar()
  elseif source == "HealthRewardBonus" then
    ZyruIncremental.TrackBoonEffect("HealthRewardBonusTrait")
  end
  return baseFunc(source, args)
end, ZyruIncremental)


-- Side Hustle
ModUtil.Path.Wrap("AddMoney", function(baseFunc, amount, source)
  if source == "Hermes Money Trait" and HeroHasTrait("ChamberGoldTrait") then
    ZyruIncremental.TrackBoonEffect("ChamberGoldTrait", amount)
  elseif source == "RoomRewardMoneyDrop" then
    amount = amount  * getCoinScalar()
    ZyruIncremental.TrackDrop(source, amount)
  end
  return baseFunc(amount, source)
end, ZyruIncremental)

-- Greater Recall
ModUtil.Path.Wrap("AddAmmoPresentation", function (base, ...)
  base(...)
  if HeroHasTrait("MagnetismTrait") then
    ZyruIncremental.TrackBoonEffect("MagnetismTrait")
  end
end, ZyruIncremental)


-- ModUtil.Path.Context.Wrap("ApplyConsumableItemResourceMultiplier", function ()
--   ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, source, args)
--     if source == "HealthRewardBonus" then
--       return baseFunc(source, args) * getMaxHealthScalar()
--     elseif source == "MoneyRewardBonus" then
--       -- TODO add coin multiplier scaling
--       return baseFunc(source, args)
--     end
--     return baseFunc(source, args)
--   end, ZyruIncremental)
-- end, ZyruIncremental)

ModUtil.Path.Wrap("AddMaxHealth", function (baseFunc, healthGained, source, args )
  args = args or {}
  source = source or {}
  if source.AddMaxHealth ~= nil then
    ZyruIncremental.TrackDrop("RoomRewardMaxHealthDrop", healthGained)
  end
  return baseFunc(healthGained, source, args)
end, ZyruIncremental)


-- takes the EXP level of a boon and applies 
function ZyruIncremental.CalculatePropertyChangeWithGodLevels(traitName, propertyChange)
  if not propertyChange or type(propertyChange) ~= "table" then
    return propertyChange
  end
  -- attempt recursive strategy e.g. AphroditeWeaponTrait.AddOutgoingDamageModifiers.ValidWeaponMultiplier
  if not propertyChange.IdenticalMultiplier then
    local propertyChangeKVPs = CollapseTableAsOrderedKeyValuePairs(propertyChange)
		for i, kvp in ipairs( propertyChangeKVPs ) do
			local key = kvp.Key
			local value = kvp.Value
			if key ~= "ExtractValue" and key ~= "ExtractValues" then
				propertyChange[key] = ZyruIncremental.CalculatePropertyChangeWithGodLevels(traitName, propertyChange[key])
			end
		end
		return propertyChange
  end

  local saveTraitData = ZyruIncremental.Data.BoonData[traitName]
  if saveTraitData == nil then
    return propertyChange
  end

  -- scale pom value according to pom reward level
  local pomLevel = ZyruIncremental.Data.DropData.StackUpgrade.Level
  propertyChange.IdenticalMultiplier.DiminishingReturnsMultiplier = TraitMultiplierData.DefaultDiminishingReturnsMultiplier * (1 + 0.02 * (pomLevel - 1))
  -- scale identical multiplier (pom base proportion) according to level
  local level = (saveTraitData.Level - 1) or 0
  local val = propertyChange.IdenticalMultiplier.Value
  if val < 0 then -- TODO: figure out other cases?
    -- val = -0.6 -> 0.4 base proportion
    -- level 4 => 0.4 base -> (1 + 4 * 0.05) * 0.4 = 0.48
    -- 0.48 - 1
    propertyChange.IdenticalMultiplier.Value = (1 + val) * (1 + level * 0.1) - 1
    -- DebugPrint { Text = val .. " " .. propertyChange.IdenticalMultiplier.Value }
  end
  return propertyChange
end

-- TraitScripts.lua:236
-- TODO: wraps / locals / whatever here
ModUtil.Path.Override("ProcessTraitData", function( args )
	if args == nil then
		return
	elseif ( args.TraitName == nil and args.TraitData == nil ) or args.Unit == nil then
		return
	end
	local traitName = args.TraitName
	local unit = args.Unit
	local rarity = args.Rarity
	local fakeStackNum = args.FakeStackNum

	local traitData = args.TraitData or DeepCopyTable(TraitData[traitName])
	if traitName == nil then
		traitName = args.TraitData.Name
	end
	traitData.Title = traitData.Name

	local numExisting = GetTraitCount( unit, traitData )

	if args.ForBoonInfo then
		numExisting = 0
	end

	local rarityMultiplier = args.RarityMultiplier or 1
	if rarity ~= nil and traitData.RarityLevels ~= nil and traitData.RarityLevels[rarity] ~= nil and traitData.RarityMultiplier == nil then
		local rarityData = traitData.RarityLevels[rarity]
		if rarityData.Multiplier ~= nil then
			rarityMultiplier = rarityData.Multiplier
		else
			rarityMultiplier = RandomFloat(rarityData.MinMultiplier, rarityData.MaxMultiplier)
		end
		traitData.Rarity = rarity
		traitData.RarityMultiplier = rarityMultiplier
	end

	-- NOTE(Dexter) GetProcessedValue makes calls to the RNG. For determinism, we must iterate in sorted order.
	local traitDataKVPs = CollapseTableAsOrderedKeyValuePairs(traitData)
	for i, kvp in ipairs( traitDataKVPs ) do
		local key = kvp.Key
		local value = kvp.Value
		if key ~= "PropertyChanges" and key ~= "EnemyPropertyChanges" and key ~= "WeaponDataOverride" then
			local propertyRarityMultiplier = rarityMultiplier or 1
			if traitData[key] and type(traitData[key]) == "table" and traitData[key].CustomRarityMultiplier then
				local rarityData = traitData[key].CustomRarityMultiplier[traitData.Rarity]
				if rarityData then
					if rarityData.Multiplier ~= nil then
						propertyRarityMultiplier = rarityData.Multiplier
					else
						propertyRarityMultiplier = RandomFloat(rarityData.MinMultiplier, rarityData.MaxMultiplier)
					end
				end
			end
      -- CHANGES
      if key == "AddOutgoingDamageModifiers" and value ~= nil then
        value = ZyruIncremental.CalculatePropertyChangeWithGodLevels(traitName, value)
      end
      -- END CHANGES
			traitData[key] = GetProcessedValue(value, { NumExisting = numExisting, RarityMultiplier = propertyRarityMultiplier, FakeStackNum = fakeStackNum })
		end
	end

	if not IsEmpty( unit.Traits ) and traitData.RemainingUses ~= nil then
		for i, data in pairs( GetHeroTraitValues( "TraitDurationIncrease", { Unit = unit })) do
			if data.ValidTraits == nil or Contains( data.ValidTraits, traitName ) then
				if traitData.RemainingUses ~= nil then
					traitData.RemainingUses = traitData.RemainingUses + data.Amount
				end
			end
		end
	end

	if traitData.PropertyChanges == nil and traitData.EnemyPropertyChanges == nil then
		return traitData
	end

	local changes = {}
	if traitData.PropertyChanges ~= nil then
		table.insert( changes, "PropertyChanges" )
	end
	if traitData.EnemyPropertyChanges ~= nil then
		table.insert( changes, "EnemyPropertyChanges" )
	end

	for i, changeKey in ipairs(changes) do
		local sortedTraitDataAtChangeKey = CollapseTableOrdered(traitData[changeKey])
		for s, propertyChange in ipairs(sortedTraitDataAtChangeKey) do
			if propertyChange.BaseMin ~= nil or propertyChange.BaseValue ~= nil then
				local propertyRarityMultiplier = rarityMultiplier or 1
				if propertyChange.CustomRarityMultiplier then
					local rarityData = propertyChange.CustomRarityMultiplier[traitData.Rarity]
					if rarityData then
						if rarityData.Multiplier ~= nil then
							propertyRarityMultiplier = rarityData.Multiplier
						else
							propertyRarityMultiplier = RandomFloat(rarityData.MinMultiplier, rarityData.MaxMultiplier)
						end
					end
				end
        -- CHANGES
        if propertyChange ~= nil then
          propertyChange = ZyruIncremental.CalculatePropertyChangeWithGodLevels(traitName, propertyChange)
        end
        -- END CHANGES
				local newValue = GetProcessedValue(propertyChange, { Unit = unit, NumExisting = numExisting, RarityMultiplier = propertyRarityMultiplier, FakeStackNum = fakeStackNum  })
				propertyChange.ChangeValue = newValue
				propertyChange.BaseValue = newValue
				if propertyChange.ChangeType == nil then
					if numExisting > 0 then
						propertyChange.ChangeType = "Add"
					else
						propertyChange.ChangeType = "Absolute"
					end
				end
			end
		end
	end
	return traitData
end)