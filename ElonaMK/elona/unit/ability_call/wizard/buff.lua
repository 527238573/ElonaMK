--多个类似技能，buff类
local abi_type


--[[*****************
--远古智慧
--**************--]]


abi_type = data.ability["ancient_wisdom"]
abi_type.cooldown = 0.6
--技能描述
function abi_type.description(abi,unit)
  local t = {}
  --复制下面的，下面的伤害要改这里也要改
  local chant_time = 0.6 --吟唱1.2
  local mag_up= math.floor(5 +abi:getLevel()* c.averageAttrGrow *0.1 + unit:base_mag()*0.03)
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,string.format(tl("吟唱%.1f秒，增加自身魔力","Chant %.1f seconds, Increase your own magic +"),chant_time),c.DES_WHITE)
  c.addDesLine(t,string.format("%d",mag_up),c.DES_MAG)
  c.addDesLine(t,tl("点。持续60秒。"," For 60 seconds."),c.DES_WHITE)
  return t
end


--abi技能实体，source_unit施放单位，showmsg是否显示失败（不能释放）信息，target给予的target（可能为nil，可能来自ai，来自ai的会有额外标注）
--返回值，suc是否成功释放， traintime ，学习技能比率 trainlevel 学习技能等级
function abi_type.func(abi,source_unit,showmsg,target)
  --先确定目标。确定目标的过程类似远程射击。
  --尝试吟唱
  local chant_time = 0.6 --吟唱1.2
  local req_d = source_unit:requestDelay(chant_time,"selfbuff") 
  if req_d ==false then return false end --吟唱失败。
  
  local effect = Effect.new("ancient_wisdom")
  local mod_t = {}
  effect.mod_t = mod_t
  local mag_up= math.floor(5 +abi:getLevel()* c.averageAttrGrow *0.1 + source_unit:base_mag()*0.03)
  mod_t["mag"] = mag_up --mag+10
  effect.remain =60 --持续60秒
  
  effect.description = string.format(tl("魔力提升%d点。","Magic increase %d."),mag_up)
  
  local frame = FrameClip.createUnitFrame("ancient_wisdom")
  source_unit:addFrameClip(frame)
  source_unit:addEffect(effect)
  g.playSound_delay("enchant",source_unit.x,source_unit.y,0.15)
  if showmsg then addmsg(string.format(tl("%s使用远古智慧,魔力提升了。","%s cast Ancient Wisdom, magic increased."),source_unit:getShortName()),"info") end
  
  
  return true,5,source_unit.level
end