Damage ={
  
  dam = 0, --伤害值
  dtype = 1, --类型0真实1物理2魔法 
  resist_pen =0, --固定穿透
  resist_mul = 0,--百分比穿透。
  hitLevel = 1,--命中等级。
  cause = "attack",--造成伤害的原因。一般就是伤害型攻击（普攻，法术）。其他还有毒，抹杀，流血，陷阱等等。
  crital = false,--暴击的伤害？
}
local niltable = { --默认值为nil的成员变量
  subtype = true, --副类型， bash，cut，stab，fire，ice，nature，earth，dark，light 这种，可能增加更多。相应的抗性res_+属性名。
  deal_dam = true,--造成伤害的结果。
}

saveMetaType("Damage",Damage)--注册保存类型
Damage.__newindex = function(o,k,v)
  if Damage[k]==nil and niltable[k]==nil then error("使用了Damage的意料之外的值:"..k) else rawset(o,k,v) end
end