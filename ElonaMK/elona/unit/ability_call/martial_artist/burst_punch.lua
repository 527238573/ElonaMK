
local abi_type


--[[*****************
--爆裂拳 burst_punch
--**************--]]


abi_type = data.ability["burst_punch"]
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
  local req_d = source_unit:requestDelay(1.1,"burst_punch") 
  if not req_d then return false end --动作失败。

  source_unit:face_target(target)--朝向目标
  local t_unit = target.unit
  --攻击动画
  local dx,dy =  t_unit.x -source_unit.x ,t_unit.y - source_unit.y
  
  local clip  = Animation.BurstPunch(dx,dy,0.8,0.1,0.3)
  source_unit:addClip(clip)
  local delay = clip.stage2
  local frame = FrameClip.createUnitFrame("storingEnergy")
  frame.dy = -10
  frame.dx = dx==0 and 10*dy or -10*dx
  
  source_unit:addFrameClip(frame)
  g.playSound("storeEnergy",source_unit.x,source_unit.y)
  
  local dam_ins = source_unit:getAbilityDamageInstance(abi,2,1,10)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "bash" --类型钝击
  dam_ins.hit_lv = dam_ins.hit_lv +10

  source_unit:insertAnimDelayFunc(delay,CB.burst_punch_delay_call,source_unit,t_unit,t_unit.x,t_unit.y,dx,dy,dam_ins)
  return true,1.2,target:getTargetLv()
end

--延迟调用函数 axay 目标点 
function CB.burst_punch_delay_call(source_unit,target_unit,ax,ay,dx,dy,dam_ins)
  --先选择当前目标
  if target_unit:is_dead() then
    target_unit = nil
  end
  if target_unit~=nil then
    local lx,ly = target_unit:getLineXY()
    if lx~=ax or ly ~=ay then
        target_unit = nil --被躲开了
    end
  end
  if target_unit ==nil then --尝试寻找该位置的目标
    local nunit = source_unit.map:unit_at(ax,ay) 
    if nunit~=nil and source_unit:isHostile(nunit) then
      target_unit = nunit
    end
  end
  
  if target_unit ==nil then
    if source_unit:isInPlayerTeam() then
      addmsg(string.format(tl("%s打出重拳，但挥空了。","%s throws a big punch, but missed."),source_unit:getShortName()),"info")
    end
    g.playSound("swing_heavy",ax,ay,3)
    return 
  end
  
  
  local showmsg = (source_unit:isInPlayerTeam() or target_unit:isInPlayerTeam() )
  if showmsg then addmsg(string.format(tl("%s重锤%s。","%s heavy punch %s."),source_unit:getShortName(),target_unit:getShortName()),"info") end
  local show_miss = false
  local hit = false
  if c.dist_2d(ax,ay,target_unit.x,target_unit.y)<1.5 then
    hit = target_unit:check_melee_hit(source_unit,dam_ins,0.1)
    --hit = false
    show_miss = true
  end
  if hit>0 then
    g.playSound("heavy_punch2",ax,ay,1)
    local impact_xishu = 1.5
    if dx~=0 and dy~=0 then impact_xishu = 1.2 end
    local impact_rnd = (rnd()-0.5)*4 *impact_xishu    
    local tdx,tdy = 8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx
    local impact_clip  = Animation.Impact(0.2,0.25,tdx,tdy,0)
    target_unit:addClip(impact_clip)
    local flat_clip  = Animation.TurnFlat(0.2,0.25,0.7,0)
    target_unit:addClip(flat_clip)
    local frame = FrameClip.createUnitFrame("impact2",-tdx,-tdy)
    frame.drop_to_map = true
    frame.rotation = math.pi/4 + math.atan2(dy,-dx)
    target_unit:addFrameClip(frame)
    
    local pushdam = dam_ins:clone()
    pushdam.dam = pushdam.dam/4
    target_unit:KnockBack(dx,dy,4,source_unit,pushdam)
    
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

