function Z.GetTotalHeroTraitValueWrapperGenerator (traitNameToTrack, comparator, debug)
    ModUtil.Path.Wrap("GetTotalHeroTraitValue", function (baseFunc, traitName, args)
        local res = baseFunc(traitName, args)
        if debug then
            DebugPrint({ text = "GetTotalHeroTraitValue" })
        end
        if traitName == traitNameToTrack and comparator(res) then
            Z.TrackBoonEffect(Z.GetHeroTraitValuesMap[traitNameToTrack])
        end
        return res
    end, Z)
end

function ToLookupValue( table, setValue )
    local setValueToUse = setValue or true
      local lookup = {}
      for key,value in pairs( table ) do
          lookup[value] = setValueToUse
      end
      return lookup
end


function Z.GetSourceDamageName(triggerArgs)
    local sourceWeaponData = triggerArgs.AttackerWeaponData
  
    if triggerArgs.EffectName ~= nil then
      return triggerArgs.EffectName
    elseif sourceWeaponData ~= nil then
      -- Actual source can vary within sourceWeaponData
      if sourceWeaponData.Name == "RushWeapon" then
        for k, trait in pairs(CurrentRun.Hero.Traits) do
          if trait.Slot == "Rush" then
            return trait.Name
          end
        end
      elseif sourceWeaponData.Name == "RangedWeapon" then
        for k, trait in pairs(CurrentRun.Hero.Traits) do
          if trait.Slot == "Ranged" then
            return trait.Name
          end
        end
      elseif Z.WeaponToBoonMap[sourceWeaponData.Name] ~= nil then
        return sourceWeaponData.Name
      end
      return sourceWeaponData.Name
      -- end sourceWeaponData variance check
    elseif ProjectileData[triggerArgs.SourceWeapon] ~= nil then
      return ProjectileData[triggerArgs.SourceWeapon].Name
    elseif Z.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon] ~= nil then
      return Z.WhatTheFuckIsThisToBoonMap[triggerArgs.SourceWeapon]
    end
    return triggerArgs.SourceWeapon
  
end

-------------------
-- LEVEL SCALING --
-------------------

-- assumes start at 1
function Z.GetExperienceForNextBoonLevel ( level )
  -- tribute to AI:TG
  return 1000 * (level * (level - 1) * (2 * level - 1) / 6 + level)
end

-- assumes start at one
function Z.GetExperienceForNextGodLevel ( level )
  return math.floor(4 * math.pow(1.25, level - 1) + level * level)
end

function AddGodExperience ( god, amount )
  -- called on every boon level-up

  if god == nil then
    DebugPrint { Text = "god was nil" }
    return
  end

  local godData = Z.Data.GodData[god]

  if godData == nil then
    DebugPrint { Text = "godData was somehow undefined... god: " .. god }
    return
  end

  if type(amount) ~= "number" then
    DebugPrint { Text = "GodExperience gain was not a number: " .. ModUtil.ToString.Deep(amount)}
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
  if Z.GetExperienceForNextGodLevel(godData.Level) <= godData.Experience then
    -- TODO: queue level-up dialogue and voice lines
    godData.Level = godData.Level + 1

    -- add another rarity bonus
    godData.RarityBonus = godData.RarityBonus + 10
  end

end

local shiftFactor = 0.01
local defaultStddev = 1
local rarityArray = { "Common", "Rare", "Epic", "Heroic", "Supreme", "Ultimate", "Transcendental", "Mythic", "Olympic" }
function Z.ComputeRarityForGod( god )
  
  local godData = Z.Data.GodData[god] or {}
  local rarityBonus = godData.RarityBonus or 0

  -- God's Pride
  rarityBonus = rarityBonus + GetNumMetaUpgrades( "EpicBoonDropMetaUpgrade" )
  
  local rarityTraits = GetHeroTraitValues("RarityBonus")
  for i, rarityTraitData in ipairs(rarityTraits) do
    local name = rarityTraitData.RequiredGod or ""
    name = string.sub(name, 1, string.len(rarityTraitData.RequiredGod) - 7)
    if rarityTraitData.RequiredGod == nil or rarityTraitData.RequiredGod == name then
      if rarityTraitData.RareBonus then
        rarityBonus = rarityBonus + 100 * rarityTraitData.RareBonus
      end
    end
  end

  local chances = Z.ComputeRarityArrayForGod(god)
  local cumulativeChance = 0
  local roll = RandomNumber()
  for i, rarity in ipairs(rarityArray) do
    if roll < (chances[rarity] + cumulativeChance) then
      return rarity
    end
    cumulativeChance = cumulativeChance + chances[rarity]
  end
  return "Common"

end


Z.RarityArrayMap = {}
function Z.ComputeRarityArrayForGod( god )
  local chosenGod = god or "Zeus"
  local godData = Z.Data.GodData[chosenGod]
  local rarityBonus = godData.RarityBonus + (ModUtil.Path.Get("TransientState[" ..chosenGod .. "RarityBonus]", Z) or 0)
  if Z.RarityArrayMap[tostring(rarityBonus)] ~= nil then
    return Z.RarityArrayMap[tostring(rarityBonus)]
  end


  local actualRarityBonus = rarityBonus / 100
  local chances = {}

  local previousValue = 0
  local minRarityThreshold = 0.005
  local minThresholdBroken = false
  local lastRarity = "Common"
  for i, rarity in ipairs(rarityArray) do
    local boonRarityChance = 0
    local result = 0
    if not minThresholdBroken then
      local mu = actualRarityBonus
      result = pNorm(i - mu, 0, 1, 1e-4)
      boonRarityChance = result - previousValue;
      if boonRarityChance < minRarityThreshold and i < 9 then
        boonRarityChance = 0
        minThresholdBroken = true
      else
        previousValue = result
        lastRarity = rarity

      end
    end
    chances[rarity] = boonRarityChance
  end

  -- DebugPrint {Text = "Last rarity: " .. lastRarity .. ", Last Result: " .. previousValue}
  chances[lastRarity] = chances[lastRarity] + 1 - previousValue

  -- DebugPrint { Text = "Rarity: " .. tostring((1 + actualRarityBonus) * 100) .. "%%: ".. ModUtil.ToString.Deep(chances)}

  Z.RarityArrayMap[tostring(rarityBonus)] = chances
  return chances
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
end, Z)

ModUtil.Path.Wrap("SetupRunData", function (baseFunc)
--[[
  Get existing merge table mappings and apply
]]
  ------------------
  -- TraitData -----
  ------------------
  ModUtil.Table.Merge(TraitData, Z.TraitData)
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
  Z.MergeDataArrays({
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
  Z.MergeDataArrays({
    {
      Array = "WeaponSets.HeroSecondaryWeapons",
      Value = hermesAfterImageWeapons
    }
  })
  --- baseFunc
  baseFunc()
end, Z)
-- TODO: wrapping setupRunData versus just redoing it manually
SetupRunData()


-- Dev scripts
ModUtil.LoadOnce( function ( ) 
  _G["k"] = ModUtil.ToString.TableKeys
  
end)
