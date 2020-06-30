local suit = require"ui/suit"

local pickDropWin = Window.new()
ui.pickDropWin = pickDropWin

local s_win = {name = tl("背包","Inventory"),id=newid(),x= (c.win_W-ui.right_w)/2-400+50,y =(c.win_H-ui.bottom_h)/2-300+50, w= 800,h =600,dragopt = {id= newid()}}
local parchment = require"ui/component/window/parchment"
local titleFrame = require"ui/component/window/titleFrame"
local close_quads = c.pic.close_quads2
local close_opt = {id= newid()}
local sideTab_quads = c.pic.sideTab_quads
local uiClip = c.pic.ui_clip
local takeall_opt = {name =tl("全部拾取(r)","Take all(r)"),font=c.font_c16,id= newid()}
local sideTabs = {
  {name= tl("拾取物品","Pick up items"),opt = {id= newid(),color = {0.8,0.8,1}},icon = 17,selectIndex = 1,},
  {name= tl("丢弃物品","Drop items"),opt = {id= newid(),color = {1,0.85,0.85}},icon = 18,selectIndex = 1,},
}
local selectTab = 1
local curList ={}
local seeEntry --预先声明的函数
local targetInventory
local target_X --当前x。
local target_Y --当前Y。
local itemSelect -- 声明函数，
local close_at_end= false --标记推出。防止中途半截退出致使后续出bug



local function loadCurList()
  curList = {}
  local onetab = sideTabs[selectTab]
  if selectTab==1 then --拾取
    local itemlist = targetInventory.list
    for i=1,#itemlist do
      local curitem = itemlist[i]
      if (not curitem:isHidden()) then
        curList[#curList+1] = curitem
      end
    end
  elseif selectTab ==2 then --丢弃
    p.inv:sort()--预sort
    local itemlist = p.inv.list --直接获取items.只读。增删物品要通过inventory的方法
    for i=1,#itemlist do
      local curitem = itemlist[i]
      if (not curitem:isHidden()) then
        curList[#curList+1] = curitem
      end
    end
  else
    error("error:pick/drop win selectTab error")
  end
  --调整选择。
  onetab.selectIndex = c.clamp(onetab.selectIndex,1,#curList) --如果list为0个，则index=1.因为后比较较小值。
end

local function changeTab(index)
  if index ==selectTab then return end
  selectTab = c.clamp(index,1,#sideTabs)
  loadCurList()
  seeEntry()
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

local info_str = tl("快捷键1~10:指定物品快捷键   方向键:选择物品  Q/E键:退出/确定 TAB:切换类型","Shortcuts 1~10: [Specify shortcuts] Arrow keys: [Select] Q/E button: [Quit/Confirm] Tab:[Switch type]")
local weight_str = tl("总重量:","Total Weight:")
local function drawBack(x,y,w,h)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(uiClip.img,uiClip.attr,x+80,y+40,0,1,1)
  if selectTab == 2 then love.graphics.draw(uiClip.img,uiClip.attr,x+660,y+40,0,1,1) end
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("道具名称","Item Name"), x+103, y+40) --改成一次性的读取翻译
  love.graphics.line(x+83, y+58,x+200, y+58)
  if selectTab == 2 then
    love.graphics.print(tl("重量","Weight"), x+683, y+40) --改成一次性的读取翻译
    love.graphics.line(x+663, y+58,x+750, y+58)
  end
  local curWeight = p:getCarryWeight()
  local maxWeight = p:getCarryLimit()
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(c.font_c18)
  love.graphics.print(string.format("(%s  %.1f/%.1f)",weight_str,curWeight,maxWeight), x+400, y+33)

  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.line(x+20, y+h-45,x+w-50, y+h-45)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(info_str, x+30, y+h-41)
end




local colorBlue = {111/255,147/255,210/255,150/255}
local colorRed = {210/255,147/255,111/255,150/255}

local function one_item(num,x,y,w,h)
  x =x+20
  w= w-20
  local chover = colorRed
  local cselect = colorBlue
  if selectTab == 1 then 
    --chover = colorBlue
    --cselect = colorRed
  end
  
  local curItem = curList[num]
  if curItem ==nil then return end
  local curTab = sideTabs[selectTab]
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
      love.graphics.setColor(chover)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif state =="active" then
      love.graphics.setColor(151/255,107/255,150/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if curTab.selectIndex==num then
      love.graphics.setColor(cselect)
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
    render.drawUIItem(curItem,x+20,y+h/2,0.75)
    if useWk then love.graphics.setScissor(sc_x,sc_y,scw,sch) end
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
    love.graphics.setColor(curItem:getDisplayNameColor())
    love.graphics.setFont(c.font_c18)
    love.graphics.print(name, x+95, y+6)


    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.printf(string.format("%.1f kg",curItem:getWeight()), x+w-100, y+8,80,"right")
  end
  suit:registerDraw(draw_entry)
  local entry_st = suit:standardState(curItem)
  if entry_st.hit then
    curTab.selectIndex=num
    itemSelect(true)
  end
  return entry_st
end




local itemsScroll = {w= 500,h = 468,itemYNum= 15,win_w =s_win.w-40,win_h =480,opt ={id= newid(),hide_disable = true},wheel_step = 32,v_value = 0}
local function itemList(x,y)
  local w,h = itemsScroll.win_w,itemsScroll.win_h
  itemsScroll.h = (h/itemsScroll.itemYNum) *#curList
  suit:List(itemsScroll,one_item,itemsScroll.opt,x,y,w,h)
end

--使当前条目完整可见。
function seeEntry()
  local cindex = sideTabs[selectTab].selectIndex
  local singleH = itemsScroll.win_h/itemsScroll.itemYNum
  local upLine = singleH*(cindex-1)
  if itemsScroll.v_value >upLine then itemsScroll.v_value = upLine end
  local downLine = singleH*(cindex)
  if itemsScroll.v_value+itemsScroll.win_h<downLine then itemsScroll.v_value = downLine-itemsScroll.win_h end
  --如果超过了合法值会自动调整
end

function itemSelect(useMouse)
  local curTab = sideTabs[selectTab]
  local curIndex= curTab.selectIndex
  if curList[curIndex] ==nil then return end
  local curItem = curList[curIndex]
  if selectTab ==1 then --拾取
    if not p:canPickupItem(curItem,true) then
      g.playSound("fail1")
      return 
    end
    if not targetInventory:containsItem(curItem) then
      --时间经过该物品已经不在那里。
      addmsg(tl("那个物品已经不在这里。","The item is no longer here."),"info")
      g.playSound("fail1")
      loadCurList() --重载列表。
      return
    end
    p.mc:pickUpItem(curItem)
    loadCurList() --重载列表。
    if #curList==0 then close_at_end = true end
  elseif selectTab ==2 then --丢弃
    if not p:canDropItem(curItem,true) then
      g.playSound("fail1")
      return 
    end
    if not p.inv:containsItem(curItem) then
      --时间经过该物品已经不在那里。
      addmsg(tl("那个物品已经不在背包里。","The item is no longer in the Inventory."),"info")
      g.playSound("fail1")
      loadCurList() --重载列表。
      return
    end
    if curItem:canStack() and curItem.num>1 then
       local function selectNum_callback(num)--数量选择 回调函数
        if num<=0 then return end --未选择数量，不变
        if not p.inv:containsItem(curItem) then
          --时间经过该物品已经不在那里。
          addmsg(tl("那个物品已经不在背包里。","The item is no longer in the Inventory."),"info")
          g.playSound("fail1")
          loadCurList() --重载列表。
          return
        end
        if num <curItem.num then
         curItem = curItem:slice(num)
        end
        p.mc:dropItem(curItem)
        loadCurList() --重载列表。
      end
      if useMouse then
        pickDropWin:OpenChild(ui.numberAskWin,selectNum_callback,1,curItem.num,curItem.num,love.mouse.getX(),love.mouse.getY(),tl("丢下几个?","How many to drop?"))
      else
        pickDropWin:OpenChild(ui.numberAskWin,selectNum_callback,1,curItem.num,curItem.num,nil,nil,tl("丢下几个?","How many to drop?"))
      end
    else--直接丢出
      p.mc:dropItem(curItem)
      loadCurList() --重载列表。
    end
  end
end





local function pressUp()
  if #curList ==0 then return end
  local curTab = sideTabs[selectTab]
  if curTab.selectIndex <=1 then return end
  curTab.selectIndex = c.clamp(curTab.selectIndex-1,1,#curList)
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressDown()
  if #curList ==0 then return end
  local curTab = sideTabs[selectTab]
  if curTab.selectIndex ==#curList then return end
  curTab.selectIndex = c.clamp(curTab.selectIndex+1,1,#curList)
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressLeft()
  if #curList ==0 then return end
  local curTab = sideTabs[selectTab]
  if curTab.selectIndex ==1 then return end
  curTab.selectIndex = c.clamp(curTab.selectIndex-itemsScroll.itemYNum,1,#curList)
  itemsScroll.v_value = itemsScroll.v_value-itemsScroll.win_h
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressRight()
  if #curList ==0 then return end
  
  local curTab = sideTabs[selectTab]
  if curTab.selectIndex ==#curList then return end
  curTab.selectIndex = c.clamp(curTab.selectIndex+itemsScroll.itemYNum,1,#curList)
  itemsScroll.v_value = itemsScroll.v_value+itemsScroll.win_h
  --控制窗口到必须显示出本条目
  seeEntry()
  g.playSound("pop1")
end

local function pressTab()
  if selectTab ==1 then 
    changeTab(2)
  else
    changeTab(1)
  end
end

local function takeAll(useMouse)
  if selectTab ==2 then  return end
  loadCurList()
  for i=1,#curList do 
    local curItem = curList[i]
    if p:canPickupItem(curItem,true) then
      p.mc:pickUpItem(curItem,true)
    end
  end
  if #curList>=1 then g.playSound("get1") end
  if useMouse then
    close_at_end = true 
  else
    pickDropWin:Close() 
  end
end


local function turboComfirm()
  if pickDropWin.child then pickDropWin.child:Close() ;return end--关闭子层
  itemSelect(false)
end


function pickDropWin:keyinput(key)
  if key=="cancel" then  self:Close() ;g.playSound("book1")
  elseif key=="comfirm" then itemSelect(false) ; ui.registerTurboKey("comfirm",0.07,turboComfirm)
  elseif key=="up" then  pressUp(); ui.registerTurboKey("up",0.07,pressUp)
  elseif key=="down" then  pressDown(); ui.registerTurboKey("down",0.07,pressDown)
  elseif key=="left" then  pressLeft(); ui.registerTurboKey("left",0.07,pressLeft)
  elseif key=="right" then  pressRight(); ui.registerTurboKey("right",0.07,pressRight)
  elseif key=="tab" then  pressTab() 
  elseif key=="key_g" and selectTab == 1 then  itemSelect(false) ; ui.registerTurboKey("key_g",0.07,turboComfirm)
  elseif key=="key_r" and selectTab == 1 then  takeAll(false)
  end
end

function pickDropWin:win_open(ispick,curinv)
  target_X = p.mc.x
  target_Y = p.mc.y
  targetInventory = curinv
  if ispick then selectTab = 1 else selectTab =2 end
  loadCurList()
  close_at_end = false
  seeEntry()
  g.playSound("inv")
end


function pickDropWin:win_close()
  ui.clearTurboKey()
  cmap:releaseItemList(target_X,target_Y)
end


function pickDropWin:window_do(dt)
  if p.mc.x~=target_X or p.mc.y ~= target_Y then self:Close(); return end --一旦发生位移，被推挤等等，界面停止。

  suit:DragArea(s_win,true,s_win.dragopt)
  sideTab(s_win.x,s_win.y)
  local curTab = sideTabs[selectTab]
  parchment(s_win.id,s_win.x,s_win.y,s_win.w,s_win.h,selectTab)
  titleFrame(s_win.id,curTab.name,s_win.x+40,s_win.y-10,300,40,curTab.icon)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x+40,s_win.y-10,300,40)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-44,s_win.y+4,30,24)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  itemList(s_win.x+10,s_win.y+65)
  if selectTab == 1 then 
    local takeall_st =suit:S9Button(takeall_opt.name,takeall_opt,s_win.x+s_win.w-190,s_win.y+23,120,38) 
    if takeall_st.hit then takeAll(true) end
  end
  if close_st.hit or close_at_end then 
    self:Close() 
    g.playSound("book1")
  end
end