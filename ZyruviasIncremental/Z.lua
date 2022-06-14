ModUtil.RegisterMod("Z")

local config = {
    lta = null;
}
Z.config = config

ModUtil.WrapBaseFunction("DamageEnemy", function(baseFunc, victim, triggerArgs) 
  local res = baseFunc( victim, triggerArgs )
  local obj = triggerArgs or {}
  config.lta = obj;
  
  local sourceWeaponData = obj.AttackerWeaponData
  local text = ""
  
  if obj.SourceWeapon ~= nil then
    text=obj.SourceWeapon
  end
  if obj.DamageAmount ~= nil then
    text=text.." "..obj.DamageAmount
  end
  if sourceWeaponData ~= nil then
    --text = text.." "..ModUtil.TableKeysString(sourceWeaponData)
  end

  DebugPrint({ Text = text })
  return res

end, Z)