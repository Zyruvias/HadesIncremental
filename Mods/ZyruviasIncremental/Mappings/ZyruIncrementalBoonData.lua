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
      --[[
        Boons that inherit from ShopTier1Trait and DO NOT need overrides:
        Zeus: RetaliateWeaponTrait, ZeusLightningDebuff, 
      ]]--
      ShopTier1Trait = {
        RarityLevels = T1RarityTable
      },
      ShopTier2Trait = {
        RarityLevels = T2RarityTable
      },
      -- Zeus Boons
      SuperGenerationTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      ZeusBoltAoETrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      ZeusBonusBoltTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      -- I fucking hate this
      ZeusBonusBounce = {
        RarityLevels = scalingTable(5, 1)
      },
      ZeusWeaponTrait = {
        RarityLevels = scalingTable(2.5, 0.5, 0.5)
      },
      ZeusSecondaryTrait = {
        RarityLevels = scalingTable(2.5, 0.5, 0.5)
      },
      ZeusRangedTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      PerfectDashBoltTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      ZeusRushTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      ZeusShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      OnWrathDamageBuffTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      -- Athena Boons
      AthenaRangedTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      AthenaRushTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      AthenaBackstabDebuffTrait = { 
        RarityLevels = scalingTable(2, 0.25)
      },
      AthenaShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      EnemyDamageTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
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
      LastStandHealTrait = {
        RarityLevels = StaticMultiplierTable
      },
      LastStandDurationTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      PreloadSuperGenerationTrait = {
        RarityLevels = scalingTable(2.5, 0.5, 0.5)
      },
      -- Aphrodite Boons
      HealthRewardBonusTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      AphroditeDurationTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      AphroditePotencyTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      AphroditeRangedTrait = {
        RarityLevels = scalingTable(1.444, 0.111, 0.333)
      },
      AphroditeRangedBonusTrait = {
        RarityLevels = scalingTable(3, 0.5),
        -- increasing DamageRadius
        PropertyChanges = {
          {},
          { ChangeValue = 1.5},
        },
      },
      AphroditeRushTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      AphroditeShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      AphroditeWeakenTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      AphroditeRetaliateTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      ProximityArmorTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },

      -- Ares Boons
      AresWeaponTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      AresSecondaryTrait = {
        RarityLevels = scalingTable(2.333, 0.333, 0.333)
      },
      -- OnSpawnSwordTrait
      AresRangedTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.3)
      },
      AresRushTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      AresShoutTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      AresAoETrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.3)
      },
      AresLoadCurseTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      
      AresLongCurseTrait = {
        RarityLevels = scalingTable(1.5, 0.25, 0.5)
      },
      AresRetaliateTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      IncreasedDamageTrait = {
        RarityLevels = scalingTable(2.4, 0.4)
      },
      LastStandDamageBonusTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      OnEnemyDeathDamageInstanceBuffTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },


      -- Artemis Boons
      ArtemisRangedTrait = {
        RarityLevels = scalingTable(1.58, 0.145, 0.435)
      },
      ArtemisRushTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      ArtemisCriticalTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      -- CriticalBufferMultiplierTrait rework?
      CriticalSuperGenerationTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4),
        CriticalSuperGainAmount = {
          BaseValue = 1
        },
      },
      ArtemisShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      CritBonusTrait = {
        RarityLevels = scalingTable(3, 0.5, 1)
      },
      ArtemisAmmoExitTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      --TODO: CritVulnerabilityTrait = {}
      ArtemisSupportingFireTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },

      -- Dionysus Boons
      DionysusSlowTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      GiftHealthTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      FountainDamageBonusTrait = {
        RarityLevels = scalingTable(2.333, 0.333, 0.333)
      },
      DionysusWeaponTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      DionysusSecondaryTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      DionysusRangedTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      DionysusRushTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      DionysusShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      DoorHealTrait = {
        RarityLevels = scalingTable(2.2666, 0.2666)
      },
      -- Demeter Boons
      DemeterRangedTrait = {
        RarityLevels = scalingTable(1.6, 0.15, 0.3)
      },
      DemeterRangedBonusTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      DemeterRushTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      DemeterShoutTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      HealingPotencyTrait = {
        RarityLevels = scalingTable(1.3, 0.1, 0.3)
      },
      CastNovaTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      ZeroAmmoBonusTrait = {
        RarityLevels = scalingTable(5, 1, 1)
      },
      MaximumChillBlast = {
        RarityLevels = scalingTable(1.5, 0.125)
      },
      -- TODO: HarvestBoonTrait rework?
      DemeterRetaliateTrait = {
        RarityLevels = scalingTable(3, 0.5),
        PropertyChanges = {
          { BaseMin = 40, BaseMax = 40},
        },
      },
      -- Poseidon Boons
      PoseidonRangedTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      PoseidonRushTrait = {
        RarityLevels = scalingTable(1.8, 0.2, 0.4)
      },
      DefensiveSuperGenerationTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      PoseidonShoutDurationTrait = {
        RarityLevels = scalingTable(2, 0.25)
      },
      BonusCollisionTrait = {
        RarityLevels = {
          RarityLevels = scalingTable(2, 0.25)
        },
      },
      SlamExplosionTrait = {
        RarityLevels = {
          RarityLevels = scalingTable(3, 0.5)
        },
      },
      SlipperyTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      BossDamageTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      RoomRewardBonusTrait = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },

      -- Hermes Boons
      HermesShoutDodge = {
        RarityLevels = scalingTable(1.4, 0.1, 0.2)
      },
      BonusDashTrait = {
        RarityLevels = scalingTable(5, 1)
      },
      DodgeChanceTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      -- TODO: RapidCastTrait
      -- TODO: Hypersprint already good enough???
      RushSpeedBoostTrait = {
        RarityLevels = scalingTable(2, 0.2, 0.2)
      },
      MoveSpeedTrait = {
        RarityLevels = scalingTable(1.33333, 0.08333)
      },
      RushRallyTrait = {
        RarityLevels = scalingTable(0.7, 0.05)
      },
      HermesWeaponTrait = {
        RarityLevels = scalingTable(0.7, -0.14, -0.14)
      },
      HermesSecondaryTrait = {
        RarityLevels = scalingTable(5, 1, 1)
      },
      -- TODO: RegeneratingSuperTrait should not be better than smoldering air
      
      ChamberGoldTrait = {
        RarityLevels = scalingTable(2.2, 0.4, 1.2)
      },
      SpeedDamageTrait = {
        RarityLevels = scalingTable(3, 0.5)
      },
      -- TODO: Beowulf casts
    })
  end, Z)