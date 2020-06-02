local suit = require"ui/suit"


local testWin = Window.new()
ui.testWin = testWin

local s_win = {name = tl("测试","debug"),id=newid(),x= (c.win_W-ui.right_w)/2-400+50,y =(c.win_H-ui.bottom_h)/2-300+50, w= 800,h =600,dragopt = {id= newid()}}
local parchment = require"ui/component/window/parchment"
local titleFrame = require"ui/component/window/titleFrame"
local close_quads = c.pic.close_quads2
local close_opt = {id= newid()}


local curList ={}

local function loadCurList()
  curList ={}
  for k,v in pairs(g.TestList) do
    table.insert(curList,{name = k,func = v})
  end
  
end

local function callNum(index)
  testWin:Close();
  curList[index].func()
end



local function one_item(num,x,y,w,h)
  x =x+20
  w= w-20
  local curItem = curList[num]
  if curItem ==nil then return end
  local state = suit:registerHitbox(nil,curItem,x,y,w,h-1)
  local function draw_entry()
    if num%2==1 then
      love.graphics.setColor(0.5,0.5,0.4,0.2)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    local name = curItem.name
    local nameLength = c.font_c18:getWidth(name)
    local nameHeight = c.font_c18:getHeight(name)
    if state =="hovered" then
      love.graphics.setColor(111/255,147/255,210/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif state =="active" then
      love.graphics.setColor(151/255,107/255,150/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end

    --hotkey

    --love.graphics.setColor(1,1,1)
    --love.graphics.draw(uiClip.img,uiClip.hotkey,x+57,y+4,0,1.5,1.4)
    --love.graphics.setFont(c.font_c16)
    --love.graphics.setColor(0,0,0)
    --love.graphics.print(tostring(num), x+63, y+7)
    --love.graphics.print(tostring(num), x+65, y+9)
    --love.graphics.setColor(1,1,1)
    --love.graphics.print(tostring(num), x+64, y+8)
    --name
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(c.font_c18)
    love.graphics.print(name, x+95, y+6)


  end
  suit:registerDraw(draw_entry)
  local entry_st = suit:standardState(curItem)
  if entry_st.hit then
    g.playSound("click1")
    callNum(num)
  end
  return entry_st
end


local itemsScroll = {w= 500,h = 468,itemYNum= 15,win_w =s_win.w-40,win_h =480,opt ={id= newid(),hide_disable = true},wheel_step = 32}
local function itemList(x,y)
  local w,h = itemsScroll.win_w,itemsScroll.win_h
  --suit:registerDraw(drawBack_list,x,y,w,h)
  itemsScroll.h = (h/itemsScroll.itemYNum) *#curList-- #skill_List
  suit:List(itemsScroll,one_item,itemsScroll.opt,x,y,w,h)
end



function testWin:keyinput(key)
  if key=="cancel" then  self:Close();g.playSound("book1")
  end
end

function testWin:win_open()
  loadCurList()
  g.playSound("inv")
end

function testWin:win_close()
  ui.clearTurboKey()
end

function testWin:window_do(dt)
  suit:DragArea(s_win,true,s_win.dragopt)


  parchment(s_win.id,s_win.x,s_win.y,s_win.w,s_win.h)
  titleFrame(s_win.id,s_win.name,s_win.x+40,s_win.y-10,300,40,2)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x+40,s_win.y-10,300,40)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-44,s_win.y+4,30,24)
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  itemList(s_win.x+10,s_win.y+65)
  if close_st.hit then 
    self:Close() 
    g.playSound("book1")
  end
  
end