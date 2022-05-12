ModUtil.RegisterMod("ZyruviasIncremental")

local config = {

}
ZyruviasIncremental.config = config

ModUtil.WrapBaseFunction("DamageEnemy", function(baseFunc, victim, triggerArgs) 
  baseFunc( victim, triggerArgs )
  DebugPrint({ Text="" .. triggerArgs.EffectName .. " " .. triggerArgs.DamageAmount})

end, ZyruviasIncremental)