ZyruIncremental.TraitData = {
    -- Hermes Duo Boons
    ZeusHermesSynergyTrait = {
        Name = "ZeusHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "ZeusHermesSynergyTrait" },
        Icon = "Demeter_Artemis_01",
        PropertyChanges =
        {
            {
                TraitName = "ImpactBoltTrait",
                WeaponName = "LightningStrikeImpact",
                WeaponProperty = "Cooldown",
                ChangeValue = 0,
                Absolute = true,
            },
            {
                TraitName = "ZeusWeaponTrait",
                WeaponName = "ChainLightning",
                WeaponProperty = "Cooldown",
                ChangeValue = 0,
                Absolute = true,
            },
            {
                TraitName = "ZeusSecondaryTrait",
                WeaponName = "LightningStrikeSecondary",
                ProjectileProperty = "ImmunityDuration",
                ChangeValue = 0,
                Absolute = true,
            },
            {
                TraitName = "ZeusRushTrait",
                WeaponName = "LightningDash",
                ProjectileProperty = "ImmunityDuration",
                ChangeValue = 0,
                Absolute = true,
            },
            -- change "cooldown"
            {
                TraitName = "ZeusChargedBoltTrait",
                WeaponName = "ZeusLegendaryWeapon",
                ProjectileName = "LightningSpark",
                WeaponProperty = "ClipRegenInterval",
                ChangeValue = 0.01,
                Absolute = true,
            },
            -- each cooldown, restore full "clip"
            {
                TraitName = "ZeusChargedBoltTrait",
                WeaponName = "ZeusLegendaryWeapon",
                ProjectileName = "LightningSpark",
                WeaponProperty = "FullClipRegen",
                ChangeValue = true,
            },
        },
    },

    PoseidonHermesSynergyTrait = {
        Name = "PoseidonHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "PoseidonHermesSynergyTrait" },
        Icon = "Demeter_Artemis_02",
        OnDamageEnemyFunction = {
            FunctionName = "PoseidonHermesDamageLoot",
            FunctionArgs = {},
        },
    },

    ArtemisHermesSynergyTrait = {
        Name = "ArtemisHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "ArtemisHermesSynergyTrait" },
        Icon = "Demeter_Artemis_02",
        OnEnemyCrittedFunction = {
            Name = "AddCritSpeedBoost",
            Args = { },
        },
    },

    DionysusHermesSynergyTrait = {
        Name = "DionysusHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "DionysusHermesSynergyTrait" },
        Icon = "Demeter_Artemis_01",
        PropertyChanges = {
            {
                WeaponNames = WeaponSets.HeroPhysicalWeapons,
                TraitName = "DionysusWeaponTrait",
                EffectName = "DamageOverTime",
                EffectProperty = "StackAmount",
                DeriveValueFrom = "MaxStacks",
                ChangeValue = true,
            },
        },
    },

    -- TODO: on death defiance instead?
    AresHermesSynergyTrait = {
        Name = "AresHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "AresHermesSynergyTrait" },
        Icon = "Demeter_Artemis_01",
        OnEnemyKillFunction = {
            Name = "IncreaseBloodlust",
            Args = {},
        },
        OnHeroDamageTakenFunction = {
            Name = "ResetBloodlust",
            Args = {},
        },
        BloodlustDamageMultiplier =  1.05,
        AddOutgoingDamageModifiers =
        {
            UseTraitValue = "BloodlustDamageBonus",
        },
        BloodlustDamageBonus = 1,
    },

    AphroditeHermesSynergyTrait = {
        Name = "AphroditeHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "AphroditeHermesSynergyTrait" },
        Icon = "Demeter_Artemis_01",
        AddOnDodgeWeapons = { Weapon = "AphroditeSuperCharm" },
        
        PreEquipWeapons = { "AphroditeSuperCharm", },
        PropertyChanges =
        {
            -- {
            --     TraitName = "AphroditeHermesSynergyTrait",
            --     WeaponName = "DeathAreaWeakenAphrodite",
            --     ProjectileProperty = "DamageLow",
            --     BaseMin = 125,
            --     BaseMax = 125,
            --     IdenticalMultiplier =
            --     {
            --         Value = DuplicateVeryStrongMultiplier,
            --     },
            --     ExtractValue =
            --     {
            --         ExtractAs = "TooltipDamage",
            --     },
            -- },
            -- {
            --     WeaponName = "DeathAreaWeakenAphrodite",
            --     ProjectileProperty = "DamageHigh",
            --     DeriveValueFrom = "DamageLow",
            -- },
            {
                WeaponNames = { "AphroditeSuperCharm", "AphroditeMaxSuperCharm",},
                EffectName = "Charm",
                EffectProperty = "Duration",
                BaseValue = 5,
                ChangeType = "Add",
                MinMultiplier = 0.2,
                IdenticalMultiplier =
                {
                    Value = -0.9,
                },
                ExtractValue =
                {
                    ExtractAs = "TooltipDuration",
                    DecimalPlaces = 1,
                },
            },
        },
    },

    DemeterHermesSynergyTrait = {
        Name = "DemeterHermesSynergyTrait",
        InheritFrom = { "SynergyTrait" },
        RequiredFalseTraits = { "DemeterHermesSynergyTrait" },
        Icon = "Demeter_Artemis_01",
        PropertyChanges = {
            {
                WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
                ProjectileProperty = "UnlimitedUnitPenetration",
                ChangeValue = true,
                ChangeType = "Absolute"
            },
            {
                WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
                ProjectileProperty = "Range",
                ChangeValue = 10,
                ChangeType = "Multiply"
            },
        },
    },
    ChangingTidesLegendary = {
        Name = "ChangingTidesLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "ChangingTidesLegendary" },
        Icon = "Demeter_Artemis_01",
        SetupFunction = {
            Name = "ZyruIncremental.SetupPoseidonVacuum",
            RunOnce = true,
        },
    },
    
    SeductiveVictoryLegendary = {
        Name = "SeductiveVictoryLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "SeductiveVictoryLegendary" },
        Icon = "Demeter_Artemis_01",
        SetupFunction = {
            Name = "ZyruIncremental.SetupSeductiveVictory",
            RunOnce = true,
        },
    },

    PermanentVulnerabilityLegendary = {
        Name = "PermanentVulnerabilityLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "PermanentVulnerabilityLegendary" },
        Icon = "Demeter_Zeus_01",
        SetupFunction = {
            Name = "ZyruIncremental.SetupPermanentVulnerability",
            RunOnce = true,
        },
        PropertyChanges = {
            {
                WeaponName = "CritVulnerabilityWeapon",
                EffectName = "CritVulnerability",
                EffectProperty = "Duration",
                ChangeValue = 100000,
                ChangeType = "Absolute",
            },
        },
    },

    UnendingHangoverLegendary = {
        Name = "UnendingHangoverLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "UnendingHangoverLegendary" },
        Icon = "Demeter_Zeus_01",
        PropertyChanges = {
            {
                WeaponNames = WeaponSets.HeroPhysicalWeapons,
                EffectName = "DamageOverTime",
                EffectProperty = "Duration",
                ChangeType = "Absolute",
                ChangeValue = 100000,
                -- ExtractValue =
                -- {
                --     ExtractAs = "TooltipPoisonDuration",
                --     SkipAutoExtract = true,
                --     External = true,
                --     BaseType = "Effect",
                --     WeaponName = "SwordWeapon",
                --     BaseName = "DamageOverTime",
                --     BaseProperty = "Duration",
                -- },
            },
            {
                WeaponNames = WeaponSets.HeroSecondaryWeapons,
                EffectName = "DamageOverTime",
                EffectProperty = "Duration",
                ChangeType = "Absolute",
                ChangeValue = 100000,
            },
            {
                WeaponNames = WeaponSets.HeroRushWeapons,
                EffectName = "DamageOverTime",
                EffectProperty = "Duration",
                ChangeType = "Absolute",
                ChangeValue = 100000,
            },
        },
    },

    StrategicCooperationBlessingLegendary = {
        Name = "StrategicCooperationBlessingLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "StrategicCooperationBlessingLegendary" },
        Icon = "Demeter_Zeus_01",
        SetupFunction = {
            Name = "ZyruIncremental.SetupStrategicCooperationBlessingLegendary",
            RunOnce = true,
        },
        StrategicCooperationBlessingDamageBonus = 1,
        AddOutgoingDamageModifiers =
        {
            UseTraitValue = "StrategicCooperationBlessingDamageBonus",
        },
    },

    -- TODO: use ShortDescription in the help text

    ChaosRandomStatusLegendary = {
        Name = "ChaosRandomStatusLegendary",
        InheritFrom = { "ChaosBlessingTrait" },
        RequiredFalseTraits = { "ChaosRandomStatusLegendary" },
        PreEquipWeapons = {
            "ChaosDoomApplicator",
            "ChaosWeakApplicator",
            "ChaosCritVulnerabilityApplicator",
            "ChaosJoltedApplicator",
            "ChaosHangoverApplicator",
            "ChaosShoalsApplicator",
            "ChaosBackstabVulnerabilityApplicator",
        },
        CustomName = "lol lmfao", -- TODO: fix this shiiiiit
        Icon = "Boon_Chaos_Blessing_08",
        OnHitEnemyFunction = {
            Name = "ZyruIncremental.ApplyChaosStatuses"
        },
        RarityLevels =
        {
            Legendary =
            {
                MinMultiplier = 1,
                MaxMultiplier = 1,
            },
        },
        ChanceToPlay = 0.20, --TODO: do I need this??
        -- NOTE: This is Chaos's version of `LinkedUpgrades`. I hate it.
        RequiredOneOfTraits =  { "ChaosBlessingMeleeTrait", "ChaosBlessingRangedTrait", "ChaosBlessingAmmoTrait", "ChaosBlessingMaxHealthTrait", "ChaosBlessingBoonRarityTrait", "ChaosBlessingMoneyTrait", "ChaosBlessingMetapointTrait", "ChaosBlessingSecondaryTrait", "ChaosBlessingDashAttackTrait","ChaosBlessingBackstabTrait", "ChaosBlessingAlphaStrikeTrait" },
        RequiredRunHasOneOfTraits = {
            -- Standard PriorityChance Statuses
            "ZeusLightningDebuff", "CritVulnerabilityTrait", "AthenaBackstabDebuffTrait", "SlipperyTrait",
            -- "Innate" Statuses
            "DionysusWeaponTrait", "DionysusSecondaryTrait", "DionysusRushTrait", "DionysusShoutTrait",
            "AphroditeWeaponTrait", "AphroditeSecondaryTrait", "AphroditeRushTrait", "AphroditeRangedTrait", "AphroditeRetaliateTrait", "AphroditeDeathTrait",
            "DemeterWeaponTrait", "DemeterSecondaryTrait", "DemeterRushTrait", "DemeterShoutTrait", "DemeterRetaliateTrait", "DemeterRangedBonusTrait",
            "AresWeaponTrait", "AresSecondaryTrait", "AresRetaliateTrait",
        },
        PropertyChanges = {
            -- Doom
            {
                WeaponName = "ChaosDoomApplicator",
                EffectName = "DelayedDamage",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            {
                WeaponName = "ChaosDoomApplicator",
                EffectName = "DelayedDamage",
                EffectProperty = "Amount",
                BaseMin = 100,
                BaseMax = 100,
                -- DeriveFrom damage source, setupFunction maybe?
            },
            -- Weaken
            {
                WeaponName = "ChaosWeakApplicator",
                EffectName = "ReduceDamageOutput",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            -- Hunter's Mark
            {
                WeaponName = "ChaosCritVulnerabilityApplicator",
                EffectName = "CritVulnerability",
                EffectProperty = "CritVulnerabilityAddition",
                BaseValue = 0.25,
            },
            -- Jolted
            {
                WeaponName = "ChaosJoltedApplicator",
                EffectName = "ZeusAttackPenalty",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            {
                WeaponName = "ZeusAttackBolt",
                ProjectileProperty = "DamageLow",
                BaseMin = 60,
                BaseMax = 60,
                DepthMult = DepthDamageMultiplier,
                IdenticalMultiplier =
                {
                    Value = DuplicateStrongMultiplier,
                },
                ExtractValue =
                {
                    ExtractAs = "TooltipDamage",
                },
            },
            -- Dionysus
            {
                WeaponName = "ChaosHangoverApplicator",
                EffectName = "DamageOverTime",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            {
                WeaponName = "ChaosHangoverApplicator",
                EffectName = "DamageOverTime",
                EffectProperty = "Amount",
                ChangeType = "Add",
                BaseMin = 8,
                BaseMax = 8,
                MinMultiplier = 0.335,
                AsInt = true,
            },
            -- Backstab Vulnerability
            
            {
                WeaponName = "ChaosBackstabVulnerabilityApplicator",
                EffectName = "AthenaBackstabVulnerability",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            {
                WeaponName = "ChaosBackstabVulnerabilityApplicator",
                EffectName = "AthenaBackstabVulnerability",
                EffectProperty = "Modifier",
                BaseValue = 0.50,
                DepthMult = DepthDamageMultiplier,
                ChangeType = "Add",
            },
            -- Shoals
            {
                WeaponName = "ChaosShoalsApplicator",
                EffectName = "DamageOverDistance",
                EffectProperty = "Active",
                ChangeValue = true,
            },
            {
                WeaponName = "ChaosShoalsApplicator",
                EffectName = "DamageOverDistance",
                EffectProperty = "MaxTriggerDamage",
                BaseValue = 10,
                MinMultiplier = 0.2,
                ChangeType = "Add",
            },
        },
    },

    DemeterFamineLegendary = {
        Name = "DemeterFamineLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "DemeterFamineLegendary" },
        Icon = "Demeter_Zeus_01",
        SetupFunction = {
            Name = "ZyruIncremental.SetupDemeterFamineLegendary",
            RunOnce = true,
        },
        FamineHealthMultiplier = 1,
    },

    HermesAfterImageLegendary = {
        Name = "HermesAfterImageLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = {
            "HermesAfterImageLegendary",
            -- TODO: No mirage, curse of drowning, ... etc?
        },
        Icon = "Demeter_Zeus_01",
        OnHitEnemyFunction = {
            Name = "ZyruIncremental.ApplyAfterImageLegendary"
        },
    },

    AresMurderousEfficacyLegendary = {
        Name = "AresMurderousEfficacyLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "AresMurderousEfficacyLegendary" },
        Icon = "Demeter_Zeus_01",
        AddOutgoingDamageModifiers =
		{
			ValidWeaponMultiplier =
			{
				BaseValue = 1.5,
				SourceIsMultiplier = true
			},
			ExtractValues =
			{
				{
					Key = "ValidWeaponMultiplier",
					ExtractAs = "TooltipDamage",
					Format = "PercentDelta",
				},
			},
		},
    },

    ZeusChainRangeLegendary = {
        Name = "ZeusChainRangeLegendary",
        InheritFrom = { "ShopTier3Trait" },
        RequiredFalseTraits = { "ZeusChainRangeLegendary" },
        Icon = "Demeter_Zeus_01",
        PropertyChanges = {
            {
				WeaponName = "ChainLightning",
				ProjectileProperty = "NumJumps",
                ChangeValue = 100000,
                ChangeType = "Add"
            },
            {
				WeaponName = "ChainLightning",
				ProjectileProperty = "JumpDamageMultiplier",
                ChangeValue = 1.2,
                ChangeType = "Absolute"
            },
            {
				WeaponName = "ChainLightning",
				ProjectileProperty = "JumpRange",
                ChangeValue = 100000,
                ChangeType = "Absolute"
            },
            {
				WeaponName = "ChainLightning",
				ProjectileProperty = "Range",
                ChangeValue = 100000,
                ChangeType = "Absolute"
            },
        },

    },

}

--[[
    Upgrade shape: {
        Name
        Cost
        OnApplyFunction
        OnApplyFunctionArgs
        Source?
        Sources?
    }
    ]]--
ZyruIncremental.UpgradeData = {

    -----------------
    -- HERMES DUOS --
    -----------------
    ZeusHermesSynergyTrait = {
        Name = "ZeusHermesSynergyTraitUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Sources = { ZyruIncremental.Constants.Gods.ZEUS, ZyruIncremental.Constants.Gods.HERMES },
        Costs = {
            [ZyruIncremental.Constants.Gods.ZEUS] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "ZeusHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "ZeusUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "HermesWeaponTrait", "HermesSecondaryTrait" },
                    { "ZeusWeaponTrait", "ZeusSecondaryTrait" },
                },
            },
        },
    },

    PoseidonHermesSynergyTrait = {
        Name = "PoseidonHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.POSEIDON] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "PoseidonHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "PoseidonUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "ChamberGoldTrait" },
                    { "PoseidonPickedUpMinorLootTrait", "RoomRewardBonusTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.POSEIDON, ZyruIncremental.Constants.Gods.HERMES },
    },

    ArtemisHermesSynergyTrait = {
        Name = "ArtemisHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ARTEMIS] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "ArtemisHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "ArtemisUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "HermesMoveSpeedTrait", "RushSpeedBoostTrait" },
                    { "ArtemisWeaponTrait", "ArtemisSecondaryTrait", "ArtemisRangedTrait", "ArtemisShoutTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.ARTEMIS, ZyruIncremental.Constants.Gods.HERMES },
    },
    DionysusHermesSynergyTrait = {
        Name = "DionysusHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.DIONYSUS] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "DionysusHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "DionysusUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "HermesMoveSpeedTrait", "RushSpeedBoostTrait" },
                    { "DionysusWeaponTrait", "DionysusSecondaryTrait", "DionysusRangedTrait", "DionysusShoutTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.DIONYSUS, ZyruIncremental.Constants.Gods.HERMES },
    },

    AresHermesSynergyTrait = {
        Name = "AresHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ARES] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "AresHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AresUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "HermesMoveSpeedTrait", "RushSpeedBoostTrait", "FastClearDodgeBonusTrait", "SpeedDamageTrait" },
                    { "IncreasedDamageTrait", "LastStandDamageBonusTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.ARES, ZyruIncremental.Constants.Gods.HERMES },
    },

    AphroditeHermesSynergyTrait = {
        Name = "AphroditeHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.APHRODITE] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "AphroditeHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AphroditeUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "DodgeChanceTrait", "HermesShoutDodge" },
                    { "AphroditeWeaponTrait", "AphroditeSecondaryTrait", "AphroditeRangedTrait", "AphroditeRushTrait", "AphroditeRetaliateTrait", "AphroditeDeathTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.APHRODITE, ZyruIncremental.Constants.Gods.HERMES },
    },

    DemeterHermesSynergyTrait = {
        Name = "DemeterHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.DEMETER] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "DemeterHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "DemeterUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "RapidCastTrait", "AmmoReloadTrait" },
                    { "DemeterRangedTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.DEMETER, ZyruIncremental.Constants.Gods.HERMES },
    },

    -- TODO: make this
    AthenaHermesSynergyTrait = {
        Name = "AthenaHermesSynergyTrait",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ATHENA] = 100,
            [ZyruIncremental.Constants.Gods.HERMES] = 10,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "AthenaHermesSynergyTrait",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AthenaUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "RapidCastTrait", "AmmoReloadTrait" },
                    { "DemeterRangedTrait" },
                },
            },
        },
        Sources = { ZyruIncremental.Constants.Gods.ATHENA, ZyruIncremental.Constants.Gods.HERMES },
    },

    -----------------
    -- ARES        --
    -----------------
    -----------------
    -- POSEIDON    --
    -----------------
    -----------------
    -- ZEUS        --
    -----------------
    -----------------
    -- ATHENA      --
    -----------------
    -----------------
    -- ARTEMIS     --
    -----------------
    -----------------
    -- DEMETER     --
    -----------------
    -----------------
    -- ARES        --
    -----------------
    -----------------
    -- NYX / MIRROR--
    -----------------

    -- POSEIDON
    ChangingTidesLegendaryUpgrade = {
        Name = "ChangingTidesLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.POSEIDON] = 100,
        },
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "ChangingTidesLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "PoseidonUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    -- TODO: add poseidon prereqs
                    -- { "RapidCastTrait", "AmmoReloadTrait" },
                    -- { "DemeterRangedTrait" },
                    --TODO: beowulf flare
                    { "PoseidonWeaponTrait", "PoseidonSecondaryTrait", "PoseidonRangedTrait", "PoseidonRushTrait"},
                    { "SlipperyTrait" },
                },
            },
        },
        Source = ZyruIncremental.Constants.Gods.POSEIDON,
    },

    -- APHRODITE
    SeductiveVictoryUpgrade = {
        Name = "SeductiveVictoryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.APHRODITE] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.APHRODITE,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "SeductiveVictoryLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AphroditeUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "AphroditeWeaponTrait", "AphroditeSecondaryTrait", "AphroditeRangedTrait", "AphroditeRushTrait"},
                    { "AphroditeDurationTrait" },
                },
            },
        },
    },

    -- ARTEMIS LEGENDARY
    PermanentVulnerabilityLegendaryUpgrade = {
        Name = "PermanentVulnerabilityLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ARTEMIS] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.ARTEMIS,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "PermanentVulnerabilityLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "ArtemisUpgrade",
            LinkedUpgrades = {
                OneOf = { "CritVulnerabilityTrait" },
            },
        },
    },

    -- DIONYSUS LEFENGDARY
    UnendingHangoverLegendaryUpgrade = {
        Name = "UnendingHangoverLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.DIONYSUS] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.DIONYSUS,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "UnendingHangoverLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "DionysusUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "DionysusWeaponTrait", "DionysusSecondaryTrait", "DionysusRushTrait", "DionysusShoutTrait", },
                    { "FountainDamageBonusTrait", "GiftHealthTrait" },
                },
            },
        },
    },

    -- ATHENA LEFENGDARY
    StrategicCooperationBlessingLegendaryUpgrade = {
        Name = "StrategicCooperationBlessingLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ATHENA] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.ATHENA,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "StrategicCooperationBlessingLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AthenaUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "AthenaWeaponTrait", "AthenaSecondaryTrait", "AthenaRushTrait", "AthenaRangedTrait", "AthenaShoutTrait", },
                    {
                        -- From CodexMenu Mod
                        "LightningCloudTrait", "AutoRetaliateTrait", "AmmoBoltTrait", "ImpactBoltTrait", 
                        "ReboundingAthenaCastTrait", "JoltDurationTrait", "ImprovedPomTrait", "RaritySuperBoost", 
                        "BlizzardOrbTrait", "TriggerCurseTrait", "SlowProjectileTrait", "ArtemisReflectBuffTrait", 
                        "CurseSickTrait", "HeartsickCritDamageTrait", "DionysusAphroditeStackIncreaseTrait", "AresHomingTrait", 
                        "IceStrikeArrayTrait", "HomingLaserTrait", "RegeneratingCappedSuperTrait", "StatusImmunityTrait", 
                        "PoseidonAresProjectileTrait", "CastBackstabTrait", "NoLastStandRegenerationTrait", "PoisonTickRateTrait", 
                        "StationaryRiftTrait", "SelfLaserTrait", "ArtemisBonusProjectileTrait", "PoisonCritVulnerabilityTrait",
                        -- Incremental Duos
                        "ZeusHermesSynergyTrait", "PoseidonHermesSynergyTrait",
                        "AthenaHermesSynergyTrait", -- TODO: Make this <-
                        "DemeterHermesSynergyTrait", "DionysusHermesSynergyTrait", "ArtemisHermesSynergyTrait", "AphroditeHermesSynergyTrait",
                        "AresHermesSynergyTrait",
                        -- Legendaries
                        "ZeusChargedBoltTrait", "MoreAmmoTrait", "DionysusComboVulnerability", "InstantChillKill", "DoubleCollisionTrait",
                        "ShieldHitTrait", "CharmTrait", "AresCursedRiftTrait", "MagnetismTrait", "UnstoredAmmoDamageTrait",
                        -- Incremental Legendaries
                        -- TODO: Add these after initial implementation round
                    },
                },
            },
        },
    },

    -- CHAOS LEGENDARY
    ChaosRandomStatusLegendaryUpgrade = {
        Name = "ChaosRandomStatusLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.CHAOS] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.CHAOS,
        OnApplyFunctions =  { "ZyruIncremental.AddTraitToTraitData", "ZyruIncremental.MergeDataArrays"},
        OnApplyFunctionArgs = { 
            { Name = "ChaosRandomStatusLegendary" },
            { 
                {
                    Array = "LootData.TrialUpgrade.PermanentTraits",
                    Value = { "ChaosRandomStatusLegendary" },
                },
            },
        },

    },

    -- DEMETER LEGENDARY
    DemeterFamineLegendaryUpgrade = {
        Name = "DemeterFamineLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.DEMETER] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.DEMETER,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "DemeterFamineLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "DemeterUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    { "DemeterWeaponTrait", "DemeterSecondaryTrait", "DemeterRushTrait", "DemeterShoutTrait", },
                    { "HealingPotencyTrait", "MaximumChillBonusSlow" },
                },
            },
        },
    },

    -- HermesAfterImageLegendaryUpgrade = {
    --     Name = "HermesAfterImageLegendaryUpgrade",
    --     Cost = 0,
    --     CostType = "",
    --     Source = ZyruIncremental.Constants.Gods.HERMES,
    --     OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
    --     OnApplyFunctionArgs = { 
    --         Name = "HermesAfterImageLegendary",
    --         AddLinkedUpgrades = true,
    --         LinkedUpgradeName = "HermesUpgrade",
    --         LinkedUpgrades = {
    --             OneFromEachSet = {
    --                 {
    --                     "HermesWeaponTrait",
    --                     "HermesSecondaryTrait",
    --                     "RapidCastTrait",
    --                     "AmmoReloadTrait",
    --                     "AmmoReclaimTrait",
    --                     "BonusDashTrait",
    --                 },
    --                 {
    --                     -- ATTACK
    --                     "AresWeaponTrait",
    --                     "AphroditeWeaponTrait",
    --                     "AthenaWeaponTrait",
    --                     "ArtemisWeaponTrait",
    --                     "PoseidonWeaponTrait",
    --                     "DionysusWeaponTrait",
    --                     "DemeterWeaponTrait",
    --                     "ZeusWeaponTrait",
    --                     -- SPECIAL
    --                     "AresSecondaryTrait",
    --                     "AphroditeSecondaryTrait",
    --                     "AthenaSecondaryTrait",
    --                     "ArtemisSecondaryTrait",
    --                     "PoseidonSecondaryTrait",
    --                     "DionysusSecondaryTrait",
    --                     "DemeterSecondaryTrait",
    --                     "ZeusSecondaryTrait",
    --                     -- RANGED -- TODO: Beowulf casts
    --                     "AresRangedTrait",
    --                     "AphroditeRangedTrait",
    --                     "AthenaRangedTrait",
    --                     "ArtemisRangedTrait",
    --                     "PoseidonRangedTrait",
    --                     "DionysusRangedTrait",
    --                     "DemeterRangedTrait",
    --                     "ZeusRangedTrait",
    --                     -- DASH
    --                     "AresRushTrait",
    --                     "AphroditeRushTrait",
    --                     "AthenaRushTrait",
    --                     "ArtemisRushTrait",
    --                     "PoseidonRushTrait",
    --                     "DionysusRushTrait",
    --                     "DemeterRushTrait",
    --                     "ZeusRushTrait",
    --                 },
    --             },
    --         },
    --     },
    -- },

     -- ARES LEGENDARY
     AresMurderousEfficacyLegendaryUpgrade = {
        Name = "AresMurderousEfficacyLegendaryUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON,
        Costs = {
            [ZyruIncremental.Constants.Gods.ARES] = 100,
        },
        Source = ZyruIncremental.Constants.Gods.ARES,
        OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
        OnApplyFunctionArgs = { 
            Name = "AresMurderousEfficacyLegendary",
            AddLinkedUpgrades = true,
            LinkedUpgradeName = "AresUpgrade",
            LinkedUpgrades = {
                OneFromEachSet = {
                    {  "AresRushTrait", "AresShoutTrait","AresRangedTrait" },
                    { "AresLoadCurseTrait", "AresLongCurseTrait", "AresDragTrait", "AresAoETrait" },
                    { "AresWeaponTrait", "AresSecondaryTrait", "AresRetaliateTrait"},
                },
            },
        },
    },

    -- ZEUS LEGENDARY
    -- ZeusChainRangeLegendaryUpgrade = {
    --     Name = "ZeusChainRangeLegendaryUpgrade",
        -- Costs = {
        --     [ZyruIncremental.Constants.Gods.ZEUS] = 100,
        -- },
    --     Source = ZyruIncremental.Constants.Gods.ZEUS,
    --     OnApplyFunction = "ZyruIncremental.AddTraitToTraitData",
    --     OnApplyFunctionArgs = { 
    --         Name = "ZeusChainRangeLegendary",
    --         AddLinkedUpgrades = true,
    --         LinkedUpgradeName = "ZeusUpgrade",
    --         LinkedUpgrades = {
    --             OneFromEachSet = {
    --                 {  "ZeusRangedTrait", "ZeusWeaponTrait", },
    --                 { "ZeusBonusBounceTrait" },
    --             },
    --         },
    --     },
    -- },


    ---------------------
    -- RARITY UPGRADES --
    ---------------------
    ZeusRarityUpgrade = {
        Name = "ZeusRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.ZEUS,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            ZeusRarityBonus = 10,
        },
    },

    
    PoseidonRarityUpgrade = {
        Name = "PoseidonRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.POSEIDON,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            PoseidonRarityBonus = 10,
        },
    },

    
    AthenaRarityUpgrade = {
        Name = "AthenaRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.ATHENA,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            AthenaRarityBonus = 10,
        },
    },

    
    AresRarityUpgrade = {
        Name = "AresRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.ARES,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            AresRarityBonus = 10,
        },
    },

    AphroditeRarityUpgrade = {
        Name = "AphroditeRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.APHRODITE,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            AphroditeRarityBonus = 10,
        },
    },

    ArtemisRarityUpgrade = {
        Name = "ArtemisRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.ARTEMIS,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            ArtemisRarityBonus = 10,
        },
    },

    DionysusRarityUpgrade = {
        Name = "DionysusRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.DIONYSUS,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            DionysusRarityBonus = 10,
        },
    },

    HermesRarityUpgrade = {
        Name = "HermesRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.HERMES,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            HermesRarityBonus = 10,
        },
    },

    DemeterRarityUpgrade = {
        Name = "DemeterRarityUpgrade",
        Type = ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY,
        CostsFunctionName = "GetRarityUpgradeCost",
        Source = ZyruIncremental.Constants.Gods.DEMETER,
        OnApplyFunction = "AugmentTransientState",
        Value = 10,
        OnApplyFunctionArgs = {
            DemeterRarityBonus = 10,
        },
    },

    -------------------
    -- MISC UPGRADES --
    -------------------
    AthenaExperienceUpgrade = {
        Name = "AthenaExperienceUpgrade",
        CostsFunctionName = "GetRarityUpgradeCost", -- TODO: actually fix this shit,
        OnApplyFunction = "AugmentTransientState",
        OnApplyFunctionArgs = {
            AthenaExperienceBonus = 5,
        },

    },
}

-- Ares Hermes Duo
ModUtil.Path.Wrap("KillEnemy", function ( baseFunction, victim, triggerArgs )
    for i, functionData in pairs(GetHeroTraitValues("OnEnemyKillFunction")) do
        if _G[functionData.Name] ~= nil then
            _G[functionData.Name](victim, functionData.Args, triggerArgs)
        end
    end

    return baseFunction( victim, triggerArgs )
end)

function IncreaseBloodlust()
    for k, traitData in pairs(CurrentRun.Hero.Traits) do
        if traitData.BloodlustDamageBonus ~= nil then
            traitData.BloodlustDamageBonus = traitData.BloodlustDamageBonus + (traitData.BloodlustDamageMultiplier - 1)
        end
    end
end

ModUtil.Path.Wrap("DamageHero", function ( baseFunction, victim, triggerArgs )
    for i, functionData in pairs(GetHeroTraitValues("OnHeroDamageTakenFunction")) do
        if _G[functionData.Name] ~= nil then
            _G[functionData.Name](victim, functionData.Args, triggerArgs)
        end
    end

    return baseFunction( victim, triggerArgs )
end)

function ResetBloodlust()
    for k, traitData in pairs(CurrentRun.Hero.Traits) do
        if traitData.BloodlustDamageBonus ~= nil then
            traitData.BloodlustDamageBonus = 1
        end
    end
end
-- end ARES HERMES DUO

function AddOnDodgeWeapons( hero, upgradeData )
	if upgradeData.AddOnHitWeapons == nil then
		return
	end

    if hero.OnDodgeWeapons == nil then
        hero.OnDodgeWeapons = {}
    end
    for k, onHitWeaponName in pairs( upgradeData.AddOnDodgeWeapons ) do
        hero.OnDodgeWeapons[onHitWeaponName] = upgradeData.OnHitWeaponProperties or true
    end
end

OnDodge{ "_PlayerUnit",
	function( triggerArgs )
        -- if CurrentRun.Hero.OnDodgeWeapons ~= nil then
            for i, weapon in ipairs(GetHeroTraitValues("AddOnDodgeWeapons")) do
                -- local createdObstacle = false
                local nearestEnemyId = GetClosest({ Id = CurrentRun.Hero.ObjectId, DestinationName = "EnemyTeam", IgnoreInvulnerable = true, IgnoreHomingIneligible = true })
                if nearestEnemyId == 0 then
                    -- targetId = SpawnObstacle({ Name = "InvisibleTarget", Group = "Scripting", DestinationId = CurrentRun.Hero.ObjectId })
                    nearestEnemyId = CurrentRun.Hero.ObjectId
                    createdObstacle = true
                end
                FireWeaponFromUnit({ Weapon = "AphroditeSuperCharm", Id = CurrentRun.Hero.ObjectId, DestinationId = CurrentRun.Hero.ObjectId, AutoEquip = true, ClearAllFireRequests = true })
            end
        -- end
	end
}

-- END APHRODITE HERMES DUO

ModUtil.Path.Wrap("DamageOverTimeApply", function (baseFunc, args)
    -- DebugPrint { Text = ModUtil.ToString.Shallow(args.Stacks) }
    ZyruIncremental.Args = args
    return baseFunc(args)
end, ZyruIncremental)

function PoseidonHermesDamageLoot ( args, attacker, victim )
    GiveRandomConsumables({
        NotRequiredPickup = true,
        LootOptions =
        {
            -- TODO: Balancing / add all drops?
            -- { Name = "Money", MinAmount = 10, MaxAmount = 30, Chance = 0.01, },
            { Name = "HealDropMinor", Chance = 0.01, },
            { Name = "RoomRewardMetaPointDrop", Chance = 0.005, },
            { Name = "GemDrop", Chance = 0.005, },
            { Name = "SuperLockKeyDrop", Chance = 0.00025, }, -- Titan's Blood
            { Name = "GiftDrop", Chance = 0.0005, },
            -- { Name = "SuperGemDrop", Chance = 0.0, },
            -- { Name = "SuperGiftDrop", Chance = 0.0, }, -- ambrosia 
            -- { Name = "SuperGemDrop", Chance = 0.0, },
            -- { Name = "SuperGemDrop", Chance = 0.0, },
        },
        DestinationId = victim.ObjectId
    })

end
    
OnEffectApply {
    function ( args )
        if args.EffectName == "DamageOverTime" then
            ModifyEffect({
                Id = args.triggeredById,
                EffectName = "DamageOverTime",
                EffectProperty = "Stacks",
                ChangeValue = 5,
                ChangeType = "Absolute",
            })
        end
    end
}

function AddCritSpeedBoost(args) 
    local propertyChanges =
    {
        {
            UnitProperty = "Speed",
            ChangeValue = 1.1,
            ChangeType = "Multiply",
            ExtractValue =
            {
                ExtractAs = "TooltipSpeed",
                Format = "PercentDelta",
            },
        },
    }
    

    thread(function ( )
        ApplyUnitPropertyChanges( CurrentRun.Hero, propertyChanges, false)
        wait(5)
        ApplyUnitPropertyChanges( CurrentRun.Hero, propertyChanges, false, true)
    end)

end

function ZyruIncremental.SetupSeductiveVictory( hero, args )
    thread( SeductiveVictoryThread, args )
end

function SeductiveVictoryThread( args )
    while CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead do
		wait(0.1, RoomThreadName)
        -- DebugPrint { Text = "attempting to check if enemies are all weakened"}
		if CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead and IsCombatEncounterActive( CurrentRun ) and not IsEmpty( RequiredKillEnemies ) then
			local allEnemiesWeakened = true
			for enemyId, enemy in pairs(RequiredKillEnemies) do
				if not HasEffect({ Id = enemy.ObjectId, EffectName = "ReduceDamageOutput"}) then
					allEnemiesWeakened = false
                    -- DebugPrint { Text = tostring(enemyId) .. " does not have weaken"}
				end
			end

			if allEnemiesWeakened then
                -- DebugPrint { Text = "attempting to stun all enemies" }
	            ApplyEffectFromWeapon({ Id = CurrentRun.Hero.ObjectId, DestinationIds = GetAllKeys( RequiredKillEnemies ), WeaponName = "ArmorBreakAttack", EffectName = "ArmorBreakStun", Duration = 0.5 })

			end
		end
	end
end

function ZyruIncremental.SetupPoseidonVacuum(hero, args)
    thread(AlternatingTidesThread, args)
end

function AlternatingTidesThread(args)
    local isPush = true
    while CurrentRun and CurrentRun.Hero and not CurrentRun.Hero.IsDead do
        local leadLocation = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId })
        
        local targetIds = GetClosestIds({
            Id = CurrentRun.Hero.ObjectId,
            DestinationName = "EnemyTeam",
            IgnoreInvulnerable = true,
            IgnoreHomingIneligible = true,
            Distance = 10000 
        })

        for i, targetId in pairs(targetIds) do
            if ActiveEnemies[targetId] ~= nil and not ActiveEnemies[targetId].IsDead then
                local speed = (isPush and -1 or 1) * 0.666 * GetRequiredForceToEnemy( targetId, leadLocation )
                local angle = GetAngleBetween({ Id = targetId, DestinationId = leadLocation })
                ApplyForce({
                    Id = targetId,
                    Speed = speed,
                    Angle = angle
                })
            end
        end
        wait(3, "AlternatePoseidonLegendary")
        isPush = not isPush
	end
end

-- ARTEMIS ALTERNATE LEGENDARY
function ZyruIncremental.SetupPermanentVulnerability()
    ModUtil.Path.Wrap("ClearEffect", function(baseFunc, args)
        if args and args.Name == "CritVulnerability" then
            return
        end
        return baseFunc(args)
    end, ZyruIncremental)

    ModUtil.Path.Wrap("BlockEffect", function(baseFunc, args)
        if args and args.Name == "CritVulnerability" then
            return
        end
        return baseFunc(args)
    end, ZyruIncremental)
end

-- ATHENA LEGENDARY
function ZyruIncremental.SetupStrategicCooperationBlessingLegendary ( )
--[[
    1. Compute the initial damage multiplier
    2. Add wrapper to AddTraitToHero
    
]]

    -- 1.
    local damageBonus = 1
    local damageIncrement = 0.05
    for i, traitData in pairs(CurrentRun.Hero.Traits) do
        -- DebugPrint { Text = ModUtil.ToString.Shallow(traitData)}
        if traitData.InheritFrom
            and (Contains(traitData.InheritFrom, "SynergyTrait")
            or Contains(traitData.InheritFrom, "ShopTier3Trait"))    
        then
            -- DebugPrint { Text = "Found" .. tostring(traitData.Name) .. " for bonus damage" }
            damageBonus = damageBonus + damageIncrement
        end
    end

    for k, traitData in pairs(CurrentRun.Hero.Traits) do
        if traitData.StrategicCooperationBlessingDamageBonus then
            -- DebugPrint { Text = "Setting athena legendary bonus damage" }
            traitData.StrategicCooperationBlessingDamageBonus = damageBonus
            -- ExtractValues( CurrentRun.Hero, traitData, traitData )
        end
    end
    -- 2.

    ModUtil.Path.Wrap("AddTraitToHero", function (baseFunc, args)
        baseFunc(args)
        -- DebugPrint { Text = ModUtil.ToString.Shallow(args)}

        -- GameState.LastPickedTraitName
        local traitData = TraitData[GameState.LastPickedTraitName]
        if traitData ~= nil
        and (Contains(traitData.InheritFrom, "SynergyTrait")
            or Contains(traitData.InheritFrom, "ShopTier3Trait"))
        then
            for k, traitData in pairs(CurrentRun.Hero.Traits) do
                if traitData.StrategicCooperationBlessingDamageBonus then
                    traitData.StrategicCooperationBlessingDamageBonus =
                        traitData.StrategicCooperationBlessingDamageBonus + damageIncrement
                end
            end

        end
    end, ZyruIncremental)

end


-- CHAOS LEGENDARY MAPPINGS
local statusEnums = {
    ZEUS = "ZEUS",
    ARES = "ARES",
    DIONYSUS = "DIONYSUS",
    POSEIDON = "POSEIDON",
    APHRODITE = "APHRODITE",
    ARTEMIS = "ARTEMIS",
    ATHENA = "ATHENA",
    DEMETER = "DEMETER",
}
local godTraitWeaponStatusMapping = {
    [statusEnums.ZEUS] = "ChaosJoltedApplicator",
    [statusEnums.ARES] = "ChaosDoomApplicator",
    [statusEnums.DIONYSUS] = "ChaosHangoverApplicator",
    [statusEnums.POSEIDON] = "ChaosShoalsApplicator",
    [statusEnums.APHRODITE] = "ChaosWeakApplicator",
    [statusEnums.ARTEMIS] = "ChaosCritVulnerabilityApplicator",
    [statusEnums.ATHENA] = "ChaosBackstabVulnerabilityApplicator",
}

local excludedRecursiveWeapons = {
    "ChaosDoomApplicator",
    "ChaosWeakApplicator",
    "ChaosCritVulnerabilityApplicator",
    "ChaosJoltedApplicator",
    "ChaosHangoverApplicator",
    "ChaosShoalsApplicator",
    "ChaosBackstabVulnerabilityApplicator",
}

function ZyruIncremental.ApplyChaosStatuses( victim, functionDataArgs, triggerArgs )
    if Contains(excludedRecursiveWeapons, tostring(triggerArgs.SourceWeapon)) then
        return
    end
    
    local s = GetRandomValue(statusEnums)
    -- initialize victim status map
    if victim.ZyruChaosStatus == nil or type(victim.ZyruChaosStatus) ~= "table" then
        victim.ZyruChaosStatus = {}
    end

    -- prevent duplicate status application
    if victim.ZyruChaosStatus[s] then
        return
    end
    victim.ZyruChaosStatus[s] = true

    
    if s == statusEnums.DEMETER then
        ApplyEffectFromWeapon({ Id = CurrentRun.Hero.ObjectId, DestinationId = victim.ObjectId, WeaponName = "ChillRetaliate", EffectName = "DemeterSlow", AutoEquip = true })
    else
        FireWeaponFromUnit({
            Weapon = godTraitWeaponStatusMapping[s],
            Id = CurrentRun.Hero.ObjectId,
            DestinationId = victim.ObjectId,
            FireFromTarget = true
        })
    end
end 

ModUtil.Path.Wrap("CheckOnDamagedPowers", function (baseFunc, victim, attacker, args)
    baseFunc(victim, attacker, args)

    -- OnHitEnemyFunction
    if attacker == CurrentRun.Hero and victim ~= nil and victim.TriggersOnDamageEffects then
        for i, functionData in pairs(GetHeroTraitValues("OnHitEnemyFunction")) do
            if _G[functionData.Name] ~= nil then
                -- DebugPrint { Text = "CheckOnDamagedPowers: OnHitEnemyFunction: "..functionData.Name}
                _G[functionData.Name](victim, functionData.Args, args)
            end
        end
    end
    
end, ZyruIncremental)

function ZyruIncremental.SetupDemeterFamineLegendary ()

    ModUtil.Path.Wrap("SetupEnemyObject", function (baseFunc, newEnemy, currentRun, args)
        local enemy = baseFunc(newEnemy, currentRun, args)
        if not enemy.IsBoss then
            enemy.Health = enemy.MaxHealth * 0.7
        end 
        return enemy
    end, ZyruIncremental)
end

-- Add PropertyChanges to allow status effects per weapon
function ZyruIncremental.ApplyAfterImageLegendary ( victim, functionDataArgs, triggerArgs )

    -- DebugPrint { Text = tostring(triggerArgs.SourceWeapon) }
    ZyruIncremental.Args = triggerArgs

    if victim.AfterImageWeapon == nil then
        victim.AfterImageWeapon = {}
    end

    local weaponToFire = triggerArgs.SourceWeapon
    -- if Contains(WeaponSets.HeroPhysicalWeapons, triggerArgs.SourceWeapon) then
    --     weaponToFire = triggerArgs.SourceWeapon
    --     slotToFill = "ATTACK"
    -- elseif Contains(WeaponSets.HeroSecondaryWeapons, triggerArgs.SourceWeapon) then
    --     weaponToFire = triggerArgs.SourceWeapon
    --     slotToFill = "SPECIAL"
    -- elseif Contains(WeaponSets.HeroRangedWeapons, triggerArgs.SourceWeapon) then
    --     weaponToFire = triggerArgs.SourceWeapon
    --     slotToFill = "CAST"
    -- elseif 
    --     Contains({
    --         "AresRushProjectile",
    --         "PoseidonRushProjectile",
    --         "AthenaRushProjectile",
    --         "DemeterRushProjectile",
    --         "AphroditeRushProjectile",
    --         "DionysusDashProjectile",
    --         "LightningDash"
    --     }, triggerArgs.SourceWeapon)
    -- then
    --     weaponToFire = triggerArgs.SourceWeapon
    --     slotToFill = "DASH"
    -- end

    -- if victim.AfterImageWeapon[slotToFill] ~= nil then
    --     return
    -- end

    -- AfterImage
    -- DebugPrint { Text = string.sub(weaponToFire, -10, -1) }
    if string.sub(weaponToFire, -10, -1) == "AfterImage" then return end

    if weaponToFire ~= nil then
        thread(
            function ()
                -- DebugPrint { Text = "attemptiung to fire " .. weaponToFire .. "AfterImage"}
                wait (0.5)
                FireWeaponFromUnit({
                    Weapon = weaponToFire .. "AfterImage",
                    Id = CurrentRun.Hero.ObjectId,
                    DestinationId = victim.ObjectId,
                    FireFromTarget = true,
                    AutoEquip = true,
                })
            end
        )
    end

end