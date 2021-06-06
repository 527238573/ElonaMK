
--brain状态机，这个table存放各种状态。
Brain= {
  lastPlan = 0,--上一次思考的时间(RL时间)
  thisPlan = 0,--这一次思考的时间
  
  isFighting = false,-- 是否在战斗状态  这个状态只作为自身AI的状态，不要用来其他查询
  
}
local niltable = { --默认值为nil的成员变量
  owner = true,--brain的所有者，unit
  fight_target = true, --如果在这一
  
}
saveMetaType("Brain",Brain,niltable)--注册保存类型

Brain.__newindex = function(o,k,v)
  if Brain[k]==nil and niltable[k]==nil then error("使用了Brain的意料之外的值。") else rawset(o,k,v) end
end

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

