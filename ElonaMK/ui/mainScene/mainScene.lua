

local suit = require"ui/suit"
local panel_id = newid()
local btntest_opt = {id = newid()}
local btnZoom_opt = {id = newid()}

require "ui/mainScene/mainTouch"
require "ui/mainScene/KeyControl"
require "ui/mainScene/minimap"
require "ui/mainScene/stateWin"
require "ui/mainScene/messageWin"
local mainpanel = require "ui/component/mainPanel"
local cameraZbutton = require "ui/component/cameraZbutton"
local bottemBar = require"ui/mainScene/bottomBar"
local effectView = require"ui/mainScene/effectView"

local minimapX = c.win_W-275
local messageY = 468

function ui.mainScene(dt)
  --测试
  ui.mainTouch()
  ui.mainKeyCheck(dt)
  mainpanel(panel_id,c.win_W - ui.camera.right_w,0,ui.camera.right_w,c.win_H)
  local zoombtn = suit:S9Button("zoom change",btnZoom_opt,c.win_W-275,0,130,30)
  local obtn = suit:S9Button("overmap地图",btntest_opt,c.win_W-140,0,140,30)
  
  ui.minimap(c.win_W-275,34)
  cameraZbutton(c.win_W-20,34)
  ui.stateWin(c.win_W-275,295)
  ui.messageWin(c.win_W - ui.camera.right_w+5,messageY,ui.camera.right_w-10,c.win_H-messageY-52)
  bottemBar()
  effectView()
  
  if obtn.hit then 
    ui.overmapScene_Open()
  end
  if zoombtn.hit then 
    if ui.camera.zoom == 0.5 then
      ui.camera.setZoom(1)
    else
      ui.camera.setZoom(ui.camera.zoom-0.25)
    end
  end
  
end

