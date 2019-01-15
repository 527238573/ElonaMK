local suit = require"ui/suit"

local buttons_img = love.graphics.newImage("assets/ui/cameraZbutton.png")
local up_quads  = {img = buttons_img,
  love.graphics.newQuad(0,0,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(18,0,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(36,0,18,86,buttons_img:getDimensions())}
local mid_quads  = {img = buttons_img,
  love.graphics.newQuad(0,86,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(18,86,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(36,86,18,86,buttons_img:getDimensions())}
local down_quads  = {img = buttons_img,
  love.graphics.newQuad(0,172,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(18,172,18,86,buttons_img:getDimensions()),
  love.graphics.newQuad(36,172,18,86,buttons_img:getDimensions())}

local camera = ui.camera
local grid = g.map.grid
return function(x,y)
  local up = suit:ImageButton(up_quads,up_quads, x,y,18,86)
  local mid = suit:ImageButton(mid_quads,mid_quads, x,y+86,18,86)
  local down = suit:ImageButton(down_quads,down_quads, x,y+172,18,86)
  if camera.cur_Z == grid.minZsub +3 then
    up_quads.state = "active"
  end
  if camera.cur_Z == grid.minZsub +2 then
    mid_quads.state = "active"
  end
  if camera.cur_Z == grid.minZsub +1 then
    down_quads.state = "active"
  end
  if g.cameraLock.locked then return end
  if up.hit then 
    local toset = grid.minZsub +3
    if toset>=-10 and toset<=12 then
      camera.setZ(toset)
    end
  end
  if mid.hit then 
    local toset = grid.minZsub +2
    if toset>=-10 and toset<=12 then
      camera.setZ(toset)
    end
  end
  if down.hit then 
    local toset = grid.minZsub +1
    if toset>=-10 and toset<=12 then
      camera.setZ(toset)
    end
  end
  
end