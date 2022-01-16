

--初次创建单位调用
function Unit:initBrain()
  local brain = {owner = self}
  setmetatable(brain,Brain)
  self.brain = brain
  
  brain.thisPlan =  p.calendar:getTurnpast()-1
end


local function searchEnemy(unit,brain)
  if (brain.thisPlan - brain.lastSearchEnemyTurn) <1.5 then return nil end --间隔时间太短不会去找
  brain.lastSearchEnemyTurn = brain.thisPlan
  return unit:findNearestEnemy()
end



--是否能持续在fighting状态
local function checkOnFighting(unit,brain)
  local target = brain.fight_target
  if target ==nil then return false end
  if target:is_dead() then return false end --
  if not unit:isHostile(target)  then return false end --阵营转化
  if not unit:seesUnit(target)  then return false end--看不见就不追，以后可能改为还会追一小段
  return true
end

--在战斗中已有目标的情况下，考虑是否切换目标。目前根据距离，以后可能考虑被击仇恨
local function checkCanChangeTarget(unit,brain)
  local target = brain.fight_target
  local new_target = searchEnemy(unit,brain)
  if new_target ==nil or new_target == target then return end --不用切换
  local dist_old = c.dist_2d(target.x,target.y,unit.x,unit.y)
  local dist_new = c.dist_2d(new_target.x,new_target.y,unit.x,unit.y)
  if dist_new<dist_old-1 then
    local f = dist_old/dist_new
    f = c.remap_to(f,1,3,0.3,0.7) --根据距离1~3倍 ，30%到70% 几率切换目标
    if rnd()<f then
      brain.fight_target =new_target
    end
  end
end


local function checkFightingState(unit,brain)
  
  
  if brain.isFighting then
    local continueFighting = checkOnFighting(unit,brain)
    if continueFighting then
      --考虑是否切换目标
      checkCanChangeTarget(unit,brain)
      return --继续战斗
    end
    brain.isFighting = false
    brain.fight_target = nil --退出战斗
  end
  
  --当前不在战斗状态，搜索附近敌人
  local target = searchEnemy(unit,brain)
  if target ~=nil then
    brain.isFighting = true
    brain.fight_target = target
    brain.path = nil
  end
  
  
end


--行动
function Unit:planAndMove()
  local brain = self.brain
  brain.lastPlan = brain.thisPlan
  brain.thisPlan = p.calendar:getTurnpast()
  --先判定是否在战斗状态。
  checkFightingState(self,brain)
  if brain.isFighting then
    brain:inFightingAct(self)
  else
    brain:noFightingAct(self)
  end
end