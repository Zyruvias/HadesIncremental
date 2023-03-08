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
local UpgradeSourceEnums = {
    ZEUS = "Zeus"
    -- "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter",
    --     -- Other portraits Nyx, Chaos, Hammer, Pom(?), Heart (?), Coin (?), Zagrues (?)
    --     "Nyx", "Chaos", "Pom", "Heart", "Coin", "Zagreus"
}

--[[
    Upgrade shape: {
        Name
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
            Source = UpgradeSourceEnums.ZEUS
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

        -----------------
        -- ARES        --
        -----------------
        AresDoomDurationUpgrade = {
            Name = "AresDoomDurationUpgrade",
            CostType = "",
            Cost = 0,
            OnApplyFunction = "Z.MergeDataTable",
            OnApplyFunctionArgs = aresDoomDurationUpgradeDataArgs
        }
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