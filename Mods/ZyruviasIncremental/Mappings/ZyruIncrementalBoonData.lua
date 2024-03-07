local T1RarityTable = {
    Supreme = {
      MinMultiplier = 2.7,
      MaxMultiplier = 3.0,
    },
    Ultimate = {
      MinMultiplier = 3.0,
      MaxMultiplier = 3.5,
    },
    Transcendental = {
      MinMultiplier = 3.5,
      MaxMultiplier = 4.0,
    },
    Mythic = {
      MinMultiplier = 4.0,
      MaxMultiplier = 4.5,
    },
    Olympic = {
      MinMultiplier = 4.5,
      MaxMultiplier = 5.0,
    },
}

local T2RarityTable = ModUtil.Table.Copy(T1RarityTable)

local StaticMultiplierTable = {
  Supreme = { Multiplier = 1.8 },
  Ultimate = { Multiplier = 2.0 },
  Transcendental = { Multiplier = 2.2 },
  Mythic = { Multiplier = 2.6 },
  Olympic = { Multiplier = 3.0 },
}

local rarities = { "Supreme", "Ultimate", "Transcendental", "Mythic", "Olympic"}
local function scalingTable(start, increment, bonus)
  local result = { }
  local current = start
  for _, rarity in ipairs(rarities) do
    result[rarity] = { Multiplier = current}
    current = current + increment
  end
  if bonus ~= nil then
    result["Olympic"].Multiplier = result["Olympic"].Multiplier + bonus
  end

  return result
end

-- TextFormat Setup
ModUtil.LoadOnce(function ( )
    ModUtil.Table.Merge(Color, {
      BoonPatchSupreme = { 255, 238, 50, 255 },
      BoonPatchUltimate = { 58, 255, 176, 255 },
      BoonPatchTranscendental = { 255, 158, 208, 255 },
      BoonPatchMythic = { 149, 145, 255, 255 },
      BoonPatchOlympic = { 127, 255, 30, 255 },
    });

    ModUtil.Table.Merge(TextFormats, {
      SupremeFormat = {
        Graft = true,
        Color = Color.BoonPatchSupreme
      },
      UltimateFormat = {
        Graft = true,
        Color = Color.BoonPatchUltimate
      },
      TranscendentalFormat = {
        Graft = true,
        Color = Color.BoonPatchTranscendental
      },
      MythicFormat = {
        Graft = true,
        Color = Color.BoonPatchMythic
      },
      OlympicFormat = {
        Graft = true,
        Color = Color.BoonPatchOlympic
      },
    })
  
    ModUtil.Table.Merge(TraitData, {
      -- General %Scaling Boons
      ShopTier1Trait = { RarityLevels = T1RarityTable },
      ShopTier2Trait = { RarityLevels = T2RarityTable },
      ----------------
      -- Zeus Boons --
      ----------------
      SuperGenerationTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ZeusBoltAoETrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ZeusBonusBoltTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      -- I fucking hate this
      ZeusBonusBounceTrait = { RarityLevels = scalingTable(5, 1) },
      ZeusWeaponTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      ZeusSecondaryTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      ZeusRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ShieldLoadAmmo_ZeusRangedTrait = { RarityLevels = scalingTable(2.0, 0.25, 0.5) },
      PerfectDashBoltTrait = { RarityLevels = scalingTable(3, 0.5) },
      ZeusRushTrait = { RarityLevels = scalingTable(3, 0.5) },
      ZeusShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      OnWrathDamageBuffTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      ZeusLightningDebuff = { RarityLevels = scalingTable(3.0, 0.5, 1) },
      -- Athena Boons
      AthenaWeaponTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      AthenaSecondaryTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      AthenaRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ShieldLoadAmmo_AthenaRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AthenaRushTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AthenaBackstabDebuffTrait = { 
        RarityLevels = scalingTable(2, 0.25)
      },
      AthenaShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      AthenaShieldTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AthenaRetaliateTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      EnemyDamageTrait = { RarityLevels = scalingTable(3, 0.5) },
      TrapDamageTrait = {
        RarityLevels = {
          Common = { Multiplier = 1.0 },
          Rare = { Multiplier = 1.1 },
          Epic = { Multiplier = 1.2 },
          Heroic = { Multiplier = 1.3 },
          Supreme = { Multiplier = 1.4 },
          Ultimate = { Multiplier = 1.5 },
          Transcendental = { Multiplier = 1.58333 },
          Mythic = { Multiplier = 1.625 },
          Olympic = { Multiplier = 1.66667 },
        },
      },
      LastStandHealTrait = { RarityLevels = StaticMultiplierTable },
      LastStandDurationTrait = { RarityLevels = scalingTable(2, 0.25) },
      PreloadSuperGenerationTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      -- Aphrodite Boons
    
    -- AphroditeDeathTrait = ZyruIncremental.Constants.Gods.APHRODITE,
      AphroditeWeaponTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      AphroditeSecondaryTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      AphroditeDeathTrait = { RarityLevels = scalingTable(2.5, 0.5, 0.5) },
      HealthRewardBonusTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AphroditeDurationTrait = { RarityLevels = scalingTable(3, 0.5) },
      AphroditePotencyTrait = { RarityLevels = scalingTable(2, 0.25) },
      AphroditeRangedTrait = { RarityLevels = scalingTable(1.444, 0.111, 0.333) },
      ShieldLoadAmmo_AphroditeRangedTrait = { RarityLevels = scalingTable(1.444, 0.111, 0.333) },
      AphroditeRangedBonusTrait = {
        RarityLevels = scalingTable(3, 0.5),
        -- increasing DamageRadius
        PropertyChanges = {
          {},
          { ChangeValue = 1.5},
        },
      },
      AphroditeRushTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AphroditeShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      AphroditeWeakenTrait = { RarityLevels = scalingTable(3, 0.5) },
      AphroditeRetaliateTrait = { RarityLevels = scalingTable(2, 0.25) },
      ProximityArmorTrait = { RarityLevels = scalingTable(2, 0.25) },

      -- Ares Boons
      
    
      AresWeaponTrait = { RarityLevels = scalingTable(3, 0.5) },
      AresSecondaryTrait = { RarityLevels = scalingTable(2.333, 0.333, 0.333) },
      AresRangedTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.3) },
      ShieldLoadAmmo_AresRangedTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.3) },
      AresRushTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      AresShoutTrait = { RarityLevels = scalingTable(2, 0.25) },
      AresAoETrait = { RarityLevels = scalingTable(1.4, 0.1, 0.3) },
      AresDragTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.3) },
      AresLoadCurseTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      
      AresLongCurseTrait = { RarityLevels = scalingTable(1.5, 0.25, 0.5) },
      AresRetaliateTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      IncreasedDamageTrait = { RarityLevels = scalingTable(2.4, 0.4) },
      LastStandDamageBonusTrait = { RarityLevels = scalingTable(3, 0.5) },
      OnEnemyDeathDamageInstanceBuffTrait = { RarityLevels = scalingTable(3, 0.5) },


      -- Artemis Boons
      ArtemisWeaponTrait = { RarityLevels = scalingTable(3, 0.5) },
      ArtemisSecondaryTrait = { RarityLevels = scalingTable(3, 0.5) },
      ArtemisRangedTrait = { RarityLevels = scalingTable(1.58, 0.145, 0.435) },
      ShieldLoadAmmo_ArtemisRangedTrait = { RarityLevels = scalingTable(1.58, 0.145, 0.435) },
      ArtemisRushTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ArtemisCriticalTrait = { RarityLevels = scalingTable(3, 0.5) },
      CriticalBufferMultiplierTrait = { RarityLevels = scalingTable(3, 0.5) },
      -- CriticalBufferMultiplierTrait rework?
      CriticalSuperGenerationTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4),
        CriticalSuperGainAmount = { BaseValue = 1 },
      },
      ArtemisShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      CritBonusTrait = { RarityLevels = scalingTable(3, 0.5, 1) },
      ArtemisAmmoExitTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      CritVulnerabilityTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      --TODO: CritVulnerabilityTrait = {}
      ArtemisSupportingFireTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },

      -- Dionysus Boons
      DionysusSlowTrait = { RarityLevels = scalingTable(3, 0.5) },
      GiftHealthTrait = { RarityLevels = scalingTable(2, 0.25) },
      FountainDamageBonusTrait = { RarityLevels = scalingTable(2.333, 0.333, 0.333) },
      DionysusWeaponTrait = { RarityLevels = scalingTable(2, 0.25) },
      DionysusSecondaryTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      DionysusRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ShieldLoadAmmo_DionysusRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      DionysusRushTrait = { RarityLevels = scalingTable(3, 0.5) },
      DionysusShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      DoorHealTrait = { RarityLevels = scalingTable(2.2666, 0.2666) },
      LowHealthDefenseTrait = { RarityLevels = scalingTable(2.5, 0.5) },
      DionysusSpreadTrait = { RarityLevels = scalingTable(2, 0.25) },
      DionysusGiftDrop = { RarityLevels = scalingTable(2.5, 0.5) },
      DionysusDefenseTrait = { RarityLevels = scalingTable(2.5, 0.5) },
      DionysusPoisonPowerTrait = { RarityLevels = scalingTable(2.5, 0.5) },
      
      -- Demeter Boons
      DemeterWeaponTrait = { RarityLevels = scalingTable(3, 0.5) },
      DemeterSecondaryTrait = { RarityLevels = scalingTable(3, 0.5) },
      -- InstantChillKill = ZyruIncremental.Constants.Gods.DEMETER,
      DemeterRangedTrait = { RarityLevels = scalingTable(1.6, 0.15, 0.3) },
      ShieldLoadAmmo_DemeterRangedTrait = { RarityLevels = scalingTable(1.6, 0.15, 0.3) },
      DemeterRangedBonusTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      DemeterRushTrait = { RarityLevels = scalingTable(3, 0.5) },
      DemeterShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      HealingPotencyTrait = { RarityLevels = scalingTable(1.3, 0.1, 0.3) },
      CastNovaTrait = { RarityLevels = scalingTable(2, 0.25) },
      ZeroAmmoBonusTrait = { RarityLevels = scalingTable(5, 1, 1) },
      MaximumChillBlast = { RarityLevels = scalingTable(1.5, 0.125) },
      MaximumChillBonusSlow = { RarityLevels = scalingTable(3, 0.5) },
      -- TODO: HarvestBoonTrait rework?
      DemeterRetaliateTrait = {
        RarityLevels = scalingTable(3, 0.5),
        PropertyChanges = { { BaseMin = 40, BaseMax = 40}, },
      },
      -- Poseidon Boons
      PoseidonWeaponTrait = { RarityLevels = scalingTable(3, 0.5) },
      PoseidonSecondaryTrait = { RarityLevels = scalingTable(3, 0.5) },
      PoseidonRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      ShieldLoadAmmo_PoseidonRangedTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      PoseidonRushTrait = { RarityLevels = scalingTable(1.8, 0.2, 0.4) },
      PoseidonShoutDurationTrait = { RarityLevels = scalingTable(2, 0.25) },
      BonusCollisionTrait = { RarityLevels = { RarityLevels = scalingTable(2, 0.25) }, },
      SlamExplosionTrait = { RarityLevels = { RarityLevels = scalingTable(3, 0.5) }, },
      SlipperyTrait = { RarityLevels = scalingTable(3, 0.5) },
      BossDamageTrait = { RarityLevels = scalingTable(3, 0.5) },
      RoomRewardBonusTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      PoseidonShoutTrait = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      DefensiveSuperGenerationTrait = { RarityLevels = scalingTable(2, 0.25) },
      EncounterStartOffenseBuffTrait = { RarityLevels = scalingTable(2, 0.25) },
      RandomMinorLootDrop = { RarityLevels = scalingTable(2, 0.25) },

      -- Hermes Boons
    -- RapidCastTrait = ZyruIncremental.Constants.Gods.HERMES,
    -- AmmoReloadTrait = ZyruIncremental.Constants.Gods.HERMES,
    -- RegeneratingSuperTrait = ZyruIncremental.Constants.Gods.HERMES,
    
    -- SpeedDamageTrait = ZyruIncremental.Constants.Gods.HERMES,
      HermesShoutDodge = { RarityLevels = scalingTable(1.4, 0.1, 0.2) },
      BonusDashTrait = { RarityLevels = scalingTable(5, 1) },
      AmmoReclaimTrait = { RarityLevels = scalingTable(6, 1) },
      DodgeChanceTrait = { RarityLevels = scalingTable(3, 0.5) },
      -- TODO: RapidCastTrait
      -- TODO: Hypersprint already good enough???
      RushSpeedBoostTrait = { RarityLevels = scalingTable(2, 0.2, 0.2) },
      MoveSpeedTrait = { RarityLevels = scalingTable(1.33333, 0.08333) },
      RushRallyTrait = { RarityLevels = scalingTable(0.7, 0.05) },
      HermesWeaponTrait = { RarityLevels = scalingTable(0.7, -0.14, -0.14) },
      HermesSecondaryTrait = { RarityLevels = scalingTable(5, 1, 1) },
      AmmoReloadTrait = { RarityLevels = scalingTable(1.5, 0.25, 0.25)},
      -- TODO: RegeneratingSuperTrait should not be better than smoldering air
      
      ChamberGoldTrait = { RarityLevels = scalingTable(2.2, 0.4, 1.2) },
      SpeedDamageTrait = { RarityLevels = scalingTable(3, 0.5) },
    })

    -- Exclusive Access rewrite
    ModUtil.Table.Replace(TraitData.RaritySuperBoost, {
      InheritFrom = { "SynergyTrait" },
      Icon = "Dionysus_Poseidon_01",
      RequiredFalseTrait = "RaritySuperBoost",
      ZyruRarityBonus = 2
    })
    -- TODO: Rare Crop rewrite
    ModUtil.Table.Merge(TraitData.HarvestBoonTrait, {
		  RoomsPerUpgrade = 5,
    })
  end, ZyruIncremental)

-- SleepSoul's RCLib mappings as a baseline. Go check out his mods, he's brilliant.
ModUtil.LoadOnce(function ()

  ZyruIncremental.BoonToGod = {
    -- Uses in-game names for boons.
    -- -- Duos
    -- BlizzardOrbTrait = ZyruIncremental.Constants.Gods,
    -- SlowProjectileTrait = ZyruIncremental.Constants.Gods,
    -- SelfLaserTrait = ZyruIncremental.Constants.Gods,
    -- JoltDurationTrait = ZyruIncremental.Constants.Gods,
    -- HomingLaserTrait = ZyruIncremental.Constants.Gods,
    -- PoseidonAresProjectileTrait = ZyruIncremental.Constants.Gods,
    -- CurseSickTrait = ZyruIncremental.Constants.Gods,
    -- PoisonTickRateTrait = ZyruIncremental.Constants.Gods,
    -- ArtemisReflectBuffTrait = ZyruIncremental.Constants.Gods,
    -- RaritySuperBoost = ZyruIncremental.Constants.Gods,
    -- StationaryRiftTrait = ZyruIncremental.Constants.Gods,
    -- HeartsickCritDamageTrait = ZyruIncremental.Constants.Gods,
    -- AresHomingTrait = ZyruIncremental.Constants.Gods,
    -- IceStrikeArrayTrait = ZyruIncremental.Constants.Gods,
    -- ReboundingAthenaCastTrait = ZyruIncremental.Constants.Gods,
    -- AmmoBoltTrait = ZyruIncremental.Constants.Gods,
    -- DionysusAphroditeStackIncreaseTrait = ZyruIncremental.Constants.Gods,
    -- TriggerCurseTrait = ZyruIncremental.Constants.Gods,
    -- ArtemisBonusProjectileTrait = ZyruIncremental.Constants.Gods,
    -- CastBackstabTrait = ZyruIncremental.Constants.Gods,
    -- ImpactBoltTrait = ZyruIncremental.Constants.Gods,
    -- LightningCloudTrait = ZyruIncremental.Constants.Gods,
    -- RegeneratingCappedSuperTrait = ZyruIncremental.Constants.Gods,
    -- PoisonCritVulnerabilityTrait = ZyruIncremental.Constants.Gods,
    -- NoLastStandRegenerationTrait = ZyruIncremental.Constants.Gods,
    -- ImprovedPomTrait = ZyruIncremental.Constants.Gods,
    -- StatusImmunityTrait = ZyruIncremental.Constants.Gods,
    -- AutoRetaliateTrait = ZyruIncremental.Constants.Gods,
    
    -- Zeus
    ZeusWeaponTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusSecondaryTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusRangedTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ShieldLoadAmmo_ZeusRangedTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusRushTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusShoutTrait = ZyruIncremental.Constants.Gods.ZEUS,
    
    ZeusLightningDebuff = ZyruIncremental.Constants.Gods.ZEUS,
    
    ZeusBonusBounceTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusBonusBoltTrait = ZyruIncremental.Constants.Gods.ZEUS,
    ZeusBoltAoETrait = ZyruIncremental.Constants.Gods.ZEUS,
    RetaliateWeaponTrait = ZyruIncremental.Constants.Gods.ZEUS,
    PerfectDashBoltTrait = ZyruIncremental.Constants.Gods.ZEUS,
    SuperGenerationTrait = ZyruIncremental.Constants.Gods.ZEUS,
    OnWrathDamageBuffTrait = ZyruIncremental.Constants.Gods.ZEUS,
    
    ZeusChargedBoltTrait = ZyruIncremental.Constants.Gods.ZEUS,
    
    -- Athena
    AthenaWeaponTrait = ZyruIncremental.Constants.Gods.ATHENA,
    AthenaSecondaryTrait = ZyruIncremental.Constants.Gods.ATHENA,
    AthenaRangedTrait = ZyruIncremental.Constants.Gods.ATHENA,
    ShieldLoadAmmo_AthenaRangedTrait = ZyruIncremental.Constants.Gods.ATHENA,
    AthenaRushTrait = ZyruIncremental.Constants.Gods.ATHENA,
    AthenaShoutTrait = ZyruIncremental.Constants.Gods.ATHENA,
    
    AthenaBackstabDebuffTrait = ZyruIncremental.Constants.Gods.ATHENA,
    
    AthenaShieldTrait = ZyruIncremental.Constants.Gods.ATHENA,
    AthenaRetaliateTrait = ZyruIncremental.Constants.Gods.ATHENA,
    TrapDamageTrait = ZyruIncremental.Constants.Gods.ATHENA,
    EnemyDamageTrait = ZyruIncremental.Constants.Gods.ATHENA,
    LastStandHealTrait = ZyruIncremental.Constants.Gods.ATHENA,
    LastStandDurationTrait = ZyruIncremental.Constants.Gods.ATHENA,
    PreloadSuperGenerationTrait = ZyruIncremental.Constants.Gods.ATHENA,
    
    ShieldHitTrait = ZyruIncremental.Constants.Gods.ATHENA,
    
    -- Poseidon
    PoseidonWeaponTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    PoseidonSecondaryTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    PoseidonRangedTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    ShieldLoadAmmo_PoseidonRangedTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    PoseidonRushTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    PoseidonShoutTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    
    SlipperyTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    
    SlamExplosionTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    BonusCollisionTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    EncounterStartOffenseBuffTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    RandomMinorLootDrop = ZyruIncremental.Constants.Gods.POSEIDON,
    RoomRewardBonusTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    BossDamageTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    DefensiveSuperGenerationTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    PoseidonShoutDurationTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    
    DoubleCollisionTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    FishingTrait = ZyruIncremental.Constants.Gods.POSEIDON,
    
    -- Ares
    AresWeaponTrait = ZyruIncremental.Constants.Gods.ARES,
    AresSecondaryTrait = ZyruIncremental.Constants.Gods.ARES,
    AresRangedTrait = ZyruIncremental.Constants.Gods.ARES,
    ShieldLoadAmmo_AresRangedTrait = ZyruIncremental.Constants.Gods.ARES,
    AresRushTrait = ZyruIncremental.Constants.Gods.ARES,
    AresShoutTrait = ZyruIncremental.Constants.Gods.ARES,
    
    AresAoETrait = ZyruIncremental.Constants.Gods.ARES,
    AresDragTrait = ZyruIncremental.Constants.Gods.ARES,
    AresRetaliateTrait = ZyruIncremental.Constants.Gods.ARES,
    IncreasedDamageTrait = ZyruIncremental.Constants.Gods.ARES,
    OnEnemyDeathDamageInstanceBuffTrait = ZyruIncremental.Constants.Gods.ARES,
    LastStandDamageBonusTrait = ZyruIncremental.Constants.Gods.ARES,
    AresLongCurseTrait = ZyruIncremental.Constants.Gods.ARES,
    AresLoadCurseTrait = ZyruIncremental.Constants.Gods.ARES,
    
    AresCursedRiftTrait = ZyruIncremental.Constants.Gods.ARES,
    
    -- Aphrodite
    AphroditeWeaponTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeSecondaryTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeRangedTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    ShieldLoadAmmo_AphroditeRangedTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeRushTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeShoutTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    
    AphroditeDurationTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditePotencyTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeWeakenTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeRetaliateTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeDeathTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    ProximityArmorTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    HealthRewardBonusTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    AphroditeRangedBonusTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    
    CharmTrait = ZyruIncremental.Constants.Gods.APHRODITE,
    
    -- Artemis
    ArtemisWeaponTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisSecondaryTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisRangedTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ShieldLoadAmmo_ArtemisRangedTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisRushTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisShoutTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    
    CritVulnerabilityTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    
    CritBonusTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisSupportingFireTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisAmmoExitTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    ArtemisCriticalTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    CriticalBufferMultiplierTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    CriticalSuperGenerationTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    
    MoreAmmoTrait = ZyruIncremental.Constants.Gods.ARTEMIS,
    
    -- Dionysus
    DionysusWeaponTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusSecondaryTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusRangedTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    ShieldLoadAmmo_DionysusRangedTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusRushTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusShoutTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    
    DoorHealTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    LowHealthDefenseTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusGiftDrop = ZyruIncremental.Constants.Gods.DIONYSUS,
    FountainDamageBonusTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusSlowTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusSpreadTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusDefenseTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    DionysusPoisonPowerTrait = ZyruIncremental.Constants.Gods.DIONYSUS,
    
    DionysusComboVulnerability = ZyruIncremental.Constants.Gods.DIONYSUS,
    
    -- Demeter
    DemeterWeaponTrait = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterSecondaryTrait = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterRangedTrait = ZyruIncremental.Constants.Gods.DEMETER, --BEAM
    ShieldLoadAmmo_DemeterRangedTrait = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterRushTrait = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterShoutTrait = ZyruIncremental.Constants.Gods.DEMETER,
    
    ZeroAmmoBonusTrait = ZyruIncremental.Constants.Gods.DEMETER,
    MaximumChillBlast = ZyruIncremental.Constants.Gods.DEMETER,
    MaximumChillBonusSlow = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterRetaliateTrait = ZyruIncremental.Constants.Gods.DEMETER,
    CastNovaTrait = ZyruIncremental.Constants.Gods.DEMETER,
    HealingPotencyTrait = ZyruIncremental.Constants.Gods.DEMETER,
    HarvestBoonDrop = ZyruIncremental.Constants.Gods.DEMETER,
    DemeterRangedBonusTrait = ZyruIncremental.Constants.Gods.DEMETER,
    InstantChillKill = ZyruIncremental.Constants.Gods.DEMETER,
    
    -- Hermes
    BonusDashTrait = ZyruIncremental.Constants.Gods.HERMES,
    RushSpeedBoostTrait = ZyruIncremental.Constants.Gods.HERMES,
    MoveSpeedTrait = ZyruIncremental.Constants.Gods.HERMES,
    RushRallyTrait = ZyruIncremental.Constants.Gods.HERMES,
    DodgeChanceTrait = ZyruIncremental.Constants.Gods.HERMES,
    HermesWeaponTrait = ZyruIncremental.Constants.Gods.HERMES,
    HermesSecondaryTrait = ZyruIncremental.Constants.Gods.HERMES,
    ChamberGoldTrait = ZyruIncremental.Constants.Gods.HERMES,
    AmmoReclaimTrait = ZyruIncremental.Constants.Gods.HERMES,
    RapidCastTrait = ZyruIncremental.Constants.Gods.HERMES,
    AmmoReloadTrait = ZyruIncremental.Constants.Gods.HERMES,
    HermesShoutDodge = ZyruIncremental.Constants.Gods.HERMES,
    RegeneratingSuperTrait = ZyruIncremental.Constants.Gods.HERMES,
    
    SpeedDamageTrait = ZyruIncremental.Constants.Gods.HERMES,
    
    MagnetismTrait = ZyruIncremental.Constants.Gods.HERMES,
    UnstoredAmmoDamageTrait = ZyruIncremental.Constants.Gods.HERMES,
  }
end)
