
--原地发呆一次。
local function idle(unit,brain,changeDirRate)
  unit:short_delay(0.3,"idle")
  if rnd()<changeDirRate then
    unit.status.face = rnd(1,8)
  end
end

--随机闲逛
local function wander(unit,brain)
  brain.curState = "wander"
  local walkRate = 0.2
  if rnd()>walkRate then --发呆
    idle(unit,brain,walkRate)
    return
  end
  --随机走向一个方向
  local map  =unit.map
  local rf = rnd(1,8)
  for f = 1,8 do
    local face = (f+rf)%8 +1
    local dx,dy = c.face_dir(face)
    dx,dy = unit.x +dx,unit.y+dy
    
    if map:can_pass(dx,dy) and not map:unit_at(dx,dy) and unit:squareDangerLevel(dx,dy,map)<1 then
      
      if unit:walk_to(dx,dy) then return end --成功走路就结束
    end
  end
  idle(unit,brain,walkRate)
end


local function follow_move(unit,brain,f_unit)
  
  local function followPath()
    local res,path = unit.map:pathFind(unit.x,unit.y,f_unit.x,f_unit.y,22,2)
    path.destX,path.destY = f_unit.x,f_unit.y
    brain.path = path
    brain.path_step = 0
  end
  
  if brain.curState ~="follow" then
    brain.curState = "follow"
    followPath()
  elseif brain.path_step>2 or brain.path ==nil then
    followPath()
  else
    local orx,ory = brain.path.destX,brain.path.destY
    if math.abs(f_unit.x-orx)>2 or math.abs(f_unit.y-ory)>2 then --原有的路径有偏差
      followPath()
    end
  end
  
  local path = brain.path
  if path:isInvalid(unit) then
    wander(unit,brain)
    debugmsg("invaild wander")
    --followPath()
    return
  end
  if path:walkNext(unit) then
    brain.path_step = brain.path_step+1
  else
    unit:short_delay(0.1,"idle")
    brain.path = nil
    debugmsg("path walk Next failed")
    --followPath()
  end
end

--跟随f_unit
local function follow(unit,brain,f_unit)
  local dis = c.dist_2d(unit.x,unit.y,f_unit.x,f_unit.y)
  if dis <2 then
    wander(unit,brain)
  elseif dis<3 then
    if rnd()> 0.5 then 
      wander(unit,brain)
    else
      follow_move(unit,brain,f_unit)
    end
  else
    follow_move(unit,brain,f_unit)
  end
end




function Brain:noFightingAct(unit)
  if self.follow_target then
    follow(unit,self,self.follow_target)
  elseif self.wander_region then
    
  else
    wander(unit,self)
  end
end
