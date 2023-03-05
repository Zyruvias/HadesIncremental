function Z.AddUpgrade(upgradeName, args)
    args = args or {}
    if GameState.ZyruIncremental == nil or GameState.ZyruIncremental.UpgradeData == nil then
        DebugPrint { Text = "GameState not properly defined"}
        return false
    end
    table.insert(GameState.ZyruIncremental.UpgradeData, upgradeName)
    if args.SkipApply then
        return true
    end

    local upgrade = Z.UpgradeData[upgradeName]
    DebugPrint { Text = ModUtil.ToString.Deep(upgrade) }
    if upgrade.OnApplyFunction ~= nil then
        _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
    end
    return true
end

function Z.AddTraitToTraitData(args)
    local boonToAdd = Z.TraitData[args.Name]
    if boonToAdd == nil then
        return
    end
    DebugPrint { Text = "Trait Added: " .. ModUtil.ToString.Deep(boonToAdd) }
    ModUtil.Table.Merge(TraitData, {
        [args.Name] = boonToAdd
    })
    -- args.LinkedUpgrades for duos / boon prereqs
    if args.AddLinkedUpgrades ~= nil then
        DebugPrint { Text = "Found LinkedUpgrades" }
        ModUtil.Table.Merge(
            LootData[args.LinkedUpgradeName].LinkedUpgrades,
            {
                [args.Name] = args.LinkedUpgrades
            }
        )
    end
end

function Z.MergeDataTable(args)
    for i, mergeArgs in ipairs(args) do
        ModUtil.Table.Merge(_G[mergeArgs.Table], mergeArgs.Value)
    end
    -- ConcatTableValues(TraitData.AresWeaponTrait.PropertyChanges, {
    --     {
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
    --     {
    --         TraitName = "AresSecondaryTrait",
    --         WeaponNames = WeaponSets.HeroSecondaryWeapons,
    --         EffectName = "DelayedDamage",
    --         EffectProperty = "Duration",
    --         DeriveValueFrom = "DurationSource"
    --     }
    -- })
end