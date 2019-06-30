local suit = require"ui/suit"

local equipWin = Window.new()
ui.equipWin = equipWin

local s_win = {name = tl("背包","Inventory"),id=newid(),x= (c.win_W-ui.right_w)/2-400+50,y =(c.win_H-ui.bottom_h)/2-300+50, w= 800,h =600,dragopt = {id= newid()}}
local teamButtons = require"ui/component/window/teamButtons"
local parchment = require"ui/component/window/parchment"
local titleFrame = require"ui/component/window/titleFrame"
local close_quads = c.pic.close_quads2
local close_opt = {id= newid()}
local sideTab_quads = c.pic.sideTab_quads
local uiClip = c.pic.ui_clip
local sideTabs = {}
sideTabs[1] = require"ui/window/equip/equipmentWin"
sideTabs[2] = require"ui/window/equip/tacticsWin"
sideTabs[3] = require"ui/window/equip/spellWin"
local selectTab = 1

local function changeTab(index)
  if index ==selectTab then return end
  selectTab = c.clamp(index,1,#sideTabs)
  --loadCurList()
  --seeEntry()
  g.playSound("card1")
end

local function sideTab(x,y)
  local startX = x-184
  local startY = y+44
  local lineH = 76
  for i=1,#sideTabs do
    local onetab = sideTabs[i]
    local tab_st = suit:ImageButton(sideTab_quads,onetab.opt,startX,startY+(i-1)*lineH,240,84)
    if selectTab ==i then onetab.opt.state ="active"end
    if tab_st.hit then changeTab(i) end
  end
  suit:registerDraw(function() 
      love.graphics.setColor(1,1,1)
      local list = c.pic.uiIcon
      for i=1,#sideTabs do
        love.graphics.draw(list.img,list[sideTabs[i].icon],startX+10,startY-4+lineH*(i-1),0,2,2)
      end
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.setFont(c.font_c18)
      for i=1,#sideTabs do
        love.graphics.printf(sideTabs[i].name, startX+70, startY+25+lineH*(i-1),120,"center") 
      end
    end)
end



local function pressTab()
  local newindex = selectTab+1
  if newindex>#sideTabs then newindex = 1 end
  changeTab(newindex)
end

function equipWin:keyinput(key)
  if key=="cancel" then  self:Close();g.playSound("book1") 
  --if key=="left" then  pressLeft() end
  --if key=="right" then  pressRight() end
  elseif key=="tab" then  pressTab() 
  elseif key=="f1" then  p:changeMC(1) 
  elseif key=="f2" then  p:changeMC(2) 
  elseif key=="f3" then  p:changeMC(3) 
  elseif key=="f4" then  p:changeMC(4) 
  end
  sideTabs[selectTab].keyinput(key)
end

function equipWin:win_open(index)
  g.playSound("inv")
  selectTab = c.clamp(index or 1,1,#sideTabs)
end

function equipWin:win_close()
  
end


function equipWin:window_do(dt)
  suit:DragArea(s_win,true,s_win.dragopt)
  sideTab(s_win.x,s_win.y)
  local curTab = sideTabs[selectTab]
  parchment(s_win.id,s_win.x,s_win.y,s_win.w,s_win.h)
  titleFrame(s_win.id,curTab.name,s_win.x+40,s_win.y-10,300,40,curTab.icon)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x+40,s_win.y-10,300,40)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-44,s_win.y+4,30,24)
  teamButtons(s_win.x+370,s_win.y)
  curTab.window_do(dt,s_win)
  if close_st.hit then
    self:Close() 
    g.playSound("book1")
  end
end