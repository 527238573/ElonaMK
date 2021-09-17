
--brain状态机，这个table存放各种状态。
Brain= {
  lastPlan = 0,--上一次思考的时间(RL时间)
  thisPlan = 0,--这一次思考的时间
  
  isFighting = false,-- 是否在战斗状态  这个状态只作为自身AI的状态，不要用来其他查询
  
  curState = "idle",--当前状态（总状态）
  
  
  path_step=0,
}
local niltable = { --默认值为nil的成员变量
  owner = true,--brain的所有者，unit
  fight_target = true, --如果在这一
  
  --非战斗状态变量
  follow_target = true,--需要跟随的目标，为nil不跟随
  wander_region = true,--乱逛限制的区域
  
  path = true,
  
  
  
}
saveMetaType("Brain",Brain,niltable)--注册保存类型

Brain.__newindex = function(o,k,v)
  if Brain[k]==nil and niltable[k]==nil then error("使用了Brain的意料之外的值。") else rawset(o,k,v) end
end

--brain有很多引用类型，需要在切换地图及传输时保证清除

--需要在保存前清除一些引用
function Brain:preSave()
  --如果fight_target隶属同一张地图才保留，否则不保留。
  if self.fight_target then
    if not(self.fight_target.map == self.owner.map and self.owner.map ~=nil) then --必须在同一张图且不为nil，才能保存目标
      self.fight_target = nil
    end
  end
  
end
function Brain:loadfinish()
  
end

