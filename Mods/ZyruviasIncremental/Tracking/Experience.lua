local shrineExpFactorTable = {
    EnemyDamageShrineUpgrade = 1.05,
    HealingReductionShrineUpgrade = 1.05,
    ShopPricesShrineUpgrade = 1.1,
    EnemyCountShrineUpgrade = 1.02,
    BossDifficultyShrineUpgrade = 1.1,
    EnemyHealthShrineUpgrade = 1.05,
    EnemyEliteShrineUpgrade = 1.15,
    MinibossCountShrineUpgrade = 1.1,
    ForceSellShrineUpgrade = 1.2,
    EnemySpeedShrineUpgrade = 1.1,
    TrapDamageShrineUpgrade = 1.05,
    MetaUpgradeStrikeThroughShrineUpgrade = 1.2,
    EnemyShieldShrineUpgrade = 1.02,
    ReducedLootChoicesShrineUpgrade = 1.25,
    BiomeSpeedShrineUpgrade = 1.05,
    NoInvulnerabilityShrineUpgrade = 1
}

function ZyruIncremental.ComputeShrinePactExperienceMultiplier(args)
    args = args or {}
    if args.Cached and ZyruIncremental.ShrinePactExperienceMultiplierCache ~= nil then
        -- DebugPrint { Text = "returning cached shrine mult: " .. tostring(ZyruIncremental.ShrinePactExperienceMultiplierCache)}
        return ZyruIncremental.ShrinePactExperienceMultiplierCache
    end
    local value = 1 -- multValue
    local additiveValue = 1
    local mixedValue = 1
    for i, pactConditionName in ipairs(ShrineUpgradeOrder) do
        local upgradeData = MetaUpgradeData[pactConditionName]
        local expFactor = shrineExpFactorTable[pactConditionName]
        local pactConditionCount = GetNumMetaUpgrades(pactConditionName) or 0
        if pactConditionCount > 0 then
            value = value * math.pow(expFactor, pactConditionCount)
            additiveValue = additiveValue + (expFactor - 1) * pactConditionCount
            mixedValue = mixedValue * ((expFactor - 1) * pactConditionCount + 1)
        end
    end
    -- DebugPrint { Text = "Mult: " .. tostring(value) ..  ", Mixed: " .. tostring(mixedValue) .. ", Additive: " .. tostring(additiveValue)}
    ZyruIncremental.ShrinePactExperienceMultiplierCache = value
    return mixedValue
end



function ComputeSourceExpMultCache()
    ZyruIncremental.CachedExpMultipliersByGod = {}
    for i, olympian in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter", "Chaos" }) do
        ComputeCurrentSourceExpMult(olympian)
    end
end

ModUtil.LoadOnce(ComputeSourceExpMultCache)

function ComputeCurrentSourceExpMult(source)
    local currentPrestige = ZyruIncremental.Data.CurrentPrestige
    if currentPrestige == 0 then
        return 1
    end
    if ZyruIncremental.CachedExpMultipliersByGod[source] ~= nil then
        return ZyruIncremental.CachedExpMultipliersByGod[source]
    end
    local multiplier = 1
    for i, prestigeData in ipairs(ZyruIncremental.Data.PrestigeData) do
        multiplier = multiplier * (prestigeData.ExperienceMulitpliers[source] or 1)
    end
    ZyruIncremental.CachedExpMultipliersByGod[source] = multiplier
    return multiplier
end
--[[
    Computes next prestige's experience multipliers by given source.
    FORMULA:
    - New Multiplier = Math.pow([(50 + MaxPoints) / 50], 0.6) -- can vary exponent
        - 10  points by god: 1.12x mult
        - 25  points by god: 1.27x mult
        - 50  points by god: 1.51x mult
        - 100 points by god: 1.93x mult
]]
function ComputeNextSourceExpMult(source)
    -- GodData hardcoded
    local maxPointsObtained = ZyruIncremental.Data.GodData[source].MaxPoints
    local mult = math.pow((50 + maxPointsObtained) / 50, 0.6)
    return mult
end
