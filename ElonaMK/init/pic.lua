c.pic ={}
local suit = require"ui/suit"
local parchmentImg= love.graphics.newImage("assets/ui/parchment.png")
c.pic["parchment"] = suit.createS9Table(parchmentImg,0,0,parchmentImg:getWidth(),parchmentImg:getHeight(),20,20,16,16)


local titleKuangImg= love.graphics.newImage("assets/ui/kuang.png")
c.pic["titleKuang"] = suit.createS9Table(titleKuangImg,0,0,titleKuangImg:getWidth(),titleKuangImg:getHeight(),6,6,6,6)

local editorbtnImg = love.graphics.newImage("assets/ui/editor_button.png")
c.pic["editor_btn_quads"] = {
  normal = suit.createS9Table(editorbtnImg,0,0,75,23,3,3,3,3),
  hovered= suit.createS9Table(editorbtnImg,0,23,75,23,3,3,3,3),
  active = suit.createS9Table(editorbtnImg,0,46,75,23,3,3,3,3)
}


local closeImg = love.graphics.newImage("assets/ui/closeBtn.png")
c.pic["close_quads"] = 
{
  normal = love.graphics.newQuad(0,0,30,24,30,72),
  hovered=  love.graphics.newQuad(0,24,30,24,30,72),
  active =  love.graphics.newQuad(0,48,30,24,30,72),
  img = closeImg,
}


local msg_panel_img = love.graphics.newImage("assets/ui/messageWin.png")
c.pic["msg_panel_quads"] =  suit.createS9Table(msg_panel_img,0,0,32,32,6,6,6,6)

local msg_img = love.graphics.newImage("assets/ui/message2.png")
c.pic["msg_quads"] =  suit.createS9Table(msg_img,0,0,msg_img:getWidth(),msg_img:getHeight(),4,4,4,4)