

--初次创建单位调用
function Unit:initBrain()
  local brain = {owner = self}
  setmetatable(brain,Brain)
  self.brain = brain
  
  brain.thisPlan =  p.calendar:getTurnpast()-1
end





local function fightingAct(unit,brain)
  
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
    brain:noFightingAct(self)
  end
end