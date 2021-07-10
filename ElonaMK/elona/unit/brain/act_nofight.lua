
--原地发呆一次。
local function idle(unit,brain,changeDirRate)
  unit:short_delay(0.3,"idle")
  if rnd()<changeDirRate then
    unit.status.face = rnd(1,8)
  end
end

--随机闲逛
local function wander(unit,brain)
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

--跟随f_unit
local function follow(unit,brain,f_unit)
  
end




function Brain:noFightingAct(unit)
  if self.follow_target then
    follow(unit,self,self.follow_target)
  elseif self.wander_region then
    
  else
    wander(unit,self)
  end
end
