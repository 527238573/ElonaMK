local suit = require"ui/suit"

local closeImg = love.graphics.newImage("assets/ui/closeBtn.png")
ui.res.close_quads = 
{
  normal = love.graphics.newQuad(0,0,30,24,30,72),
  hovered=  love.graphics.newQuad(0,24,30,24,30,72),
  active =  love.graphics.newQuad(0,48,30,24,30,72),
  img = closeImg,
}
local tabImg = love.graphics.newImage("assets/ui/tab.png")
ui.res.tab_quads = 
{
  normal = suit.createS9Table(tabImg,0,0,24,24,6,6,6,6),
  hovered=  suit.createS9Table(tabImg,0,24,24,24,6,6,6,6),
  active =  suit.createS9Table(tabImg,0,48,24,24,6,6,6,6),
}


local tableftImg= love.graphics.newImage("assets/ui/tab_left.png")
ui.res.tab_left_quads = 
{
  normal = suit.createS9Table(tableftImg,0,0,32,32,6,8,6,6),
  hovered=  suit.createS9Table(tableftImg,0,32,32,32,6,8,6,6),
  active =  suit.createS9Table(tableftImg,0,64,32,32,6,8,6,6),
}


local somebarImg= love.graphics.newImage("assets/ui/somebar.png")
ui.res.somebar = {
  back = suit.createS9Table(somebarImg,0,0,32,32,6,6,6,6),
  front = suit.createS9Table(somebarImg,0,32,32,32,8,8,8,8),
  triangle = love.graphics.newQuad(0,64,32,32,32,96),
  img = somebarImg,
}

ui.res.common_img = love.graphics.newImage("assets/ui/common.png")
ui.res.common_ycross = love.graphics.newQuad(0,0,22,22,ui.res.common_img:getDimensions())
ui.res.common_reset = love.graphics.newQuad(16,32,22,22,ui.res.common_img:getDimensions())
ui.res.common_backt = suit.createS9Table(ui.res.common_img,32,0,32,32,6,6,6,6)
ui.res.common_head = love.graphics.newQuad(64,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_torso = love.graphics.newQuad(80,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_arms = love.graphics.newQuad(96,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_hands = love.graphics.newQuad(112,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_legs = love.graphics.newQuad(128,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_feet = love.graphics.newQuad(144,0,16,16,ui.res.common_img:getDimensions())
ui.res.common_weapon = love.graphics.newQuad(64,16,16,16,ui.res.common_img:getDimensions())
ui.res.common_fists = love.graphics.newQuad(80,16,16,16,ui.res.common_img:getDimensions())
--ui.res.common_eqbar = love.graphics.newQuad(0,32,16,16,ui.res.common_img:getDimensions())
ui.res.common_repair =  love.graphics.newQuad(96,16,32,32,ui.res.common_img:getDimensions())
ui.res.common_remove =  love.graphics.newQuad(128,16,32,32,ui.res.common_img:getDimensions())
ui.res.common_changeTire =  love.graphics.newQuad(96,48,32,32,ui.res.common_img:getDimensions())


ui.res.common_menuS9 = suit.createS9Table(ui.res.common_img,0,32,16,16,4,4,4,4)
ui.res.common_contentS9 = suit.createS9Table(ui.res.common_img,0,48,16,16,3,3,3,3)
ui.res.common_pbackS9 = suit.createS9Table(ui.res.common_img,48,32,16,16,6,6,6,6)
ui.res.common_pfrontS9 = suit.createS9Table(ui.res.common_img,48,48,16,16,6,6,6,6)
ui.res.common_eActionS9 = suit.createS9Table(ui.res.common_img,64,32,32,32,4,6,5,5)


ui.res.aim_cross = love.graphics.newImage("assets/ui/aim_cross2.png")
ui.res.aim_point = love.graphics.newImage("assets/ui/aim_point.png")

ui.res.iteminfo_img = love.graphics.newImage("assets/ui/iteminfo.png")
ui.res.iteminfo_quad  = suit.createS9Table(ui.res.iteminfo_img,0,0,26,30,6,8,6,6)


ui.res.hpstate_img = love.graphics.newImage("assets/ui/hpbar.png")
ui.res.hpquad_speed = love.graphics.newQuad(123,78,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_str = love.graphics.newQuad(123,92,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_dex = love.graphics.newQuad(156,92,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_int = love.graphics.newQuad(123,106,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_per = love.graphics.newQuad(156,106,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_morale = love.graphics.newQuad(12,139,11,11,ui.res.hpstate_img:getDimensions())
ui.res.hpquad_pain = love.graphics.newQuad(0,139,11,11,ui.res.hpstate_img:getDimensions())


ui.res.wait_panel_img = love.graphics.newImage("assets/ui/waiting.png")
ui.res.wait_quads =  suit.createS9Table(ui.res.wait_panel_img,0,0,28,32,6,10,6,6)


ui.res.dir_arrow_img =love.graphics.newImage("assets/ui/directionArrow.png")


ui.res.msg_panel_img = love.graphics.newImage("assets/ui/messageWin.png")
ui.res.msg_panel_quads =  suit.createS9Table(ui.res.msg_panel_img,0,0,32,32,6,6,6,6)