--[[
    Author: Ponywarrior
        - ponywarrior (discord)
        - https://github.com/PonyWarrior/
        - https://github.com/PonyWarrior/HadesModRepo for their other hades work.
    Disclaimer: Included in ZyruIncremental mod with explicit permission from the author themselves
]]
ModUtil.LoadOnce(function ()
    for i, propertyChange in pairs(TraitData.ShieldLoadAmmoTrait.PropertyChanges) do
        if propertyChange.ProjectileProperty ~= nil and propertyChange.ProjectileProperty == "Type" then
            TraitData.ShieldLoadAmmoTrait.PropertyChanges[i] =
            {
                WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
                ProjectileProperty = "Fuse",
                ChangeValue = 0,
                ChangeType = "Absolute",
            }
        end
    end
    for traitName, traitData in pairs(TraitData) do
        if traitData.PropertyChanges ~= nil then
            for i, propertyChange in pairs(traitData.PropertyChanges) do
                if propertyChange.TraitName ~= nil and propertyChange.TraitName == "ShieldLoadAmmoTrait" and propertyChange.ProjectileProperty ~= nil and propertyChange.ProjectileProperty == "Type" then
                    traitData.PropertyChanges[i] =
                    {
                        TraitName = "ShieldLoadAmmoTrait",
                        WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
                        ProjectileProperty = "Fuse",
                        ChangeValue = 0,
                        ChangeType = "Absolute",
                    }
                end
            end
        end
    end
    table.insert(TraitData.ShieldLoadAmmo_AphroditeRangedTrait.PropertyChanges,
    {
        WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
        ProjectileProperty = "Type",
        ChangeValue = "HOMING",
        ChangeType = "Absolute",
    })
    table.insert(TraitData.ShieldLoadAmmo_AphroditeRangedTrait.PropertyChanges,
    {
        WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
        ProjectileProperty = "Fuse",
        ChangeValue = 0,
        ChangeType = "Absolute",
    })
    table.insert(TraitData.ShieldLoadAmmo_AthenaRangedTrait.PropertyChanges,
    {
        WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
        ProjectileProperty = "Type",
        ChangeValue = "HOMING",
        ChangeType = "Absolute",
    })
    table.insert(TraitData.ShieldLoadAmmo_AthenaRangedTrait.PropertyChanges,
    {
        WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
        ProjectileProperty = "Fuse",
        ChangeValue = 0,
        ChangeType = "Absolute",
    })
end)