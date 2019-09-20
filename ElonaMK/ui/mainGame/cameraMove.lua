




local move
local om_move
function ui.cameraInterpolationMove(time)
  local startX,startY = g.camera.centerX,g.camera.centerY
  
  move = {startX = startX,startY=startY,time = 0,totalTime = time}
end

function ui.overmapCameraInterpolationMove(time)
  local startX,startY = g.wcamera.centerX,g.wcamera.centerY
  om_move = {startX = startX,startY=startY,time = 0,totalTime = time}
end

function ui.cameraMove(dt)
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


function ui.overmapCameraMove(dt)
  if om_move then
    om_move.time =om_move.time +dt
    if om_move.time >=om_move.totalTime then
      om_move = nil
    else
      local rate = om_move.time/om_move.totalTime
      local cx,cy = g.wcamera.centerX,g.wcamera.centerY
      g.wcamera:setCenter(om_move.startX + rate*(cx-om_move.startX),om_move.startY + rate*(cy-om_move.startY))
    end
  end
end