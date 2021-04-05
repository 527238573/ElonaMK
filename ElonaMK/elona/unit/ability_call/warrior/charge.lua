local abi_type


--[[*****************
--冲锋 charge
--**************--]]

--提前声明的local function
local apply_dam_charge



abi_type = data.ability["charge"]
abi_type.cooldown = 0.5
abi_type.costMana = 0
function abi_type.description(abi,unit)
  local t = {}
  --复制下面的，下面的伤害要改这里也要改
  local dice =1
  local base =5
  local face =7
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,tl("从三格距离外冲撞敌人，造成","Charge the enemy from a distance of more than three squares, dealing "),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_SKI)
  c.addDesLine(t,tl("物理钝击伤害。可以将敌人撞退。"," physical bash damage. The enemy can be knocked back."),c.DES_WHITE)
  return t
end

function abi_type.func(abi,source_unit,showmsg,target)
  
  --寻找目标的条件函数
  local function CheckCondition(unit,x,y)
    if unit then x,y = unit.x,unit.y end
    local currange= c.dist_2d(source_unit.x,source_unit.y,x,y)
    if currange<2.5 then --距离太近
      return false
    end
    local map = source_unit.map
    if not map:can_pass(x,y) then
      return false
    end
    
    if unit then 
      if not source_unit:isHostile(unit) then
        return false
      end
      --在周围1格寻找落脚点
      for nx,ny in c.closest_xypoint_rnd(x,y,1) do
        if map:can_pass(nx,ny) and map:unit_at(nx,ny) ==nil then
          return true --有落脚点
        end
      end
      return false
    else
      return true
    end
  end
  target = source_unit:findConditionRangeUnitOrSquare(false,target,false,CheckCondition)
  
  if target ==nil then 
    if showmsg then addmsg(tl("找不到可以冲锋的目标!","Can't find a target to charge!")) end
    return false 
  end --找不到目标
  local req_d = source_unit:requestDelay(0.5,"charge") 
  if not req_d then return false end --动作失败。
  
  source_unit:face_target(target)--朝向目标
  local tx,ty = target.x,target.y
  if target.unit then tx,ty =  target.unit.x,target.unit.y end
  
  
  local sx,sy = source_unit.x,source_unit.y
  local dist = c.dist_2d(sx,sy,tx,ty)
  local fdx,fdy = (sx-tx)/dist*30 ,(sy-ty)/dist*30
  
  local rot = math.atan2(ty-sy,tx-sx)
  
  rot = (-math.pi*9/8-rot)%(math.pi*2) *4/math.pi
  rot = math.ceil(rot)
  if rot <=0 then rot =8 end
  --debugmsg("rot:"..rot)
  
  local runTime = dist*0.08 
  
  source_unit:short_delay(runTime+0.1,"charge")
  --添加冲刺状态
  local effect = Effect.new("sprinting")
  effect.remain =runTime+0.1 --
  source_unit:addEffect(effect)
  --添加冲刺动画
  local clip  = Animation.Charge(runTime,source_unit.x,source_unit.y,tx,ty,fdx,fdy)
  source_unit:addClip(clip)
  --添加冲刺特效
  local frame = FrameClip.createUnitFrame("chargeSpeed")
  frame:setLoopPeriod(runTime+0.2)
  frame:setFadeInFadeOut(0.2,0.2)
  frame:setUnitBack(source_unit)
  frame.rotation = math.atan2(ty-sy,-(tx-sx))
  --frame.rotation_speed = -1
  source_unit:addFrameClip(frame)
  
  --播放音效
  g.playSound("charge2",source_unit.x,source_unit.y)
  
  --计算伤害
  local dam_ins = source_unit:getAbilityDamageInstance(abi,1,7,5)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "bash" --类型钝击
  --延迟调用
  source_unit:insertAnimDelayFunc(runTime,apply_dam_charge,dam_ins,tx,ty,fdx,fdy,rot,source_unit,target.unit)
  
  return true,10,target:getTargetLv()
end

--延迟调用
--charge_rot冲锋方向换算成的1-8的方向，用于决定落脚点
function apply_dam_charge(dam_ins,x,y,fdx,fdy,charge_rot,source_unit,target_unit)
  
  local map = source_unit.map
  
  local unit_at_des  = map:unit_at(x,y) 
  if unit_at_des and( not source_unit:isHostile(unit_at_des)) then
    unit_at_des = nil
  end
  if unit_at_des and (target_unit==nil) then
    target_unit = unit_at_des
  end
  if unit_at_des == target_unit then
    unit_at_des = nil
  end
  
  
  --先确定目标位置会不会被撞击到
  local hitTarget = false 
  local recoverToDes = true --恢复位置为冲锋目标点
  if target_unit then
    if target_unit.x == x and target_unit.y ==y then
      recoverToDes = false
      hitTarget = true
    else
      local lx,ly = target_unit:getLineXY()
      if lx==x and ly ==y then
        hitTarget = true
      end
    end
  end
  
  --回退点
  local ex,ey = x,y
  --推挤点
  local px,py = x,y
  
  
  local function checkBackPoint(dir)
    dir = (dir-1)%8 +1 --使dir在合法区间
    debugmsg("check dir:"..dir)
    local cx,cy  = c.face_dir(dir)
    cx,cy = x +cx,y+cy
    if map:can_pass(cx,cy)  then
      local searchu = map:unit_at(cx,cy)
      if searchu ==nil or (searchu==source_unit and source_unit.next_unit==nil) then
        ex,ey = cx,cy
        return true
      end
    end
  end
  local function checkPushPoint(dir)
    dir = (dir-1)%8 +1 --使dir在合法区间
    local cx,cy  = c.face_dir(dir)
    cx,cy = x +cx,y+cy
    if map:can_pass(cx,cy) and map:unit_at(cx,cy) ==nil then
      px,py = cx,cy
      return true
    end
  end
  
  --尝试推挤
  local push = false
  if not recoverToDes then
    --push条件。体重必须合适范围，不能太重。 不能处于冲刺或霸体状态
    if target_unit:getWeight()<1.5*source_unit:getWeight() and target_unit:canPush() then 
      if checkPushPoint(charge_rot) then-- or checkPushPoint(charge_rot-1)  or checkPushPoint(charge_rot+1) then
        push = true --成功找到位置进行推挤
        recoverToDes = true
      end
    end
  end
  --push = false
  
  --寻找向后落点
  if not recoverToDes then
    
    if checkBackPoint(charge_rot-4)  or checkBackPoint(charge_rot-3)  or checkBackPoint(charge_rot-5) then
      recoverToDes = false
      --debugmsg("check back suc")
    else
      --debugmsg("check back fail")
      recoverToDes = true--没办法只能恢复到
    end
  end
  
  
  if push then
    --推挤动画
    local pushx,pushy = c.face_dir(charge_rot)
    target_unit:push_to(px,py,0,0.3)
    local l = math.sqrt(pushx*pushx +pushy*pushy)
    
    local impact_clip  = Animation.Impact(0.3,0.4,-fdx*2,-fdy*2,0)
    target_unit:addClip(impact_clip)
    
    target_unit:clips_update(0)
    
    
    
  elseif hitTarget then
    --被撞动画
    local impact_clip  = Animation.Impact(0.4,0.25,-fdx*1.5,-fdy*1.5,0)
    target_unit:addClip(impact_clip)
  end
  
  if push or hitTarget then
    local frame = FrameClip.createUnitFrame("impact1",fdx/2,fdy/2,0)
    frame.drop_to_map = true
    frame.rotation = math.pi/4 + math.atan2(fdy,-fdx)
    target_unit:addFrameClip(frame)
    g.playSound("impact1",x,y)
    
    --必中，直接赋予伤害
    target_unit:deal_damage(source_unit,dam_ins,0.1)
  end
  
  
  --debugmsg("ex ey :"..ex..","..ey)
  if recoverToDes then
    --debugmsg("push place")
    map:unitPushPlace(source_unit,ex,ey)
  else
    map:unitMove(source_unit,ex,ey)
  end
  
  
  
  local c_coordx = x*64+fdx
  local c_coordy = y*64+fdy
  
  local runTime = c.dist_2d(c_coordx,c_coordy,ex*64,ey*64)/64 *0.4
  
  --source_unit:teleport_to(tx,ty)
  local clip  = Animation.RecoverPos(runTime,x,y,fdx,fdy,ex,ey)
  source_unit:addClip(clip)
  source_unit:clips_update(0)
  
  source_unit:short_delay(runTime,"recover")
end
saveFunction(apply_dam_charge)
