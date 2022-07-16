
local function idle(unit,brain)
  unit:short_delay(0.3,"idle")
end



local function meleeAttack(unit,brain,target)
  brain.curState = "meleeAttack"
  local suc = unit:attak_to(target.x,target.y,target)
  if not suc then 
    debugmsg("meleeAttack unknow reason failed!")
    idle(unit,brain) 
  end 
end


local function moveToTarget(unit,brain,target)
  
  local function followPath()
    local res,path = unit.map:pathFind(unit.x,unit.y,target.x,target.y,21,1.8)
    path.destX,path.destY = target.x,target.y
    brain.path = path
    brain.path_step = 0
  end
  --创建路径（如果需要）
  if brain.curState ~="fightingMove" then
    brain.curState = "fightingMove"
    followPath()
  elseif brain.path_step>2 or brain.path ==nil then
    followPath()
  else
    local orx,ory = brain.path.destX,brain.path.destY
    if math.abs(target.x-orx)>1 or math.abs(target.y-ory)>1 then --原有的路径有偏差
      followPath()
    end
  end
  
  --延路径移动
  local path = brain.path
  if path:isInvalid(unit) then
    followPath()
    path =  brain.path
    if (path:isInvalid(unit)) then
      unit:short_delay(1,"idle")
      debugmsg("error.   way length<=1")
      return
    end
  end
  if path:walkNext(unit) then
    brain.path_step = brain.path_step+1
  else
    unit:short_delay(0.05,"idle")
    brain.path = nil
    debugmsg("path walk Next failed")
  end
  
end



--目前只考虑近战
function Brain:inFightingAct(unit)
  local target = self.fight_target
  
  local distance = c.dist_2d(unit.x,unit.y,target.x,target.y)
  if distance<1.5 then --在一格近战范围内
    meleeAttack(unit,self,target)
  else
    moveToTarget(unit,self,target)
  end
end