-- HandleUpgradeChoiceSelection for poms
ModUtil.Path.Wrap("HandleUpgradeChoiceSelection", function (baseFunc, screen, button)
  if button.LootData.Name == "StackUpgrade" then
    local traitName = button.Data.Name
    local levelCount  = GetTraitNameCount(CurrentRun.Hero, traitName)
    for i = levelCount, levelCount + button.LootData.StackNum - 1 do
      DebugPrint { Text = i }
      Z.TrackDrop(button.LootData.Name, math.floor(150 / math.pow(2, (i - 1) / 2)))
    end
  end

  return baseFunc(screen, button)
end, Z)

-- this is Eury/pomslice/nectar
ModUtil.Path.Wrap("AddStackToTraits", function (baseFunc, source, args)
  if args and args.Thread then
    -- this calls itself again, wait for those changes to resolve before doing anything 
    return baseFunc(source, args)
  end
  DebugPrint { Text = ModUtil.ToString.Deep(source)}
  DebugPrint { Text = ModUtil.ToString.Deep(args)}
  Z.TrackDrop("StackUpgrade", (source.NumTraits or 1) * (source.NumStacks or 1) * 75 )
  return baseFunc(source, args)
end, Z)

function Z.TrackDrop(source, amount)
  if source == nil or amount == nil then
    DebugPrint { Text = "drop source or amount nil"}
    return
  end
  
  DebugPrint { Text = "Drop Tracked: " .. source .. " for " .. tostring(amount) }
  local dropData = Z.Data.DropData[source]
  dropData.Count = dropData.Count + 1
  dropData.Amount = dropData.Amount + amount
  dropData.Experience = dropData.Experience + Z.DropExperienceFactor[source] * amount
  -- if level-up: 
  if Z.GetExperienceForNextBoonLevel(dropData.Level) <= dropData.Experience then
    dropData.Level = dropData.Level + 1
    local voiceLine = GetRandomValue(Z.DropLevelUpVoiceLines[source])
    if voiceLine ~= nil then
      DebugPrint { Text = ModUtil.ToString.Deep(voiceLine) }
      PlayVoiceLine(voiceLine)
    end
  end
end

ModUtil.WrapBaseFunction("SetTraitsOnLoot", function(baseFunc, lootData, args)
  -- Calculate normal rarity for the sake of Duos / Legendaries, I like the current system.
  DebugPrint { Text = ModUtil.ToString.Shallow(lootData)}
  baseFunc(lootData, args)
  Z.DebugLoot = DeepCopyTable(lootData)


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
  
  -- TODO: fix hammer spawn / chaos spawn
  -- TODO: Fix boons
  for i, upgradeData in ipairs(upgradeOptions) do
    DebugPrint { Text = ModUtil.ToString.Shallow(upgradeData)}
    if god ~= nil and upgradeData.Rarity ~= "Legendary" then
      local chosenRarity = Z.ComputeRarityForGod(god)
      DebugPrint { Text = "Rolled " .. chosenRarity }
      if rarityTable[chosenRarity] ~= nil and rarityTable[chosenRarity][upgradeData.ItemName] then
        -- DebugPrint { Text = "Boon has " .. chosenRarity .. " table"}
        upgradeData.Rarity = chosenRarity
      end
		end
    -- TODO: Pom rarity??? hamer RARITY?????????
  end

end, Z)

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
          locals.addDamageMultiplier = ModUtil.Wrap( locals.addDamageMultiplier, addDamageMultiplierWrapper, Z )
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
    end, Z )
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
        DebugPrint { Text = tostring(data.Name) .. " " .. tostring(multiplier) }
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
      DebugPrint { Text = "enemyDamageSources:" .. ModUtil.ToString.Deep(enemyDamageSources)}
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
  end, Z)
  
  ModUtil.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
    local armorBeforeAttack = victim.HealthBuffer or 0
    local res = baseFunc( victim, triggerArgs )
    
    local obj = triggerArgs or {}
    Z.lta = obj
    Z.Victim = victim
    Z.DamageMap = damageMultiplierMap
    
    if RequiredKillEnemies[victim.ObjectId] == nil and victim.Name ~= "TrainingMelee" then
      -- DebugPrint{ Text = "Non-required Enemy Hit"}
      return
    end

    local damageResult = damageMultiplierMap
    if damageResult == nil then
      DebugPrint { Text = " NULL DAMAGE RESULT FOUND"}
      Z.Debug = {
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
      -- DebugPrint({ Text = "EffectName found: ".. obj.EffectName })
      local traitUsed = Z.EffectToBoonMap[obj.EffectName]
      if traitUsed ~= nil then
        -- DebugPrint({ Text = obj.SourceWeapon })
        -- DebugPrint({ Text = ModUtil.ToString.Deep(traitUsed) })
        if type(traitUsed) == "table" then
          traitUsed = traitUsed[triggerArgs[traitUsed.MapSource]]
          -- DebugPrint({ Text = ModUtil.ToString.Shallow(traitUsed) })
          
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
      elseif Z.WeaponToBoonMap[weapon.Name] ~= nil then
        sourceName = weapon.Name
        boonsUsed[Z.WeaponToBoonMap[weapon.Name]] = true
      end
      -- end sourceWeaponData variance check
    elseif ProjectileData[triggerArgs.SourceWeapon] ~= nil then
      weapon = ProjectileData[triggerArgs.SourceWeapon]
      local traitUsed = Z.ProjectileToBoonMap[weapon.Name]
      if traitUsed ~= nil then
        boonsUsed[traitUsed] = damageResult.BaseDamage
      end
  
      sourceName = weapon.Name
    elseif Z.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon] ~= nil then
      weapon = Z.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]
      sourceName = weapon
      boonsUsed[Z.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]] = damageResult.BaseDamage
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
      local trait = HeroHasTrait(name) and name or Z.DamageModifiersToBoonMap[name]
      if trait ~= nil then
        DebugPrint{ Text = tostring(trait) .. ": " .. tostring(damageProportion)}
        boonsUsed[trait] = (boonsUsed[trait] or 0) + damageProportion
      end
    end
  
    -- START DEBUG
    Z.Weapon = weapon
    Z.BoonsUsed = boonsUsed
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
    if Z.HailMaryMap[sourceName] ~= nil then
      -- DebugPrint({ Text = "Searching for ".. sourceName .. " in HailMaryMap"})
      for k, trait in pairs(Z.HailMaryMap[sourceName]) do
        if HeroHasTrait(trait) then
          boonsUsed[trait] = damageResult.BaseDamage
        end
      end
    end
  
    -- Apply all boons tracked in this damage source computation
    for k,v in pairs(boonsUsed) do
      Z.TrackBoonEffect(k, v)
    end
  
    -- DebugPrint({ Text = text })
    return res
  
  end, Z)
  
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
      local trait = HeroHasTrait(name) and name or Z.DamageModifiersToBoonMap[name]
      if trait ~= nil then
        DebugPrint{ Text = tostring(trait) .. ": " .. tostring(boonExpProportion) .. " " .. tostring(multiplierContribution)}
        boonsUsed[trait] = (boonsUsed[trait] or 0) + boonExpProportion
      end
    end
  
    for k,v in pairs(boonsUsed) do
      Z.TrackBoonEffect(k, v)
    end
  end, Z)

end, Z)

function Z.TrackBoonEffect ( traitName, damageValue )
  if Z.Data == nil or traitName == nil then
    return
  end

  if type(traitName) == "table" then
    DebugPrint { Text = "table found as boon: " .. ModUtil.ToString.Shallow(traitName)}
    return
  end

  if Z.BoonsToIgnore[traitName] then
    DebugPrint { Text = "Found ignored trait " .. traitName }
    return
  end

  if Z.Data.BoonData[traitName] == nil then
    DebugPrint({ Text =  traitName .. " initialized" })
    Z.Data.BoonData[traitName] = {
      Count = 0,
      Value = 0,
      Experience = 0,
      Level = 1
    }
  end

  local saveTraitData = Z.Data.BoonData[traitName]

  -- assign use count, damage, experience
  local expGained = 0
  saveTraitData.Count = saveTraitData.Count + 1
  if type(damageValue) == "number" then
    saveTraitData.Value = saveTraitData.Value + damageValue
    if (Z.BoonExperienceFactor[traitName] == nil) then
      DebugPrint { Text = traitName .. " not found in BoonExperienceFactor map"}
      return
    end
    saveTraitData.Experience = saveTraitData.Experience + Z.BoonExperienceFactor[traitName] * damageValue
    expGained = expGained + Z.BoonExperienceFactor[traitName] * damageValue
  end

  if (Z.BoonExperiencePerUse[traitName] == nil) then
    DebugPrint { Text = traitName .. " not found in BoonExperiencePerUse map"}
  else
    saveTraitData.Experience = saveTraitData.Experience + Z.BoonExperiencePerUse[traitName]
    expGained = expGained + Z.BoonExperiencePerUse[traitName]
  end

  if expGained > 0 then
    thread( DisplayExperiencePopup, expGained )
  end

  -- check for level-ups
  if Z.GetExperienceForNextBoonLevel(saveTraitData.Level) < saveTraitData.Experience then
    saveTraitData.Level = saveTraitData.Level + 1
    DebugPrint { Text = traitName .. " has reached level " .. tostring(saveTraitData.Level)}
    -- Add God Levels
    AddGodExperience(Z.BoonToGod[traitName], saveTraitData.Level - 1)
    -- TODO: Add queuing for boon levels/god levels
    -- Add UI level up message
    DisplayBoonLevelupPopup( { traitName }, saveTraitData.Level)
    -- voice lines??
    if TraitData[traitName].God ~= nil then
      local voiceLine = GetRandomValue(Z.BoonLevelUpVoiceLines[TraitData[traitName].God])
      DebugPrint { Text = ModUtil.ToString.Deep(voiceLine) }
      PlayVoiceLine(voiceLine)
    end
  end
end

ModUtil.Path.Wrap("PurchaseConsumableItem", function ( baseFunc, currentRun, consumableItem, args) 
  DebugPrint{ Text = ModUtil.ToString.Deep(consumableItem) }
  -- consumableItem.Name
  baseFunc(currentRun, consumableItem, args)
end, Z)

-------------------------------------------------------------------------------
------------------------------- ZEUS ------------------------------------------
-------------------------------------------------------------------------------


-- START CLOUDED JUDGEMENT, BOILING POINT DETECTION
ModUtil.Path.Context.Wrap("CalculateSuperGain", function()
  ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
    local res = baseFunc(traitName, args)
    if Z.SuperTraitMap[traitName] ~= nil then
      if res > 1 then
        Z.TrackBoonEffect(Z.SuperTraitMap[traitName])
      end
    end
    return res
  end, Z)
end, Z)
-- END CLOUDED JUDGEMENT, BOILING POINT DETECTION

-- START BILLOWING STRENGTH, SECOND WIND DETECTION
ModUtil.Path.Context.Wrap("CommenceSuperMove", function()
  ModUtil.Path.Wrap("GetHeroTraitValues", function (baseFunc, ...)
    local res = baseFunc(...)
    for key, trait in pairs(res) do
      DebugPrint({ Text = ModUtil.ToString.Deep(trait) })
      if Z.SuperTraitMap[trait[1]] ~= nil then
        Z.TrackBoonEffect(Z.SuperTraitMap[trait[1]])
      end
    end
    return res
  end, Z)
end, Z)
-- END BILLOWING STRENGTH, BOILING POINT DETECTION

-- DOUBLE STRIKE
ModUtil.Path.Context.Wrap("FireWeaponWithinRange", function()
  ModUtil.Path.Wrap("RandomChance", function(baseFunc, ...)
    local randomRes = false
    randomRes = baseFunc(...)
    if randomRes then
      Z.TrackBoonEffect("ZeusBonusBoltTrait")
    end
    return randomRes
  end, Z)
end, Z)
-- END DOUBLE STRIKE


-------------------------------------------------------------------------------
------------------------------- DIONYSUS --------------------------------------
-------------------------------------------------------------------------------


-- After Party
ModUtil.Path.Context.Wrap("EndEncounterEffects", function () 
  ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
    local res = baseFunc(traitName, args)
    if traitName == "CombatEncounterHealthPercentFloor" and res > 0 then
      Z.TrackBoonEffect("DoorHealTrait")
    end
    return res
  end, Z)
end, Z)

-- LowHealthDefenseTrait (Positive Outlook)

-- DionysusMaxHealthTrait (Premium Vintage)
ModUtil.Path.Wrap("AddMaxHealth", function (baseFunc, amount, source)
  baseFunc(amount, source)
  if source == "DionysusMaxHealthTrait" then
    Z.TrackBoonEffect(source)
  end
end, Z)

-------------------------------------------------------------------------------
------------------------------- APHRODITE -------------------------------------
-------------------------------------------------------------------------------

-- Life Affirmation
ModUtil.Path.Context.Wrap("ApplyConsumableItemResourceMultiplier", function ()
  Z.GetTotalHeroTraitValueWrapperGenerator(
    "HealthRewardBonus",
    function (value) return value > 1 end,
    true
  )
end, Z)

-------------------------------------------------------------------------------
------------------------------- ATHENA ----------------------------------------
-------------------------------------------------------------------------------
-- Proud Bearing (annd well items???)
ModUtil.Path.Context.Wrap("StartEncounterEffects", function ()
  Z.GetTotalHeroTraitValueWrapperGenerator(
    "StartingSuperAmount",
    function (value) return value > 0 end
  )
end, Z)

-- Athena Aid
ModUtil.Path.Wrap("AthenaShout", function (baseFunc)
  Z.TrackBoonEffect("AthenaShoutTrait")
  return baseFunc()
end, Z)

ModUtil.Path.Wrap("CheckLastStand", function (baseFunc, ...)
  Z.GetTotalHeroTraitValueWrapperGenerator(
    "LastStandHealFraction",
    function (value) return value > 0 end
  )
  if HeroHasTrait("LastStandDurationTrait") then
    Z.TrackBoonEffect("LastStandDurationTrait")
  end
  return baseFunc(...)
end, Z)



-------------------------------------------------------------------------------
------------------------------- DEMETER ---------------------------------------
-------------------------------------------------------------------------------

-- TODO: This shouldn't get tracked 2 times on selecting Nourished Soul
ModUtil.Path.Context.Wrap("CalculateHealingMultiplier", function ()
  Z.GetTotalHeroTraitValueWrapperGenerator(
    "TraitHealingBonus",
    function (value) return value > 1 end
  )
end, Z)

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
        Z.TrackBoonEffect("AresLoadCurseTrait")
      end

    elseif triggerArgs.EffectName == "ReduceDamageOutput" and not triggerArgs.Reapplied then
      if HeroHasTrait("AphroditeDurationTrait") then
        Z.TrackBoonEffect("AphroditeDurationTrait")
      end
    end
    -- TODO: Numbing Sensation should go here.
  end
}

-------------------------------------------------------------------------------
-------vc------------------------ ARTEMIS ---------------------------------------
-------------------------------------------------------------------------------
-- ModUtil.Path.Context.Wrap("DamageEnemy", function ()
--   Z.GetTotalHeroTraitValueWrapperGenerator(
--     "CriticalSuperGainAmount",
--     function (value) return value > 0 end
--   )
-- end, Z)

-------------------------------------------------------------------------------
------------------------------- HERMES ----------------------------------------
-------------------------------------------------------------------------------

-- Auto Reload
ModUtil.Path.Wrap("ReloadAmmoPresentation", function (baseFunc)
  baseFunc()
  if HeroHasTrait("AmmoReloadTrait") then
    Z.TrackBoonEffect("AmmoReloadTrait")
  end
end, Z)

-- FlurryCast
OnWeaponFired{ "RangedWeapon", 
  function ()
    if HeroHasTrait("RapidCastTrait") then
      Z.TrackBoonEffect("RapidCastTrait")
    end
  end
}
-- AmmoReclaimTrait (Quick Reload)
ModUtil.Path.Context.Wrap("DropStoredAmmo", function ()
  ModUtil.Path.Wrap("GetHeroTraitValues", function(baseFunc, source, args)
    if source == ("AmmoDropWeapons") and HeroHasTrait("AmmoReclaimTrait") then
      Z.TrackBoonEffect("AmmoReclaimTrait")
    end
    return baseFunc(source, args)
  end, Z)
end, Z)

-- Quick Recovery
ModUtil.Path.Wrap("Heal", function (baseFunc, victim, args)
  if args.SourceName == "RallyHeal" and HeroHasTrait("RushRallyTrait") then
    Z.TrackBoonEffect("RushRallyTrait")
  end
  return baseFunc(victim, args)
end, Z)

-- Greater Reflex
OnWeaponFired{ "RushWeapon",
  function ( triggerArgs )
    for k, v in pairs({"BonusDashTrait", "RushSpeedBoostTrait" }) do
      if HeroHasTrait(v) then
        Z.TrackBoonEffect(v)
      end
    end
  end
}

-- Greater Evasion
OnDodge{ "_PlayerUnit",
	function( triggerArgs )
    if HeroHasTrait("DodgeChanceTrait") then
      Z.TrackBoonEffect("DodgeChanceTrait")
    end
	end
}

-- Quick Favor
ModUtil.Path.Context.Wrap("SuperRegeneration", function()
  ModUtil.Path.Wrap("BuildSuperMeter", function(baseFunc, ...)
    if HeroHasTrait("RegeneratingSuperTrait") then
      Z.TrackBoonEffect("RegeneratingSuperTrait")
    end
    return baseFunc(...)
  end, Z)
end, Z)

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
      Z.TrackBoonEffect("MoveSpeedTrait")
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
        Z.TrackBoonEffect("HermesWeaponTrait")
      end
    end
  }
  
  OnWeaponFired{ specialWeapons,
    function ( triggerArgs )
      if HeroHasTrait("HermesSecondaryTrait") then
        Z.TrackBoonEffect("HermesSecondaryTrait")
      end
    end
  }
end)

---- DROP DATA SCALING
-- TODO - ApplyConsumableItemResourceMultiplier wrap
local getMaxHealthScalar = function ()
  if GameState.ZyruviIncremental == nil then return 1 end
  local level = Z.Data.DropData.RoomRewardMaxHealthDrop.Level or 0
  return (1 + (level - 1) * 0.1)
end

local getCoinScalar = function ()
  if GameState.ZyruviIncremental == nil then return 1 end
  local level = Z.Data.DropData.RoomRewardMoneyDrop.Level or 0
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
end, Z)


-- Side Hustle
ModUtil.Path.Wrap("AddMoney", function(baseFunc, amount, source)
  -- DebugPrint{ Text = tostring(amount) .. tostring(source)}
  if source == "Hermes Money Trait" and HeroHasTrait("ChamberGoldTrait") then
    Z.TrackBoonEffect("ChamberGoldTrait")
  elseif source == "RoomRewardMoneyDrop" then
    amount = amount  * getCoinScalar()
    Z.TrackDrop(source, amount)
  end
  return baseFunc(amount, source)
end, Z)


-- ModUtil.Path.Context.Wrap("ApplyConsumableItemResourceMultiplier", function ()
--   ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, source, args)
--     if source == "HealthRewardBonus" then
--       return baseFunc(source, args) * getMaxHealthScalar()
--     elseif source == "MoneyRewardBonus" then
--       -- TODO add coin multiplier scaling
--       return baseFunc(source, args)
--     end
--     return baseFunc(source, args)
--   end, Z)
-- end, Z)

ModUtil.Path.Wrap("AddMaxHealth", function (baseFunc, healthGained, source, args )
  args = args or {}
  source = source or {}
  if source.AddMaxHealth ~= nil then
    Z.TrackDrop("RoomRewardMaxHealthDrop", healthGained)
  end
  return baseFunc(healthGained, source, args)
end, Z)


local originalIdenticalMultipliers = {}
local originalPomScaling = TraitMultiplierData.DefaultDiminishingReturnsMultiplier

ModUtil.Path.Wrap("ProcessTraitData", function (baseFunc, args)

  ModUtil.Path.Decorate("GetProcessedValue", function (innerFunc, property, innerArgs)
    innerFunc(property, innerArgs)
  end, Z)
  ModUtil.Path.Decorate.Pop("GetProcessedValue")
end, Z)

ModUtil.Path.Wrap("AddTraitToHero", function (baseFunc, args)
  if args.TraitName and not args.TraitData then
    args.TraitData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = args.TraitName, Rarity = args.Rarity })
  end


  local traitData = args.TraitData
	local changes = {}
  if args.TraitData.PropertyChanges ~= nil then
		table.insert( changes, "PropertyChanges" )
	end
  for i, changeKey in ipairs(changes) do
    if not TraitData[args.TraitName] or not  TraitData[args.TraitName][changeKey] then
      break
    end
		for s, propertyChange in ipairs(TraitData[args.TraitName][changeKey]) do
			if propertyChange.BaseMin ~= nil or propertyChange.BaseValue ~= nil then
        -- scale pom value according to pom reward level
        local pomLevel = Z.Data.DropData.StackUpgrade.Level
        TraitMultiplierData.DefaultDiminishingReturnsMultiplier = originalPomScaling * (1 + 0.02 * (pomLevel - 1))
        DebugPrint { Text = "setting diminishing returns to " .. TraitMultiplierData.DefaultDiminishingReturnsMultiplier }
        local saveTraitData = Z.Data.BoonData[args.TraitName]
        if saveTraitData ~= nil then
          local level = saveTraitData.Level or 1

          -- cache identical multiplier changes so we don't keep changing the pom value after initial grab
          if originalIdenticalMultipliers[args.TraitName] == nil then
            DebugPrint { Text = "Setting originalIM for " .. args.TraitName  .. " to " .. propertyChange.IdenticalMultiplier.Value }
            originalIdenticalMultipliers[args.TraitName] = propertyChange.IdenticalMultiplier.Value
          end
          local val = originalIdenticalMultipliers[args.TraitName]
          -- val = -0.6 -> 0.4 base proportion
          -- level 4 => 0.4 base -> (1 + 4 * 0.05) * 0.4 = 0.48
          -- 0.48 - 1
          propertyChange.IdenticalMultiplier.Value = (1 + val) * (1 + level * 0.1) - 1
          DebugPrint { Text = val .. " " .. propertyChange.IdenticalMultiplier.Value }
        end
			end
		end
	end
  return baseFunc(args)
end, Z)