c.pic ={}
local parchmentImg= love.graphics.newImage("assets/ui/parchment.png")
c.pic["parchment"] = c.createS9Table(parchmentImg,0,0,parchmentImg:getWidth(),parchmentImg:getHeight(),20,20,16,16)


local titleKuangImg= love.graphics.newImage("assets/ui/kuang.png")
c.pic["titleKuang"] = c.createS9Table(titleKuangImg,0,0,titleKuangImg:getWidth(),titleKuangImg:getHeight(),6,6,6,6)

local editorbtnImg = love.graphics.newImage("assets/ui/editor_button.png")
c.pic["editor_btn_quads"] = {
  normal = c.createS9Table(editorbtnImg,0,0,75,23,3,3,3,3),
  hovered= c.createS9Table(editorbtnImg,0,23,75,23,3,3,3,3),
  active = c.createS9Table(editorbtnImg,0,46,75,23,3,3,3,3)
}


local closeImg = love.graphics.newImage("assets/ui/closeBtn.png")
c.pic["close_quads"] = 
{
  normal = love.graphics.newQuad(0,0,30,24,30,72),
  hovered=  love.graphics.newQuad(0,24,30,24,30,72),
  active =  love.graphics.newQuad(0,48,30,24,30,72),
  img = closeImg,
}

local closeImg2 = love.graphics.newImage("assets/ui/PcloseBtn.png")
c.pic["close_quads2"] = 
{
  normal = love.graphics.newQuad(0,0,30,24,30,72),
  hovered=  love.graphics.newQuad(0,24,30,24,30,72),
  active =  love.graphics.newQuad(0,48,30,24,30,72),
  img = closeImg2,
}

local btnImg = love.graphics.newImage("ui/suit/assets/button.png")
c.pic["btn_quads"] = {
  normal = c.createS9Table(btnImg,0,0,28,32,6,10,6,6),
  hovered= c.createS9Table(btnImg,0,32,28,32,6,10,6,6),
  active = c.createS9Table(btnImg,0,64,28,32,6,10,6,6)
}


local btn2_img = love.graphics.newImage("ui/suit/assets/button2.png")
c.pic["btn2_quads"] = {
  normal = c.createS9Table(btn2_img,0,0,28,32,6,10,6,6),
  hovered= c.createS9Table(btn2_img,0,32,28,32,6,10,6,6),
  active = c.createS9Table(btn2_img,0,64,28,32,6,10,6,6)
}


local msg_panel_img = love.graphics.newImage("assets/ui/messageWin.png")
c.pic["msg_panel_quads"] =  c.createS9Table(msg_panel_img,0,0,32,32,6,6,6,6)

local msg_img = love.graphics.newImage("assets/ui/message2.png")
c.pic["msg_quads"] =  c.createS9Table(msg_img,0,0,msg_img:getWidth(),msg_img:getHeight(),4,4,4,4)


local uiIcon_img = love.graphics.newImage("assets/ui/uiIcon.png")
c.pic["uiIcon"] = {img = uiIcon_img}
local w = math.floor(uiIcon_img:getWidth()/32)
local h = math.floor(uiIcon_img:getHeight()/32)
for y =0,h do
  for x=0,w do
    c.pic.uiIcon[y*w +x+1] = love.graphics.newQuad(x*32,y*32,32,32,uiIcon_img:getWidth(),uiIcon_img:getHeight())
  end
end
local uiAttr_img = love.graphics.newImage("assets/ui/attr.png")
c.pic["uiAttr"] = {img = uiAttr_img}
w = math.floor(uiAttr_img:getWidth()/16)
h = math.floor(uiAttr_img:getHeight()/16)
for y =0,h do
  for x=0,w do
    c.pic.uiAttr[y*w +x+1] = love.graphics.newQuad(x*16,y*16,16,16,uiAttr_img:getWidth(),uiAttr_img:getHeight())
  end
end



local ui_clip_img = love.graphics.newImage("assets/ui/ui_clip.png")
c.pic["ui_clip"] = {img = ui_clip_img}
c.pic.ui_clip.attr = love.graphics.newQuad(0,0,20,16,ui_clip_img:getWidth(),ui_clip_img:getHeight())
c.pic.ui_clip.hotkey = love.graphics.newQuad(32,0,22,16,ui_clip_img:getWidth(),ui_clip_img:getHeight())
c.pic.ui_clip.select = love.graphics.newQuad(64,0,16,16,ui_clip_img:getWidth(),ui_clip_img:getHeight())

local progressBar_img = love.graphics.newImage("assets/ui/progressBar.png")
c.pic["progressBar"] = {img = progressBar_img}
w = math.floor(progressBar_img:getWidth()/16)
h = math.floor(progressBar_img:getHeight()/16)
for y =0,h do
  for x=0,w do
    c.pic.progressBar[y*w +x+1] = c.createS9Table(progressBar_img,x*16,y*16,16,16,6,6,6,6)
  end
end


local sideTab_img = love.graphics.newImage("assets/ui/sideTab.png")
c.pic["sideTab_quads"] = 
{
  normal = c.createS9Table(sideTab_img,0,0,240,64,8,24,22,10),
  hovered= c.createS9Table(sideTab_img,0,64,240,64,8,24,22,10),
  active = c.createS9Table(sideTab_img,0,128,240,64,8,24,22,10),
  img = sideTab_img,
}


local teamBtn_img = love.graphics.newImage("assets/ui/teamBtn.png")
c.pic["teamBtn_quads"] = 
{
  normal = c.createS9Table(teamBtn_img,0,0,28,32,10,14,10,10),
  hovered= c.createS9Table(teamBtn_img,0,32,28,32,10,14,10,10),
  active = c.createS9Table(teamBtn_img,0,64,28,32,10,14,10,10),
  disable= c.createS9Table(teamBtn_img,0,96,28,32,10,14,10,10),
  skull= love.graphics.newQuad(0,128,28,32,teamBtn_img:getWidth(),teamBtn_img:getHeight()),
  img = teamBtn_img,
}
c.pic["empty_member"] =  love.graphics.newImage("assets/ui/emptyMember.png")

local lifebar_img = love.graphics.newImage("assets/ui/lifeBar.png")
c.pic["lifebar_quads"] = 
{
  green= love.graphics.newQuad(0,0,lifebar_img:getWidth(),6,lifebar_img:getWidth(),lifebar_img:getHeight()),
  blue= love.graphics.newQuad(0,6,lifebar_img:getWidth(),4,lifebar_img:getWidth(),lifebar_img:getHeight()),
  img = lifebar_img,
}
c.pic["unit_shadow"] = love.graphics.newImage("assets/ui/unit_shadow.png")

local somebar_img = love.graphics.newImage("assets/ui/somebar.png")
c.pic["slider_bar"] = {
  back = c.createS9Table(somebar_img,0,0,32,32,6,6,6,6),
  front = c.createS9Table(somebar_img,0,32,32,32,8,8,8,8),
  triangle = love.graphics.newQuad(0,64,32,32,32,96),
  img = somebar_img,
}


