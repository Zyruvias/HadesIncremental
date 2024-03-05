function ZyruIncremental.AddUpgrade(upgradeName, args)
    args = args or {}
    if ZyruIncremental.Data == nil or ZyruIncremental.Data.UpgradeData == nil then
        -- DebugPrint { Text = "GameState not properly defined"}
        return false
    end
    table.insert(ZyruIncremental.Data.UpgradeData, upgradeName)
    if args.SkipApply then
        return true
    end

    local upgrade = ZyruIncremental.UpgradeData[upgradeName]
    if upgrade.OnApplyFunction ~= nil then
        _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
    end
    
    if upgrade.OnApplyFunctions ~= nil then
        for k, functionName in ipairs(upgrade.OnApplyFunctions) do
            local functionArgs = upgrade.OnApplyFunctionArgs[k]
            _G[functionName](functionArgs)
        end
    end
    return true
end

-- TODO: if using this function for resets, unapply functions or boot to menu
function ZyruIncremental.RemoveUpgrade(upgradeName, args)
    args = args or {}
    if ZyruIncremental.Data == nil or ZyruIncremental.Data.UpgradeData == nil then
        -- DebugPrint { Text = "GameState not properly defined"}
        return false
    end

    for i,v in ipairs(ZyruIncremental.Data.UpgradeData) do
        if v == upgradeName then
            table.remove(ZyruIncremental.Data.UpgradeData, i)
            -- DebugPrint { Text = "Removing " .. upgradeName .. " from GameState. Current upgrade values:"}
            -- DebugPrint { Text = ModUtil.ToString.Shallow(ZyruIncremental.Data.UpgradeData)}
            return
        end
    end

end

function ZyruIncremental.AddTraitToTraitData(args)
    local boonToAdd = ZyruIncremental.TraitData[args.Name]
    if boonToAdd == nil then
        return
    end
    -- args.LinkedUpgrades for duos / boon prereqs
    if args.AddLinkedUpgrades ~= nil then
        -- DebugPrint { Text = "Found LinkedUpgrades" }
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

function ZyruIncremental.MergeDataTables(args)
    for i, mergeArgs in ipairs(args) do
        ModUtil.Table.Merge(_G[mergeArgs.Table], mergeArgs.Value)
    end
end

function ZyruIncremental.MergeDataArrays(args)
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

function ZyruIncremental.HasUpgrade(upgradeName, args)
    return Contains(ZyruIncremental.Data.UpgradeData, upgradeName)
end

function ZyruIncremental.GetAllUpgradesBySource(source)
    local toReturn = {}
    for i, upgrade in pairs(ZyruIncremental.UpgradeData) do
        if upgrade.Source == source or upgrade.Sources ~= nil and Contains(upgrade.Sources, source) then
            table.insert(toReturn, DeepCopyTable(upgrade))
        end
    end
    return toReturn
end

function GetUpgradeCost(upgrade)
    if upgrade.CostsFunctionName ~= nil then
        return _G[upgrade.CostsFunctionName](upgrade)
    end
    return upgrade.Costs
end

function IsUpgradeAffordable(upgrade)
    for source, cost in pairs(GetUpgradeCost(upgrade)) do
        local currentCurrency = ZyruIncremental.Data.GodData[source].CurrentPoints or 0
        if ZyruIncremental.Data.GodData[source].CurrentPoints < cost then
            return false
        end
    end
    return true
end

function SubtractUpgradeCosts(upgrade)
    for source, cost in pairs(GetUpgradeCost(upgrade)) do
        local currentCurrency = ZyruIncremental.Data.GodData[source].CurrentPoints or 0
        ZyruIncremental.Data.GodData[source].CurrentPoints = ZyruIncremental.Data.GodData[source].CurrentPoints - cost
    end
end

function GetRarityUpgradeCost(upgrade)
    -- check number of `source`RarityUpgrades that already exist in the upgrades
    local cost = 1
    local costScalingFactor = 2 -- TODO: generalize?
    for i, upgradeName in ipairs(ZyruIncremental.Data.UpgradeData) do
        if upgradeName == upgrade.Name then
            cost = cost + costScalingFactor
        end
    end
    -- upgrade.Costs structure
    return {
        [upgrade.Source] = cost
    }
end

function ZyruIncremental.AttemptPurchaseUpgrade(screen, button)
    local upgrade = button.Upgrade
    if ZyruIncremental.HasUpgrade(upgrade.Name) then
        -- TODO: CannotPurchaseVoiceLines all but last?
        -- DebugPrint { Text = "Already have upgrade: " .. upgrade.Name }
		thread( PlayVoiceLines, HeroVoiceLines.CannotPurchaseVoiceLines, true )
        return
    end
    if IsUpgradeAffordable(upgrade) then
        -- add upgrade to save
        ZyruIncremental.AddUpgrade(upgrade.Name)
        -- subtract Cost
        SubtractUpgradeCosts(upgrade)
        -- exhibit signs of self awareness
		thread( PlayVoiceLines, HeroVoiceLines.GenericUpgradePickedVoiceLines, true )
        -- DebugPrint { Text = "Purchased upgrade: " .. upgrade.Name }
    else
		thread( PlayVoiceLines, HeroVoiceLines.NotEnoughCurrencyVoiceLines, true )
        -- DebugPrint { Text = "Cannot purchase upgrade: " .. upgrade.Name }
    end
    -- reupdate the info screen in case of changing costs or whatever
    UpdateUpgradeInfoScreen(screen, upgrade)
end

function AugmentTransientState(args)
    ZyruIncremental.TransientState = ZyruIncremental.TransientState or {}
    for name, val in pairs(args) do
        if type(val) == "number" then
            ZyruIncremental.TransientState[name] = (ZyruIncremental.TransientState[name] or 0) + val
        elseif type(val) == "string" then
            ZyruIncremental.TransientState[name] = val
        end

    end
end

function ApplyTransientPatches(args)
    local fileOptions = ModUtil.Path.Get("Data.FileOptions", ZyruIncremental)
    if fileOptions == nil then
        return
    end

    if fileOptions.StartingPoint == ZyruIncremental.Constants.SaveFile.EPILOGUE then
        -- gotta strip requirements from cosmetic data...
        DebugPrint { Text = "Attempting to apply transient patches..."}
        for itemName, itemData in pairs(ConditionalItemData) do
            itemData.GameStateRequirements = {}
        end
    end
end