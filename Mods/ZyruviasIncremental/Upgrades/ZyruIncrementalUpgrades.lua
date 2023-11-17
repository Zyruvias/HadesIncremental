function Z.AddUpgrade(upgradeName, args)
    args = args or {}
    if Z.Data == nil or Z.Data.UpgradeData == nil then
        DebugPrint { Text = "GameState not properly defined"}
        return false
    end
    table.insert(Z.Data.UpgradeData, upgradeName)
    if args.SkipApply then
        return true
    end

    local upgrade = Z.UpgradeData[upgradeName]
    DebugPrint { Text = ModUtil.ToString.Deep(upgrade) }
    if upgrade.OnApplyFunction ~= nil then
        _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
    end
    
    if upgrade.OnApplyFunctions ~= nil then
        for k, functionName in ipairs(upgrade.OnApplyFunctions) do
            local functionArgs = upgrade.OnApplyFunctionArgs[k]
            DebugPrint { Text = "AddUpgrade: Calling " .. functionName .. " with " .. ModUtil.ToString.Deep(functionArgs)}
            _G[functionName](functionArgs)
        end
    end
    return true
end

-- TODO: if using this function for resets, unapply functions or boot to menu
function Z.RemoveUpgrade(upgradeName, args)
    args = args or {}
    if Z.Data == nil or Z.Data.UpgradeData == nil then
        DebugPrint { Text = "GameState not properly defined"}
        return false
    end

    for i,v in ipairs(Z.Data.UpgradeData) do
        if v == upgradeName then
            table.remove(Z.Data.UpgradeData, i)
            DebugPrint { Text = "Removing " .. upgradeName .. " from GameState. Current upgrade values:"}
            DebugPrint { Text = ModUtil.ToString.Shallow(Z.Data.UpgradeData)}
            return
        end
    end

end

function Z.AddTraitToTraitData(args)
    local boonToAdd = Z.TraitData[args.Name]
    if boonToAdd == nil then
        return
    end
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
    -- TODO: SetupRunData already calls this, see if you can hook into it
    -- ProcessDataInheritance( TraitData[args.Name], TraitData )
end

function Z.MergeDataTables(args)
    for i, mergeArgs in ipairs(args) do
        ModUtil.Table.Merge(_G[mergeArgs.Table], mergeArgs.Value)
    end
end

function Z.MergeDataArrays(args)
    for i, mergeArgs in ipairs(args) do
        ModUtil.Path.Set(
            mergeArgs.Array,
            ModUtil.Array.Join(
                ModUtil.Path.Get(mergeArgs.Array),
                mergeArgs.Value
            )
        )
    end
end