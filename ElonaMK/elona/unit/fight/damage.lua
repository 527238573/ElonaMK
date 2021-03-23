Damage ={
  
  dam = 0, --伤害值
  dtype = 1, --类型0真实1物理2魔法 
  atk_lv = 1,-- 攻击等级。会根据防御等级比较，进行压制
  hit_lv = 1,--命中等级。
  crit_lv = 1,--暴击等级。小于等于0不暴击
  cause = "attack",--造成伤害的原因。一般就是伤害型攻击（普攻，法术）。其他还有毒，抹杀，流血，陷阱等等。
}
local niltable = { --默认值为nil的成员变量
  subtype = true, --副类型， bash，cut，stab，fire，ice，nature，earth，dark，light 这种，可能增加更多。相应的抗性res_+属性名。
  deal_dam = true,--造成伤害的结果。实际掉血量。
}



saveMetaType("Damage",Damage,niltable)--注册保存类型
Damage.__newindex = function(o,k,v)
  if Damage[k]==nil and niltable[k]==nil then error("使用了Damage的意料之外的值:"..k) else rawset(o,k,v) end
end

c.damageType =
{
  bash = 1,--钝击
  cut = 1,--劈砍
  stab =1,--穿刺
  fire = 2,--火焰，精神
  ice = 2,-- 冰水
  nature = 2, --自然
  earth = 2, --大地
  dark = 2, --暗
  light = 2, --光
}