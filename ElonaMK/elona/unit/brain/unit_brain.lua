

--初次创建单位调用
function Unit:initBrain()
  local brain = {owner = self}
  setmetatable(brain,Brain)
  self.brain = brain
  
  brain.thisPlan =  p.calendar:getTurnpast()-1
end





local function fightingAct(unit,brain)
  
end


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



local function noFightingAct(unit,brain)
  
  wander(unit,brain)
end



local function checkFightingState(unit,brain)
  --若不再fihgting状态
  --考虑是否进入fighitng状态
  --1.被揍了，查询最近被揍信息，考虑进入战斗
  --2.看到视野有敌人
  
  --若在fighting状态
  --考虑退出fighting状态或切换目标
  --当前目标已死，失去视野并超时，
  --切换目标，被揍状态考虑，或主动切换
  
  
  brain.isFighting = false
  
end


--行动
function Unit:planAndMove()
  local brain = self.brain
  brain.lastPlan = brain.thisPlan
  brain.thisPlan = p.calendar:getTurnpast()
  --先判定是否在战斗状态。
  checkFightingState(self,brain)
  if brain.isFighting then
    fightingAct(self,brain)
  else
    noFightingAct(self,brain)
  end
end