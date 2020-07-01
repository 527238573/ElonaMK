
local suit = require"ui/suit"
--old
local wait_panel_img = love.graphics.newImage("assets/ui/waiting.png")
local quads =  suit.createS9Table(wait_panel_img,0,0,28,32,6,10,6,6)

function ui.waitingMessage(message)
  --message = "测试waring中..."
  love.graphics.present()
  local edge = 30
  local w,h = 350,200
  local x,y = (c.win_W-w)/2-50,(c.win_H-h)/2-150
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(quads,x,y,w,h)
  love.graphics.oldColor(30,30,30)
  love.graphics.setFont(c.font_c20)
  love.graphics.printf( message, x+edge, y+edge, w-2*edge, "center" )
  love.graphics.present()
end