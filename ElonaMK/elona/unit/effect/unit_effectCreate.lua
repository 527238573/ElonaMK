--创建特定的effect。

--进入吟唱状态。
--magic_style 1= 大圈，2=小圈，3 = 地圈
--time 吟唱时间。
--返回一个effect，对effect使用setEndCall设置一个回调函数，指示成功完成吟唱之后的动作。
function Unit:addEffect_chanting(magic_style,time)
  time =math.max(0,time)
  --计算time，可能有施法加速等等。
  
  local effect = Effect.new("chanting")
  effect.remain = time
  if magic_style==1 then
    local frame = FrameClip.createUnitFrame("magic_circle")
    frame:setLoopPeriod(time)
    frame.rotation_speed = -1
    self:addFrameClip(frame)
    effect:addFrame(frame)
    effect.loopSound = "chantingLoop1"
  elseif magic_style ==2 then
    local frame = FrameClip.createUnitFrame("small_magic")
    frame:setLoopPeriod(time)
    frame.rotation_speed = -0.5
    self:addFrameClip(frame)
    effect:addFrame(frame)
    effect.loopSound = "chantingLoop1"
  else -- ==3
    local frame = FrameClip.createUnitFrame("single_circle")
    frame:setLoopPeriod(time)
    frame.scaleX = 0.5
    frame.scaleY = 0.25
    frame.dy = -self:get_foot_offset()
    frame.underUnit = true
    frame.rot_uv_speed = 1
    self:addFrameClip(frame)
    effect:addFrame(frame)
    effect.loopSound = "chantingLoop1"
  end
  self:addEffect(effect)
  self:bar_delay(time,"chant","chant")--启用行动占用。
  return effect
end