
local abi_type


--[[*****************
--跳斩 jump_slash
--**************--]]

abi_type = data.ability["jump_slash"]
abi_type.cooldown = 0
abi_type.costMana = 0
function abi_type.description(abi,unit)
  local t = {}
  --复制下面的，下面的伤害要改这里也要改
  local dice =2
  local base =10
  local face =20
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,tl("先跳起再重重劈下，造成","Jump first and then slash from above, dealing "),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_SKI)
  c.addDesLine(t,tl("物理劈砍伤害。"," physical cut damage."),c.DES_WHITE)
  return t
end

function abi_type.func(abi,source_unit,showmsg,target)
  target = source_unit:findCloseRangeEnemy(showmsg,target,false) --近战技能不会清除目标
  if target ==nil then return false end --找不到目标
  local req_d = source_unit:requestDelay(0.8,"jump_slash") --style =2
  if not req_d then return false end --动作失败。

  source_unit:face_target(target)--朝向目标
  local t_unit = target.unit
  --攻击动画
  local dx,dy =  t_unit.x -source_unit.x ,t_unit.y - source_unit.y
  local clip  = Animation.JumpSlash(0.4,0.5,dx*28,dy*28,35,0.4)
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


  local dam_ins = source_unit:getAbilityDamageInstance(abi,2,20,10)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "cut" --类型切砍

  source_unit:insertAnimDelayFunc(delay,CB.jump_slash_delay_call,source_unit,t_unit,t_unit.x,t_unit.y,dx,dy,dam_ins)
  return true,1.2,target:getTargetLv()
end

--延迟调用函数
function CB.jump_slash_delay_call(source_unit,target_unit,ax,ay,dx,dy,dam_ins)
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
    local impact_clip  = Animation.Impact(0.2,0.25,tdx,tdy,0)
    target_unit:addClip(impact_clip)
    local flat_clip  = Animation.TurnFlat(0.2,0.25,0.7,0)
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

