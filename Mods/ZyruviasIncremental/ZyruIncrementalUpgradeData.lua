ModUtil.LoadOnce(function () 
    Z.TraitData = {
        -- Hermes Duo Boons
        -- TODO: duo color on boon presentation
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
                FunctionArgs = {}
            }
        },

        ArtemisHermesSynergyTrait = {
            Name = "ArtemisHermesSynergyTrait",
            InheritFrom = { "SynergyTrait" },
            RequiredFalseTraits = { "ArtemisHermesSynergyTrait" },
            Icon = "Demeter_Artemis_02",
            OnEnemyCrittedFunction = {
                Name = "AddCritSpeedBoost",
                Args = { }
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
                }
            }
        },

        AresHermesSynergyTrait = {
            Name = "AresHermesSynergyTrait",
            InheritFrom = { "SynergyTrait" },
            RequiredFalseTraits = { "AresHermesSynergyTrait" },
            Icon = "Demeter_Artemis_01",
            OnEnemyKillFunction = {
                Name = "IncreaseBloodlust",
                Args = {}
            },
            OnHeroDamageTakenFunction = {
                Name = "ResetBloodlust",
                Args = {}
            },
            BloodlustDamageMultiplier =  1.01,
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
                --     }
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
            }
        },
        ChangingTidesLegendary = {
            Name = "ChangingTidesLegendary",
            InheritFrom = { "ShopTier3Trait" },
            RequiredFalseTraits = { "ChangingTidesLegendary" },
            Icon = "Demeter_Artemis_01",
            EnableTides = true,
        },
        
        SeductiveVictoryLegendary = {
            Name = "SeductiveVictoryLegendary",
            InheritFrom = { "ShopTier3Trait" },
            RequiredFalseTraits = { "SeductiveVictoryLegendary" },
            Icon = "Demeter_Artemis_01",
            SetupFunction = {
                Name = "Z.SetupSeductiveVictory",
                RunOnce = true,
            }
        },

        PermanentVulnerabilityLegendary = {
            Name = "PermanentVulnerabilityLegendary",
            InheritFrom = { "ShopTier3Trait" },
            RequiredFalseTraits = { "PermanentVulnerabilityLegendary" },
            Icon = "Demeter_Zeus_01",
            SetupFunction = {
                Name = "Z.SetupPermanentVulnerability",
                RunOnce = true,
            },
            -- TODO: Fix this shit
            PropertyChanges = {
                {
                    WeaponName = "CritVulnerabilityWeapon",
                    EffectName = "CritVulnerability",
                    EffectProperty = "Duration",
                    ChangeValue = 100000,
                    ChangeType = "Absolute",
                }
            }
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
                    -- }
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
            }
        },

        StrategicCooperationBlessingLegendary = {
            Name = "StrategicCooperationBlessingLegendary",
            InheritFrom = { "ShopTier3Trait" },
            RequiredFalseTraits = { "StrategicCooperationBlessingLegendary" },
            Icon = "Demeter_Zeus_01",
            SetupFunction = {
                Name = "Z.SetupStrategicCooperationBlessingLegendary",
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
            CustomName = "lol lmfao", -- TODO: fix this shiiiiit
            Icon = "Boon_Chaos_Blessing_08",
            OnEnemyDamagedFunction = {
                Name = "Z.ApplyChaosStatuses"
            },
            RarityLevels =
            {
                Legendary =
                {
                    MinMultiplier = 1,
                    MaxMultiplier = 1,
                },
            },
            ChanceToPlay = 0.20,
            RetaliateChillStacks = 10, -- Emulate Frozen Touch without reequipping the weapon
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
            }
        }
    
    }

    local attackLength = TableLength(TraitData.AresWeaponTrait.PropertyChanges)
    local specialLength = TableLength(TraitData.AresSecondaryTrait.PropertyChanges)
    local revengeLength = TableLength(TraitData.AresRetaliateTrait.PropertyChanges)
    -- {
        --         TraitName = "AresRetaliateTrait",
        --         WeaponName = "AresRetaliate",
        --         EffectName = "DelayedDamage",
        --         EffectProperty = "Duration",
        --         BaseValue = 0.25,
        --         ChangeType = "Absolute",
        --         DeriveSource = "DurationSource",
        --     },
        --     {
        --         TraitName = "ShieldLoadAmmo_AresRangedTrait",
        --         WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
        --         EffectName = "DelayedDamage",
        --         EffectProperty = "Duration",
        --         DeriveValueFrom = "DurationSource"
        --     },
        --     {
        --         TraitName = "AresWeaponTrait",
        --         WeaponNames = WeaponSets.HeroPhysicalWeapons,
        --         EffectName = "DelayedDamage",
        --         EffectProperty = "Duration",
        --         DeriveValueFrom = "DurationSource"
        --     },
    local aresDoomDurationUpgradeDataArgs = {
        {
            Table = "TraitData",
            Value = {
                AresWeaponTrait = {
                    PropertyChanges = {
                        [attackLength + 1] = {
                            {
                                TraitName = "AresWeaponTrait",
                                WeaponNames = WeaponSets.HeroPhysicalWeapons,
                                EffectName = "DelayedDamage",
                                EffectProperty = "Duration",
                                BaseValue = 0.25,
                                ChangeType = "Absolute",
                            }
                        }
                    }
                }
            }
        },
        {
            Table = "TraitData",
            Value = {
                AresSecondaryTrait = {
                    PropertyChanges = {
                        [specialLength + 1] = {
                            {
                                TraitName = "AresSecondaryTrait",
                                WeaponNames = WeaponSets.HeroSecondaryWeapons,
                                EffectName = "DelayedDamage",
                                EffectProperty = "Duration",
                                BaseValue = 0.25,
                                ChangeType = "Absolute",
                            }
                        }
                    }
                }
            }
        },
        {
            Table = "TraitData",
            Value = {
                AresRetaliateTrait = {
                    PropertyChanges = {
                        [revengeLength + 1] = {
                            {
                                TraitName = "AresRetaliateTrait",
                                WeaponName = "AresRetaliate",
                                EffectName = "DelayedDamage",
                                EffectProperty = "Duration",
                                BaseValue = 0.25,
                                ChangeType = "Absolute",
                            },
                        }
                    }
                }
            }
        },
    }

-- TODO : constants over magic strings
Z.UpgradeSourceEnums = {
    ZEUS = "Zeus",
    NYX = "NYX",
    POSEIDON = "POSEIDON",
    APHRODITE = "APHRODITE"
    -- "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter",
    --     -- Other portraits Nyx, Chaos, Hammer, Pom(?), Heart (?), Coin (?), Zagrues (?)
    --     "Nyx", "Chaos", "Pom", "Heart", "Coin", "Zagreus"
}

Z.UpgradeTypeEnums = {
    PURCHASE_BOON = "PURCHASE_BOON",
    MIRROR_UPGRADE = "MIRROR_UPGRADE",
    UPGRADE_BOON = "UPGRADE_BOON",
    STANDARD = "STANDARD"
}
--[[
    Upgrade shape: {
        Name -- TODO: is this necessary
        CostType
        Cost
        OnApplyFunction
        OnApplyFunctionArgs
        Purchased
        Source
    }
    ]]--
    Z.UpgradeData = {

        -----------------
        -- HERMES DUOS --
        -----------------
        ZeusHermesSynergyTrait = {
            Name = "ZeusHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "ZeusHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "ZeusUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "HermesWeaponTrait", "HermesSecondaryTrait" },
                        { "ZeusWeaponTrait", "ZeusSecondaryTrait" },
                    }
                }
            },
            Purchased = false,
            Source =Z.UpgradeSourceEnums.ZEUS
        },

        PoseidonHermesSynergyTrait = {
            Name = "PoseidonHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "PoseidonHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "PoseidonUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "ChamberGoldTrait" },
                        { "PoseidonPickedUpMinorLootTrait", "RoomRewardBonusTrait" },
                    }
                }
            }
        },

        ArtemisHermesSynergyTrait = {
            Name = "ArtemisHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "ArtemisHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "ArtemisUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "HermesMoveSpeedTrait", "RushSpeedBoostTrait" },
                        { "ArtemisWeaponTrait", "ArtemisSecondaryTrait", "ArtemisRangedTrait", "ArtemisShoutTrait" },
                    }
                }
            }
        },
        DionysusHermesSynergyTrait = {
            Name = "DionysusHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "DionysusHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "DionysusUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "HermesMoveSpeedTrait", "RushSpeedBoostTrait" },
                        { "DionysusWeaponTrait", "DionysusSecondaryTrait", "DionysusRangedTrait", "DionysusShoutTrait" },
                    }
                }
            }
        },

        AresHermesSynergyTrait = {
            Name = "AresHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "AresHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "AresUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "HermesMoveSpeedTrait", "RushSpeedBoostTrait", "FastClearDodgeBonusTrait", "SpeedDamageTrait" },
                        { "IncreasedDamageTrait", "LastStandDamageBonusTrait" },
                    }
                }
            }
        },

        AphroditeHermesSynergyTrait = {
            Name = "AphroditeHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "AphroditeHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "AphroditeUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "DodgeChanceTrait", "HermesShoutDodge" },
                        { "AphroditeWeaponTrait", "AphroditeSecondaryTrait", "AphroditeRangedTrait", "AphroditeRushTrait", "AphroditeRetaliateTrait", "AphroditeDeathTrait" },
                    }
                }
            }
        },

        DemeterHermesSynergyTrait = {
            Name = "DemeterHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "DemeterHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "DemeterUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "RapidCastTrait", "AmmoReloadTrait" },
                        { "DemeterRangedTrait" },
                    }
                }
            }
        },

        AthenaHermesSynergyTrait = {
            Name = "AthenaHermesSynergyTrait",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "AthenaHermesSynergyTrait",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "AthenaUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "RapidCastTrait", "AmmoReloadTrait" },
                        { "DemeterRangedTrait" },
                    }
                }
            }
        },

        -----------------
        -- ARES        --
        -----------------
        AresDoomDurationUpgrade = {
            Name = "AresDoomDurationUpgrade",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.MergeDataTable",
            OnApplyFunctionArgs = aresDoomDurationUpgradeDataArgs
        },
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
        ShadowPresenceFieryPresenceDualSidedUpgrade = {
            Name = "ShadowPresenceFieryPresenceDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "BackstabMetaUpgrade", "FirstStrikeMetaUpgrade" }
        },

        ChthonicVitalityDarkRegenerationDualSidedUpgrade = {
            Name = "ChthonicVitalityDarkRegenerationDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "DoorHealMetaUpgrade", "DarknessHealMetaUpgrade" }
        },

        -- TODO: Fix applying all DD settings correctly on upgrade purchase
        -- TODO: Fix rendering order on pips
        DeathDefianceStubbornDefianceDualSidedUpgrade = {
            Name = "DeathDefianceStubbornDefianceDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "ExtraChanceMetaUpgrade", "ExtraChanceReplenishMetaUpgrade" }
        },
    
        GreaterReflexRuthlessReflexDualSidedUpgrade = {
            Name = "GreaterReflexRuthlessReflexDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "StaminaMetaUpgrade", "PerfectDashMetaUpgrade" }
        },
    
        BoilingBloodAbyssalBloodDualSidedUpgrade = {
            Name = "BoilingBloodAbyssalBloodDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "StoredAmmoVulnerabilityMetaUpgrade", "StoredAmmoSlowMetaUpgrade" }
        },
    
        InfernalSoulStygianSoulDualSidedUpgrade = {
            Name = "InfernalSoulStygianSoulDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "AmmoMetaUpgrade", "ReloadAmmoMetaUpgrade" }
        },
    
        DeepPocketsGoldenTouchDualSidedUpgrade = {
            Name = "DeepPocketsGoldenTouchDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "MoneyMetaUpgrade", "InterestMetaUpgrade" }
        },
    
        ThickSkinHighConfidenceDualSidedUpgrade = {
            Name = "ThickSkinHighConfidenceDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "HealthMetaUpgrade", "HighHealthDamageMetaUpgrade" }
        },
    
        PrivilegedStatusFamilyFavoriteDualSidedUpgrade = {
            Name = "PrivilegedStatusFamilyFavoriteDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "VulnerabilityEffectBonusMetaUpgrade", "GodEnhancementMetaUpgrade" }
        },
    
        OlympianFavorDarkForesightDualSidedUpgrade = {
            Name = "OlympianFavorDarkForesightDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "RareBoonDropMetaUpgrade", "RunProgressRewardMetaUpgrade" }
        },
    
        GodsPrideGodsLegacyDualSidedUpgrade = {
            Name = "GodsPrideGodsLegacyDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "EpicBoonDropMetaUpgrade", "DuoRarityBoonDropMetaUpgrade" }
        },
    
        FatedAuthorityFatedPersuasionDualSidedUpgrade = {
            Name = "FatedAuthorityFatedPersuasionDualSidedUpgrade",
            Cost = 0,
            CostType = "",
            Source =Z.UpgradeSourceEnums.NYX,
            OnApplyFunction = "Z.ApplyBothMirrorSidesForUpgrade",
            OnApplyFunctionArgs = { "RerollMetaUpgrade", "RerollPanelMetaUpgrade" }
        },

        -- Mirror Expansion Upgrades

        -- POSEIDON
        PoseidonAlternatingTidesUpgrade = {
            Name = "PoseidonAlternatingTidesUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.POSEIDON,
            OnApplyFunction = "Z.EnablePoseidonVacuumFunction",
        },

        -- APHRODITE
        SeductiveVictoryUpgrade = {
            Name = "SeductiveVictoryUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.APHRODITE,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "SeductiveVictoryLegendary",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "AphroditeUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "AphroditeWeaponTrait", "AphroditeSecondaryTrait", "AphroditeRangedTrait", "AphroditeRushTrait"},
                        { "AphroditeDurationTrait" }
                    }
                }
            }
        },

        -- ARTEMIS LEGENDARY
        PermanentVulnerabilityLegendaryUpgrade = {
            Name = "PermanentVulnerabilityLegendaryUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.ARTEMIS,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "PermanentVulnerabilityLegendary",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "ArtemisUpgrade",
                LinkedUpgrades = {
                    OneOf = { "CritVulnerabilityTrait" }
                }
            }
        },

        -- DIONYSUS LEFENGDARY
        UnendingHangoverLegendaryUpgrade = {
            Name = "UnendingHangoverLegendaryUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.DIONYSUS,
            OnApplyFunction = "Z.AddTraitToTraitData",
            OnApplyFunctionArgs = { 
                Name = "UnendingHangoverLegendary",
                AddLinkedUpgrades = true,
                LinkedUpgradeName = "DionysusUpgrade",
                LinkedUpgrades = {
                    OneFromEachSet = {
                        { "DionysusWeaponTrait", "DionysusSecondaryTrait", "DionysusRushTrait", "DionysusShoutTrait", },
                        { "FountainDamageBonusTrait", "GiftHealthTrait" }
                    }
                }
            }
        },

        -- ATHENA LEFENGDARY
        StrategicCooperationBlessingLegendaryUpgrade = {
            Name = "StrategicCooperationBlessingLegendaryUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.ATHENA,
            OnApplyFunction = "Z.AddTraitToTraitData",
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
                        }
                    }
                }
            }
        },

        -- CHAOS LEGENDARY
        ChaosRandomStatusLegendaryUpgrade = {
            Name = "ChaosRandomStatusLegendaryUpgrade",
            Cost = 0,
            CostType = "",
            Source = Z.UpgradeSourceEnums.CHAOS,
            OnApplyFunctions =  { "Z.AddTraitToTraitData", "Z.MergeDataArrays"},
            OnApplyFunctionArgs = { 
                { Name = "ChaosRandomStatusLegendary" },
                { 
                    {
                        Array = "LootData.TrialUpgrade.PermanentTraits",
                        Value = { "ChaosRandomStatusLegendary" }
                    }
                }
            }

        },

    }
end)

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
            DebugPrint { Text = "Resetting Bloodlust" }
            traitData.BloodlustDamageBonus = 1
        end
    end
end
-- end ARES HERMES DUO

-- APHRODITE HERMES DUO
-- TODO: clean this up, generic hook is better
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
                -- DebugPrint { Text = tostring(nearestEnemyId)}
                FireWeaponFromUnit({ Weapon = "AphroditeSuperCharm", Id = CurrentRun.Hero.ObjectId, DestinationId = CurrentRun.Hero.ObjectId, AutoEquip = true, ClearAllFireRequests = true })
                -- FireWeaponFromUnit({ 
                --     Weapon = weapon.Weapon,
                --     AutoEquip = true,
                --     Id = nearestEnemyId,
                --     DestinationId = CurrentRun.Hero.ObjectId,
                --     FireFromTarget = true
                -- })
                -- if createdObstacle then
                --     Destroy({ Id = nearestEnemyId })
                -- end
                -- DebugPrint { Text = ModUtil.ToString.Deep(weapon) }
            end
        -- end
	end
}

-- END APHRODITE HERMES DUO

ModUtil.Path.Wrap("DamageOverTimeApply", function (baseFunc, args)
    DebugPrint { Text = ModUtil.ToString.Shallow(args.Stacks) }
    Z.Args = args
    return baseFunc(args)
end, Z)

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
            { Name = "SuperLockKeyDrop", Chance = 0.0025, }, -- Titan's Blood
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
            DebugPrint { Text = "Attempting to modify DamageOverTime" }
            DebugPrint { Text = tostring(HasEffect({ Id = args.triggeredById, EffectName = "DamageOverTime",}))}
            DebugPrint { Text = ModUtil.ToString.Shallow()}
            ModifyEffect({
                Id = args.triggeredById,
                EffectName = "DamageOverTime",
                EffectProperty = "Stacks",
                ChangeValue = 5,
                ChangeType = "Absolute",
            })
        end
        -- DebugPrint { Text = a.EffectName .. " " .. a.Stacks.. " " ..a.Modifier.. " " ..a.Duration.. " " ..a.EffectType}
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
            }
        },
    }
    
    DebugPrint { Text = "Adding Crit Speed Boost"}

    thread(function ( )
        ApplyUnitPropertyChanges( CurrentRun.Hero, propertyChanges, false)
        wait(5)
        ApplyUnitPropertyChanges( CurrentRun.Hero, propertyChanges, false, true)
    end)

end

-- Keepsake changes
ModUtil.LoadOnce(function ( )
    ModUtil.Table.Merge(TraitData.GiftTrait, {
        ChamberThresholds = {25, 50, 100, 150, 200, 250, 500, 1000},
        RarityLevels = {
            Heroic =
            {
                Multiplier = 2.5,
            },
            Supreme =
            {
                Multiplier = 3.0,
            },
            Ultimate =
            {
                Multiplier = 3.5,
            },
            Transcendental =
            {
                Multiplier = 4.0,
            },
            Mythic =
            {
                Multiplier = 4.5,
            },
            Olympic =
            {
                Multiplier = 5,
            },
        }
    })
end)

-- Mirror Upgrads
-- TODO: should this be game state or is local generation fine? mid-run quitiout shenanigans
-- TODO: fix multiple / not-enough applications, LuaUpgrade false maybe?
local mirrorUpgradesToDuplicate = {}
function Z.ApplyBothMirrorSidesForUpgrade(upgradeNames)
    ConcatTableValues(mirrorUpgradesToDuplicate, upgradeNames)
    for i, upgrade in ipairs(upgradeNames) do
        DebugPrint { Text = "Attempting to apply " .. upgrade }
        if GameState.MetaUpgrades[upgrade] == 0 and GameState.MetaUpgrades[upgrade] ~= GameState.MetaUpgradeState[upgrade] then
            GameState.MetaUpgrades[upgrade] = GameState.MetaUpgradeState[upgrade]
            DebugPrint { Text = "Applying " .. upgrade }
            -- TODO: apply specific upgrades only ones, use loop in ApplyMetaUpgrades only
            ApplyMetaUpgrades( CurrentRun.Hero, true )
        end
    end
end

ModUtil.LoadOnce(function ()
    ModUtil.Path.Wrap("IsMetaUpgradeActive", function (baseFunc, upgradeName)
        if Contains(mirrorUpgradesToDuplicate, upgradeName) then
            return true
        end
        return baseFunc(upgradeName)
    end, Z)
end)

-- PoseidonAlternatingTidesUpgrade
-- OnEffectApply{
--     function ( triggerArgs )
--         DebugPrint { Text = ModUtil.ToString.Shallow(triggerArgs.EffectName) }
--     end
-- }

function Z.EnablePoseidonVacuumFunction( args )
    Z.AddTraitToTraitData({ 
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
                { "SlipperyTrait" }
            }
        }
    })
    -- initial push / pull behavior
    local isActive = true
    -- TODO: clean this up, do it like aphrodite's
    local applyVacuumEffect
    local isPush = true
    applyVacuumEffect = function()
        isActive = true
        local leadLocation = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId })
        
        DebugPrint { Text = "calculating applyVacuumEffect"}
        local targetIds = GetClosestIds({
            Id = CurrentRun.Hero.ObjectId,
            DestinationName = "EnemyTeam",
            IgnoreInvulnerable = true,
            IgnoreHomingIneligible = true,
            Distance = 10000 
        })
        DebugPrint { Text = tostring(targetIds)}
        for i, targetId in pairs(targetIds) do
            
            DebugPrint { Text = tostring(targetId)}
            if ActiveEnemies[targetId] ~= nil and not ActiveEnemies[targetId].IsDead then
                local speed = isPush and -2500 or 0.666 * GetRequiredForceToEnemy( targetId, leadLocation)
                local angle = GetAngleBetween({ Id = targetId, DestinationId = leadLocation })
                DebugPrint { Text = "Applying force " .. tostring(speed) .."to " .. tostring(targetId) .. " at angle " .. tostring(angle)}
                ApplyForce({
                    Id = targetId,
                    Speed = speed,
                    Angle = angle
                })
            end
        end
        wait(3, "AlternatePoseidonLegendary")
        if isActive then
            applyVacuumEffect()
        end
    end
    ModUtil.Path.Wrap("StartEncounterEffects", function ( baseFunc, currentRun )
        local retVal = baseFunc(currentRun)
        DebugPrint { Text = "Starting Encounter Effects"}
        isPush = not isPush
        isActive = false
        for i, traitData in pairs(CurrentRun.Hero.Traits ) do
            if traitData.EnableTides == true then
                isActive = true
            end
        end
        if isActive then
            thread(applyVacuumEffect)
        end
        return retVal
    end, Z)

    -- EndEncounterEffects( currentRun, currentRoom, currentEncounter )
    
    ModUtil.Path.Wrap("EndEncounterEffects", function ( baseFunc, currentRun, currentRoom, currentEncounter )
        isActive = false
        DebugPrint { Text = "Ending Encounter Effects"}
        return baseFunc(currentRun, currentRoom, currentEncounter)
    end, Z)
end

-- Aphrodite legendary, seductive victory
--[[
    local shareData = GetHeroTraitValues("BondDamageShareData")[1]
    local enemyIds = GetAllKeys( ActiveEnemies )
    for index, id in pairs(enemyIds) do
        local enemy = ActiveEnemies[id]
        if enemy and not enemy.IsDead and IsEmpty( enemy.InvulnerableFlags ) and IsEmpty ( enemy.PersistentInvulnerableFlags )
            and enemy.ActiveEffects and enemy.ActiveEffects.MarkBondTarget and Contains(shareData.WeaponNames, sourceWeaponData.Name ) and not triggerArgs.EffectName then
            local damageAmount = triggerArgs.DamageAmount * shareData.Multiplier
            if HeroData.DefaultHero.HeroAlliedUnits[ enemy.Name ] and shareData.AlliedDamageMultiplier then
                damageAmount = damageAmount * shareData.AlliedDamageMultiplier
            end
            Damage( enemy, { EffectName = "DamageShare", DamageAmount = damageAmount, Silent = false, PureDamage = true } )
        end
    end
]]

function Z.SetupSeductiveVictory( hero, args )
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

-- ARTEMIS ALTERNATE LEGENDARY
function Z.SetupPermanentVulnerability()
    ModUtil.Path.Wrap("ClearEffect", function(baseFunc, args)
        if args and args.Name == "CritVulnerability" then
            return
        end
        return baseFunc(args)
    end, Z)

    ModUtil.Path.Wrap("BlockEffect", function(baseFunc, args)
        if args and args.Name == "CritVulnerability" then
            return
        end
        return baseFunc(args)
    end, Z)
end


-- ModUtil.Path.Wrap("MarkRandomNearby", function(baseFunc, victim, args)
--     local id = victim.ObjectId
--     baseFunc(args)

--     thread(function ()
--         wait(0.055)
--         ApplyEffect { Id = id, Name = "CritVulnerability"}
--         DebugPrint { Text = "reapplying crit vuln to " .. tostring(id)}
--     end)
    
-- end, Z)

-- ATHENA LEGENDARY
function Z.SetupStrategicCooperationBlessingLegendary ( )
--[[
    1. Compute the initial damage multiplier
    2. Add wrapper to AddTraitToHero
    
]]

    -- 1.
    local damageBonus = 1
    local damageIncrement = 0.05
    for i, traitData in pairs(CurrentRun.Hero.Traits) do
        DebugPrint { Text = ModUtil.ToString.Shallow(traitData)}
        if traitData.InheritFrom
            and (Contains(traitData.InheritFrom, "SynergyTrait")
            or Contains(traitData.InheritFrom, "ShopTier3Trait"))    
        then
            DebugPrint { Text = "Found" .. tostring(traitData.Name) .. " for bonus damage" }
            damageBonus = damageBonus + damageIncrement
        end
    end

    for k, traitData in pairs(CurrentRun.Hero.Traits) do
        if traitData.StrategicCooperationBlessingDamageBonus then
            DebugPrint { Text = "Setting athena legendary bonus damage" }
            traitData.StrategicCooperationBlessingDamageBonus = damageBonus
            -- ExtractValues( CurrentRun.Hero, traitData, traitData )
        end
    end
    -- 2.

    ModUtil.Path.Wrap("AddTraitToHero", function (baseFunc, args)
        baseFunc(args)
        DebugPrint { Text = ModUtil.ToString.Shallow(args)}

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
                        DebugPrint { Text = "New Athena Legendary Damage Bonus = " .. tostring(traitData.StrategicCooperationBlessingDamageBonus)}
                    -- ExtractValues( CurrentRun.Hero, traitData, traitData )
                end
            end

        end
    end, Z)

end

function Z.ApplyChaosStatuses( victim, functionDataArgs, triggerArgs )
    -- check existing chaos statuses (and valid weapons)
    -- pick random status to apply
    -- set enemy status to not reapply
    -- TODO: one status per enemy, or one status at a time?
    DebugPrint { "Attempting to apply ZyruChaosStatus " .. tostring(s)}
    if victim.ZyruChaosStatus ~= nil then
        return
    end
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

    local s = GetRandomValue(statusEnums)

    -- TODO: use ApplyEffectFromWeapon ? for some of these
    if s == statusEnums.ZEUS then
        ApplyEffect({ Id = victim.ObjectId, EffectName = "ZeusAttackPenalty" })
        victim.ZyruChaosStatus = "ZeusAttackPenalty"
        return
    elseif s == statusEnums.ARES then
        -- check for doom source boons and ApplyEffectFromWeapon

    elseif s == statusEnums.DIONYSUS then
        -- check for doom source boons and ApplyEffectFromWeapon

    elseif s == statusEnums.POSEIDON then
        -- apply rupture function?

    elseif s == statusEnums.APHRODITE then
        -- apply ReducedDamageOutput effect? from weapon?

    elseif s == statusEnums.ARTEMIS then
        -- HM does not really rely on boon / weapon checks LOL
		FireWeaponFromUnit({ Weapon = "CritVulnerabilityWeapon", AutoEquip = true, Id = CurrentRun.Hero.ObjectId, DestinationId = victim.ObjectId, FireFromTarget = true})
        victim.ZyruChaosStatus = "CritVulnerability"
        return
    elseif s == statusEnums.ATHENA then
        -- check for existing athena backstab vulnerability first so the damage doesn't scale too much

    elseif s == statusEnums.DEMETER then
        MaxChillOnTarget(victim, victim.ObjectId, triggerArgs)
        victim.ZyruChaosStatus = "RetaliateChill"
        return
    end

end 

-- MIRROR EXTENSION UPGRADES
function Z.ExtendMirrorUpgrade(args)
    
end

