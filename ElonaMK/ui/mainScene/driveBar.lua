
local suit = require"ui/suit"
local quads =  ui.res.msg_panel_quads

local small_key = true
local shortcut_img = love.graphics.newImage("assets/ui/shortcut_key.png")
local shortcut_quad = love.graphics.newQuad(0,6,364,38,shortcut_img:getDimensions())
local key_quad = love.graphics.newQuad(0,0,364,6,shortcut_img:getDimensions())

local function ShortCutKey(midx)
  local size = small_key and 1.5 or 2
  local leftborder =  midx- 364/2*size+40
  local clampb = c.win_W-288 - 364*size-4
  leftborder = math.min(leftborder,clampb)
  local topborder = c.win_H - 38*size
  local function drawBarBack()
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(shortcut_img,shortcut_quad,leftborder,topborder,0,size,size)
    love.graphics.draw(shortcut_img,key_quad,leftborder+4*size,topborder+5*size,0,size,size)
  end
  suit:registerDraw(drawBarBack)
end


local ptext = love.graphics.newText(c.font_c18)
local txt = tl(" 转向 [←→]  速度 [↑↓]  行进 [space]  停止驾驶 [q]  其他 [e] "," turn [←→]  speed [↑↓]  advance [space]  Stop driving [q]  menu [e]")
local function driveBar(midx)
  local veh = player.controlling_vehicle
  
  
  local w = 700
  local h = 80
  local hh = 5
  local x = midx-w/2
  local y = c.win_H-h
  local function drawBarBack()
    love.graphics.oldColor(255,255,255)
    suit.theme.drawScale9Quad(quads,x,y,w,h+hh)
    love.graphics.setFont(c.font_c18)
    love.graphics.oldColor(180,180,180)
    love.graphics.print(txt, x+8, y+4)
    love.graphics.oldColor(210,210,210)
    love.graphics.print(tl("设定速度:","Cruise velocity:"), x+8, y+28)
    if veh.cruise_safe then
      love.graphics.oldColor(90,225,90)
    else
      love.graphics.oldColor(220,120,120)
    end
    love.graphics.print(string.format("%d",math.floor(veh.cruise_velocity)), x+128, y+28)
    
    love.graphics.oldColor(210,210,210)
    love.graphics.print(tl("当前速度:","Velocity:"), x+8, y+52)
    
    love.graphics.oldColor(120,120,255)
    love.graphics.print(string.format("%d",math.floor(veh.velocity)), x+128, y+52)
    
    love.graphics.oldColor(210,210,210)
    love.graphics.print(tl("剩余燃料:","Fuel:"), x+358, y+28)
    love.graphics.oldColor(190,135,135)
    love.graphics.print(tl("86%"), x+458, y+28)
    
    
    love.graphics.oldColor(210,210,210)
    love.graphics.print(tl("剩余电池:","Residual battery:"), x+358, y+52)
    love.graphics.oldColor(190,190,90)
    love.graphics.print(tl("34%"), x+458, y+52)
    
    
  end
  suit:registerDraw(drawBarBack)
end






local function middleBar(midx)
  if player:useing_vehicle_control() then
    driveBar(midx)
  else
    ShortCutKey(midx)
  end
end








return middleBar