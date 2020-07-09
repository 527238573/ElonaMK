local suit = require "ui/suit"
local bit = require("bit")

local touch = {}
return function()
  local actived = suit:isActive(touch)
  if actived then
      -- mouse update
      local mx,my = love.mouse.getX(),love.mouse.getY()
      --mx = (mx - touch.startX)/editor.camera.workZoom
      --my = (my - touch.startY)/editor.camera.workZoom
      
      --editor.camera:setCenter(touch.centerX-mx,touch.centerY+my)
      
    end
  suit:registerHitFullScreen(nil,touch)
  if suit:isActive(touch) and not actived then
    -- mouse update
    local mx,my = love.mouse.getX(),love.mouse.getY()
    mx,my = g.camera:screenToModel(mx,my)
    local sx = bit.arshift(mx,6)
    local sy1 = bit.arshift(my-32,6)
    local sy2 = bit.arshift(my,6)
    p.mc.target = Target:new(cmap:unit_at(sx,sy1),sx,sy2)
    p.mc:checkTarget()
    
    
  end
  
  
end