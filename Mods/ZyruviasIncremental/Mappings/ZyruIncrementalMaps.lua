-- SAVE DATA SETUP
ZyruIncremental.InitializeSaveDataAndPatchIfNecessary = function ()
  if not ZyruIncremental.Data.Flags or ZyruIncremental.Data.Flags.Initialized == nil then
    ZyruIncremental.Data.BoonData = { } -- Set Dynamically
      -- levevl, rarity bonus, experience, max points, current points
    ZyruIncremental.Data.GodData = { 
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
    ZyruIncremental.Data.DropData = {
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
    ZyruIncremental.Data.UpgradeData = {
      
    }
    ZyruIncremental.Data.Currencies = {
      
    }
    ZyruIncremental.Data.FileOptions = {
      StartingPoint = ZyruIncremental.Constants.SaveFile.EPILOGUE,
      DifficultySetting = ZyruIncremental.Constants.SaveFile.STANDARD,
      ExperiencePopupBehavior = ZyruIncremental.Constants.Settings.EXP_ON_HIT,
      LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE,
    }
    ZyruIncremental.Data.Flags = {
      Initialized = true,
    }
  end

  -- APPLY VERSION PATCHES
  if not ZyruIncremental.Data.Flags.MostRecentVersionPlayed then
    ZyruIncremental.Data.Flags.MostRecentVersionPlayed = ZyruIncremental.CurrentVersion
  end
end

ModUtil.LoadOnce(ZyruIncremental.InitializeSaveDataAndPatchIfNecessary)
  -- SAVE DATA UPGRADE PROCESSING
ModUtil.LoadOnce( function ( )
  if ZyruIncremental.Data.UpgradeData == nil then 
    return
  end

  -- process existing upgrades
  for i, upgradeName in ipairs(ZyruIncremental.Data.UpgradeData) do
    local upgrade = ZyruIncremental.UpgradeData[upgradeName]
    if upgrade == nil then
      -- check upgrades themselves for a name match, reworked names recently
      for u, uData in pairs(ZyruIncremental.UpgradeData) do
        if uData.Name == upgradeName then
          upgrade = uData
        end
      end
      -- still not found? remove it 
      if upgrade == nil then
        return ZyruIncremental.RemoveUpgrade(upgradeName)
      end

    end
    if upgrade.OnApplyFunction ~= nil then
      _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
    end
    if upgrade.OnApplyFunctions ~= nil then
        for k, functionName in ipairs(upgrade.OnApplyFunctions) do
            local functionArgs = upgrade.OnApplyFunctionArgs[k]
            _G[functionName](functionArgs)
        end
    end
  end

end)

ModUtil.LoadOnce(function ( )
    DebugPrint({ Text = "LOADING ZyruIncremental Map Setup Data..." })
    ZyruIncremental.WhatTheFuckIsThisToBoonMap = {
      DemeterMaxChill = "MaximumChillBlast",
      PoseidonCollisionBlast = "SlamExplosionTrait",
    }
    -- Second-to-Last runort WeaponData table -> Boon conversion
    ZyruIncremental.WeaponToBoonMap = {
      -- Zeus
      LightningStrikeX = "ZeusShoutTrait",
      -- Ares
      AresSurgeWeapon = "AresShoutTrait",
      -- Aphrodite
      AphroditeSuperCharm = "AphroditeShoutTrait",
      AphroditeMaxSuperCharm = "AphroditeShoutTrait",
      -- Artemis
      ArtemisShoutWeapon = "ArtemisShoutTrait",
      ArtemisMaxShoutWeapon = "ArtemisShoutTrait",
      ArtemisAmmoWeapon = "ArtemisAmmoExitTrait",
      -- Demeter
      ChillRetaliate = "DemeterRetaliateTrait",
      DemeterChillKill = "InstantChillKill",
      DemeterMaxChill = "MaximumChillBlast",
      -- Poseidon
      PoseidonSurfWeapon = "PoseidonShoutTrait",
    }
    -- EffectData -> Boon Conversion, uses dynamic mapping below
    ZyruIncremental.EffectToBoonMap = {
      -- Poseidon
      DamageOverDistance = "SlipperyTrait",
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
    }
    -- dynamic mapping for Effect Data
    for i, weaponName in ipairs(WeaponSets.HeroAllWeapons) do
      local weaponTable = { weaponName }
      if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
        weaponTable = ConcatTableValues({ weaponName }, WeaponSets.LinkedWeaponUpgrades[weaponName])
      end
        
      if Contains({ "SwordWeapon", "SpearWeapon", "ShieldWeapon", "BowWeapon", "GunWeapon", "FistWeapon" }, weaponName) then
        ModUtil.Table.Merge(ZyruIncremental.EffectToBoonMap.DamageOverTime, ToLookupValue(weaponTable, "DionysusWeaponTrait"))
        ModUtil.Table.Merge(ZyruIncremental.EffectToBoonMap.DelayedDamage, ToLookupValue(weaponTable, "AresWeaponTrait"))
      elseif Contains({ "SwordParry","BowSplitShot","SpearWeaponThrow", "ShieldThrow", "FistWeaponSpecial", "GunGrenadeToss" }, weaponName) then
        ModUtil.Table.Merge(ZyruIncremental.EffectToBoonMap.DamageOverTime, ToLookupValue(weaponTable, "DionysusSecondaryTrait"))
        ModUtil.Table.Merge(ZyruIncremental.EffectToBoonMap.DelayedDamage, ToLookupValue(weaponTable, "AresSecondaryTrait"))
      end
  
    end
  
    -- Projectile -> Boon Mapping
    ZyruIncremental.ProjectileToBoonMap = {
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
      ArtemisAmmoWeapon = "ArtemisAmmoExitTrait",
      -- Demeter
      DemeterMaxChill = "MaximumChillBlast",
      DemeterSuper = "DemeterShoutTrait",
      DemeterMaxSuper = "DemeterShoutTrait",
      DemeterAmmoWind = "CastNovaTrait",
      -- Athena
      MagicShieldRetaliate = "AthenaRetaliateTrait"
    }
  
    ZyruIncremental.SuperTraitMap = {
      SuperGainMultiplier = "SuperGenerationTrait", -- zeus
      DefensiveSuperGainMultiplier = "DefensiveSuperGenerationTrait", -- Poseidon
      HermesWrathBuff = "HermesShoutDodge" -- Second Wind
    }
    
    ZyruIncremental.DamageModifiersToBoonMap = {
      ---------------
      -- OFFENSIVE --
      ---------------
      IncreaseDamageTaken = "AphroditeWeakenTrait",
      LastStandDamageBonus = "LastStandDamageBonusTrait",
      ShoutDamageBonus = "OnWrathDamageBuffTrait",
      AresShoutBuff = "OnWrathDamageBuffTrait", -- zeus billowing
      
      ZeroRangedWeaponAmmoMultiplier = "ZeroAmmoBonusTrait",
      AthenaBackstabVulnerability = "AthenaBackstabDebuffTrait",
      DionysusComboVulnerability = "DionysusComboVulnerability",
      ProjectileDeflectedMultiplier = "AthenaShieldTrait",
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
    ZyruIncremental.GetHeroTraitValuesMap = {
      StartingSuperAmount = "PreloadSuperGenerationTrait",
      HealthRewardBonus = "HealthRewardBonusTrait",
      TraitHealingBonus = "HealingPotencyTrait",
      LastStandHealFraction = "LastStandHealTrait",
      CriticalSuperGainAmount = "CriticalSuperGenerationTrait",
    }

    -- Used to track boons whose effects universally apply to a given source that
    -- otherwise only appear in engine property changes
    ZyruIncremental.HailMaryMap = {
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
      DamageOverTime = { "DionysusSlowTrait" },
      PoseidonSurfWeapon = { "PoseidonShoutDurationTrait" }
    }

    ZyruIncremental.BoonExperienceFactor = {
      RetaliateWeaponTrait = 1,
      SuperGenerationTrait = 20,
      DefensiveSuperGenerationTrait = 10,
      ZeusBoltAoETrait =  1,
      ZeusBonusBoltTrait =  0,
      ZeusBonusBounceTrait =  0,
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
      AthenaShoutTrait = 0, -- NA
      EnemyDamageTrait = 1,
      TrapDamageTrait = 1,
      LastStandHealTrait = 0,
      LastStandDurationTrait = 0,
      PreloadSuperGenerationTrait =  1,
      AthenaRetaliateTrait = 1,
      ShieldHitTrait = 0, -- NA
      PoseidonWeaponTrait = 1,
      PoseidonSecondaryTrait = 1,
      PoseidonRangedTrait = 1,
      ShieldLoadAmmo_PoseidonRangedTrait =  1,
      PoseidonRushTrait = 1,
      PoseidonShoutTrait = 1,
      PoseidonShoutDurationTrait = 0,
      BonusCollisionTrait = 1,
      SlamStunTrait = 1,
      SlamExplosionTrait = 1,
      EncounterStartOffenseBuffTrait = 1,
      OnEnemyDeathDefenseBuffTrait = 1,
      SlipperyTrait = 1,
      BossDamageTrait = 1,
      DoubleCollisionTrait = 0, -- NA
      FishingTrait = 1,
      HealthRewardBonusTrait = 1,
      RoomRewardBonusTrait = 1,
      ReducedEnemySpawnsTrait = 1,
      UnusedWeaponBonusTrait = 1,
      UnusedWeaponBonusTraitAddGems = 1,
      HealthBonusTrait = 0,
      PoseidonPickedUpMinorLootTrait = 1,
      RoomRewardMaxHealthTrait = 1,
      RoomRewardEmptyMaxHealthTrait = 1,
      ArtemisWeaponTrait = 1,
      ArtemisSecondaryTrait = 1,
      ArtemisRangedTrait = 1,
      ArtemisRushTrait = 1,
      ArtemisCriticalTrait = 3,
      CriticalBufferMultiplierTrait = 1,
      CriticalSuperGenerationTrait = 10,
      CriticalStunTrait = 1,
      ArtemisShoutTrait = 1,
      ArtemisShoutBuffTrait = 1,
      MarkedDropGoldTrait = 1,
      ArtemisBonusProjectileTrait = 1,
      MoreAmmoTrait = 1,
      RoomAmmoTrait = 1,
      UnstoredAmmoDamageTrait = 1,
      AmmoReloadTrait = 1,
      AmmoReclaimTrait = 0, -- NA
      CritBonusTrait = 2,
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
      CharmTrait = 0, -- NA
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
      OnEnemyDeathDamageInstanceBuffTrait = 0, -- NA
      DionysusSpreadTrait = 1,
      DionysusSlowTrait = 0,
      DionysusAoETrait = 1,
      DionysusDefenseTrait = 1,
      GiftHealthTrait = 1,
      DionysusMaxHealthTrait = 10,
      DionysusWeaponTrait = 1,
      DionysusSecondaryTrait = 1,
      DionysusRangedTrait = 1,
      DionysusComboVulnerability = 1,
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
      DoorHealTrait = 10,
      DemeterWeaponTrait = 1,
      MaximumChillBonusSlow = 1,
      MaximumChillBlast = 1,
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
      BonusDashTrait = 0, -- NA
      RapidRushTrait = 0, -- NA
      DeathDefianceFreezeTimeTrait = 1,
      FreezeTimeDashTrait = 1,
      CollisionTouchTrait = 1,
      DodgeChanceTrait = 0,
      RapidCastTrait = 1,
      RushSpeedBoostTrait = 0, -- NA
      MoveSpeedTrait = 35,
      RushRallyTrait = 10,
      HermesShoutDodge = 0,
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

    ZyruIncremental.BoonExperiencePerUse = {
      RetaliateWeaponTrait = 0,
      SuperGenerationTrait = 0,
      DefensiveSuperGenerationTrait = 0,
      ZeusBoltAoETrait = 0,
      ZeusBonusBoltTrait = 35,
      ZeusBonusBounceTrait = 15,
      ZeusWeaponTrait = 0,
      ZeusSecondaryTrait = 0,
      ZeusRangedTrait = 0,
      PerfectDashBoltTrait = 0,
      ZeusChargedBoltTrait = 0,
      ZeusRushTrait = 0,
      ZeusShoutTrait = 0,
      ZeusLightningDebuff = 0,
      WrathDamageBuffTrait = 0,
      RetainTempHealthTrait = 0,
      AthenaWeaponTrait = 0,
      AthenaSecondaryTrait = 0,
      AthenaRangedTrait = 0,
      AthenaRushTrait = 0,
      AthenaShieldTrait = 0,
      AthenaBackstabDebuffTrait = 0,
      AthenaShoutTrait = 100,
      EnemyDamageTrait = 0,
      TrapDamageTrait = 0,
      LastStandHealTrait = 500,
      LastStandDurationTrait = 500,
      PreloadSuperGenerationTrait = 0,
      AthenaRetaliateTrait = 0,
      ShieldHitTrait = 250,
      PoseidonWeaponTrait = 0,
      PoseidonSecondaryTrait = 0,
      PoseidonRangedTrait = 0,
      ShieldLoadAmmo_PoseidonRangedTrait =  1,
      PoseidonRushTrait = 0,
      PoseidonShoutTrait = 100,
      PoseidonShoutDurationTrait = 100,
      BonusCollisionTrait = 0,
      SlamStunTrait = 0,
      SlamExplosionTrait = 0,
      EncounterStartOffenseBuffTrait = 0,
      OnEnemyDeathDefenseBuffTrait = 0,
      SlipperyTrait = 0,
      BossDamageTrait = 0,
      DoubleCollisionTrait = 25,
      FishingTrait = 0,
      HealthRewardBonusTrait = 0,
      RoomRewardBonusTrait = 0,
      ReducedEnemySpawnsTrait = 0,
      UnusedWeaponBonusTrait = 0,
      UnusedWeaponBonusTraitAddGems = 0,
      HealthBonusTrait = 250,
      PoseidonPickedUpMinorLootTrait = 0,
      RoomRewardMaxHealthTrait = 0,
      RoomRewardEmptyMaxHealthTrait = 0,
      ArtemisWeaponTrait = 0,
      ArtemisSecondaryTrait = 0,
      ArtemisRangedTrait = 0,
      ArtemisRushTrait = 0,
      ArtemisCriticalTrait = 0,
      CriticalBufferMultiplierTrait = 0,
      CriticalSuperGenerationTrait = 5,
      CriticalStunTrait = 0,
      ArtemisShoutTrait = 0,
      ArtemisShoutBuffTrait = 0,
      MarkedDropGoldTrait = 0,
      ArtemisBonusProjectileTrait = 0,
      MoreAmmoTrait = 0,
      RoomAmmoTrait = 0,
      UnstoredAmmoDamageTrait = 0,
      AmmoReloadTrait = 0,
      AmmoReclaimTrait = 0,
      CritBonusTrait = 5,
      ArtemisAmmoExitTrait = 0,
      CritVulnerabilityTrait = 25,
      ArtemisSupportingFireTrait = 0,
      AphroditeDurationTrait = 100,
      AphroditePotencyTrait = 0,
      AphroditeWeaponTrait = 0,
      AphroditeSecondaryTrait = 0,
      AphroditeRangedTrait = 0,
      ShieldLoadAmmo_AphroditeRangedTrait = 0,
      AphroditeRangedBonusTrait = 0,
      CastBackstabTrait = 0,
      AphroditeRushTrait = 0,
      AphroditeShoutTrait = 100,
      AphroditeWeakenTrait = 0,
      AphroditeRetaliateTrait = 0,
      AphroditeDeathTrait = 0,
      ProximityArmorTrait = 0,
      CharmTrait = 75,
      AresWeaponTrait = 0,
      AresSecondaryTrait = 0,
      OnSpawnSwordTrait = 0,
      AresRangedTrait = 0,
      AresRushTrait = 0,
      AresShoutTrait = 0,
      AresAoETrait = 0,
      AresDragTrait = 0,
      AresLoadCurseTrait = 25,
      AresLongCurseTrait = 0,
      AresCursedRiftTrait = 50,
      AresRetaliateTrait = 0,
      IncreasedDamageTrait = 0,
      OnWrathDamageBuffTrait = 0,
      LastStandDamageBonusTrait = 0,
      OnEnemyDeathDamageInstanceBuffTrait = 125,
      DionysusSpreadTrait = 0,
      DionysusSlowTrait = 10,
      DionysusAoETrait = 0,
      DionysusDefenseTrait = 0,
      GiftHealthTrait = 0,
      DionysusMaxHealthTrait = 100,
      DionysusWeaponTrait = 0,
      DionysusSecondaryTrait = 0,
      DionysusRangedTrait = 0,
      DionysusComboVulnerability = 0,
      ShieldLoadAmmo_DionysusRangedTrait =  1,
      ShieldLoadAmmo_AthenaRangedTrait = 0,
      ShieldLoadAmmo_ArtemisRangedTrait = 0,
      ShieldLoadAmmo_DemeterRangedTrait = 0,
      ShieldLoadAmmo_ZeusRangedTrait = 0,
      ShieldLoadAmmo_AresRangedTrait = 0,
      DionysusRushTrait = 0,
      AmmoFieldTrait = 0,
      AmmoBoltTrait = 0,
      DionysusShoutTrait = 0,
      DionysusPoisonPowerTrait = 0,
      DoorHealTrait = 50,
      DemeterWeaponTrait = 0,
      MaximumChillBlast = 0,
      DemeterSecondaryTrait = 0,
      DemeterRangedTrait = 0,
      DemeterRangedBonusTrait = 0,
      DemeterRushTrait = 0,
      DemeterShoutTrait = 0,
      HealingPotencyTrait = 0,
      CastNovaTrait = 0,
      HarvestBoonTrait = 0,
      ZeroAmmoBonusTrait = 0,
      DemeterRetaliateTrait = 0,
      MagnetismTrait = 100,
      BonusDashTrait = 25,
      RapidRushTrait = 25,
      DeathDefianceFreezeTimeTrait = 0,
      FreezeTimeDashTrait = 0,
      CollisionTouchTrait = 0,
      DodgeChanceTrait = 50,
      RapidCastTrait = 25,
      RushSpeedBoostTrait = 25,
      MoveSpeedTrait = 0,
      RushRallyTrait = 10,
      HermesWeaponTrait = 50,
      HermesSecondaryTrait = 50,
      HermesShoutDodge = 100,
      RegeneratingSuperTrait = 15,
      ChamberGoldTrait = 100,
      SpeedDamageTrait = 0,
      MoneyMultiplierTrait = 0,
      ChaosBlessingMeleeTrait = 0,
      ChaosBlessingRangedTrait = 0,
      ChaosBlessingAlphaStrikeTrait = 0,
      ChaosBlessingBackstabTrait = 0,
      ChaosBlessingAmmoTrait = 0,
      ChaosBlessingMaxHealthTrait = 0,
      ChaosBlessingBoonRarityTrait = 0,
      ChaosBlessingTroveTrait = 0,
      ChaosBlessingMoneyTrait = 0,
      ChaosBlessingGemTrait = 0,
      ChaosBlessingMetapointTrait = 0,
      ChaosBlessingTrapDamageTrait = 0,
      ChaosBlessingSecretTrait = 0,
      ChaosBlessingHealTrait = 0,
      ChaosBlessingExtraChanceTrait = 0,
      ChaosBlessingSecondaryTrait = 0,
      ChaosBlessingDashAttackTrait = 0,
      FountainDamageBonusTrait = 0,
    }

    ZyruIncremental.BoonsToIgnore = {
      AresHermesSynergyTrait = true
    }

    ZyruIncremental.BoonGrantExperienceOutCombat = {
      -- TODO: does anything go here? side hustle?
    }

end)




-- audio mappings
ModUtil.LoadOnce(function ( ) 
  ZyruIncremental.BoonLevelUpVoiceLines = {
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

  ZyruIncremental.DropExperienceFactor = {
    RoomRewardMoneyDrop = 1,
    RoomRewardMaxHealthDrop = 4,
    StackUpgrade = 1,
  }

  ZyruIncremental.DropLevelUpVoiceLines = {
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
end, ZyruIncremental)

-- enemy data: newEnemy.HealthMultiplier
ModUtil.Path.Wrap("SetupEnemyObject", function (baseFunc, newEnemy, currentRun, args)
  local difficultyModifier = ZyruIncremental.DifficultyModifier or 1
  newEnemy.HealthMultiplier = (newEnemy.HealthMultiplier or 1) * difficultyModifier
  -- armor
  if newEnemy.HealthBuffer ~= nil and newEnemy.HealthBuffer > 0 then
		newEnemy.HealthBufferMultiplier = (newEnemy.HealthBufferMultiplier or 1) * difficultyModifier
	end

  return baseFunc(newEnemy, currentRun, args)
end, ZyruIncremental)

function ZyruIncremental.ComputeDifficultyModifier (fileDifficulty, property) 
  local fileDifficultyMap = ZyruIncremental.Constants.Difficulty[property]
  local difficultyScalar = fileDifficultyMap[fileDifficulty] or 1
  local numRunsToExponentiate = TableLength(GameState.RunHistory) - 1
  if ZyruIncremental.Data.FileOptions.StartingPoint == ZyruIncremental.Constants.SaveFile.FRESH_FILE then
    if GetNumRunsCleared() < 10 then
      return 1
    elseif ZyruIncremental.Data.FreshFileRunCompletion == nil then
      -- compute the file-cached multiplier
      local runIndex = 0
      local attemptIndex = 1
      for k, run in pairs( GameState.RunHistory ) do
        if run.Cleared then
          runIndex = runIndex + 1
        end
        if runIndex == 10 then
          ZyruIncremental.Data.FreshFileRunCompletion = attemptIndex
          break
        end
      end
    end
    -- return the cached value
    -- e.g. 10th win on attempt 18, this is attempt 19, total length - 
    numRunsToExponentiate = numRunsToExponentiate - ZyruIncremental.Data.FreshFileRunCompletion + 1
  end
  return math.pow(difficultyScalar, numRunsToExponentiate)
end

ModUtil.Path.Wrap("StartNewRun", function (baseFunc, ...)
  local run = baseFunc(...)

  if not ZyruIncremental.Data.Flags or not ZyruIncremental.Data.Flags.Initialized then
    return run
  end 
  ZyruIncremental.DifficultyModifier = ZyruIncremental.ComputeDifficultyModifier(
    ZyruIncremental.Data.FileOptions.DifficultySetting,
    ZyruIncremental.Constants.Difficulty.Keys.INCOMING_DAMAGE_SCALING
  )
  AddIncomingDamageModifier(CurrentRun.Hero, {
    Name = "ZyruIncremental",
    GlobalMultiplier = ZyruIncremental.DifficultyModifier
  })

  return run
end, ZyruIncremental)

function ZyruIncremental.InitializeEpilogueStartSaveData()
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
    NPC_Thanatos_01 = {Value = 10, NewTraits = {}},
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
    SisyphusAssistTrait = 1,
    ThanatosAssistTrait = 1,
    FuryAssistTrait = 1,
    DusaAssistTrait = 1,
    AchillesPatroclusAssistTrait = 1,
    SkellyAssistTrait = 1,
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
  TextLinesRecord["PoseidonWrathIntro01"] = true
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
  -- Quest completion
  for k, questName in ipairs( QuestOrderData ) do
		local questData = QuestData[questName]
    GameState.QuestStatus[questData.Name] = "CashedOut"
  end
  GameState.Resources = {
    SuperGiftPoints = 10,
    MetaPoints = 5000,
    LockKeys = 50,
    SuperLockKeys = 50,
    Gems = 2500,
    SuperGems = 20,
    GiftPoints = 100
  }
  -- Cosmetic Items
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
    UnusedWeaponBonusAddGems = true,
    GiftDropRunProgress = true,
    HadesEMFight = true,


  }
  GameState.CosmeticsAdded = {
    CodexBoonList = true,
  }
  UseRecord = {}
  UseRecord["DeathArea"] = {}
  UseRecord["DeathAreaBedroom"] = {}
  for cosmeticName, cosmeticData in pairs( ConditionalItemData ) do
		if not cosmeticData.DebugOnly and cosmeticData.ResourceCost ~= nil and not cosmeticData.Disabled then
				GameState.CosmeticsAdded[cosmeticName] = true
        GameState.Cosmetics[cosmeticName] = true

        -- I can't check for where its used and I just want to be done with this task
        if cosmeticData.InspectPoint ~= nil then
          UseRecord["DeathArea"][cosmeticData.InspectPoint] = true
          UseRecord["DeathAreaBedroom"][cosmeticData.InspectPoint] = true
        end
			end
	end
  for cosmeticName, cosmeticData in pairs( GameData.MiscCosmetics ) do
		if not cosmeticData.DebugOnly and cosmeticData.ResourceCost ~= nil and not cosmeticData.Disabled then
				GameState.CosmeticsAdded[cosmeticName] = true
        GameState.Cosmetics[cosmeticName] = true
			end
	end
  for cosmeticName, cosmeticData in pairs( GameData.LoungeCosmetics ) do
		if not cosmeticData.DebugOnly and cosmeticData.ResourceCost ~= nil and not cosmeticData.Disabled then
				GameState.CosmeticsAdded[cosmeticName] = true
        GameState.Cosmetics[cosmeticName] = true
			end
	end
  for trackName, trackData in pairs( MusicPlayerTrackData ) do
		if not trackData.DebugOnly and trackData.ResourceCost ~= nil then
			GameState.CosmeticsAdded[trackData.Name] = true
      GameState.Cosmetics[trackData.Name] = true
		end
	end
  -- QoL to disable the tutorials
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
  -- Inspect Points?
  -- TextSpeechRecord?
  for npcKey, npcObj in pairs(UnitSetData.NPCs) do
    for propKey, propValue in pairs(npcObj) do
      if type(propValue) == "table" then
        -- InteractTextSetLines
        for textKey, textObj in pairs(propValue) do
          if type(textObj) == "table" and textObj.PlayOnce == true then
            TextLinesRecord[textKey] = true
          end
        end
      end
    end
  end

  -- LootData Text Lines
  for lootKey, lootValue in pairs(LootData) do
    for propKey, propValue in pairs(lootValue) do
      if type(propValue) == "table" then
        -- InteractTextSetLines
        for textKey, textObj in pairs(propValue) do
          if type(textObj) == "table" and textObj.PlayOnce == true then
            TextLinesRecord[textKey] = true
          end
        end
      end
    end
  end

  -- initialize sex scenes
  TextLinesRecord["BecameCloseWithMegaera01"] = true
  TextLinesRecord["BecameCloseWithThanatos01"] = true
  TextLinesRecord["BecameCloseWithDusa01"] = true
  -- inititalize EM4 availability
  TextLinesRecord["Fury2FirstAppearance"] = true
  TextLinesRecord["Fury3FirstAppearance"] = true
  -- allow keepsakes in Hades immediately
  TextLinesRecord["HadesAllowsLegendaryKeepsakes01"] = true

  -- INSPECT POINTS
  UseRecord = UseRecord or {}

  local inspectTables = {
    DeathLoopData = {
      "DeathArea",
      "DeathAreaBedroom",
      "DeathAreaBedroomHades",
      "DeathAreaBedroomHades",
      "DeathAreaOffice",
      "RoomPreRun",
    },
    ["RoomSetData.Base"] = {
      "RoomChallenge01",
      "RoomChallenge02",
      "RoomChallenge03",
      "RoomChallenge04",
      "CharonFight01",
    },
    ["RoomSetData.Asphodel"] = {
      "B_PreBoss01",
      "B_PostBoss01",
      "B_MiniBoss02",
      "B_Shop01",
      "B_Reprieve01",
      "B_Intro",
      "B_Story01"
    },
    ["RoomSetData.Elysium"] = {
      "C_PreBoss01",
      "C_Shop01",
      "C_Reprieve01",
      "C_Story01",
      "C_Intro",
    },
    ["RoomSetData.Secrets"] = {
      "RoomSecret01",
      "RoomSecret02",
      "RoomSecret03",
    },
    ["RoomSetData.Styx"] = {
      "D_MiniBoss02",
      "D_Reprieve01",
      "D_Intro",
      "D_Hub",
    },
    -- Surface doesn't really matter but for thoroughness
    ["RoomSetData.Surface"] = {
      "E_Intro",
      "E_Story01",
    },
    ["RoomSetData.Tartarus"] = {
      "A_PreBoss01",
      "A_Boss01",
      "A_PostBoss01",
      "A_MiniBoss03",
      "A_MiniBoss04",
      "A_Reprieve01",
      "A_Shop01",
      "RoomOpening",
      "A_Story01",
    }

  }

  for tableName, tableMapNames in pairs(inspectTables) do 
    for i, mapName in ipairs(tableMapNames) do
      for id, itemData in ipairs(_G[tableName][mapName].InspectPoints) do
        UseRecord[mapName] = UseRecord[mapName] or {}
        UseRecord[mapName][id] = true
      end
    end
  end

  
  -- Codex -- enable and fill out progress by threshold and unlock amounts
  CodexStatus.Enabled = true
	for chapterName, chapterData in pairs(Codex) do
    if CodexStatus[chapterName] == nil then
      CodexStatus[chapterName] = {}
    end
		for entryName, entryData in pairs(Codex[chapterName].Entries) do
      
      if CodexStatus[chapterName][entryName] == nil then
        CodexStatus[chapterName][entryName] = {}
      end
      for i, entry in ipairs(entryData.Entries) do
        if entry.UnlockGameStateRequirements then
          -- unlock required text lines for entry
          if entry.UnlockGameStateRequirements.RequiredTextLines then
            for j, line in ipairs(entry.UnlockGameStateRequirements.RequiredTextLines) do
              TextLinesRecord[line] = true
            end
          end
          if entry.UnlockGameStateRequirements.RequiredAnyTextLines then
            for j, line in ipairs(entry.UnlockGameStateRequirements.RequiredAnyTextLines) do
              TextLinesRecord[line] = true
            end
          end
        end
        -- TODO: this cumulative adding may cause problems. idk though. if you're reading this halp
        -- unlock UnlockThreshold
        local incrementValue = entry.UnlockThreshold or 0
        if entry.UnlockThreshold then
          IncrementCodexValue(chapterName, entryName, entry.UnlockThreshold  )
        end
        -- TODO: is this ...
        if CodexStatus[chapterName][entryName][i] == nil or type(CodexStatus[chapterName][entryName][i]) ~= "table" then
          CodexStatus[chapterName][entryName][i] = {}
        end
        CodexStatus[chapterName][entryName][i].Unlocked = true
      end
		end
	end
  UnlockExistingEntries()
  -- gotta do this after file state change
  ApplyTransientPatches({})

end