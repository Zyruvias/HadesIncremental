-- SAVE DATA SETUP
Z.InitializeSaveData = function ()
  if Z.Data.Initialized == nil then
    Z.Data.BoonData = { } -- Set Dynamically
      -- levevl, rarity bonus, experience, max points, current points
      -- TODO: Poms or hammer rarity?
    Z.Data.GodData = { 
      Zeus = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Poseidon = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Athena = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Aphrodite = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Artemis = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Ares = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Dionysus = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Hermes = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Demeter = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
      Chaos = { Level = 1, RarityBonus = 0, Experience = 0, CurrentPoints = 0, MaxPoints = 0, },
    }
    -- track acquisition of runources: health / gold
    -- meta currencies???
    Z.Data.DropData = {
      RoomRewardMoneyDrop = { Level = 1, Count = 0, Amount = 0, Experience = 0 },
      RoomRewardMaxHealthDrop = { Level = 1, Count = 0, Amount = 0, Experience = 0 },
      StackUpgrade = { Level = 1, Count = 0, Amount = 0, Experience = 0 },
    }
    -- Dynamically set / prescribed
    --[[
      Upgrade shape: {
        Name
        CostType
        Cost
        OnApplyFunction
        OnApplyFunctionArgs
        Purchased
      }
    ]]--
    Z.Data.UpgradeData = {
      
    }
    Z.Data.Currencies = {
      
    }
    Z.Data.FileOptions = {
      StartingPoint = "Fresh File"
    }
    Z.Data.Initialized = true
  end
end

ModUtil.LoadOnce(Z.InitializeSaveData)
  function ZyruTestUpgrade(args) 
    DebugPrint { Text = "Upgrade applied with args: " .. ModUtil.ToString.Deep(args)}
  end

  -- SAVE DATA UPGRADE PROCESSING
ModUtil.LoadOnce( function ( )
  if Z.Data.UpgradeData == nil then 
    return
  end

  -- debug upgrade proof of concept
  -- Z.AddUpgrade({
  --   Name = "ZyruTestUpgrade",
  --   OnApplyFunction = "ZyruTestUpgrade",
  --   OnApplyFunctionArgs = {
  --     Count = 1,
  --   },
  --   Purchased = true,
  -- }, { 
  --   SkipApply = true 
  -- })

  -- process existing upgrades
  for i, upgradeName in ipairs(Z.Data.UpgradeData) do
    local upgrade = Z.UpgradeData[upgradeName]
    if upgrade == nil then
      DebugPrint { Text = "Upgrade " .. upgradeName .. " not found in UpgradeData, removing ..."}
      Z.RemoveUpgrade(upgradeName)
    else
      -- DebugPrint { Text = ModUtil.ToString.Deep(upgrade)}
      if upgrade.OnApplyFunction ~= nil then
        _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
      end
      if upgrade.OnApplyFunctions ~= nil then
          for k, functionName in ipairs(upgrade.OnApplyFunctions) do
              local functionArgs = upgrade.OnApplyFunctionArgs[k]
              DebugPrint { Text = "Processing Savefile Upgrades: Calling " .. functionName .. " with " .. ModUtil.ToString.Deep(functionArgs)}
              _G[functionName](functionArgs)
          end
      end
    end
  end

end)

ModUtil.LoadOnce(function ( )
    DebugPrint({ Text = "LOADING ZYRUMAP SETUP" })
    Z.WhatTheFuckIsThisToBoonMap = {
      DemeterMaxChill = "MaximumChillBlast",
    }
    -- Second-to-Last runort WeaponData table -> Boon conversion
    Z.WeaponToBoonMap = {
      -- Ares
      AresSurgeWeapon = "AresShoutTrait",
      -- Poseidon
      PoseidonSurfWeapon = "PoseidonShoutTrait",
      -- Aphrodite
      AphroditeSuperCharm = "AphroditeShoutTrait",
      AphroditeMaxSuperCharm = "AphroditeShoutTrait",
      -- Artemis
      ArtemisShoutWeapon = "ArtemisShoutTrait",
      ArtemisAmmoWeapon = "ArtemisAmmoExitTrait",
      -- Demeter
      ChillRetaliate = "DemeterRetaliateTrait",
      DemeterChillKill = "InstantChillKill",
    }
    -- EffectData -> Boon Conversion, uses dynamic mapping below
    Z.EffectToBoonMap = {
      -- Poseidon
      DamageOverDistance = "SlipperyTrait",
      PoseidonCollisionBlast = "SlamExplosionTrait",
      -- Ares
      DelayedDamage = {
        MapSource = "SourceWeapon",
        AresRetaliate = "AresRetaliateTrait",
      },
      AresSurgeWeapon = "AresShoutTrait",
      -- Dionysus
      DamageOverTime = {
        MapSource = "SourceWeapon",
        -- Map the "MapSource" table to inverse l,ook-up
        RushWeapon = "DionysusRushTrait",
        DionysusShoutWeapon = "DionysusShoutTrait",
        DionysusPlagueWeapon = "DionysusSpreadTrait",
      },
      -- Demeter
      DemeterWorldChill = "MaximumChillBonusSlow",
      DemeterAmmoWind = "CastNovaTrait",
    }
    -- dynamic mapping for Effect Data
    for i, weaponName in ipairs(WeaponSets.HeroAllWeapons) do
      local weaponTable = { weaponName }
      if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
        weaponTable = ConcatTableValues({ weaponName }, WeaponSets.LinkedWeaponUpgrades[weaponName])
      end
        
      if Contains({ "SwordWeapon", "SpearWeapon", "ShieldWeapon", "BowWeapon", "GunWeapon", "FistWeapon" }, weaponName) then
        ModUtil.Table.Merge(Z.EffectToBoonMap.DamageOverTime, ToLookupValue(weaponTable, "DionysusWeaponTrait"))
        ModUtil.Table.Merge(Z.EffectToBoonMap.DelayedDamage, ToLookupValue(weaponTable, "AresWeaponTrait"))
      elseif Contains({ "SwordParry","BowSplitShot","SpearWeaponThrow", "ShieldThrow", "FistWeaponSpecial", "GunGrenadeToss" }, weaponName) then
        ModUtil.Table.Merge(Z.EffectToBoonMap.DamageOverTime, ToLookupValue(weaponTable, "DionysusSecondaryTrait"))
        ModUtil.Table.Merge(Z.EffectToBoonMap.DelayedDamage, ToLookupValue(weaponTable, "AresSecondaryTrait"))
      end
  
    end
  
    -- Projectile -> Boon Mapping
    Z.ProjectileToBoonMap = {
      -- Zeus
      ChainLightning = "ZeusWeaponTrait",
      LightningStrikeSecondary = "ZeusSecondaryTrait",
      LightningDash = "ZeusRushTrait",
      LightningStrikeX = "ZeusShoutTrait",
      LightningPerfectDash = "PerfectDashBoltTrait",
      ZeusLegendaryWeapon = "ZeusChargedBoltTrait",
      LightningStrikeRetaliate = "RetaliateWeaponTrait",
      ZeusAttackBolt = "ZeusLightningDebuff",
      -- Aphrodite
      DeathAreaWeakenAphrodite = "AphroditeDeathTrait",
      AreaWeakenAphrodite = "AphroditeRetaliateTrait",
      -- Artemis
      ArtemisLegendary = "ArtemisSupportingFireTrait",
      -- Demeter
      DemeterMaxChill = "MaximumChillBlast",
      -- Athena
      MagicShieldRetaliate = "AthenaRetaliateTrait"
    }
  
    Z.SuperTraitMap = {
      SuperGainMultiplier = "SuperGenerationTrait", -- zeus
      DefensiveSuperGainMultiplier = "DefensiveSuperGenerationTrait", -- Poseidon
      AresShoutBuff = "OnWrathDamageBuffTrait", -- zeus billowing
      HermesWrathBuff = "HermesShoutDodge" -- Second Wind
    }
    
    Z.DamageModifiersToBoonMap = {
      ---------------
      -- OFFENSIVE --
      ---------------
      IncreaseDamageTaken = "AphroditeWeakenTrait",
      
      ZeroAmmoBonusTrait = "ZeroAmmoBonusTrait",
      ---------------
      -- DEFENSIVE --
      ---------------
      ProximityArmorTrait = "ProximityArmorTrait",
      EnemyDamageTrait = "EnemyDamageTrait",
      TrapDamageTrait = "TrapDamageTrait",
      WinePuddleDefense = "DionysusDefenseTrait",
      LowHealthDefenseTrait = "LowHealthDefenseTrait",
    }
    
    -- TODO: Generic GetHeroTraitValues Map for single use effects
    -- TODO: Convert other things to this map if they exist elsewhere
    Z.GetHeroTraitValuesMap = {
      StartingSuperAmount = "PreloadSuperGenerationTrait",
      HealthRewardBonus = "HealthRewardBonusTrait",
      TraitHealingBonus = "HealingPotencyTrait",
      LastStandHealFraction = "LastStandHealTrait",
      CriticalSuperGainAmount = "CriticalSuperGenerationTrait",
    }

    -- Used to track boons whose effects universally apply to a given source that
    -- otherwise only appear in engine property changes
    Z.HailMaryMap = {
      -- Aphrodite
      AphroditeRangedTrait = { "AphroditeRangedBonusTrait" },
      -- Zeus
      ChainLightning = { "ZeusBonusBounceTrait" },
      LightningStrikeSecondary = { "ZeusBoltAoETrait" },
      LightningDash = { "ZeusBoltAoETrait" },
      LightningStrikeX = { "ZeusBoltAoETrait" },
      LightningPerfectDash = { "ZeusBoltAoETrait" },
      ZeusLegendaryWeapon = { "ZeusBonusBounceTrait" },
      LightningStrikeRetaliate = { "ZeusBoltAoETrait" },
      ZeusAttackBolt = { "ZeusBoltAoETrait" },
      ZeusRangedTrait = { "ZeusBonusBounceTrait" },
      -- Ares
      AresRushTrait = { "AresDragTrait", "AresCursedRiftTrait", "AresAoETrait" },
      AresRangedTrait = { "AresDragTrait", "AresCursedRiftTrait", "AresAoETrait" },
      AresSurgeWeapon = { "AresDragTrait", "AresCursedRiftTrait", "AresAoETrait" },
      -- Demeter
      DemeterRangedTrait = { "DemeterRangedBonusTrait" },
      -- Dionysus
      DamageOverTime = { "DionysusSlowTrait" }
    }

    Z.BoonExperienceFactor = {
      RetaliateWeaponTrait = 1,
      SuperGenerationTrait = 1,
      DefensiveSuperGenerationTrait = 1,
      ZeusBoltAoETrait =  1,
      ZeusBonusBoltTrait =  1,
      ZeusBonusBounceTrait =  1,
      ZeusWeaponTrait = 1,
      ZeusSecondaryTrait = 1,
      ZeusRangedTrait = 1,
      ZeusLightningDebuff = 1,
      PerfectDashBoltTrait = 1,
      ZeusChargedBoltTrait = 1,
      ZeusRushTrait = 1,
      ZeusShoutTrait = 1,
      WrathDamageBuffTrait = 1,
      RetainTempHealthTrait = 1,
      AthenaWeaponTrait = 1,
      AthenaSecondaryTrait = 1,
      AthenaRangedTrait = 1,
      AthenaRushTrait = 1,
      AthenaShieldTrait = 1,
      AthenaBackstabDebuffTrait = 1,
      AthenaShoutTrait = 1,
      EnemyDamageTrait = 1,
      TrapDamageTrait = 1,
      LastStandHealTrait = 1,
      LastStandDurationTrait = 1,
      PreloadSuperGenerationTrait =  1,
      AthenaRetaliateTrait = 1,
      ShieldHitTrait = 1,
      PoseidonWeaponTrait = 1,
      PoseidonSecondaryTrait = 1,
      PoseidonRangedTrait = 1,
      ShieldLoadAmmo_PoseidonRangedTrait =  1,
      PoseidonRushTrait = 1,
      PoseidonShoutTrait = 1,
      PoseidonShoutDurationTrait = 1,
      BonusCollisionTrait = 1,
      SlamStunTrait = 1,
      SlamExplosionTrait = 1,
      EncounterStartOffenseBuffTrait = 1,
      OnEnemyDeathDefenseBuffTrait = 1,
      SlipperyTrait = 1,
      BossDamageTrait = 1,
      DoubleCollisionTrait = 1,
      FishingTrait = 1,
      HealthRewardBonusTrait = 1,
      RoomRewardBonusTrait = 1,
      ReducedEnemySpawnsTrait = 1,
      UnusedWeaponBonusTrait = 1,
      UnusedWeaponBonusTraitAddGems = 1,
      HealthBonusTrait = 1,
      PoseidonPickedUpMinorLootTrait = 1,
      RoomRewardMaxHealthTrait = 1,
      RoomRewardEmptyMaxHealthTrait = 1,
      ArtemisWeaponTrait = 1,
      ArtemisSecondaryTrait = 1,
      ArtemisRangedTrait = 1,
      ArtemisRushTrait = 1,
      ArtemisCriticalTrait = 1,
      CriticalBufferMultiplierTrait = 1,
      CriticalSuperGenerationTrait = 1,
      CriticalStunTrait = 1,
      ArtemisShoutTrait = 1,
      ArtemisShoutBuffTrait = 1,
      MarkedDropGoldTrait = 1,
      ArtemisBonusProjectileTrait = 1,
      MoreAmmoTrait = 1,
      RoomAmmoTrait = 1,
      UnstoredAmmoDamageTrait = 1,
      AmmoReloadTrait = 1,
      AmmoReclaimTrait = 1,
      CritBonusTrait = 1,
      ArtemisAmmoExitTrait = 1,
      CritVulnerabilityTrait = 1,
      ArtemisSupportingFireTrait = 1,
      AphroditeDurationTrait = 1,
      AphroditePotencyTrait = 1,
      AphroditeWeaponTrait = 1,
      AphroditeSecondaryTrait = 1,
      AphroditeRangedTrait = 1,
      ShieldLoadAmmo_AphroditeRangedTrait = 1,
      AphroditeRangedBonusTrait = 1,
      CastBackstabTrait = 1,
      AphroditeRushTrait = 1,
      AphroditeShoutTrait = 1,
      AphroditeWeakenTrait = 1,
      AphroditeRetaliateTrait = 1,
      AphroditeDeathTrait = 1,
      ProximityArmorTrait = 1,
      CharmTrait = 1,
      AresWeaponTrait = 1,
      AresSecondaryTrait = 1,
      OnSpawnSwordTrait = 1,
      AresRangedTrait = 1,
      AresRushTrait = 1,
      AresShoutTrait = 1,
      AresAoETrait = 1,
      AresDragTrait = 1,
      AresLoadCurseTrait = 1,
      AresLongCurseTrait = 1,
      AresCursedRiftTrait = 1,
      AresRetaliateTrait = 1,
      IncreasedDamageTrait = 1,
      OnWrathDamageBuffTrait = 1,
      LastStandDamageBonusTrait = 1,
      OnEnemyDeathDamageInstanceBuffTrait = 1,
      DionysusSpreadTrait = 1,
      DionysusSlowTrait = 1,
      DionysusAoETrait = 1,
      DionysusDefenseTrait = 1,
      GiftHealthTrait = 1,
      DionysusMaxHealthTrait = 1,
      DionysusWeaponTrait = 1,
      DionysusSecondaryTrait = 1,
      DionysusRangedTrait = 1,
      ShieldLoadAmmo_DionysusRangedTrait =  1,
      ShieldLoadAmmo_AthenaRangedTrait = 1,
      ShieldLoadAmmo_ArtemisRangedTrait = 1,
      ShieldLoadAmmo_DemeterRangedTrait = 1,
      ShieldLoadAmmo_ZeusRangedTrait = 1,
      ShieldLoadAmmo_AresRangedTrait = 1,
      DionysusRushTrait = 1,
      AmmoFieldTrait = 1,
      AmmoBoltTrait = 1,
      DionysusShoutTrait = 1,
      DionysusPoisonPowerTrait = 1,
      DoorHealTrait = 1,
      DemeterWeaponTrait = 1,
      DemeterSecondaryTrait = 1,
      DemeterRangedTrait = 1,
      DemeterRangedBonusTrait = 1,
      DemeterRushTrait = 1,
      DemeterShoutTrait = 1,
      HealingPotencyTrait = 1,
      CastNovaTrait = 1,
      HarvestBoonTrait = 1,
      ZeroAmmoBonusTrait = 1,
      DemeterRetaliateTrait = 1,
      MagnetismTrait = 1,
      BonusDashTrait = 1,
      RapidRushTrait = 1,
      DeathDefianceFreezeTimeTrait = 1,
      FreezeTimeDashTrait = 1,
      CollisionTouchTrait = 1,
      DodgeChanceTrait = 1,
      RapidCastTrait = 1,
      RushSpeedBoostTrait = 1,
      MoveSpeedTrait = 1,
      RushRallyTrait = 1,
      HermesBonusProjectilesTrait = 1,
      HermesRangedTrait = 1,
      HermesPlannedRushTrait = 1,
      HermesPlannedRushTrait2 = 1,
      HermesWeaponTrait = 1,
      HermesSecondaryTrait = 1,
      RegeneratingSuperTrait = 1,
      ChamberGoldTrait = 1,
      SpeedDamageTrait = 1,
      MoneyMultiplierTrait = 1,
      ChaosBlessingMeleeTrait = 1,
      ChaosBlessingRangedTrait = 1,
      ChaosBlessingAlphaStrikeTrait = 1,
      ChaosBlessingBackstabTrait = 1,
      ChaosBlessingAmmoTrait = 1,
      ChaosBlessingMaxHealthTrait = 1,
      ChaosBlessingBoonRarityTrait = 1,
      ChaosBlessingTroveTrait = 1,
      ChaosBlessingMoneyTrait = 1,
      ChaosBlessingGemTrait = 1,
      ChaosBlessingMetapointTrait =  1,
      ChaosBlessingTrapDamageTrait = 1,
      ChaosBlessingSecretTrait = 1,
      ChaosBlessingHealTrait = 1,
      ChaosBlessingExtraChanceTrait = 1,
      ChaosBlessingSecondaryTrait = 1,
      ChaosBlessingDashAttackTrait = 1,
      FountainDamageBonusTrait = 1,
    }

    Z.BoonExperiencePerUse = {
      RetaliateWeaponTrait = 1,
      SuperGenerationTrait = 1,
      DefensiveSuperGenerationTrait = 1,
      ZeusBoltAoETrait =  1,
      ZeusBonusBoltTrait =  1,
      ZeusBonusBounceTrait =  1,
      ZeusWeaponTrait = 1,
      ZeusSecondaryTrait = 1,
      ZeusRangedTrait = 1,
      PerfectDashBoltTrait = 1,
      ZeusChargedBoltTrait = 1,
      ZeusRushTrait = 1,
      ZeusShoutTrait = 1,
      ZeusLightningDebuff = 1,
      WrathDamageBuffTrait = 1,
      RetainTempHealthTrait = 1,
      AthenaWeaponTrait = 1,
      AthenaSecondaryTrait = 1,
      AthenaRangedTrait = 1,
      AthenaRushTrait = 1,
      AthenaShieldTrait = 1,
      AthenaBackstabDebuffTrait = 1,
      AthenaShoutTrait = 1,
      EnemyDamageTrait = 1,
      TrapDamageTrait = 1,
      LastStandHealTrait = 1,
      LastStandDurationTrait = 1,
      PreloadSuperGenerationTrait =  1,
      AthenaRetaliateTrait = 1,
      ShieldHitTrait = 1,
      PoseidonWeaponTrait = 1,
      PoseidonSecondaryTrait = 1,
      PoseidonRangedTrait = 1,
      ShieldLoadAmmo_PoseidonRangedTrait =  1,
      PoseidonRushTrait = 1,
      PoseidonShoutTrait = 1,
      PoseidonShoutDurationTrait = 1,
      BonusCollisionTrait = 1,
      SlamStunTrait = 1,
      SlamExplosionTrait = 1,
      EncounterStartOffenseBuffTrait = 1,
      OnEnemyDeathDefenseBuffTrait = 1,
      SlipperyTrait = 1,
      BossDamageTrait = 1,
      DoubleCollisionTrait = 1,
      FishingTrait = 1,
      HealthRewardBonusTrait = 1,
      RoomRewardBonusTrait = 1,
      ReducedEnemySpawnsTrait = 1,
      UnusedWeaponBonusTrait = 1,
      UnusedWeaponBonusTraitAddGems = 1,
      HealthBonusTrait = 1,
      PoseidonPickedUpMinorLootTrait = 1,
      RoomRewardMaxHealthTrait = 1,
      RoomRewardEmptyMaxHealthTrait = 1,
      ArtemisWeaponTrait = 1,
      ArtemisSecondaryTrait = 1,
      ArtemisRangedTrait = 1,
      ArtemisRushTrait = 1,
      ArtemisCriticalTrait = 1,
      CriticalBufferMultiplierTrait = 1,
      CriticalSuperGenerationTrait = 1,
      CriticalStunTrait = 1,
      ArtemisShoutTrait = 1,
      ArtemisShoutBuffTrait = 1,
      MarkedDropGoldTrait = 1,
      ArtemisBonusProjectileTrait = 1,
      MoreAmmoTrait = 1,
      RoomAmmoTrait = 1,
      UnstoredAmmoDamageTrait = 1,
      AmmoReloadTrait = 1,
      AmmoReclaimTrait = 1,
      CritBonusTrait = 1,
      ArtemisAmmoExitTrait = 1,
      CritVulnerabilityTrait = 1,
      ArtemisSupportingFireTrait = 1,
      AphroditeDurationTrait = 1,
      AphroditePotencyTrait = 1,
      AphroditeWeaponTrait = 1,
      AphroditeSecondaryTrait = 1,
      AphroditeRangedTrait = 1,
      ShieldLoadAmmo_AphroditeRangedTrait = 1,
      AphroditeRangedBonusTrait = 1,
      CastBackstabTrait = 1,
      AphroditeRushTrait = 1,
      AphroditeShoutTrait = 1,
      AphroditeWeakenTrait = 1,
      AphroditeRetaliateTrait = 1,
      AphroditeDeathTrait = 1,
      ProximityArmorTrait = 1,
      CharmTrait = 1,
      AresWeaponTrait = 1,
      AresSecondaryTrait = 1,
      OnSpawnSwordTrait = 1,
      AresRangedTrait = 1,
      AresRushTrait = 1,
      AresShoutTrait = 1,
      AresAoETrait = 1,
      AresDragTrait = 1,
      AresLoadCurseTrait = 1,
      AresLongCurseTrait = 1,
      AresCursedRiftTrait = 1,
      AresRetaliateTrait = 1,
      IncreasedDamageTrait = 1,
      OnWrathDamageBuffTrait = 1,
      LastStandDamageBonusTrait = 1,
      OnEnemyDeathDamageInstanceBuffTrait = 1,
      DionysusSpreadTrait = 1,
      DionysusSlowTrait = 1,
      DionysusAoETrait = 1,
      DionysusDefenseTrait = 1,
      GiftHealthTrait = 1,
      DionysusMaxHealthTrait = 1,
      DionysusWeaponTrait = 1,
      DionysusSecondaryTrait = 1,
      DionysusRangedTrait = 1,
      ShieldLoadAmmo_DionysusRangedTrait =  1,
      ShieldLoadAmmo_AthenaRangedTrait = 1,
      ShieldLoadAmmo_ArtemisRangedTrait = 1,
      ShieldLoadAmmo_DemeterRangedTrait = 1,
      ShieldLoadAmmo_ZeusRangedTrait = 1,
      ShieldLoadAmmo_AresRangedTrait = 1,
      DionysusRushTrait = 1,
      AmmoFieldTrait = 1,
      AmmoBoltTrait = 1,
      DionysusShoutTrait = 1,
      DionysusPoisonPowerTrait = 1,
      DoorHealTrait = 1,
      DemeterWeaponTrait = 1,
      DemeterSecondaryTrait = 1,
      DemeterRangedTrait = 1,
      DemeterRangedBonusTrait = 1,
      DemeterRushTrait = 1,
      DemeterShoutTrait = 1,
      HealingPotencyTrait = 1,
      CastNovaTrait = 1,
      HarvestBoonTrait = 1,
      ZeroAmmoBonusTrait = 1,
      DemeterRetaliateTrait = 1,
      MagnetismTrait = 1,
      BonusDashTrait = 1,
      RapidRushTrait = 1,
      DeathDefianceFreezeTimeTrait = 1,
      FreezeTimeDashTrait = 1,
      CollisionTouchTrait = 1,
      DodgeChanceTrait = 1,
      RapidCastTrait = 1,
      RushSpeedBoostTrait = 1,
      MoveSpeedTrait = 1,
      RushRallyTrait = 1,
      HermesBonusProjectilesTrait = 1,
      HermesRangedTrait = 1,
      HermesPlannedRushTrait = 1,
      HermesPlannedRushTrait2 = 1,
      HermesWeaponTrait = 1,
      HermesSecondaryTrait = 1,
      RegeneratingSuperTrait = 1,
      ChamberGoldTrait = 1,
      SpeedDamageTrait = 1,
      MoneyMultiplierTrait = 1,
      ChaosBlessingMeleeTrait = 1,
      ChaosBlessingRangedTrait = 1,
      ChaosBlessingAlphaStrikeTrait = 1,
      ChaosBlessingBackstabTrait = 1,
      ChaosBlessingAmmoTrait = 1,
      ChaosBlessingMaxHealthTrait = 1,
      ChaosBlessingBoonRarityTrait = 1,
      ChaosBlessingTroveTrait = 1,
      ChaosBlessingMoneyTrait = 1,
      ChaosBlessingGemTrait = 1,
      ChaosBlessingMetapointTrait =  1,
      ChaosBlessingTrapDamageTrait = 1,
      ChaosBlessingSecretTrait = 1,
      ChaosBlessingHealTrait = 1,
      ChaosBlessingExtraChanceTrait = 1,
      ChaosBlessingSecondaryTrait = 1,
      ChaosBlessingDashAttackTrait = 1,
      FountainDamageBonusTrait = 1,
    }

    Z.BoonsToIgnore = {
      AresHermesSynergyTrait = true
    }

end)




-- audio mappings
ModUtil.LoadOnce(function ( ) 
  Z.BoonLevelUpVoiceLines = {
    Zeus = {
      -- Why, I am honored!
      { Cue = "/VO/Zeus_0088" },
      -- This pleases me.
      { Cue = "/VO/Zeus_0089" },
      -- Oh I feel very proud!
      { Cue = "/VO/Zeus_0167" },
      -- I am most grateful.
      { Cue = "/VO/Zeus_0087" },
      -- Thanks to you, young man.
      { Cue = "/VO/Zeus_0090" },
      -- I shall remember this, Nephew.
      { Cue = "/VO/Zeus_0091" },
      -- Bless you, Zagreus.
      { Cue = "/VO/Zeus_0092" },
    },
    Poseidon = {
      -- I'm ever-grateful, Nephew!
		  { Cue = "/VO/Poseidon_0085", },
      
		  -- I'm proud to call you nephew, little Nephew!
		  { Cue = "/VO/Poseidon_0089", },
      -- Ah, hahaha, yes!
      { Cue = "/VO/Poseidon_0205", },
      -- Haha, just as I thought!
      { Cue = "/VO/Poseidon_0202", },
    },
    Athena = {
      
      -- You honor me.
      { Cue = "/VO/Athena_0087", },
      -- I trusted I could count on you.
      { Cue = "/VO/Athena_0189", },
      -- Very good. That is, for me, at least.
      { Cue = "/VO/Athena_0191", },
    },
    Ares = {
      -- I shall remember this.
      { Cue = "/VO/Ares_0083", RequiredPlayed = { "/VO/Ares_0186" } },
      -- A thoughtful gesture.
      { Cue = "/VO/Ares_0084", RequiredPlayed = { "/VO/Ares_0186" } },
      -- You're wise to side with me.
      { Cue = "/VO/Ares_0183", RequiredPlayed = { "/VO/Ares_0186" } },
      -- Let us wage war together, then.
      { Cue = "/VO/Ares_0184", RequiredPlayed = { "/VO/Ares_0186" } },
      -- Most intriguing.
      { Cue = "/VO/Ares_0080", },
    },
    Aphrodite = {
      -- Your heart shall never carry you astray.
      { Cue = "/VO/Aphrodite_0164", },
      -- I'm grateful, deArest.
      { Cue = "/VO/Aphrodite_0090", },
      -- I won't forget this, not anytime soon!
      { Cue = "/VO/Aphrodite_0094", },
      -- I very much appreciate it.
      { Cue = "/VO/Aphrodite_0095", },
      -- I'm positively moved!
      { Cue = "/VO/Aphrodite_0096", },
      -- I knew your heart was true!
      { Cue = "/VO/Aphrodite_0160", },
    },
    Artemis = {
      -- Hey thanks!
      { Cue = "/VO/Artemis_0083", },
      -- I'm grateful.
      { Cue = "/VO/Artemis_0085", },
      -- Bless you Zagreus.
      { Cue = "/VO/Artemis_0087", },
      -- I won't forget this.
      { Cue = "/VO/Artemis_0088", },
      -- Right on the mark!
      { Cue = "/VO/Artemis_0173", },
    },
    Dionysus = {
      -- Hey cheers man!
      { Cue = "/VO/Dionysus_0077", },
      -- Hey now that is something, yeah!
      { Cue = "/VO/Dionysus_0079", },
      -- I can't say no to that!
      { Cue = "/VO/Dionysus_0080", },
      -- I owe you one man!
      { Cue = "/VO/Dionysus_0081", },
      -- Cheers, I'll take it man!
      { Cue = "/VO/Dionysus_0082", },
      -- Oh yeah I dig it man!
      { Cue = "/VO/Dionysus_0083", },
      -- Hahaha, don't you know it, man!
      { Cue = "/VO/Dionysus_0171" },
      -- Oh we are going to have a feast tonight!
      { Cue = "/VO/Dionysus_0172" },
      -- Yeaaah, man, you know what it's all about!
      { Cue = "/VO/Dionysus_0174" },
      -- Hah, cheers to you, then, man!
      { Cue = "/VO/Dionysus_0175" },
    },
    Demeter = {
      -- Ah yes, indeed.
      { Cue = "/VO/Demeter_0171", },
      -- I'm grateful, Zagreus.
      { Cue = "/VO/Demeter_0173", },
      -- You have my gratitude.
      { Cue = "/VO/Demeter_0174", },
      -- Well done, my little sprout.
      { Cue = "/VO/Demeter_0190", },
    },
    Hermes = {
      -- You got it!
      { Cue = "/VO/Hermes_0146" },
      -- You're the boss!
      { Cue = "/VO/Hermes_0147" },
    }
  }

  Z.DropExperienceFactor = {
    RoomRewardMoneyDrop = 1,
    RoomRewardMaxHealthDrop = 4,
    StackUpgrade = 1,
  }

  Z.DropLevelUpVoiceLines = {
    RoomRewardMoneyDrop = {
        -- Haaahhhhh....
        { Cue = "/VO/Charon_0010" },
        -- Mmmrrrrnnn....
        { Cue = "/VO/Charon_0011" },
        -- Hrrnmmmm....
        { Cue = "/VO/Charon_0012" },
        -- Khhhrrrrr....
        { Cue = "/VO/Charon_0013" },
        -- Heeehhhhhhh....
        { Cue = "/VO/Charon_0014" },
        -- Hhrrrrnneehhhh....
        { Cue = "/VO/Charon_0015" },
        -- Urrrrrrgggghhh...
        { Cue = "/VO/Charon_0016" },
        -- Hrrrnnnhh....
        { Cue = "/VO/Charon_0017" },
        -- Nnnnrrrrrhhh....
        { Cue = "/VO/Charon_0018" },
        -- Hnnnggghhhh....
        { Cue = "/VO/Charon_0019" },
        -- Hohhhh....
        { Cue = "/VO/Charon_0020" },
    },
    StackUpgrade = {
      -- TOODO: Persephone's voicelines
      -- Well done, Zagreus.
      { Cue = "/VO/Persephone_0319" },
      -- Excellent work, my son.
      { Cue = "/VO/Persephone_0320" },
      -- Nicely done!
      { Cue = "/VO/Persephone_0287" },
      -- Ooh look at that!
      { Cue = "/VO/Persephone_0288" },
    },
    RoomRewardMaxHealthDrop = {
      
			-- -- Good for the health.
			-- { Cue = "/VO/ZagreusField_0389", RequiredPlayed = { "/VO/ZagreusField_0737" } },
			-- -- Vitality.
			-- { Cue = "/VO/ZagreusField_4000" },
			-- -- That's life.
			-- { Cue = "/VO/ZagreusField_4001" },

      -- Good.
      { Cue = "/VO/ZagreusHome_2376" },
      -- Mm-hm.
      { Cue = "/VO/ZagreusHome_2377" },
      -- Nice.
      { Cue = "/VO/ZagreusHome_2382" },
      -- Not bad.
      { Cue = "/VO/ZagreusHome_2383" },
      -- Not too bad.
      { Cue = "/VO/ZagreusHome_2384" },
    }
  }
end )

-- mirror of night changes
-- TODO: tooltip changes
ModUtil.Path.Wrap("AddResource", function ( baseFunc, name, amount, source, args )
  -- Olympian Favor is being reinterpreted as a metareward multiplier
  local multiplier = 1 + GetNumMetaUpgrades( "RareBoonDropMetaUpgrade" ) * ( MetaUpgradeData.RareBoonDropMetaUpgrade.ChangeValue - 1 )
  local finalAmount = round(multiplier * amount)
  DebugPrint { Text = "Olympian Favor Metareward Multiplier: " .. multiplier .. " * " .. amount .. " = " .. (finalAmount)}
  return baseFunc(name, finalAmount, source, args)
end, Z)

-- enemy data: newEnemy.HealthMultiplier
ModUtil.Path.Wrap("SetupEnemyObject", function (baseFunc, newEnemy, currentRun, args)
  local difficultyModifier = Z.DifficultyModifier or 1
  newEnemy.HealthMultiplier = (newEnemy.HealthMultiplier or 1) * difficultyModifier
  -- armor
  if newEnemy.HealthBuffer ~= nil and newEnemy.HealthBuffer > 0 then
		newEnemy.HealthBufferMultiplier = (newEnemy.HealthBufferMultiplier or 1) * difficultyModifier
	end

  -- TODO: damage

  return baseFunc(newEnemy, currentRun, args)
end, Z)

local function ComputeDifficultyModifier (fileDifficulty, property) 
  local fileDifficultyMap = {
    EASY = 1.01,
    MEDIUM = 1.025,
    HARD = 1.05,
    HELL = 1.07
  }
  local difficultyScalar = fileDifficultyMap[fileDifficulty] or 1
  -- if property == "Cost" then
  --   difficultyScalar = 1 + (difficultyScalar - 1) / 2
  -- end
  return math.pow(difficultyScalar, TableLength(GameState.RunHistory))
end

ModUtil.Path.Wrap("StartNewRun", function (baseFunc, ...)
  local run = baseFunc(...)

  -- Add enemy damage modifier to Zagreus
  -- thread(function ( ) 
    Z.DifficultyModifier = 1
    -- Z.DifficultyModifier = ComputeDifficultyModifier("EASY")
    AddIncomingDamageModifier(CurrentRun.Hero, {
      Name = "ZyruIncremental",
      GlobalMultiplier = Z.DifficultyModifier
    })
  -- end)

  return run
end, Z)

-- OnAnyLoad{ function ( )
--   -- Z.DifficultyModifier = ComputeDifficultyModifier("EASY")
--   Z.DifficultyModifier = 1
-- end }

function Z.InitializeEpilogueStartSaveData()
  -- Max All NPC Hearts
  GameState.Gift = {
    NPC_Dusa_01 = {Value = 10, NewTraits = {}},
    NPC_Hades_01 = {Value = 5, NewTraits = {}},
    NPC_Skelly_01 = {Value = 9, NewTraits = {}},
    AphroditeUpgrade = {Value = 7, NewTraits = {}},
    AresUpgrade = {Value = 7, NewTraits = {}},
    NPC_FurySister_01 = {Value = 10, NewTraits = {}},
    NPC_Nyx_01 = {Value = 9, NewTraits = {}},
    NPC_Charon_01 = {Value = 7, NewTraits = {}},
    PC_Thanatos_01 = {Value = 10, NewTraits = {}},
    NPC_Orpheus_01 = {Value = 8, NewTraits = {}},
    NPC_Persephone_Home_01 = {Value = 9, NewTraits = {}},
    NPC_Eurydice_01 = {Value = 8, NewTraits = {}},
    NPC_Patroclus_01 = {Value = 8, NewTraits = {}},
    DemeterUpgrade = {Value = 7, NewTraits = {}},
    HermesUpgrade = {Value = 8, NewTraits = {}},
    NPC_Sisyphus_01 = {Value = 9, NewTraits = {}},
    TrialUpgrade = {Value = 8, NewTraits = {}},
    ArtemisUpgrade = {Value = 7, NewTraits = {}},
    NPC_Achilles_01 = {Value = 9, NewTraits = {}},
    ZeusUpgrade = {Value = 7, NewTraits = {}},
    PoseidonUpgrade = {Value = 7, NewTraits = {}},
    AthenaUpgrade = {Value = 7, NewTraits = {}},
    NPC_Cerberus_01 = {Value = 9, NewTraits = {}},
    NPC_Hypnos_01 = {Value = 8, NewTraits = {}},
    DionysusUpgrade = {Value = 7, NewTraits = {}}
  }
  -- Unlock All Keepsakes
  GameState.KeepsakeChambers = {
    ForceZeusBoonTrait = 0,
    ShopDurationTrait = 0,
    LifeOnUrnTrait = 0,
    ForceAthenaBoonTrait = 0,
    ForceAresBoonTrait = 0,
    DistanceDamageTrait = 0,
    MaxHealthKeepsakeTrait = 0,
    HadesShoutKeepsake = 0,
    ReincarnationTrait = 0,
    ShieldBossTrait = 0,
    ForceArtemisBoonTrait = 0,
    FastClearDodgeBonusTrait = 0,
    BackstabAlphaStrikeTrait = 0,
    ChamberStackTrait = 0,
    ForceDionysusBoonTrait = 0,
    DirectionalArmorTrait = 0,
    ShieldAfterHitTrait = 0,
    ForceDemeterBoonTrait = 0,
    ChaosBoonTrait = 0,
    ForcePoseidonBoonTrait = 0,
    BonusMoneyTrait = 0,
    PerfectClearDamageBonusTrait = 0,
    ForceAphroditeBoonTrait = 0,
    LowHealthDamageTrait = 0,
    VanillaTrait = 0
  }
  -- Unlock All Aspects
  GameState.WeaponUnlocks = {
    GunWeapon = {1, 1, 1, 1},
    SpearWeapon = {1, 1, 1, 1},
    FistWeapon = {1, 1, 1, 1},
    SwordWeapon = {1, 1, 1, 1},
    BowWeapon = {1, 1, 1, 1},
    ShieldWeapon = {1, 1, 1, 1}
  }
  GameState.WeaponsUnlocked = {
    GunWeapon = true,
    SpearWeapon = true,
    FistWeapon = true,
    SwordWeapon = true,
    BowWeapon = true,
    ShieldWeapon = true
  }
  GameState.WeaponsTouched = {
    GunWeapon = true,
    SpearWeapon = true,
    FistWeapon = true,
    SwordWeapon = true,
    BowWeapon = true,
    ShieldWeapon = true
  }
  -- Unlock Assists
	GameState.AssistUnlocks = {
    SisyphusAssistTrait = 4,
    ThanatosAssistTrait = 4,
    FuryAssistTrait = 4,
    DusaAssistTrait = 4,
    AchillesPatroclusAssistTrait = 4,
    SkellyAssistTrait = 4
  }
  -- Hidden Aspects
  GameState.SeenWeaponUnlocks = {
    BowWeapon4 = true,
    SwordWeapon4 = true,
    FistWeapon4 = true,
    GunWeapon4 = true,
    ShieldWeapon4 = true,
    SpearWeapon4 = true
  }
  TextLinesRecord["NyxRevealsArthurAspect01"] = true
  TextLinesRecord["AchillesRevealsGuanYuAspect01"] = true
  TextLinesRecord["ZeusRevealsLuciferAspect01"] = true
  TextLinesRecord["ArtemisRevealsRamaAspect01"] = true
  TextLinesRecord["ChaosRevealsBeowulfAspect01"] = true
  TextLinesRecord["MinotaurRevealsGilgameshAspect01"] = true
  -- Voice Lines
  -- Mirror Unlocks
  GameState.MetaUpgradeStagesUnlocked = 4
  GameState.MetaUpgradesUnlocked = {
    FirstStrikeMetaUpgrade = true,
    MoneyMetaUpgrade = true,
    NoInvulnerabilityShrineUpgrade = true,
    StoredAmmoSlowMetaUpgrade = true,
    EpicHeroicBoonMetaUpgrade = true,
    EnemySpeedShrineUpgrade = true,
    BossDifficultyShrineUpgrade = true,
    RerollPanelMetaUpgrade = true,
    ExtraChanceMetaUpgrade = true,
    ShopPricesShrineUpgrade = true,
    BiomeSpeedShrineUpgrade = true,
    MinibossCountShrineUpgrade = true,
    DoorHealMetaUpgrade = true,
    MetaUpgradeStrikeThroughShrineUpgrade = true,
    MetaPointCapShrineUpgrade = true,
    ForceSellShrineUpgrade = true,
    ReducedLootChoicesShrineUpgrade = true,
    ExtraChanceReplenishMetaUpgrade = true,
    StoredAmmoVulnerabilityMetaUpgrade = true,
    StaminaMetaUpgrade = true,
    HealthMetaUpgrade = true,
    GodEnhancementMetaUpgrade = true,
    RerollMetaUpgrade = true,
    MetaRewardMultiplierMetaUpgrade = true,
    ExtraChanceWrathMetaUpgrade = true,
    UnstoredAmmoVulnerabilityMetaUpgrade = true,
    HighHealthDamageMetaUpgrade = true,
    BackstabMetaUpgrade = true,
    EpicBoonDropMetaUpgrade = true,
    EnemyCountShrineUpgrade = true,
    HealingReductionShrineUpgrade = true,
    InterestMetaUpgrade = true,
    EnemyHealthShrineUpgrade = true,
    RareBoonDropMetaUpgrade = true,
    AmmoMetaUpgrade = true,
    EnemyDamageShrineUpgrade = true,
    ReloadAmmoMetaUpgrade = true,
    RunProgressRewardMetaUpgrade = true,
    PerfectDashMetaUpgrade = true,
    HardEncounterShrineUpgrade = true,
    EnemyShieldShrineUpgrade = true,
    DarknessHealMetaUpgrade = true,
    DuoRarityBoonDropMetaUpgrade = true,
    EnemyEliteShrineUpgrade = true,
    VulnerabilityEffectBonusMetaUpgrade = true,
    TrapDamageShrineUpgrade = true
  }
  -- TODO: unlock both sides?
  --[[
    GameState.MetaUpgradesSelected = {}
    GameState.MetaUpgradeState = {}
  ]]
  -- Quest Data -- complete, allow players to cash them in whenever
  -- Cosmetics.QuestLog = true for unlock below
  for k, questName in ipairs( QuestOrderData ) do
		local questData = QuestData[questName]
    -- GameState.QuestStatus[questData.Name] = "Complete"
    ModUtil.Table.Replace(QuestData[questData.Name].UnlockGameStateRequirements, {})
    ModUtil.Table.Replace(QuestData[questData.Name].CompleteGameStateRequirements, {})
  end
  -- GameState.Cosmetics? Maybe not if I can use this... idk
  GameState.Cosmetics = {
    -- House Items
    QuestLog = true,
    OfficeDoorUnlockItem = true,
    -- Run progression items / unlocks
    FishingUnlockItem = true,
    ShrinePointGates = true,
    Cosmetic_MusicPlayer = true,
    TartarusReprieve = true,
    AsphodelReprieve = true,
    ElysiumReprieve = true,
  }
  
  -- QoL to disable the tutorials IG?
  GameState.CompletedObjectiveSets = {
    SwordTutorial_Arthur = true,
    GunTutorial_ManualReload = true,
    UnlockWeapon = true,
    GunTutorial = true,
    FistTutorial_FistWeave = true,
    ShieldTutorial = true,
    GunTutorial_Lucifer = true,
    AspectsRevealPrompt = true,
    SwordTutorial = true,
    ShieldTutorial_BonusProjectile = true,
    SpearTutorial = true,
    FistTutorial_Vacuum = true,
    FishPrompt = true,
    SpearTutorial_SpinTravel = true,
    ShieldTutorial_Grind = true,
    GiftPrompt = true,
    FistTutorial_Gilgamesh = true,
    PerfectClear = true,
    FistTutorial = true,
    GiftRackPrompt = true,
    MetaPrompt = true,
    TimeChallenge = true,
    BedPrompt = true,
    SurvivalChallenge = true,
    AdvancedTooltipPrompt = true,
    SpearTutorial_Teleport = true,
    ShieldTutorial_Beowulf = true,
    BowTutorial = true,
    GunTutorial_SelfEmpower = true,
    ThanatosChallenge = true,
    BowTutorialLoad = true,
    Fishing = true
  }
  GameState.Resources = {
    SuperGiftPoints = 0,
    MetaPoints = 0,
    LockKeys = 0,
    SuperLockKeys = 0,
    Gems = 0,
    SuperGems = 0,
    GiftPoints = 0
  }
  -- Inspect Points?
  -- TextSpeechRecord?
  for npcKey, npcObj in pairs(UnitSetData.NPCs) do
    DebugPrint { Text = "Checking TextLines for " .. tostring(npcKey) }
    for propKey, propValue in pairs(npcObj) do
      if type(propValue) == "table" then
        -- InteractTextSetLines
        DebugPrint { Text = "Checking TextLines for " .. tostring(npcKey) .. ": " .. propKey }
        for textKey, textObj in pairs(propValue) do
          if type(textObj) == "table" and textObj.PlayOnce == true then
            DebugPrint { Text = "Setting TextLinesRecord[\"".. tostring(textKey) .."\"] " }
            TextLinesRecord[textKey] = true
          end
        end
      end
    end
  end

  -- LootData Text Lines
  for lootKey, lootValue in pairs(LootData) do
    DebugPrint { Text = "Checking TextLines for " .. tostring(lootKey) }
    for propKey, propValue in pairs(lootValue) do
      if type(propValue) == "table" then
        -- InteractTextSetLines
        DebugPrint { Text = "Checking TextLines for " .. tostring(lootKey) .. ": " .. propKey }
        for textKey, textObj in pairs(propValue) do
          if type(textObj) == "table" and textObj.PlayOnce == true then
            DebugPrint { Text = "Setting TextLinesRecord[\"".. tostring(textKey) .."\"] " }
            TextLinesRecord[textKey] = true
          end
        end
      end
    end
  end
  

end