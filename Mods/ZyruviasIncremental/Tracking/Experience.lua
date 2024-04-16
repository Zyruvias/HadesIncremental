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
	NoInvulnerabilityShrineUpgrade = 1,
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
        local pactConditionCount = GetNumMetaUpgrades( pactConditionName ) or 0
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