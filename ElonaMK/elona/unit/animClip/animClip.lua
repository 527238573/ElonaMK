AnimClip = {
  type = 0,--AnimClip的类型。
  id ="null",--。
  priority = 1,
  isRL = false,--rl类型的animClip
  finished = false,--标记后一定会自动结束
}
saveMetaType("AnimClip",AnimClip)--注册保存类型

--读取完成后自动调用。不再使用index。id是字符串，永不变化。
function AnimClip:loadfinish()
  self.type = assert(data.animClip[self.id])
  self.createFrame = -1
end

function AnimClip.new(id,totalTime,...)
  assert(totalTime>0)
  local o= {}
  o.id = id
  o.type = assert(data.animClip[id])
  o.time = 0
  o.totalTime = totalTime
  o.createFrame = g.curFrame --记录生成位于的帧。当前帧创建的对象 在当前帧不会被更新，在下一帧开始更新，统一视为在帧末尾创建的。
  setmetatable(o,AnimClip)
  o.type.init(o,...)
  return o
end

function AnimClip:getPriority()
  return self.priority or self.type.priority
end

function AnimClip:isFinished()
  return self.finished or (self.time> self.totalTime)
end

function AnimClip:updateAnim(dt,status,unit)
  if self.isRL then dt = g.dt_rl end --RL类型的clip跟随RL时间走
  if self.createFrame ~= g.curFrame  then --当前帧创建的对象不会时间经过。
    self.time = self.time+dt
  end
  if self.time> self.totalTime then return end --超时就不跟新status
  self.type.updateStatus(self,dt,status,unit)
end