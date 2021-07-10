local suit = require "ui/suit"

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id=newid(),mg= true}


local messageWin = require"ui/mainGame/right/message"
local miniMap = require"ui/component/editor/minimap"
local bottomBar = require"ui/mainGame/right/bottomBar"
local teamBar=  require"ui/mainGame/right/team"



return function()
  local x,y,w,h = win_width-300,0,300,win_height

  suit:Panel(panel_opt,x,y,w,h)
  
  if Scene.inOvermapMode() then
    miniMap(wmap,g.wcamera,x+25,y+25,250,250)
  else
    miniMap(cmap,g.camera,x+25,y+25,250,250)
  end
  teamBar(x+6,y+340)
  
  local messageY = 368
  messageWin(x+2,messageY,w-4,h-messageY-52)
  bottomBar()
end