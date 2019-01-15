
local suit = require"ui/suit"
local panel_id = newid()
local back_opt = {id = newid()}

local touch_id = newid()
local touch_startX
local touch_startY
local touch_centerX
local touch_centerY


local function touch()
  local actived = suit:isActive(touch_id)
  
  if actived then
      local mx,my = love.mouse.getX(),love.mouse.getY()
      mx = (mx - touch_startX)
      my = (my - touch_startY)
      ui.overmap.setCenter(touch_centerX-mx,touch_centerY+my)
      
    end
  suit:registerHitFullScreen(nil,touch_id)
  if suit:isActive(touch_id) and not actived then
    touch_startX,touch_startY = love.mouse.getPosition()
    touch_centerX,touch_centerY = ui.overmap.centerX,ui.overmap.centerY
  end
end

local function keymove(dt)
  local dx,dy =0,0
  if love.keyboard.isDown("w") then
    dy = 6
  elseif love.keyboard.isDown("s") then
    dy = -6
  end
  
  if love.keyboard.isDown("d") then
    dx = 6
  elseif love.keyboard.isDown("a") then
    dx = -6
  end
  
  ui.overmap.setCenter(ui.overmap.centerX+dx,ui.overmap.centerY+dy)
  
end



function ui.overmapSceneKeypressed(key)
  if key =="t" then
    local mx,my = love.mouse.getX(),love.mouse.getY()
    mx,my = ui.overmap.screenToModel(mx,my)
    ui.overmapSceneQuit()
    player:setPosition(math.floor(mx/2),math.floor(my/2),ui.overmap.cur_Z)
    ui.camera.resetToPlayerPosition()
  end
  
end


function ui.overmapScene_Open()
  ui.show_overmap = true
end


local mainpanel = require "ui/component/mainPanel"
function ui.overmapScene(dt)
  touch()
  keymove(dt)
  mainpanel(panel_id,c.win_W - ui.overmap.right_w,0,ui.overmap.right_w,c.win_H)
  local bbtn = suit:S9Button("返回",back_opt,c.win_W-140,0,140,30)
  if bbtn.hit then 
    ui.overmapSceneQuit()
  end
  
end

function ui.overmapSceneQuit()
  ui.show_overmap = false
  --ui.popout = nil --不能出现这个场景的popout
  render.overmap.clearBuffer()
  collectgarbage()
end
