AnimClip = {
  type = 0,--AnimClip的类型。
  id ="null",--。
  saveType = "AnimClip",--注册保存类型
  priority = 1,
}

saveClass["AnimClip"] = AnimClip --注册保存类型
AnimClip.__index = AnimClip

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