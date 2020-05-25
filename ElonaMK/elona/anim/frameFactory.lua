





function FrameClip.createUnitFrame(id,dx,dy,delay)
  local frame = FrameClip.new(id)
  delay = delay or 0
  frame.time = (-delay)
  frame.dx = dx or 0
  frame.dy = dy or 0
  return frame
end