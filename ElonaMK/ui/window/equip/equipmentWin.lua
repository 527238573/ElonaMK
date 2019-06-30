local suit = require"ui/suit"
--先声明本体
local equipmentWin = {name = tl("装备","Equipment"),icon = 14,opt = {id= newid()}}

local button_quads = c.pic["teamBtn_quads"]
local button_mainhand_opt = {id= newid()}
local button_offhand_opt = {id= newid()}
local button_body_opt = {id= newid()}
local button_accessory1_opt = {id= newid()}
local button_accessory2_opt = {id= newid()}

local lineh = 68
local iconlist = c.pic["uiIcon"]
local function drawBack(x,y,w,h)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+40,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+200,y+40,0,1,1)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("部位","Category"), x+73, y+40) --改成一次性的读取翻译
  love.graphics.print(tl("装备名称","Name"), x+223, y+40) --改成一次性的读取翻译
  love.graphics.line(x+53, y+58,x+140, y+58)
  love.graphics.line(x+203, y+58,x+330, y+58)
  
  
  love.graphics.setColor(0.5,0.5,0.4,0.2)
  love.graphics.rectangle("fill",x+30,y+64,w-60,lineh)
  love.graphics.rectangle("fill",x+30,y+64+lineh*2,w-60,lineh)
  love.graphics.rectangle("fill",x+30,y+64+lineh*4,w-60,lineh)
  
  love.graphics.setColor(1,1,1)
  local img = iconlist.img
  love.graphics.draw(img,iconlist[33],x+40,y+66,0,2,2)
  love.graphics.draw(img,iconlist[34],x+40,y+66+lineh,0,2,2)
  love.graphics.draw(img,iconlist[35],x+40,y+66+lineh*2,0,2,2)
  love.graphics.draw(img,iconlist[36],x+40,y+66+lineh*3,0,2,2)
  love.graphics.draw(img,iconlist[36],x+40,y+66+lineh*4,0,2,2)
end


local function equipButtons(x,y)
  local btn1_st = suit:ImageButton(button_quads,button_mainhand_opt,x+53,y+66,170,64)
  local btn2_st = suit:ImageButton(button_quads,button_offhand_opt,x+53,y+66+lineh,170,64)
  local btn3_st = suit:ImageButton(button_quads,button_body_opt,x+53,y+66+lineh*2,170,64)
  local btn4_st = suit:ImageButton(button_quads,button_accessory1_opt,x+53,y+66+lineh*3,170,64)
  local btn5_st = suit:ImageButton(button_quads,button_accessory2_opt,x+53,y+66+lineh*4,170,64)
  
end

function equipmentWin.keyinput(key)
  
end

function equipmentWin.win_open()
end

function equipmentWin.win_close()
  
end


function equipmentWin.window_do(dt,s_win)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  --equipButtons(s_win.x,s_win.y)
end

return equipmentWin