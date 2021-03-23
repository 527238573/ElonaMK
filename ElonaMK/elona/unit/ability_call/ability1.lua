debugmsg("loading ability1")

local abi_type



--发射飞弹普通的延迟调用函数。
local function fire_proj(source_unit,target,proj)
  local map =source_unit.map
  if map ==nil then return end --如果map不存在,就不发射（单位异常神隐了）
  if target.unit and target.unit.dead then
    local near_enemy  = source_unit:findNearestEnemy()--简单重选目标
    if near_enemy then
      target = Target:new(near_enemy)
      source_unit:face_target(target)--朝向目标
    end
  end
  proj:attack(source_unit,nil,nil,target,source_unit.map) --source_unit.map肯定会有值。
  
  local dx =math.cos(proj.rotation) *8
  local dy =-math.sin(proj.rotation) *8
  local clip  = AnimClip.new("impact",0.21,0.3333,dx,dy,0)--运动时间：0.07,0.14
  source_unit:addClip(clip)
end
saveFunction(fire_proj) --使这个函数可以保存，吟唱火球到一半退出并保存游戏，读取后还能重建延迟调用。

local function stepback_anim(source_unit,target,ftime)
  local tx,ty 
  if target.unit then
    tx,ty =target.unit.x,target.unit.y
  else
    tx,ty =target.x,target.y
  end
  local sx,sy = source_unit.x,source_unit.y
  local movex = tx-sx
  local movey = ty-sy
  local rotation =   -math.atan2 (movey, movex)
  local dx =-math.cos(rotation) *8
  local dy =math.sin(rotation) *8
  local clip  = AnimClip.new("impact",0.3,0.8333,dx,dy,ftime-0.3) --运动时间：0.25,0.05
  clip.isRL= true --RL时间的clip，保证和RL时间的读条同步
  source_unit:addClip(clip)
  return clip
end

--[[*****************
--火球术 fire_ball
--**************--]]

abi_type = data.ability["fire_ball"]
--abi技能实体，source_unit施放单位，showmsg是否显示失败（不能释放）信息，target给予的target（可能为nil，可能来自ai，来自ai的会有额外标注）
--返回值，suc是否成功释放， traintime ，学习技能比率 trainlevel 学习技能等级
function abi_type.func(abi,source_unit,showmsg,target)
  --先确定目标。确定目标的过程类似远程射击。
  target = source_unit:findSeeRangeEnemyOrSquare(showmsg,target,true) --会清除不合法的手选目标
  if target ==nil then return false end --找不到目标
  source_unit:face_target(target)--朝向目标
  --尝试吟唱
  local chant_time = 1.2 --吟唱1.2
  local chant_eff = source_unit:requestChanting(2,chant_time) --style =2
  if chant_eff ==nil then return false end --吟唱失败。

  --生成弹体
  local proj = Projectile.new("fire_ball")
  proj.hit_sound = "fire_ball"
  proj.shot_sound = "fire_proj1"
  proj.name = tl("火球","fire ball")
  proj.impact = 12
  proj.shot_dispersion = 110
  proj.max_range = 10
  --proj.speed = 750
  local dam_ins = source_unit:getAbilityDamageInstance(abi,2,20,10)
  dam_ins.dtype =2 --魔法攻击
  dam_ins.subtype = "fire" --类型火焰
  proj.dam_ins = dam_ins
  
  chant_eff:setEndCall(fire_proj,source_unit,target,proj)
  chant_eff:addClip(stepback_anim(source_unit,target,chant_eff.remain)) --添加后撤动作
  return true,chant_time,target:getTargetLv()
end
--技能描述
function abi_type.description(abi,unit)
  local t = {}
  --复制上面的，上面的伤害要改这里也要改
  local chant_time = 1.2 --吟唱1.2
  local dice =2
  local base =10
  local face =20
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,string.format(tl("吟唱%.1f秒，发射一枚火球，造成","Chant %.1f seconds and shoot a fireball, dealing "),chant_time),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_MAG)
  c.addDesLine(t,tl("魔法火焰伤害。可能点燃地面。"," magic fire damage.May ignite the ground."),c.DES_WHITE)
  return t
end
--[[*****************
--远古智慧
--**************--]]


abi_type = data.ability["ancient_wisdom"]
abi_type.cooldown = 0.6
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
--技能描述
function abi_type.description(abi,unit)
  local t = {}
  --复制上面的，上面的伤害要改这里也要改
  local chant_time = 0.6 --吟唱1.2
  local mag_up= math.floor(5 +abi:getLevel()* c.averageAttrGrow *0.1 + unit:base_mag()*0.03)
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,string.format(tl("吟唱%.1f秒，增加自身魔力","Chant %.1f seconds, Increase your own magic +"),chant_time),c.DES_WHITE)
  c.addDesLine(t,string.format("%d",mag_up),c.DES_MAG)
  c.addDesLine(t,tl("点。持续60秒。"," For 60 seconds."),c.DES_WHITE)
  return t
end