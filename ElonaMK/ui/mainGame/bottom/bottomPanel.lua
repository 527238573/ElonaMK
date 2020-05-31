local suit = require "ui/suit"
--虚拟的panel，没有

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()


local ammoCounter=  require"ui/mainGame/bottom/ammoCounter"
local selectInfo=  require"ui/mainGame/bottom/selectInfo"


return function()
  local x,y,w,h = win_width-300,0,300,win_height
  ammoCounter(10,win_height-3)
  selectInfo(win_width-500,win_height,200)
end