local suit = require"ui/suit"

local itemChooseWin = Window.new()
ui.itemChooseWin = itemChooseWin

local title = tl("物品选择","Item Choose")
local icon_index = 25
local blockScreen_id = newid()
local s_win = {name = tl("物品选择","Item Choose"),id=newid(),x= (c.win_W-ui.right_w)/2-400,y =(c.win_H-ui.bottom_h)/2-300+100, w= 800,h =600,dragopt = {id= newid()}}
local parchment = require"ui/component/window/parchment"
local titleFrame = require"ui/component/window/titleFrame"
local close_quads = c.pic.close_quads2
local close_opt = {id= newid()}
local uiClip = c.pic.ui_clip

local callback = nil
local closeChoose = nil --选中关闭
local selectIndex = 1
local curList ={}
local seeEntry --预先声明的函数


local function loadCurList(clist)
  curList = clist
  selectIndex = c.clamp(selectIndex,1,#curList) --如果list为0个，则index=1.因为后比较较小值。
end


local info_str = tl("方向键:选择物品 E,ENTER:确定 Q,ESC:取消","Arrow keys: [Select] e,enter: [comfirm] q,esc: [cancel]")
local function drawBack(x,y,w,h)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(uiClip.img,uiClip.attr,x+80,y+40,0,1,1)
  love.graphics.draw(uiClip.img,uiClip.attr,x+660,y+40,0,1,1)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("道具名称","Item Name"), x+103, y+40) --改成一次性的读取翻译
  love.graphics.print(tl("重量","Weight"), x+683, y+40) --改成一次性的读取翻译
  love.graphics.line(x+83, y+58,x+200, y+58)
  love.graphics.line(x+663, y+58,x+750, y+58)

  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.line(x+20, y+h-45,x+w-50, y+h-45)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(info_str, x+30, y+h-41)
end



local function one_item(num,x,y,w,h)
  x =x+20
  w= w-20
  local curItem = curList[num]
  if curItem ==nil then return end
  local state = suit:registerHitbox(nil,curItem,x,y,w,h-1)
  local swy,swh = s_win.y+65,480
  local function draw_entry()
    if num%2==1 then
      love.graphics.setColor(0.5,0.5,0.4,0.2)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    local name = curItem:getDisplayName()
    local nameLength = c.font_c18:getWidth(name)
    local nameHeight = c.font_c18:getHeight(name)
    if state =="hovered" then
      love.graphics.setColor(111/255,147/255,210/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif state =="active" then
      love.graphics.setColor(151/255,107/255,150/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if selectIndex==num then
      love.graphics.setColor(210/255,147/255,111/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
      love.graphics.setColor(1,1,1,0.6)
      love.graphics.rectangle("fill",x+91,y+2,nameLength+40,nameHeight+8)
      love.graphics.setColor(0.7,0.7,1,0.6)
      love.graphics.rectangle("line",x+91,y+2,nameLength+40,nameHeight+8)
      love.graphics.setColor(1,1,1)
      love.graphics.draw(uiClip.img,uiClip.select,x+115+nameLength,y+h/2,0,1,1,8,8)
    end

    --通过现有的scissor扩展
    local useWk = y>=swy and y<=swy+swh 
    local sc_x,sc_y,scw,sch = love.graphics.getScissor()
    if useWk then love.graphics.setScissor(sc_x,sc_y-20,scw,sch+20) end
    local  item_img,item_quad,qw,qh = curItem:getImgAndQuad()
    love.graphics.setColor(curItem:getDrawColor())
    love.graphics.draw(item_img,item_quad,x+20,y+h/2,0,0.75,0.75,qw/2,qh/2) --因为默认64×64
    if useWk then love.graphics.setScissor(sc_x,sc_y,scw,sch) end
    --name
    love.graphics.setColor(curItem:getDisplayNameColor())
    love.graphics.setFont(c.font_c18)
    love.graphics.print(name, x+95, y+6)


    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.printf(string.format("%.1f kg",curItem:getWeight()), x+w-100, y+8,80,"right")


  end
  suit:registerDraw(draw_entry)
  local entry_st = suit:standardState(curItem)
  if entry_st.hit then
    selectIndex=num
    closeChoose = num --设置这个值就表示已选定了，准备关闭窗口。
    g.playSound("click1")
  end
  return entry_st
end


--local function drawBack_list(x,y,w,h) end
local itemsScroll = {w= 500,h = 468,itemYNum= 15,win_w =s_win.w-40,win_h =480,opt ={id= newid(),hide_disable = true},wheel_step = 32}
local function itemList(x,y)
  local w,h = itemsScroll.win_w,itemsScroll.win_h
  --suit:registerDraw(drawBack_list,x,y,w,h)
  itemsScroll.h = (h/itemsScroll.itemYNum) *#curList-- #skill_List
  suit:List(itemsScroll,one_item,itemsScroll.opt,x,y,w,h)
end
--使当前条目完整可见。
function seeEntry()
  local cindex = selectIndex
  local singleH = itemsScroll.win_h/itemsScroll.itemYNum
  local upLine = singleH*(cindex-1)
  if itemsScroll.v_value >upLine then itemsScroll.v_value = upLine end
  local downLine = singleH*(cindex)
  if itemsScroll.v_value+itemsScroll.win_h<downLine then itemsScroll.v_value = downLine-itemsScroll.win_h end
  --如果超过了合法值会自动调整
end


local function pressUp()
  if #curList ==0 then return end
  if selectIndex <=1 then return end
  selectIndex = c.clamp(selectIndex-1,1,#curList)
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressDown()
  if #curList ==0 then return end
  if selectIndex >=#curList then return end
  selectIndex = c.clamp(selectIndex+1,1,#curList)
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressLeft()
  if #curList ==0 then return end
  if selectIndex <=1 then return end
  selectIndex = c.clamp(selectIndex-itemsScroll.itemYNum,1,#curList)
  itemsScroll.v_value = itemsScroll.v_value-itemsScroll.win_h
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressRight()
  if #curList ==0 then return end
  if selectIndex >=#curList then return end
  selectIndex = c.clamp(selectIndex+itemsScroll.itemYNum,1,#curList)
  itemsScroll.v_value = itemsScroll.v_value+itemsScroll.win_h
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end



function itemChooseWin:keyinput(key)
  if key=="cancel" then  self:Close();g.playSound("book1")
  elseif key=="up" then  pressUp(); ui.registerTurboKey("up",0.07,pressUp)
  elseif key=="down" then  pressDown(); ui.registerTurboKey("down",0.07,pressDown)
  elseif key=="left" then  pressLeft(); ui.registerTurboKey("left",0.07,pressLeft)
  elseif key=="right" then  pressRight(); ui.registerTurboKey("right",0.07,pressRight)
  elseif key=="comfirm" then self:Close(true);g.playSound("unpop1") 
  end
end

function itemChooseWin:win_open(clist,endcall,displayTitle,icon)
  callback = endcall
  loadCurList(clist)
  title = displayTitle
  icon_index = icon or 25
  closeChoose= nil
  g.playSound("inv")
end

function itemChooseWin:win_close(confirm)
  closeChoose= nil
  ui.clearTurboKey()
  if confirm then
    callback(curList[selectIndex],selectIndex) --回调
  else
    callback(nil,0) --回调
  end
end


function itemChooseWin:window_do(dt)
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  --suit:DragArea(s_win,true,s_win.dragopt)
  parchment(s_win.id,s_win.x,s_win.y,s_win.w,s_win.h)
  if title then 
    titleFrame(s_win.id,title,s_win.x+40,s_win.y-10,300,40,icon_index)
  end
  --suit:DragArea(s_win,false,s_win.dragopt,s_win.x+40,s_win.y-10,300,40)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-44,s_win.y+4,30,24)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  itemList(s_win.x+10,s_win.y+65)
  if close_st.hit then 
    self:Close() 
    g.playSound("book1")
  end
  if closeChoose then
    self:Close(true) 
  end
end