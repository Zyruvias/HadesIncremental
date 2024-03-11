function ZyruIncremental.GetTotalHeroTraitValueWrapperGenerator (traitNameToTrack, comparator, debug)
    ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
        local res = baseFunc(traitName, args)
        if traitName == traitNameToTrack and comparator(res) and HeroHasTrait(traitName) then
            ZyruIncremental.TrackBoonEffect(ZyruIncremental.GetHeroTraitValuesMap[traitNameToTrack], res)
        end
        return res
    end, ZyruIncremental)
end

function ToLookupValue( table, setValue )
    local setValueToUse = setValue or true
      local lookup = {}
      for key,value in pairs( table ) do
          lookup[value] = setValueToUse
      end
      return lookup
end

-------------------
-- LEVEL SCALING --
-------------------

-- assumes start at 1
function ZyruIncremental.GetExperienceForNextBoonLevel ( level )
  -- tribute to AI:TG
  return 1000 * (level * (level - 1) * (2 * level - 1) / 6 + level)
end

-- assumes start at one
function ZyruIncremental.GetExperienceForNextGodLevel ( level )
  return math.floor(4 * math.pow(1.25, level - 1) + level * level) - 5
end

function AddGodExperience ( god, amount )
  -- called on every boon level-up

  if god == nil then
    DebugPrint { Text = "god was nil" }
    return
  end

  local godData = ZyruIncremental.Data.GodData[god]

  if godData == nil then
    DebugPrint { Text = "godData was somehow undefined... god: " .. god }
    return
  end

  if type(amount) ~= "number" then
    return
  end


  -- gain one rarity bonus % every boon level-up
  godData.RarityBonus = godData.RarityBonus + 1

  -- add points
  godData.CurrentPoints = godData.CurrentPoints + amount
  godData.MaxPoints = godData.MaxPoints + amount

  -- gain the specified experience
  godData.Experience = godData.Experience + amount

  -- check for level-ups 
  if ZyruIncremental.GetExperienceForNextGodLevel(godData.Level) <= godData.Experience then
    -- TODO: queue level-up dialogue and voice lines
    godData.Level = godData.Level + 1

    -- add another rarity bonus
    godData.RarityBonus = godData.RarityBonus + 10
  end

end

local shiftFactor = 0.01
local defaultStddev = 1
local rarityArray = { "Common", "Rare", "Epic", "Heroic", "Supreme", "Ultimate", "Transcendental", "Mythic", "Olympic" }


ZyruIncremental.RarityArrayMap = {}
function ZyruIncremental.ComputeRarityDistribution( rarityBonus )
  if ZyruIncremental.RarityArrayMap[tostring(rarityBonus)] ~= nil then
    return ZyruIncremental.RarityArrayMap[tostring(rarityBonus)]
  end

  local actualRarityBonus = rarityBonus / 100
  local chances = {}

  local previousValue = 0
  local minRarityThreshold = 0.005
  local minThresholdBroken = false
  local lastRarity = "Common"
  for i, rarity in ipairs(rarityArray) do
    local mu = actualRarityBonus
    local result = pNorm(i - mu, 0, 1, 1e-3)
    local boonRarityChance = result - previousValue
    previousValue = result
    if boonRarityChance < minRarityThreshold then
      boonRarityChance = 0
    else
      previousValue = result
      lastRarity = rarity
    end
    chances[rarity] = boonRarityChance
  end

  chances[lastRarity] = chances[lastRarity] + 1 - previousValue

  ZyruIncremental.RarityArrayMap[tostring(rarityBonus)] = chances
  return chances

end
function ZyruIncremental.ComputeRarityBonusForGod( god )
  local chosenGod = god or "Zeus"
  local godData = ZyruIncremental.Data.GodData[chosenGod]
  return godData.RarityBonus + (ZyruIncremental.TransientState[god .. "RarityBonus"] or 0)
end

function ZyruIncremental.ComputeRarityArrayForGod( god )
  local rarityBonus = ZyruIncremental.ComputeRarityBonusForGod(god)
  return ZyruIncremental.ComputeRarityDistribution(rarityBonus)
end

ModUtil.Path.Wrap("RunHasOneOfTraits", function ( baseFunc, args)
  local baseVal = baseFunc(args)
  if not baseVal then
    for i, traitName in ipairs(args) do
      if HeroHasTrait(traitName) then
        return true
      end 
    end
  end
  return baseVal
end, ZyruIncremental)

function ZyruIncremental.GetGodStringFromLootName (lootName)
  local god = string.sub(lootName, 1, string.len(lootName) - 7)
  if god == "Trial" then
    god = "Chaos" -- TrialUpgrade -> Chaos boons... I am not reusing that naming convention
  elseif god == "Stack" or god == "Weapon" then
    god = nil
  end
  return god
end

ModUtil.Path.Wrap("SetupRunData", function (baseFunc)
--[[
  Get existing merge table mappings and apply
]]
  ------------------
  -- TraitData -----
  ------------------
  ModUtil.Table.Merge(TraitData, ZyruIncremental.TraitData)
  ------------------
  -- WeaponSets ----
  ------------------
  local hermesAfterImageWeapons = {}
  for i, weaponName in ipairs(WeaponSets.HeroPhysicalWeapons) do
    table.insert(hermesAfterImageWeapons, weaponName .. "AfterImage")
    if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
      for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
        table.insert(hermesAfterImageWeapons, w .. "AfterImage") 
      end
    end
  end
  ZyruIncremental.MergeDataArrays({
    {
      Array = "WeaponSets.HeroPhysicalWeapons",
      Value = hermesAfterImageWeapons
    }
  })
  
  hermesAfterImageWeapons = {}
  for i, weaponName in ipairs(WeaponSets.HeroSecondaryWeapons) do
    table.insert(hermesAfterImageWeapons, weaponName .. "AfterImage")
    if WeaponSets.LinkedWeaponUpgrades[weaponName] ~= nil then
      for i, w in ipairs(WeaponSets.LinkedWeaponUpgrades[weaponName]) do
        table.insert(hermesAfterImageWeapons, w .. "AfterImage")
      end
    end
  end
  ZyruIncremental.MergeDataArrays({
    {
      Array = "WeaponSets.HeroSecondaryWeapons",
      Value = hermesAfterImageWeapons
    }
  })
  --- baseFunc
  baseFunc()
end, ZyruIncremental)
-- TODO: wrapping setupRunData versus just redoing it manually
SetupRunData()


-- Dev scripts
ModUtil.LoadOnce( function ( )
  if ZyruIncremental.DEBUG_MODE then
    _G["k"] = ModUtil.ToString.TableKeys
  end
end)
