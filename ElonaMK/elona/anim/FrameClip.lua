FrameClip = {
  type = 0,--AnimClip的类型。
  id ="null",--。
  priority = 1,
  
  x=0, --model坐标
  y=0,
  rotation = 0, --旋转。
  flipX = false,--翻转X轴
  flipY = false,--翻转Y轴
  scaleX = 1,
  scaleY =1,
  shearX =0,
  shearY =0,
  drop_to_map = false,--当附着在单位上时，单位死亡时掉落至地图继续播放。
  
  remaining_life = 1000,--当loop激活时 最多存活时间秒。
  rotation_speed = 0,--转速。
  rot_uv = 0,--
  rot_uv_speed = 0,--
}
 saveMetaType("FrameClip",FrameClip)--注册保存类型
--frameClip可以保存。
function FrameClip:loadfinish()
  rawset(self,"type",assert(data.frames[self.id]))
  
end



function FrameClip.new(id)
  local o= {}
  o.id = id
  o.type = assert(data.frames[id])
  o.createFrame = g.curFrame --记录生成位于的帧。当前帧创建的对象 在当前帧不会被更新，在下一帧开始更新，统一视为在帧末尾创建的。
  o.playSpeed = 1--默认1原速。
  o.time = 0--播放位置  为负数表示delay。
  o.life = 0--存活总时间。
  o.loop = false --一次性。
  o.pause = false--暂停
  o.dx = 0 --与挂载点的偏移。单位用
  o.dy = 0
  o.underUnit = false--前后关系。挂载到单位身上有身前背后效果。
  setmetatable(o,FrameClip)
  return o
end


function FrameClip:updateAnim(dt)
  if not self.pause and self.createFrame ~= g.curFrame  then --当前帧创建的对象不会时间经过。
    self.time = self.time+dt*self.playSpeed
    if self.loop then self.remaining_life = self.remaining_life-dt end
    if self.updateFunc then self:updateFunc(dt) end--外围输入的自更新方法
  end
  self.life = self.life+dt
  if self.rotation_speed ~=0 then self.rotation = self.rotation + self.rotation_speed*dt end
  if self.rot_uv_speed~=0 then self.rot_uv = self.rot_uv + self.rot_uv_speed*dt end
end

function FrameClip:isFinish()
  if self.finished then return true end
  if self.loop then
    
    return self.remaining_life<0
  else
    local frameT = self.type
    return self.time>frameT.secPerFrame*frameT.frameNum
  end
end

function FrameClip:getImgQuad()
  local frameT = self.type
  local frameIndex = math.floor(self.time/frameT.secPerFrame)+1
  if frameIndex>frameT.frameNum then
    if self.loop then
      frameIndex = (frameIndex-1)%frameT.frameNum+1
      self.time = self.time%(frameT.frameNum*frameT.secPerFrame)
    else
      frameIndex = frameT.frameNum--不循环就是最后一帧。
    end
  end
  return frameT.img,frameT[frameIndex]
end

function FrameClip:setTimeToFrame(frameindex)
  local frameT = self.type
  self.time = frameT.secPerFrame*(frameindex-1)
end

function FrameClip:setLoopPeriod(remaining_life)
  self.loop = true
  self.remaining_life = remaining_life
end
