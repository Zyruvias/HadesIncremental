-- HandleUpgradeChoiceSelection for poms
ModUtil.Path.Wrap("HandleUpgradeChoiceSelection", function (baseFunc, screen, button)
  if button.LootData.Name == "StackUpgrade" then
    local traitName = button.Data.Name
    local levelCount  = GetTraitNameCount(CurrentRun.Hero, traitName)
    for i = levelCount, levelCount + button.LootData.StackNum - 1 do
      DebugPrint { Text = i }
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
  
  DebugPrint { Text = "Drop Tracked: " .. source .. " for " .. tostring(amount) }
  local dropData = ZyruIncremental.Data.DropData[source]
  dropData.Count = dropData.Count + 1
  dropData.Amount = dropData.Amount + amount
  dropData.Experience = dropData.Experience + ZyruIncremental.DropExperienceFactor[source] * amount
  -- if level-up: 
  if ZyruIncremental.GetExperienceForNextBoonLevel(dropData.Level) <= dropData.Experience then
    dropData.Level = dropData.Level + 1
    local voiceLine = GetRandomValue(ZyruIncremental.DropLevelUpVoiceLines[source])
    if voiceLine ~= nil then
      PlayVoiceLine(voiceLine)
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
	local metaupgradeEpicBoost = 100 * GetNumMetaUpgrades( "EpicBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 ) + GetNumMetaUpgrades( "EpicHeroicBoonMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	baseRarity = baseRarity + metaupgradeEpicBoost
  local metaupgradeLegendaryBoost = GetNumMetaUpgrades( "DuoRarityBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	legendaryRoll = legendaryRoll + metaupgradeLegendaryBoost

	local rarityTraits = GetHeroTraitValues("RarityBonus", { UnlimitedOnly = ignoreTempRarityBonus })
	for i, rarityTraitData in pairs(rarityTraits) do
		if rarityTraitData.RequiredGod == nil or rarityTraitData.RequiredGod == name then
			if rarityTraitData.RareBonus then
				baseRarity = baseRarity + 100 * rarityTraitData.RareBonus
			end
      -- TODO: Figure out Exclusive Access and if other epic sources make sense to preserve
			-- if rarityTraitData.EpicBonus then
			-- 	epicRoll = epicRoll + rarityTraitData.EpicBonus
			-- end
			if rarityTraitData.LegendaryBonus then
				legendaryRoll = legendaryRoll + rarityTraitData.LegendaryBonus
			end
		end
	end

  local chances = ZyruIncremental.ComputeRarityDistribution( baseRarity )
	chances.Legendary = legendaryRoll
  -- DebugPrint { Text = "Chances at " .. tostring(baseRarity) .."%: " .. ModUtil.ToString.Deep(chances)}
  return chances
end, ZyruIncremental)


ModUtil.Path.Wrap("SetTraitsOnLoot", function(baseFunc, lootData, args)
  -- Calculate normal rarity for the sake of Duos / Legendaries, I like the current system.
  DebugPrint { Text = ModUtil.ToString.Shallow(lootData)}
  baseFunc(lootData, args)
  ZyruIncremental.DebugLoot = DeepCopyTable(lootData)
  ZyruIncremental.DebugArgs = DeepCopyTable(args)
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

  -- TODO: Map upgrade names to gods?
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
      
      DebugPrint { Text = "Rolled " .. chosenRarity }
      if rarityTable[chosenRarity] ~= nil and rarityTable[chosenRarity][upgradeData.ItemName] then
        DebugPrint { Text = "Boon has " .. chosenRarity .. " table"}
        upgradeData.Rarity = chosenRarity
      end
		end
    -- TODO: Pom rarity??? hamer RARITY?????????
  end

end, ZyruIncremental)

-- TODO: override?
ModUtil.Path.Wrap("GetUpgradedRarity", function (base, baseRarity)
  -- TODO: limit by seen rarities
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

-- TODO: nyx levels?
local ignoreDamageSourceTraitMap = {
  HighHealthDamageMetaUpgrade = true,
  GodEnhancementMetaUpgrade = true,
  BackstabMetaUpgrade = true,
  StoredAmmoVulnerabilityMetaUpgrade = true,
  VulnerabilityEffectBonusMetaUpgrade = true,
  FirstStrikeMetaUpgrade = true,
  PerfectDashEmpowerApplicator = true,
}

--[[
  Outline for cleaner implementation
  ModUtil.Path.Context.Env ("Damage")
    ModUtil.Path.Wrap ("CalculateDamageMultipliers")
    ModUtil.Path.Wrap ("DamageEnemy")
    ModUtil.Path.Wrap ("DamageHero")
]]--

ModUtil.Path.Context.Wrap("Damage", function ()
  
  local enemyDamageSources = {}
  local damageMultiplierMap = {}
  
  --[[
    NOTE: This implementation of the wrap is meant to inject custom behavior in triggerArgs
    to hook into addDamageMultipliers
    ModUtil.Path.Wrap("CalculateDamageMultipliers", function( base, attacker, victim, weaponData, triggerArgs )
      DebugPrint{ Text = "Calling CalculateDamageMultipliers"}
      enemyDamageSources = {}
      local baseDamage = triggerArgs.DamageAmount
      local addDamageMultiplierWrapper = function (baseFunc, trait, multiplier)
        DebugPrint { Text = tostring(trait.Name) .. " " .. tostring(multiplier) }
        if ignoreDamageSourceTraitMap[trait.Name] == nil then
          table.insert(enemyDamageSources, { 
            Name = trait.Name, 
            Multiplier = multiplier 
          })
        end
        return baseFunc(trait, multiplier)
      end
      
      -- TODO: https://discord.com/channels/667753182608359424/667757899111596071/1009525083326390423
      -- metatable reference lookup to not destroy potential mod compatibility
      local triggerArgsMeta = { 
        __index = function( s, k, v )
          local locals = ModUtil.Locals.Stacked(3)
          DebugPrint { Text = "Stacked(1): " .. _G["k"](ModUtil.Locals.Stacked(1)) }
          DebugPrint { Text = "Stacked(2): " .. _G["k"](ModUtil.Locals.Stacked(2)) }
          DebugPrint { Text = "Stacked(3): " .. _G["k"](ModUtil.Locals.Stacked(3)) }
          DebugPrint { Text = "Stacked(4): " .. _G["k"](ModUtil.Locals.Stacked(4)) }
          DebugPrint { Text = "Stacked(5): " .. _G["k"](ModUtil.Locals.Stacked(5)) }
          DebugPrint { Text = "Stacked(6): " .. _G["k"](ModUtil.Locals.Stacked(6)) }
          DebugPrint { Text = "Stacked(7): " .. _G["k"](ModUtil.Locals.Stacked(7)) }
          DebugPrint { Text = "Stacked(8): " .. _G["k"](ModUtil.Locals.Stacked(8)) }
          DebugPrint { Text = "s, k, v: " .. tostring(s) .. " " .. tostring(k) .. " " .. tostring(v)}
          locals.addDamageMultiplier = ModUtil.Wrap( locals.addDamageMultiplier, addDamageMultiplierWrapper, ZyruIncremental )
          setmetatable( s, nil )
          return rawget( s, k, v )
        end
      }

      -- EXPERIMENT: create brand new trigger args object to have diirect control over when its accessed?
      local newTriggerArgs = ModUtil.Table.Copy.Deep(triggerArgs)
      -- TODO: triggerArgs has a meta? idk, see discord comment
      -- setmetatable( triggerArgs, triggerArgsMeta )
      setmetatable( newTriggerArgs, triggerArgsMeta )
      local value = base( attacker, victim, weaponData, newTriggerArgs )
      -- setmetatable( triggerArgs, meta )

      local d = {}
      DebugPrint { Text = "enemyDamageSources:" .. ModUtil.ToString.Deep(enemyDamageSources)}
      for i, source in pairs(enemyDamageSources) do
        d[source.Name] = (d[source.Name] or 1) + source.Multiplier - 1
      end
      damageMultiplierMap = {
        BaseDamage = baseDamage,
        Multipliers = d,
        EnDamage = value,
      }
    
      return value
    end, ZyruIncremental )
  ]]--

  -- From Scripts/Combat.lua line
  ModUtil.Path.Override("CalculateDamageMultipliers", function (attacker, victim, weaponData, triggerArgs)
      local damageReductionMultipliers = 1
      local damageMultipliers = 1.0
      local lastAddedMultiplierName = ""

      -- CHANGES
      local baseDamage = triggerArgs.DamageAmount
      -- END CHANGES
    
      if ConfigOptionCache.LogCombatMultipliers then
        DebugPrint({Text = " SourceWeapon : " .. tostring( triggerArgs.SourceWeapon )})
      end
    
      local addDamageMultiplier = function( data, multiplier )
        -- CHANGES
        -- DebugPrint { Text = tostring(data.Name) .. " " .. tostring(multiplier) }
        -- TODO: Nyx levels
        if ignoreDamageSourceTraitMap[data.Name] == nil then
          table.insert(enemyDamageSources, { 
            Name = data.Name, 
            Multiplier = multiplier 
          })
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

      local d = {}
      -- DebugPrint { Text = "enemyDamageSources:" .. ModUtil.ToString.Deep(enemyDamageSources)}
      for i, source in pairs(enemyDamageSources) do
        if source ~= nil and source.Name ~= nil then
          d[source.Name] = (d[source.Name] or 1) + source.Multiplier - 1
        end
      end
      damageMultiplierMap = {
        BaseDamage = baseDamage,
        Multipliers = d,
        ResultingDamage = baseDamage * damageMultipliers * damageReductionMultipliers,
      }

      return damageMultipliers * damageReductionMultipliers
  end, ZyruIncremental)
  
  ModUtil.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
    local armorBeforeAttack = victim.HealthBuffer or 0
    local res = baseFunc( victim, triggerArgs )
    
    local obj = triggerArgs or {}
    ZyruIncremental.lta = obj
    ZyruIncremental.Victim = victim
    ZyruIncremental.DamageMap = damageMultiplierMap
    -- and victim.Name ~= "TrainingMelee" while testing
    if RequiredKillEnemies[victim.ObjectId] == nil  then
      return
    end

    local damageResult = damageMultiplierMap
    if damageResult == nil then
      DebugPrint { Text = " NULL DAMAGE RESULT FOUND"}
      ZyruIncremental.Debug = {
        Victim = victim,
        Args = triggerArgs
      }
      return
    end
    
    local sourceWeaponData = obj.AttackerWeaponData
    local weapon = nil
    local sourceName = nil
    local boonsUsed = {}
  
    if triggerArgs.EffectName ~= nil then
      local traitUsed = ZyruIncremental.EffectToBoonMap[obj.EffectName]
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
    elseif ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon] ~= nil then
      weapon = ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]
      sourceName = weapon
      boonsUsed[ZyruIncremental.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]] = damageResult.BaseDamage
    elseif triggerArgs.AttackerIsObstacle then
      if HeroHasTrait("BonusCollisionTrait") then
        boonsUsed["BonusCollisionTrait"] = damageResult.BaseDamage
      end
    elseif triggerArgs.ProjectileDeflected then
      if HeroHasTrait("AthenaShieldTrait") then
        boonsUsed["AthenaShieldTrait"] = damageResult.BaseDamage
      end
    end
    
    -- { Base Damage: int, Multipliers: {}, ResultingDamage}
    for name, multiplier in pairs(damageResult.Multipliers) do
      local damageProportion = damageResult.BaseDamage * (multiplier - 1)
      local trait = HeroHasTrait(name) and name or ZyruIncremental.DamageModifiersToBoonMap[name]
      if trait ~= nil then
        boonsUsed[trait] = (boonsUsed[trait] or 0) + damageProportion
      end
    end
  
    -- START DEBUG
    ZyruIncremental.Weapon = weapon
    ZyruIncremental.BoonsUsed = boonsUsed
    -- END DEBUG
  
    if obj.IsCrit then
      -- TODO: distribute "exp" by source amount
      -- OnEffectApply version???
      if victim.ActiveEffectsAtDamageStart ~= nil and victim.ActiveEffectsAtDamageStart.CritVulnerability then
        -- HM
        boonsUsed["CritVulnerabilityTrait"] = true
      else
        boonsUsed["CritBonusTrait"] = true
      end
      -- DR clause, OnEffectApply
  
      -- CleanKill
      if HeroHasTrait("ArtemisCriticalTrait") then
        boonsUsed["ArtemisCriticalTrait"] = true
      end
      -- Hide Breakerf
      if HeroHasTrait("CriticalBufferMultiplierTrait") and armorBeforeAttack > 0 then
        boonsUsed["CriticalBufferMultiplierTrait"] = true
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
  
DebugPrint({ Text = text })
    return res
  
  end, ZyruIncremental)
  
  ModUtil.Path.Wrap("DamageHero", function(baseFunc, victim, args) 
    baseFunc(victim, args)
    local boonsUsed = {}

    -- damage calculation
    -- log(ratio) = log(mult1) + log(mult2) + mult(3)
    -- contribution for mult1 = log(mult1) / [log(ratio)]
    -- ratio is 20% reduction? (base - result) / base
    local damageResult = damageMultiplierMap
    if damageResult == nil or damageResult.BaseDamage == nil then
      -- PureDamage?
      DebugPrint { Text = "BaseDamage to Zag nil: " .. ModUtil.ToString.Shallow(args)}
      return
    end
    local endRatio = (damageResult.BaseDamage  - damageResult.ResultingDamage) / damageResult.BaseDamage
    DebugPrint {
      Text = "Final Reduction Ratio: (" ..
      tostring(damageResult.BaseDamage) .. " - " ..
      tostring(damageResult.ResultingDamage) .. ") / " ..
      tostring(damageResult.BaseDamage) .. " = " .. endRatio
    }
    for name, multiplier in pairs(damageResult.Multipliers) do
      local multiplierContribution = math.log(multiplier) / math.log(1 - endRatio)
      DebugPrint {
        Text = "Multiplier contribution for" .. name .. ": (" ..
        tostring(math.log(1 - multiplier)) ..") / " ..
        tostring(math.log(1 - endRatio)) .. " = " .. multiplierContribution
      }
      local boonExpProportion = damageResult.BaseDamage * multiplierContribution
      local trait = HeroHasTrait(name) and name or ZyruIncremental.DamageModifiersToBoonMap[name]
      if trait ~= nil then
        DebugPrint{ Text = tostring(trait) .. ": " .. tostring(boonExpProportion) .. " " .. tostring(multiplierContribution)}
        boonsUsed[trait] = (boonsUsed[trait] or 0) + boonExpProportion
      end
    end
  
    for k,v in pairs(boonsUsed) do
      ZyruIncremental.TrackBoonEffect(k, v, victim)
    end
  end, ZyruIncremental)

end, ZyruIncremental)

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

  if ZyruIncremental.Data.BoonData[traitName] == nil then
    DebugPrint({ Text =  traitName .. " initialized" })
    ZyruIncremental.Data.BoonData[traitName] = {
      Count = 0,
      Value = 0,
      Experience = 0,
      Level = 1
    }
  end

  local saveTraitData = ZyruIncremental.Data.BoonData[traitName]

  -- assign use count, damage, experience
  local expGained = 0
  saveTraitData.Count = saveTraitData.Count + 1
  if type(damageValue) == "number" then
    saveTraitData.Value = saveTraitData.Value + damageValue
    if (ZyruIncremental.BoonExperienceFactor[traitName] == nil) then
      DebugPrint { Text = traitName .. " not found in BoonExperienceFactor map"}
      return
    end
    saveTraitData.Experience = saveTraitData.Experience + ZyruIncremental.BoonExperienceFactor[traitName] * damageValue
    expGained = expGained + ZyruIncremental.BoonExperienceFactor[traitName] * damageValue
  end

  if (ZyruIncremental.BoonExperiencePerUse[traitName] == nil) then
    DebugPrint { Text = traitName .. " not found in BoonExperiencePerUse map"}
  else
    saveTraitData.Experience = saveTraitData.Experience + ZyruIncremental.BoonExperiencePerUse[traitName]
    expGained = expGained + ZyruIncremental.BoonExperiencePerUse[traitName]
  end

  if expGained > 0 then
    ZyruIncremental.HandleExperiencePresentationBehavior(traitName, ZyruIncremental.BoonToGod[traitName], expGained, victim)
  end

  -- check for level-ups
  if ZyruIncremental.GetExperienceForNextBoonLevel(saveTraitData.Level) < saveTraitData.Experience then
    saveTraitData.Level = saveTraitData.Level + 1
    DebugPrint { Text = traitName .. " has reached level " .. tostring(saveTraitData.Level)}
    -- Add God Levels
    AddGodExperience(ZyruIncremental.BoonToGod[traitName], saveTraitData.Level - 1)
    -- TODO: Add queuing for boon levels/god levels
    -- Add UI level up message
    DisplayBoonLevelupPopup( { traitName }, saveTraitData.Level)
    -- voice lines??
    if TraitData[traitName].God ~= nil then
      local voiceLine = GetRandomValue(ZyruIncremental.BoonLevelUpVoiceLines[TraitData[traitName].God])
      DebugPrint { Text = ModUtil.ToString.Deep(voiceLine) }
      PlayVoiceLine(voiceLine)
    end
  end
end

ModUtil.Path.Wrap("PurchaseConsumableItem", function ( baseFunc, currentRun, consumableItem, args) 
  -- consumableItem.Name
  baseFunc(currentRun, consumableItem, args)
end, ZyruIncremental)

-------------------------------------------------------------------------------
------------------------------- ZEUS ------------------------------------------
-------------------------------------------------------------------------------


-- START CLOUDED JUDGEMENT, BOILING POINT DETECTION
ModUtil.Path.Context.Wrap("CalculateSuperGain", function()
  ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
    local res = baseFunc(traitName, args)
    if ZyruIncremental.SuperTraitMap[traitName] ~= nil then
      if res > 1 then
        ZyruIncremental.TrackBoonEffect(ZyruIncremental.SuperTraitMap[traitName])
      end
    end
    return res
  end, ZyruIncremental)
end, ZyruIncremental)
-- END CLOUDED JUDGEMENT, BOILING POINT DETECTION

-- START BILLOWING STRENGTH, SECOND WIND DETECTION
ModUtil.Path.Context.Wrap("CommenceSuperMove", function()
  ModUtil.Path.Wrap("GetHeroTraitValues", function (baseFunc, ...)
    local res = baseFunc(...)
    for key, trait in pairs(res) do
      DebugPrint({ Text = ModUtil.ToString.Deep(trait) })
      if ZyruIncremental.SuperTraitMap[trait[1]] ~= nil then
        ZyruIncremental.TrackBoonEffect(ZyruIncremental.SuperTraitMap[trait[1]])
      end
    end
    return res
  end, ZyruIncremental)
end, ZyruIncremental)
-- END BILLOWING STRENGTH, BOILING POINT DETECTION

-- DOUBLE STRIKE
ModUtil.Path.Context.Wrap("FireWeaponWithinRange", function()
  ModUtil.Path.Wrap("RandomChance", function(baseFunc, ...)
    local randomRes = false
    randomRes = baseFunc(...)
    if randomRes then
      ZyruIncremental.TrackBoonEffect("ZeusBonusBoltTrait")
    end
    return randomRes
  end, ZyruIncremental)
end, ZyruIncremental)
-- END DOUBLE STRIKE


-------------------------------------------------------------------------------
------------------------------- DIONYSUS --------------------------------------
-------------------------------------------------------------------------------


-- After Party
ModUtil.Path.Context.Wrap("EndEncounterEffects", function () 
  ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
    local res = baseFunc(traitName, args)
    if traitName == "CombatEncounterHealthPercentFloor" and res > 0 then
      ZyruIncremental.TrackBoonEffect("DoorHealTrait")
    end
    return res
  end, ZyruIncremental)
end, ZyruIncremental)

-- LowHealthDefenseTrait (Positive Outlook)

-- DionysusMaxHealthTrait (Premium Vintage)
ModUtil.Path.Wrap("AddMaxHealth", function (baseFunc, amount, source)
  baseFunc(amount, source)
  if source == "DionysusMaxHealthTrait" then
    ZyruIncremental.TrackBoonEffect(source)
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
    -- DebugPrint({ Text = ModUtil.ToString.Shallow(triggerArgs) })
    if triggerArgs.EffectName == "DelayedDamage" and triggerArgs.Reapplied then
      if HeroHasTrait("AresLoadCurseTrait") then
        ZyruIncremental.TrackBoonEffect("AresLoadCurseTrait")
      end

    elseif triggerArgs.EffectName == "ReduceDamageOutput" and not triggerArgs.Reapplied then
      if HeroHasTrait("AphroditeDurationTrait") then
        ZyruIncremental.TrackBoonEffect("AphroditeDurationTrait")
      end
    end
    -- TODO: Numbing Sensation should go here.
  end
}

-------------------------------------------------------------------------------
-------vc------------------------ ARTEMIS ---------------------------------------
-------------------------------------------------------------------------------
-- ModUtil.Path.Context.Wrap("DamageEnemy", function ()
--   ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator(
--     "CriticalSuperGainAmount",
--     function (value) return value > 0 end
--   )
-- end, ZyruIncremental)

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
  end
}
-- AmmoReclaimTrait (Quick Reload)
ModUtil.Path.Context.Wrap("DropStoredAmmo", function ()
  ModUtil.Path.Wrap("GetHeroTraitValues", function(baseFunc, source, args)
    if source == ("AmmoDropWeapons") and HeroHasTrait("AmmoReclaimTrait") then
      ZyruIncremental.TrackBoonEffect("AmmoReclaimTrait")
    end
    return baseFunc(source, args)
  end, ZyruIncremental)
end, ZyruIncremental)

-- Quick Recovery
ModUtil.Path.Wrap("Heal", function (baseFunc, victim, args)
  if args.SourceName == "RallyHeal" and HeroHasTrait("RushRallyTrait") then
    ZyruIncremental.TrackBoonEffect("RushRallyTrait")
  end
  return baseFunc(victim, args)
end, ZyruIncremental)

-- Greater Reflex
OnWeaponFired{ "RushWeapon",
  function ( triggerArgs )
    for k, v in pairs({"BonusDashTrait", "RushSpeedBoostTrait" }) do
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
ModUtil.LoadOnce( function (  ) 
  local attackWeapons = ""
  local specialWeapons = ""
  for i, weaponName in ipairs(WeaponSets.HeroPhysicalWeapons) do
    attackWeapons = attackWeapons .. " " .. weaponName
    if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
      for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
        attackWeapons = attackWeapons .. " " .. w
      end
    end
  end
  
  for i, weaponName in ipairs(WeaponSets.HeroSecondaryWeapons) do
    specialWeapons = specialWeapons .. " " .. weaponName
    if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
      for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
        specialWeapons = specialWeapons .. " " .. w
      end
    end
  end
  
  OnWeaponFired{ attackWeapons,
    function ( triggerArgs )
      if HeroHasTrait("HermesWeaponTrait") then
        ZyruIncremental.TrackBoonEffect("HermesWeaponTrait")
      end
    end
  }
  
  OnWeaponFired{ specialWeapons,
    function ( triggerArgs )
      if HeroHasTrait("HermesSecondaryTrait") then
        ZyruIncremental.TrackBoonEffect("HermesSecondaryTrait")
      end
    end
  }
end)

---- DROP DATA SCALING
-- TODO - ApplyConsumableItemResourceMultiplier wrap
local getMaxHealthScalar = function ()
  if GameState.ZyruviIncremental == nil then return 1 end
  local level = ZyruIncremental.Data.DropData.RoomRewardMaxHealthDrop.Level or 0
  return (1 + (level - 1) * 0.1)
end

local getCoinScalar = function ()
  if GameState.ZyruviIncremental == nil then return 1 end
  local level = ZyruIncremental.Data.DropData.RoomRewardMoneyDrop.Level or 0
  return (1 + (level - 1) * 0.1)
end

ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, source, args)
  if source == "MaxHealthMultiplier" then
    return baseFunc(source, args) * getMaxHealthScalar()
  elseif source == "MoneyMultiplier" then
    DebugPrint({ Text =  "applying modified coin" })
    return baseFunc(source, args) * getCoinScalar()
  end
  return baseFunc(source, args)
end, ZyruIncremental)


-- Side Hustle
ModUtil.Path.Wrap("AddMoney", function(baseFunc, amount, source)
DebugPrint{ Text = tostring(amount) .. tostring(source)}
  if source == "Hermes Money Trait" and HeroHasTrait("ChamberGoldTrait") then
    ZyruIncremental.TrackBoonEffect("ChamberGoldTrait")
  elseif source == "RoomRewardMoneyDrop" then
    amount = amount  * getCoinScalar()
    ZyruIncremental.TrackDrop(source, amount)
  end
  return baseFunc(amount, source)
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
  -- TODO: what do non-pommables do when leveling?
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
    DebugPrint { Text = val .. " " .. propertyChange.IdenticalMultiplier.Value }
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