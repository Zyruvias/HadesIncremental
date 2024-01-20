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
  
  end, Z)
  
  -- TraitData Setup
  ModUtil.LoadOnce(function ( )
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
    
    -- AphroditeDeathTrait = Z.Constants.Gods.APHRODITE,
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
      -- InstantChillKill = Z.Constants.Gods.DEMETER,
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
    -- RapidCastTrait = Z.Constants.Gods.HERMES,
    -- AmmoReloadTrait = Z.Constants.Gods.HERMES,
    -- RegeneratingSuperTrait = Z.Constants.Gods.HERMES,
    
    -- SpeedDamageTrait = Z.Constants.Gods.HERMES,
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
  end, Z)

-- SleepSoul's RCLib mappings as a baseline. Go check out his mods, he's brilliant.
ModUtil.LoadOnce(function ()

  Z.BoonToGod = {
    -- Uses in-game names for boons.
    -- Duos
    BlizzardOrbTrait = Z.Constants.Gods,
    SlowProjectileTrait = Z.Constants.Gods,
    SelfLaserTrait = Z.Constants.Gods,
    JoltDurationTrait = Z.Constants.Gods,
    HomingLaserTrait = Z.Constants.Gods,
    PoseidonAresProjectileTrait = Z.Constants.Gods,
    CurseSickTrait = Z.Constants.Gods,
    PoisonTickRateTrait = Z.Constants.Gods,
    ArtemisReflectBuffTrait = Z.Constants.Gods,
    RaritySuperBoost = Z.Constants.Gods,
    StationaryRiftTrait = Z.Constants.Gods,
    HeartsickCritDamageTrait = Z.Constants.Gods,
    AresHomingTrait = Z.Constants.Gods,
    IceStrikeArrayTrait = Z.Constants.Gods,
    ReboundingAthenaCastTrait = Z.Constants.Gods,
    AmmoBoltTrait = Z.Constants.Gods,
    DionysusAphroditeStackIncreaseTrait = Z.Constants.Gods,
    TriggerCurseTrait = Z.Constants.Gods,
    ArtemisBonusProjectileTrait = Z.Constants.Gods,
    CastBackstabTrait = Z.Constants.Gods,
    ImpactBoltTrait = Z.Constants.Gods,
    LightningCloudTrait = Z.Constants.Gods,
    RegeneratingCappedSuperTrait = Z.Constants.Gods,
    PoisonCritVulnerabilityTrait = Z.Constants.Gods,
    NoLastStandRegenerationTrait = Z.Constants.Gods,
    ImprovedPomTrait = Z.Constants.Gods,
    StatusImmunityTrait = Z.Constants.Gods,
    AutoRetaliateTrait = Z.Constants.Gods,
    
    -- Zeus
    ZeusWeaponTrait = Z.Constants.Gods.ZEUS,
    ZeusSecondaryTrait = Z.Constants.Gods.ZEUS,
    ZeusRangedTrait = Z.Constants.Gods.ZEUS,
    ShieldLoadAmmo_ZeusRangedTrait = Z.Constants.Gods.ZEUS,
    ZeusRushTrait = Z.Constants.Gods.ZEUS,
    ZeusShoutTrait = Z.Constants.Gods.ZEUS,
    
    ZeusLightningDebuff = Z.Constants.Gods.ZEUS,
    
    ZeusBonusBounceTrait = Z.Constants.Gods.ZEUS,
    ZeusBonusBoltTrait = Z.Constants.Gods.ZEUS,
    ZeusBoltAoETrait = Z.Constants.Gods.ZEUS,
    RetaliateWeaponTrait = Z.Constants.Gods.ZEUS,
    PerfectDashBoltTrait = Z.Constants.Gods.ZEUS,
    SuperGenerationTrait = Z.Constants.Gods.ZEUS,
    OnWrathDamageBuffTrait = Z.Constants.Gods.ZEUS,
    
    ZeusChargedBoltTrait = Z.Constants.Gods.ZEUS,
    
    -- Athena
    AthenaWeaponTrait = Z.Constants.Gods.ATHENA,
    AthenaSecondaryTrait = Z.Constants.Gods.ATHENA,
    AthenaRangedTrait = Z.Constants.Gods.ATHENA,
    ShieldLoadAmmo_AthenaRangedTrait = Z.Constants.Gods.ATHENA,
    AthenaRushTrait = Z.Constants.Gods.ATHENA,
    AthenaShoutTrait = Z.Constants.Gods.ATHENA,
    
    AthenaBackstabDebuffTrait = Z.Constants.Gods.ATHENA,
    
    AthenaShieldTrait = Z.Constants.Gods.ATHENA,
    AthenaRetaliateTrait = Z.Constants.Gods.ATHENA,
    TrapDamageTrait = Z.Constants.Gods.ATHENA,
    EnemyDamageTrait = Z.Constants.Gods.ATHENA,
    LastStandHealTrait = Z.Constants.Gods.ATHENA,
    LastStandDurationTrait = Z.Constants.Gods.ATHENA,
    PreloadSuperGenerationTrait = Z.Constants.Gods.ATHENA,
    
    ShieldHitTrait = Z.Constants.Gods.ATHENA,
    
    -- Poseidon
    PoseidonWeaponTrait = Z.Constants.Gods.POSEIDON,
    PoseidonSecondaryTrait = Z.Constants.Gods.POSEIDON,
    PoseidonRangedTrait = Z.Constants.Gods.POSEIDON,
    ShieldLoadAmmo_PoseidonRangedTrait = Z.Constants.Gods.POSEIDON,
    PoseidonRushTrait = Z.Constants.Gods.POSEIDON,
    PoseidonShoutTrait = Z.Constants.Gods.POSEIDON,
    
    SlipperyTrait = Z.Constants.Gods.POSEIDON,
    
    SlamExplosionTrait = Z.Constants.Gods.POSEIDON,
    BonusCollisionTrait = Z.Constants.Gods.POSEIDON,
    EncounterStartOffenseBuffTrait = Z.Constants.Gods.POSEIDON,
    RandomMinorLootDrop = Z.Constants.Gods.POSEIDON,
    RoomRewardBonusTrait = Z.Constants.Gods.POSEIDON,
    BossDamageTrait = Z.Constants.Gods.POSEIDON,
    DefensiveSuperGenerationTrait = Z.Constants.Gods.POSEIDON,
    PoseidonShoutDurationTrait = Z.Constants.Gods.POSEIDON,
    
    DoubleCollisionTrait = Z.Constants.Gods.POSEIDON,
    FishingTrait = Z.Constants.Gods.POSEIDON,
    
    -- Ares
    AresWeaponTrait = Z.Constants.Gods.ARES,
    AresSecondaryTrait = Z.Constants.Gods.ARES,
    AresRangedTrait = Z.Constants.Gods.ARES,
    ShieldLoadAmmo_AresRangedTrait = Z.Constants.Gods.ARES,
    AresRushTrait = Z.Constants.Gods.ARES,
    AresShoutTrait = Z.Constants.Gods.ARES,
    
    AresAoETrait = Z.Constants.Gods.ARES,
    AresDragTrait = Z.Constants.Gods.ARES,
    AresRetaliateTrait = Z.Constants.Gods.ARES,
    IncreasedDamageTrait = Z.Constants.Gods.ARES,
    OnEnemyDeathDamageInstanceBuffTrait = Z.Constants.Gods.ARES,
    LastStandDamageBonusTrait = Z.Constants.Gods.ARES,
    AresLongCurseTrait = Z.Constants.Gods.ARES,
    AresLoadCurseTrait = Z.Constants.Gods.ARES,
    
    AresCursedRiftTrait = Z.Constants.Gods.ARES,
    
    -- Aphrodite
    AphroditeWeaponTrait = Z.Constants.Gods.APHRODITE,
    AphroditeSecondaryTrait = Z.Constants.Gods.APHRODITE,
    AphroditeRangedTrait = Z.Constants.Gods.APHRODITE,
    ShieldLoadAmmo_AphroditeRangedTrait = Z.Constants.Gods.APHRODITE,
    AphroditeRushTrait = Z.Constants.Gods.APHRODITE,
    AphroditeShoutTrait = Z.Constants.Gods.APHRODITE,
    
    AphroditeDurationTrait = Z.Constants.Gods.APHRODITE,
    AphroditePotencyTrait = Z.Constants.Gods.APHRODITE,
    AphroditeWeakenTrait = Z.Constants.Gods.APHRODITE,
    AphroditeRetaliateTrait = Z.Constants.Gods.APHRODITE,
    AphroditeDeathTrait = Z.Constants.Gods.APHRODITE,
    ProximityArmorTrait = Z.Constants.Gods.APHRODITE,
    HealthRewardBonusTrait = Z.Constants.Gods.APHRODITE,
    AphroditeRangedBonusTrait = Z.Constants.Gods.APHRODITE,
    
    CharmTrait = Z.Constants.Gods.APHRODITE,
    
    -- Artemis
    ArtemisWeaponTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisSecondaryTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisRangedTrait = Z.Constants.Gods.ARTEMIS,
    ShieldLoadAmmo_ArtemisRangedTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisRushTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisShoutTrait = Z.Constants.Gods.ARTEMIS,
    
    CritVulnerabilityTrait = Z.Constants.Gods.ARTEMIS,
    
    CritBonusTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisSupportingFireTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisAmmoExitTrait = Z.Constants.Gods.ARTEMIS,
    ArtemisCriticalTrait = Z.Constants.Gods.ARTEMIS,
    CriticalBufferMultiplierTrait = Z.Constants.Gods.ARTEMIS,
    CriticalSuperGenerationTrait = Z.Constants.Gods.ARTEMIS,
    
    MoreAmmoTrait = Z.Constants.Gods.ARTEMIS,
    
    -- Dionysus
    DionysusWeaponTrait = Z.Constants.Gods.DIONYSUS,
    DionysusSecondaryTrait = Z.Constants.Gods.DIONYSUS,
    DionysusRangedTrait = Z.Constants.Gods.DIONYSUS,
    ShieldLoadAmmo_DionysusRangedTrait = Z.Constants.Gods.DIONYSUS,
    DionysusRushTrait = Z.Constants.Gods.DIONYSUS,
    DionysusShoutTrait = Z.Constants.Gods.DIONYSUS,
    
    DoorHealTrait = Z.Constants.Gods.DIONYSUS,
    LowHealthDefenseTrait = Z.Constants.Gods.DIONYSUS,
    DionysusGiftDrop = Z.Constants.Gods.DIONYSUS,
    FountainDamageBonusTrait = Z.Constants.Gods.DIONYSUS,
    DionysusSlowTrait = Z.Constants.Gods.DIONYSUS,
    DionysusSpreadTrait = Z.Constants.Gods.DIONYSUS,
    DionysusDefenseTrait = Z.Constants.Gods.DIONYSUS,
    DionysusPoisonPowerTrait = Z.Constants.Gods.DIONYSUS,
    
    DionysusComboVulnerability = Z.Constants.Gods.DIONYSUS,
    
    -- Demeter
    DemeterWeaponTrait = Z.Constants.Gods.DEMETER,
    DemeterSecondaryTrait = Z.Constants.Gods.DEMETER,
    DemeterRangedTrait = Z.Constants.Gods.DEMETER, --BEAM
    ShieldLoadAmmo_DemeterRangedTrait = Z.Constants.Gods.DEMETER,
    DemeterRushTrait = Z.Constants.Gods.DEMETER,
    DemeterShoutTrait = Z.Constants.Gods.DEMETER,
    
    ZeroAmmoBonusTrait = Z.Constants.Gods.DEMETER,
    MaximumChillBlast = Z.Constants.Gods.DEMETER,
    MaximumChillBonusSlow = Z.Constants.Gods.DEMETER,
    DemeterRetaliateTrait = Z.Constants.Gods.DEMETER,
    CastNovaTrait = Z.Constants.Gods.DEMETER,
    HealingPotencyTrait = Z.Constants.Gods.DEMETER,
    HarvestBoonDrop = Z.Constants.Gods.DEMETER,
    DemeterRangedBonusTrait = Z.Constants.Gods.DEMETER,
    InstantChillKill = Z.Constants.Gods.DEMETER,
    
    -- Hermes
    BonusDashTrait = Z.Constants.Gods.HERMES,
    RushSpeedBoostTrait = Z.Constants.Gods.HERMES,
    MoveSpeedTrait = Z.Constants.Gods.HERMES,
    RushRallyTrait = Z.Constants.Gods.HERMES,
    DodgeChanceTrait = Z.Constants.Gods.HERMES,
    HermesWeaponTrait = Z.Constants.Gods.HERMES,
    HermesSecondaryTrait = Z.Constants.Gods.HERMES,
    ChamberGoldTrait = Z.Constants.Gods.HERMES,
    AmmoReclaimTrait = Z.Constants.Gods.HERMES,
    RapidCastTrait = Z.Constants.Gods.HERMES,
    AmmoReloadTrait = Z.Constants.Gods.HERMES,
    HermesShoutDodge = Z.Constants.Gods.HERMES,
    RegeneratingSuperTrait = Z.Constants.Gods.HERMES,
    
    SpeedDamageTrait = Z.Constants.Gods.HERMES,
    
    MagnetismTrait = Z.Constants.Gods.HERMES,
    UnstoredAmmoDamageTrait = Z.Constants.Gods.HERMES,
  }
end)
