




local move

function ui.cameraInterpolationMove(time)
  local startX,startY = g.camera.centerX,g.camera.centerY
  
  move = {startX = startX,startY=startY,time = 0,totalTime = time}
end


return function (dt)
  if move then
    move.time =move.time +dt
    if move.time >=move.totalTime then
      move = nil
    else
      local rate = move.time/move.totalTime
      local cx,cy = g.camera.centerX,g.camera.centerY
      g.camera:setCenter(move.startX + rate*(cx-move.startX),move.startY + rate*(cy-move.startY))
    end
  end
end