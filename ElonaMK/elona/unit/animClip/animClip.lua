AnimClip = {
  type = 0,--AnimClip的类型。
  id ="null",--。
  priority = 1,
  isRL = false,--rl类型的animClip
  finished = false,--标记后一定会自动结束
}
saveMetaType("AnimClip",AnimClip)--注册保存类型

function AnimClip.new(id,totalTime)
  assert(totalTime>0)
  local o= {}
  o.id = id
  o.time = 0
  o.totalTime = totalTime
  setmetatable(o,AnimClip)
  return o
end

function AnimClip:getPriority()
  return self.priority
end

function AnimClip:isFinished()
  return self.finished or (self.time>= self.totalTime)
end

function AnimClip:updateAnim(dt,status,unit)
  if self.isRL then dt = g.dt_rl end --RL类型的clip跟随RL时间走
  self.time = self.time+dt
  if self.time>=self.totalTime  or self.finished then 
    return
  end 
  self.updates[self.id](self,dt,status,unit)
end