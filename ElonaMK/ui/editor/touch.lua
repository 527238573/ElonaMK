local suit = require "ui/suit"
local bit = require("bit")


local touch = {}

return function()
  local actived = suit:isActive(touch)
  
  if actived then
      -- mouse update
      local mx,my = love.mouse.getX(),love.mouse.getY()
      mx = (mx - touch.startX)/editor.camera.workZoom
      my = (my - touch.startY)/editor.camera.workZoom
      
      editor.camera:setCenter(touch.centerX-mx,touch.centerY+my)
      
    end
  suit:registerHitFullScreen(nil,touch)
  if suit:isActive(touch) and not actived then
    -- mouse update
    touch.startX,touch.startY = love.mouse.getPosition()
    touch.centerX,touch.centerY = editor.camera.centerX,editor.camera.centerY
  end
  if suit:isActiveR(touch) then 
    local mx,my = love.mouse.getX(),love.mouse.getY()
    mx,my = editor.camera:screenToModel(mx,my)
    local sx = bit.arshift(mx,6)
    local sy = bit.arshift(my,6)
    if editor.brushPos==nil or (editor.brushPos[1]~=sx or editor.brushPos[2]~=sy ) then
      editor.brushPos = {sx,sy}
      editor.brushSquare(sx,sy)
    end
  else
    editor.brushPos = nil
  end
  
  
  if suit:isHovered(touch) and suit:wasHovered(touch) then
    local dy  = suit:getWheelNumber()
    editor.camera:setWorkZoom(editor.camera.workZoom +dy*0.25)
  end
  
  
end
