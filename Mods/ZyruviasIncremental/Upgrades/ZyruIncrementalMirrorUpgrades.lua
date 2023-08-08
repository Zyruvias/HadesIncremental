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
        end
    end
    ApplyMetaUpgrades( CurrentRun.Hero, true )
end

ModUtil.Path.Wrap("IsMetaUpgradeActive", function (baseFunc, upgradeName)
    if Contains(mirrorUpgradesToDuplicate, upgradeName) then
        return true
    end
    return baseFunc(upgradeName)
end, Z)

ModUtil.Path.Wrap("SwapMetaupgrade", function( baseFunc, screen, button )
    baseFunc(screen, button)
    if Contains(mirrorUpgradesToDuplicate, button.Name) then
        ApplyMetaUpgrades( CurrentRun.Hero, true )
    end
end, Z)
