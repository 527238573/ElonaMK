
--brain状态机，这个table存放各种状态。
Brain= {
  lastPlan = 0,--上一次思考的时间(RL时间)
  thisPlan = 0,--这一次思考的时间
  
  lastSearchEnemyTurn = 0;--上次搜索最近敌人的turn
  
  isFighting = false,-- 是否在战斗状态  这个状态只作为自身AI的状态，不要用来其他查询
  
  curState = "idle",--当前状态（总状态）
  
  
  path_step=0,--寻路状态
}
local niltable = { --默认值为nil的成员变量
  owner = true,--brain的所有者，unit
  fight_target = true, --战斗目标
  
  --非战斗状态变量
  follow_target = true,--需要跟随的目标，为nil不跟随
  wander_region = true,--乱逛限制的区域
  
  path = true,--寻路 路径
  
  
  
}
saveMetaType("Brain",Brain,niltable)--注册保存类型

Brain.__newindex = function(o,k,v)
  if Brain[k]==nil and niltable[k]==nil then error("使用了Brain的意料之外的值。") else rawset(o,k,v) end
end

--brain有很多引用类型，需要在切换地图及传输时保证清除

--需要在保存前清除一些引用
function Brain:preSave()
  --如果fight_target隶属同一张地图才保留，否则不保留。
  local function checkIsInSameMap(unit)
    if unit==nil then return nil end
    if not(unit.map == self.owner.map and self.owner.map ~=nil) then --必须在同一张图且不为nil，才能保存目标
      return nil
    end
    return unit
  end
  self.fight_target = checkIsInSameMap(self.fight_target)
  self.follow_target = checkIsInSameMap(self.follow_target)
  self.path = nil
  
end
function Brain:loadfinish()
  
end

