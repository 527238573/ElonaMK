local suit = require"ui/suit"

local statusWin = Window.new()
ui.statusWin = statusWin


local teamButtons = require"ui/component/window/teamButtons"
local parchment = require"ui/component/window/parchment"
local titleFrame = require"ui/component/window/titleFrame"
local s_win = {name = tl("人物","Character"),id=newid(),x= (c.win_W-ui.right_w)/2-400+50,y =(c.win_H-ui.bottom_h)/2-300+50, w= 800,h =600,dragopt = {id= newid()}}
local close_quads = c.pic.close_quads2
local close_opt = {id= newid()}
local subWins = {}
subWins[1] = require"ui/window/status/characterWin"
subWins[2] = require"ui/window/status/weaponSkillsWin"
subWins[3] = require"ui/window/status/professionSkillsWin"
subWins[4] = require"ui/window/status/traitsWin"
local curentActiveWin 

local sideTab_quads = c.pic.sideTab_quads
local tab_character_opt = {id= newid(),font = c.font_c16 }
local tab_weaponSkills_opt = {id= newid(),font = c.font_c16}
local tab_professionSkills_opt = {id= newid(),font = c.font_c16 }
local tab_traits_opt = {id= newid(),font = c.font_c16 }



local function pressLeft()
  g.playSound("card1")
  for i=1,#subWins do
    if curentActiveWin == subWins[i] then
      if i==1 then
        curentActiveWin = subWins[#subWins]
      else
        curentActiveWin = subWins[i-1]
      end
      curentActiveWin.win_open()
      return 
    end
  end
end

local function pressRight()
  g.playSound("card1")
  for i=1,#subWins do
    if curentActiveWin == subWins[i] then
      if i==#subWins then
        curentActiveWin = subWins[1]
      else
        curentActiveWin = subWins[i+1]
      end
      curentActiveWin.win_open()
      return 
    end
  end
end


local function changeTab(index)
  if subWins[index]== curentActiveWin then return end
  curentActiveWin = subWins[index]
  curentActiveWin.win_open()
  g.playSound("card1")
end


function statusWin:keyinput(key)
  if key=="cancel" then  statusWin:Close() ;g.playSound("book1")end
  if key=="left" then  pressLeft() end
  if key=="right" then  pressRight() end
  if key=="tab" then  pressRight() end
  if key=="f1" then  p:changeMC(1) end
  if key=="f2" then  p:changeMC(2) end
  if key=="f3" then  p:changeMC(3) end
  if key=="f4" then  p:changeMC(4) end
  curentActiveWin.keyinput(key)
end

function statusWin:win_open()
  g.playSound("skill")
  --s_win.x = (c.win_W-ui.right_w)/2-400
  --s_win.y = (c.win_H-ui.bottom_h)/2-300
  curentActiveWin = subWins[1]
  curentActiveWin.win_open()
end





function statusWin:win_close()
  
end


function statusWin:window_do(dt)
  suit:DragArea(s_win,true,s_win.dragopt)
  --使用该窗口的名字
  local startX = s_win.x-184
  local startY = s_win.y+44
  local lineH = 84
  local character_st = suit:ImageButton(sideTab_quads,tab_character_opt,startX,startY,240,84)
  if curentActiveWin == subWins[1] then tab_character_opt.state ="active"end
  local weaponSkills_st = suit:ImageButton(sideTab_quads,tab_weaponSkills_opt,startX,startY+lineH,240,84)
  if curentActiveWin == subWins[2] then tab_weaponSkills_opt.state ="active"end
  local professionSkills_st = suit:ImageButton(sideTab_quads,tab_professionSkills_opt,startX,startY+lineH*2,240,84)
  if curentActiveWin == subWins[3] then tab_professionSkills_opt.state ="active"end
  local traits_st = suit:ImageButton(sideTab_quads,tab_traits_opt,startX,startY+lineH*3,240,84)
  if curentActiveWin == subWins[4] then tab_traits_opt.state ="active"end
  suit:registerDraw(function() 
      love.graphics.setColor(1,1,1)
      local list = c.pic.uiIcon
      love.graphics.draw(list.img,list[subWins[1].icon_index],startX+10,startY-4+lineH*0,0,2,2)
      love.graphics.draw(list.img,list[subWins[2].icon_index],startX+10,startY-4+lineH*1,0,2,2)
      love.graphics.draw(list.img,list[subWins[3].icon_index],startX+10,startY-4+lineH*2,0,2,2)
      love.graphics.draw(list.img,list[subWins[4].icon_index],startX+10,startY-4+lineH*3,0,2,2)
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.setFont(c.font_c18)
      love.graphics.printf(subWins[1].name, startX+70, startY+25+lineH*0,120,"center") 
      love.graphics.printf(subWins[2].name, startX+70, startY+25+lineH*1,120,"center") 
      love.graphics.printf(subWins[3].name, startX+70, startY+25+lineH*2,120,"center") 
      love.graphics.printf(subWins[4].name, startX+70, startY+25+lineH*3,120,"center") 
    end)
  
  
  parchment(s_win.id,s_win.x,s_win.y,s_win.w,s_win.h)
  titleFrame(s_win.id,curentActiveWin.name,s_win.x+40,s_win.y-10,300,40,curentActiveWin.icon_index)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x+40,s_win.y-10,300,40)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-44,s_win.y+4,30,24)
  
  teamButtons(s_win.x+370,s_win.y)
  
  
  
  curentActiveWin.window_do(dt,s_win)
  if close_st.hit then self:Close() ;g.playSound("book1")end
  if character_st.hit then changeTab(1) end
  if weaponSkills_st.hit then changeTab(2) end
  if professionSkills_st.hit then changeTab(3) end
  if traits_st.hit then changeTab(4) end
  
end