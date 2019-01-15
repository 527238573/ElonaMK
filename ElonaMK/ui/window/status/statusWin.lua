local suit = require"ui/suit"
--先声明本体
local statusWin = ui.new_window()
ui.statusWin = statusWin
--通用dialogue等
local s_win = {name = tl("装备","Equipment"),x= c.win_W/2-500,y =c.win_H/2-300, w= 800,h =590,dragopt = {id= newid()}}
local close_quads = ui.res.close_quads
local close_opt = {id= newid()}
local tab_character_opt = {text= tl("  人物","    Character"),id= newid(),font = c.font_c16 ,textcolor = {22,22,88}}
local tab_equipment_opt = {text= tl("  装备","      Equipment"),id= newid(),font = c.font_c16,textcolor = {22,22,88}}
local tab_skill_opt = {text= tl("  技能","    Skills"),id= newid(),font = c.font_c16 ,textcolor = {22,22,88}}

--所有状态总集，人物，装备，技能
local characterWin = require "ui/window/status/characterWin"
local equipmentWin = require "ui/window/status/equipmentWin"
local skillWin = require "ui/window/status/skillWin"

local curentActiveWin = nil --当前激活的窗口，属于上面几种的一个


local function changeWin(newwin)
  if curentActiveWin ~= newwin then
    curentActiveWin.win_close()
    curentActiveWin = newwin
    curentActiveWin.win_open()
  end
end
--移动一个通用函数到这里
function statusWin.draw_player(x,y)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(ui.res.common_backt,x+9,y+35,140,140)
  
  --人物图像
  local animList = player:getAnimList()
  local scale = 2*animList.scalefactor
  local weapon_appearance = player:get_weapon_appearance()
  --love.graphics.oldColor(255,255,255)
  local drawfront = true 
  if weapon_appearance and (weapon_appearance.always_back) then
    drawfront = false
    local centx = weapon_appearance.start_cord[1]
    local centy = weapon_appearance.start_cord[2]
    love.graphics.draw(weapon_appearance.img,x+15+64,y+41+64,0,scale*weapon_appearance.scaleFactor/2,scale*weapon_appearance.scaleFactor/2,centx,centy)--绘制中心点
  end
  if animList.use_quad then
    love.graphics.draw(animList.img,animList[1],x+15,y+41,0,scale,scale)--绘制，根据位置（左下点）和缩放
  else
    love.graphics.draw(animList[1],x+15,y+41,0,scale,scale)--绘制，根据位置（左下点）和缩放
  end
  if weapon_appearance and drawfront then
    local centx = weapon_appearance.start_cord[1]
    local centy = weapon_appearance.start_cord[2]
    love.graphics.draw(weapon_appearance.img,x+15+64,y+41+64,0,scale*weapon_appearance.scaleFactor/2,scale*weapon_appearance.scaleFactor/2,centx,centy)--绘制中心点
  end
  
  
end







function statusWin.keyinput(key)
  curentActiveWin.keyinput(key)
end
function statusWin.win_open(openwin)
  if openwin == "character" then
    curentActiveWin = characterWin
  elseif openwin == "equipment" then
    curentActiveWin = equipmentWin
  elseif openwin == "skill" then
    curentActiveWin = skillWin
  elseif curentActiveWin==nil then
    curentActiveWin = characterWin --没有的话默认第一个
  end
  curentActiveWin.win_open()
end

function statusWin.win_close()
  curentActiveWin.win_close()
end

function statusWin.window_do(dt)
  suit:DragArea(s_win,true,s_win.dragopt)
  
  --使用该窗口的名字
  suit:Dialog(curentActiveWin.name,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  
  local character_st = suit:ImageButton(ui.res.tab_left_quads,tab_character_opt,s_win.x-104,s_win.y+44,110,43)
  local equipment_st = suit:ImageButton(ui.res.tab_left_quads,tab_equipment_opt,s_win.x-104,s_win.y+90,110,43)
  local skill_st = suit:ImageButton(ui.res.tab_left_quads,tab_skill_opt,s_win.x-104,s_win.y+136,110,43)
  if curentActiveWin == characterWin then tab_character_opt.state ="active"
  elseif curentActiveWin == equipmentWin then tab_equipment_opt.state ="active"
  elseif curentActiveWin == skillWin then tab_skill_opt.state ="active" end
  
  
  curentActiveWin.window_do(dt,s_win.x,s_win.y,s_win.w,s_win.h)
  
  if close_st.hit then statusWin:Close() end
  if character_st.hit then changeWin(characterWin) end
  if equipment_st.hit then  changeWin(equipmentWin) end
  if skill_st.hit then changeWin(skillWin) end
  
  
end










