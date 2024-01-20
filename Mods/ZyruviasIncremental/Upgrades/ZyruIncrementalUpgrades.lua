function Z.AddUpgrade(upgradeName, args)
    args = args or {}
    if Z.Data == nil or Z.Data.UpgradeData == nil then
        -- DebugPrint { Text = "GameState not properly defined"}
        return false
    end
    table.insert(Z.Data.UpgradeData, upgradeName)
    if args.SkipApply then
        return true
    end

    local upgrade = Z.UpgradeData[upgradeName]
    -- DebugPrint { Text = ModUtil.ToString.Deep(upgrade) }
    if upgrade.OnApplyFunction ~= nil then
        _G[upgrade.OnApplyFunction](upgrade.OnApplyFunctionArgs)
    end
    
    if upgrade.OnApplyFunctions ~= nil then
        for k, functionName in ipairs(upgrade.OnApplyFunctions) do
            local functionArgs = upgrade.OnApplyFunctionArgs[k]
            -- DebugPrint { Text = "AddUpgrade: Calling " .. functionName .. " with " .. ModUtil.ToString.Deep(functionArgs)}
            _G[functionName](functionArgs)
        end
    end
    return true
end

-- TODO: if using this function for resets, unapply functions or boot to menu
function Z.RemoveUpgrade(upgradeName, args)
    args = args or {}
    if Z.Data == nil or Z.Data.UpgradeData == nil then
        -- DebugPrint { Text = "GameState not properly defined"}
        return false
    end

    for i,v in ipairs(Z.Data.UpgradeData) do
        if v == upgradeName then
            table.remove(Z.Data.UpgradeData, i)
            -- DebugPrint { Text = "Removing " .. upgradeName .. " from GameState. Current upgrade values:"}
            -- DebugPrint { Text = ModUtil.ToString.Shallow(Z.Data.UpgradeData)}
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

function Z.HasUpgrade(upgradeName, args)
    return Contains(Z.Data.UpgradeData, upgradeName)
end

function Z.GetAllUpgradesBySource(source)
    local toReturn = {}
    for i, upgrade in pairs(Z.UpgradeData) do
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
        local currentCurrency = Z.Data.GodData[source].CurrentPoints or 0
        if Z.Data.GodData[source].CurrentPoints < cost then
            return false
        end
    end
    return true
end

function SubtractUpgradeCosts(upgrade)
    for source, cost in pairs(GetUpgradeCost(upgrade)) do
        local currentCurrency = Z.Data.GodData[source].CurrentPoints or 0
        Z.Data.GodData[source].CurrentPoints = Z.Data.GodData[source].CurrentPoints - cost
    end
end

function GetRarityUpgradeCost(upgrade)
    -- check number of `source`RarityUpgrades that already exist in the upgrades
    local cost = 1
    local costScalingFactor = 2 -- TODO: generalize?
    for i, upgradeName in ipairs(Z.Data.UpgradeData) do
        if upgradeName == upgrade.Name then
            cost = cost + costScalingFactor
        end
    end
    -- upgrade.Costs structure
    return {
        [upgrade.Source] = cost
    }
end

function Z.AttemptPurchaseUpgrade(screen, button)
    local upgrade = button.Upgrade
    if Z.HasUpgrade(upgrade.Name) then
        -- TODO: CannotPurchaseVoiceLines all but last?
        -- DebugPrint { Text = "Already have upgrade: " .. upgrade.Name }
		thread( PlayVoiceLines, HeroVoiceLines.CannotPurchaseVoiceLines, true )
        return
    end
    if IsUpgradeAffordable(upgrade) then
        -- add upgrade to save
        Z.AddUpgrade(upgrade.Name)
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
    Z.TransientState = Z.TransientState or {}
    for name, val in pairs(args) do
        if type(val) == "number" then
            Z.TransientState[name] = (Z.TransientState[name] or 0) + val
        elseif type(val) == "string" then
            Z.TransientState[name] = val
        end

    end
end