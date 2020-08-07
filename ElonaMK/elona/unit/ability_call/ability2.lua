debugmsg("loading ability2")
local abi_type




local function jump_slash_delay_call(source_unit,target_unit,ax,ay,dx,dy,dam_ins)
  local showmsg = (source_unit:isInPlayerTeam() or target_unit:isInPlayerTeam() )
  if showmsg then addmsg(string.format(tl("%s跳斩%s。","%s jump slash %s."),source_unit:getShortName(),target_unit:getShortName()),"info") end
  local show_miss = false
  local hit = false
  if c.dist_2d(ax,ay,target_unit.x,target_unit.y)<1.5 then
    hit = target_unit:check_melee_hit(source_unit,dam_ins)
    --hit = false
    show_miss = true
  end
  if hit>0 then
    g.playSound("axe_hit_3",ax,ay)
    local impact_xishu = 1.5
    if dx~=0 and dy~=0 then impact_xishu = 1.2 end
    local impact_rnd = (rnd()-0.5)*4 *impact_xishu    
    local tdx,tdy = 8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx
    local impact_clip  = AnimClip.new("impact",0.2,0.25,tdx,tdy,0)
    target_unit:addClip(impact_clip)
    local flat_clip  = AnimClip.new("turnFlat",0.2,0.25,0.7,0)
    target_unit:addClip(flat_clip)
  else
    if showmsg then addmsg(tl("被躲开了。","But got dodged."),"info") end
    if target_unit.x ==ax and target_unit.y ==ay then 
      local fu = rnd()>0.5 and 1 or -1
      target_unit:hitImpact(math.atan2(fu*dx,fu*dy),30) 
    end
    g.playSound("swing_heavy",ax,ay,3)
    if source_unit ==p.mc and  show_miss then
      target_unit:fly_miss_word(0)
    end
  end
end
saveFunction(jump_slash_delay_call)--使这个函数可以保存  。

abi_type = data.ability["jump_slash"]
--abi_type.cooldown = 0
--abi_type.costMana = 0
function abi_type.func(abi,source_unit,showmsg,target)
  target = source_unit:findCloseRangeEnemy(showmsg,target,false) --近战技能不会清除目标
  if target ==nil then return false end --找不到目标
  local req_d = source_unit:requestDelay(0.8,"jump_slash") --style =2
  if not req_d then return false end --动作失败。

  source_unit:face_target(target)--朝向目标
  local t_unit = target.unit
  --攻击动画
  local dx,dy =  t_unit.x -source_unit.x ,t_unit.y - source_unit.y
  local clip  = AnimClip.new("jump_slash",0.4,0.5,dx*28,dy*28,35,0.4)
  source_unit:addClip(clip)

  --攻击动画动画
  local delay = 0.3
  local frame = FrameClip.createUnitFrame("jump_cut",0,0,delay-0.1)
  t_unit.map:addSquareFrame(frame,t_unit.x,t_unit.y,0,32) --向地图添加
  if dx<0 then 
    if dy<0 then
      frame.rotation = rnd_float(-math.pi*0.2,math.pi*-0.1)
      frame.dy  = 10
    elseif dy==0 then
      frame.dy  = 5
      frame.rotation = rnd_float(math.pi*-0.05,math.pi*0.05)
    else
      frame.dx= 10
      frame.rotation = rnd_float(math.pi*0.2,math.pi*0.3)
    end
  elseif dx==0 then
    if dy<0 then
      frame.flipX = true 
      frame.dx = 10
      frame.rotation = rnd_float(math.pi*0.1,math.pi*0.2)
    else
      if rnd()<0.75 then
        frame.dx = 10
        frame.dy = -10
        frame.rotation = rnd_float(math.pi*0.7,math.pi*0.6)
      else
        frame.dx = -10
        frame.dy = -10
        frame.flipX = true
        frame.rotation = rnd_float(-math.pi*0.7,-math.pi*0.6)
      end
    end
  else
    frame.flipX = true 
    if dy<0 then
      frame.rotation = rnd_float(math.pi*0.1,math.pi*0.2)
    elseif dy==0 then
      frame.rotation = rnd_float(math.pi*-0.05,math.pi*0.05)
    else
      frame.dx=-5
      frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.3)
    end
  end


  local dam_ins = setmetatable({},Damage)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "cut" --类型切砍
  dam_ins.hitLevel = source_unit:getAbilityHitLevel(abi)-2
  --计算伤害
  local clevel = abi:getCombinedLevel()
  local dice =2
  local base =10+c.baseGrow(0.7,3,clevel)
  local face =20+c.faceGrow(0.12,3,clevel)
  dam_ins.dam,dam_ins.crital =source_unit:RandomAbilityDmg(abi,dice,face,base)

  source_unit:insertRLDelayFunc(delay,jump_slash_delay_call,source_unit,t_unit,t_unit.x,t_unit.y,dx,dy,dam_ins)
  return true,1.2,target:getTargetLv()
end

function abi_type.description(abi,unit)
  local t = {}
  --复制上面的，上面的伤害要改这里也要改
  local clevel = abi:getCombinedLevel()
  local dice =2
  local base =10+c.baseGrow(0.7,3,clevel)
  local face =20+c.faceGrow(0.12,3,clevel)
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,tl("先跳起再重重劈下，造成","Jump first and then slash from above, dealing "),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_SKI)
  c.addDesLine(t,tl("物理劈砍伤害。"," physical cut damage."),c.DES_WHITE)
  return t
end



--调用
local function round_slash_frameUpdate(frame,dt)
  local remaining = frame.remaining_life
  if remaining>0.8 then
    local rate = (1-remaining)/0.2
    frame.alpha = 0.3 +0.7*rate
  elseif remaining<0.2 then
    local rate = remaining/0.2
    frame.alpha = 0.3 +0.7*rate
  else
    frame.alpha = 1
  end

end
saveFunction(round_slash_frameUpdate)

local function apply_dam_round_slash(map,x,y,dam_ins,source_unit)
  local unit = map:unit_at(x,y);
  if unit and source_unit:isHostile(unit) then
    local hit = unit:check_melee_hit(source_unit,dam_ins,0.1)

    local dx,dy =  unit.x -source_unit.x ,unit.y - source_unit.y
    if hit>0 then
      g.playSound("cut2_hit",x,y)
      local impact_xishu = 1.5
      if dx~=0 and dy~=0 then impact_xishu = 1.2 end
      local impact_rnd = (rnd()-0.5)*4 *impact_xishu    
      local tdx,tdy = 8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx
      local impact_clip  = AnimClip.new("impact",0.2,0.25,tdx,tdy,0)
      unit:addClip(impact_clip)
      local fdx,fdy=0,0
      if dx~=0 and dy~=0 then
        fdx,fdy = -dx*10,-dy*10
      end
      
      local frame = FrameClip.createUnitFrame("cut_hit3",fdx,fdy,0)
      frame.drop_to_map = true
      frame.rotation = math.pi/4 + math.atan2(dy,-dx)
      unit:addFrameClip(frame)
    else
      unit:hitImpact(math.atan2(-dy,dx),25) 
      g.playSound("swing_heavy",x,y,1)
      unit:fly_miss_word(0)
    end
  end
end
saveFunction(apply_dam_round_slash)


abi_type = data.ability["round_slash"]
abi_type.cooldown = 2
abi_type.costMana = 3
function abi_type.func(abi,source_unit,showmsg,target)

  local req_d = source_unit:requestDelay(1,"round_slash") 
  if not req_d then return false end --动作失败。
  
  
  
  g.playSound("swing_round_slash",source_unit.x,source_unit.y,1)
  local cface =  source_unit.status.face
  local facerot = source_unit:getFace_Rotation()
  local clip  = AnimClip.new("round_slash",0.2,0.6,0.2,20,facerot,cface)
  source_unit:addClip(clip)

  local frame = FrameClip.createUnitFrame("round_slash",0,0,0)
  frame:setLoopPeriod(1)
  source_unit:addFrameClip(frame)
  --source_unit.map:addSquareFrame(frame,source_unit.x,source_unit.y,0,32) --向地图添加
  frame.rotation_speed = -10.4
  frame.rotation = 0+math.pi/2-facerot+10.4*0.2
  --debugmsg("facerot:"..facerot)
  --frame.rotation_speed = -10.4
  frame:setFrameUpdateFunc(round_slash_frameUpdate)

  --计算伤害
  local dam_ins = setmetatable({},Damage)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "cut" --类型切砍
  dam_ins.hitLevel = source_unit:getAbilityHitLevel(abi)-4

  local clevel = abi:getCombinedLevel()
  local dice =2
  local base =5+c.baseGrow(0.3,1,clevel)
  local face =10+c.faceGrow(0.6,1,clevel)
  dam_ins.dam,dam_ins.crital =source_unit:RandomAbilityDmg(abi,dice,face,base)
  --dam_ins.dam = 1
  --实施伤害（预）
  for i=-1,9,1 do 
    local atk_face = cface-i
    atk_face = (atk_face-1)%8+1 
    local dx,dy = c.face_dir(atk_face)
    source_unit:insertAnimDelayFunc(0.2+i*(0.6/8),apply_dam_round_slash,source_unit.map,source_unit.x+dx,source_unit.y+dy,dam_ins,source_unit)
  end

  return true,1.8,source_unit.level
end


function abi_type.description(abi,unit)
  local t = {}
  --复制上面的，上面的伤害要改这里也要改
  local clevel = abi:getCombinedLevel()
  local dice =2
  local base =5+c.baseGrow(0.3,1,clevel)
  local face =10+c.faceGrow(0.6,1,clevel)
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,tl("环形挥斩武器，造成","Slash weapon around a circle, dealing "),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_SKI)
  c.addDesLine(t,tl("物理劈砍伤害。正面的目标会受到两次伤害。"," physical cut damage.The target directly in front will take damage twice."),c.DES_WHITE)
  return t
end