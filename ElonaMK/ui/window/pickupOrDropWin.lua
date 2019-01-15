
local suit = require"ui/suit"

local blockScreen_id = newid()
local close_opt = {id= newid()}
local tab_pick_opt = {text= tl("拾取","Pick up"),id= newid(),font = c.font_c16 ,textcolor = {22,22,88}}
local tab_drop_opt = {text= tl("放下","Drop"),id= newid(),font = c.font_c16,textcolor = {22,22,88}}
local tlnames ={zweight =tl("重量:","Weight:"),zvolume =tl("体积:","Volume:"),dropinfo = tl("丢下几个?","How many to drop?"),drop_progress = tl("丢下","Drop"),pickup_progress = tl("拾取","Pick up")} 
local s_win = {namepick = tl("拾取物品","Pick item"),namedrop = tl("放下物品","Drop item"),startx= c.win_W/2-350,starty =c.win_H/2-300, w= 575,h =590,dragopt = {id= newid()}}
local myScroll = {w= s_win.w-16,h = s_win.h-174,itemYNum= 16,opt ={id= newid()}}
local takeall_btn_opt = {name =tl("全部拾取(t)","Take all(t)"),font=c.font_c16,id= newid()}

local is_pickingup = true 
local origin_pickList =nil --可拾取的list，通常是地格list，如果是其他，可能向里扔东西会掉地上
local picked_list = nil-- 已经pick的list ,key为物品，标识新捡起的物品
local droped_list = nil --丢掉的物品。,key为物品，标识新丢下的物品，颜色以区分
local callback = nil

local winClose --提前声明的关闭函数
local itemSelect --提前声明点击函数
local curCategory = 1 -- 开始默认为1（all，全部）
local curList = {} --当前catagory的所有需要显示的物品。 
local curSelectIndex = 1 --键盘focus
local hoveredIndex = nil
local close_at_end = false-- 标记退出

local function drawBack()
  if is_pickingup then
    love.graphics.oldColor(218,218,248)
  else
    love.graphics.oldColor(248,218,218)
  end
  love.graphics.rectangle("fill",s_win.x+8,s_win.y+66,s_win.w-16,s_win.h-74)
  love.graphics.oldColor(30,30,30)
  love.graphics.rectangle("fill",s_win.x+8,s_win.y+64,s_win.w-16,2)
  
  --love.graphics.setFont(c.font_c14)
  --love.graphics.oldColor(150,150,150)
  --love.graphics.print("物品名称", s_win.x+10, s_win.y+66)
  --love.graphics.print("重量(kg)", s_win.x+430, s_win.y+66)
  --love.graphics.print("体积", s_win.x+520, s_win.y+66)
  --Weight and Volume
  local inv = player.inventory
  local cur_weight = inv:getWeight()
  local max_weight = inv.maxWeight
  local cur_volume = inv:getVolume()
  local max_volume = inv.maxVolume
  local weight_info = string.format("%s %.1f/%.1f",tlnames.zweight,cur_weight/100,max_weight/100)
  local volume_info = string.format("%s %d/%d",tlnames.zvolume,cur_volume,max_volume)
  
  if cur_weight>max_weight then
    love.graphics.oldColor(176,23,43)
  else
    love.graphics.oldColor(22,22,22)
  end
  love.graphics.setFont(c.font_c16)
  love.graphics.print(weight_info, s_win.x+300, s_win.y+8)
  if cur_volume>max_volume then
    love.graphics.oldColor(176,23,43)
  else
    love.graphics.oldColor(22,22,22)
  end
  love.graphics.print(volume_info, s_win.x+420, s_win.y+8)
end


local function drawOneItem(num,curItem,opt, x,y,w,h)
  if opt.state =="active" then
    love.graphics.oldColor(111,147,210)
    love.graphics.rectangle("fill",x,y,w,h)
  elseif num == curSelectIndex then
    love.graphics.oldColor(147,169,210)
    love.graphics.rectangle("fill",x,y,w,h)
  elseif opt.state =="hovered" then
    love.graphics.oldColor(183,206,233)
    love.graphics.rectangle("fill",x,y,w,h)
  end

  love.graphics.oldColor(255,255,255)
  local  item_img,item_quad = curItem:getImgAndQuad()
  love.graphics.draw(item_img,item_quad,x+4,y,0,1,1)
  local name = curItem:getName()
  if (picked_list and picked_list[curItem]) or (droped_list and droped_list[curItem]) then 
    love.graphics.oldColor(22,46,175)
  else 
    love.graphics.oldColor(22,22,22) 
  end
  love.graphics.setFont(c.font_c16)
  love.graphics.print(name, x+45, y+8)
  love.graphics.setFont(c.font_c14)
  love.graphics.print(string.format("%.2f",curItem:getWeight()/100), x+380, y+10)
  love.graphics.print(string.format("%d",curItem:getVolume()), x+500, y+10)
end


local item_optlist = {}
local function oneItem(num,x,y,w,h)
  local curItem = curList[num]
  if curItem ==nil then return end
  item_optlist[num] = item_optlist[num] or {id = newid()}
  local opt = item_optlist[num]
  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  suit:registerDraw(drawOneItem,num,curItem, opt, x,y,w,h)

  if suit:mouseReleasedOn(opt.id) then --hit one item
    --curSelectIndex = num
    --ui.iteminfo_reset()--重置物品信息
    itemSelect(num,true)
  end
  if suit:isHovered(opt.id) and suit:wasHovered(opt.id) then --hovered
    hoveredIndex = num
  end
  
end



--载入当前列表内容，有变化就要从新载入
local function loadCurrentList()
  curList = {}
  if is_pickingup then
    debugmsg("hasitem:"..#origin_pickList)
    for i=1,#origin_pickList do
      curList[#curList+1] = origin_pickList[i]
    end
  else--背包内的物品
    player.inventory:sort()--预sort
    local payeritemlist = player.inventory.items --直接操作items
    local categories = ui.res.categories
    local cur_cateName = categories[curCategory][1]
    for i=1,#payeritemlist do
      local curitem = payeritemlist[i]
      if categories:checkInCategory(cur_cateName,curitem) then
        curList[#curList+1] = curitem
      end
    end
  end
  if curList[curSelectIndex] ==nil then curSelectIndex = 1 end--selcet默认为1
end


--press button or click item --还没有选择拾取数量 useMouse是否用鼠标的操作 
function itemSelect(index,useMouse)
  if curList[index]==nil then return end--该index没有物品。
  local curitem = curList[index]
  if is_pickingup then
    --从list取到背包内
    if not curitem:can_pickup() then
      g.message.addmsg(tl("你不能捡起液体！","You can't pick up liquid!"),"info")
      g.playSound("fail")
      return 
    end
    local finditem
    for i=1,#origin_pickList do 
      if origin_pickList[i] ==curitem then 
        table.remove(origin_pickList,i)--从源list中删除
        finditem = curitem;
        break 
      end 
    end
    if finditem==nil then debugmsg("internal error,cantfind item in picklist");return end--防止内部出错
    droped_list[curitem] = nil
    picked_list[curitem] = true
    --物品入包
    player.inventory:addItem(curitem)
    g.playSound("get")
    loadCurrentList()--重置列表
    if index>#curList then curSelectIndex =#curList end--键盘焦点超出范围则置于末尾
    --如果东西捡完则可以关闭窗口了
    if #curList==0 then close_at_end = true end
  else
    --丢出物品
    if curitem:can_stack() and curitem.stack_num>1 then
      curSelectIndex = index--暂时将信息切换为此物品
      
      local function selectNum_callback(num)--数量选择 回调函数
        s_win.popout = nil
        if num<=0 then return end --未选择数量，不变
        local newitem = player.inventory:sliceItem(curitem,num) --虽然名为newitem，但当num为最大值时表现和removeItem一样，返回的是源物品，并从背包中删除
        droped_list[newitem] = true
        picked_list[newitem] = nil
        origin_pickList[#origin_pickList+1] = newitem
        g.playSound("drop")
        loadCurrentList()--重置列表
        if index>#curList then curSelectIndex =#curList end--键盘焦点超出范围则置于末尾
      end
      
      if useMouse then
        ui.numberAskOpen(selectNum_callback,1,curitem.stack_num,curitem.stack_num,love.mouse.getX(),love.mouse.getY(),tlnames.dropinfo)
      else
        ui.numberAskOpen(selectNum_callback,1,curitem.stack_num,curitem.stack_num,nil,nil,tlnames.dropinfo)
      end
      s_win.popout = ui.numberAsk
      --问丢出数量！
    else
      --直接丢出
      player.inventory:removeItem(curitem)
      droped_list[curitem] = true
      picked_list[curitem] = nil
      origin_pickList[#origin_pickList+1] = curitem
      g.playSound("drop")
      loadCurrentList()--重置列表
      if index>#curList then curSelectIndex =#curList end--键盘焦点超出范围则置于末尾
    end
  end
end
--拿走所有
local function takeAll()
  if #origin_pickList>0 then g.playSound("get") end
  for i=#origin_pickList,1,-1 do
    local curitem = origin_pickList[i]
    origin_pickList[i] = nil
    player.inventory:addItem(curitem)
  end
  winClose()
end



--放在一个函数内，鼠标键盘操作通用调用
local function changePickOrDrop(isPick)
  if is_pickingup~= isPick then
    is_pickingup = isPick; 
    if is_pickingup then curCategory = 1 end 
    loadCurrentList()
  end
end
local function keyChangeCategory(dx)
  --键盘专用
  if is_pickingup then return end
  curCategory = curCategory+dx
  if curCategory<1 then curCategory = #ui.res.categories end
  if curCategory> #ui.res.categories then curCategory = 1 end
  loadCurrentList()
end
local function keyChangeSelect(dy)
  curSelectIndex = curSelectIndex+dy
  if curSelectIndex>#curList then curSelectIndex = 1 end
  if curSelectIndex<1 then curSelectIndex = #curList end
end



local function keyinput(key)
  if s_win.popout == ui.numberAsk then ui.numberAsk_keyinput(key);return end --向子层传递
  --debugmsg("keypress:"..key)
  if key=="escape" or key=="q"  or (not is_pickingup and key=="g") then  winClose()end
  if key=="tab" then changePickOrDrop(not is_pickingup) end
  if key=="left" or key=="a" then keyChangeCategory(-1) end
  if key=="right" or key=="d" then keyChangeCategory(1) end
  if key=="up" or key=="w" then keyChangeSelect(-1) end
  if key=="down" or key=="s" then keyChangeSelect(1) end
  if key=="e" or key=="return" or (is_pickingup and key=="g") then itemSelect(curSelectIndex,false)end
  if key=="t" and is_pickingup then takeAll() end
end

local function self_close()
  
  --若没能通过此方式正确关闭，则回调不可用，也不能正确 delay
  callback()
  
  local changeCount  = 0
  for _,_ in pairs(picked_list) do changeCount=changeCount+1 end
  for _,_ in pairs(droped_list) do changeCount=changeCount+1 end --有变化时 制造延时动作
  
  if changeCount>2 then 
    local costTime = math.min(changeCount*0.1,1.2)
    player:shortActivity(is_pickingup and tlnames.pickup_progress or tlnames.drop_progress,costTime) 
  end
  
  curList = nil
  origin_pickList = nil
  picked_list= nil
  droped_list=  nil
  callback = nil
  ui.key_g_delay = 0.4
  
  
end

--打开拾取或丢弃窗口。打开此窗口时背景操作全部关闭。is_pick表示是否是拾取，否则是丢弃。picklist是从那个list的拾取。丢弃就是从背包。recall，回调，完成后。
local function self_open(is_pick,pickList,recall)
  if pickList ==nil then debugmsg("nil picklist");return end
  is_pickingup = is_pick
  origin_pickList = pickList
  callback= recall
  picked_list = {}
  droped_list={}
  
  s_win.x,s_win.y =s_win.startx,s_win.starty --每次进入都重置位置
  curCategory = 1;curSelectIndex = 1--每次进入重置
  close_at_end = false
  loadCurrentList()
  
end


local function window_do()
  
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  suit:DragArea(s_win,true,s_win.dragopt)
  
  
  suit:Dialog(is_pickingup and s_win.namepick or s_win.namedrop,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(ui.res.close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  suit:registerDraw(drawBack)
  
  local pick_st = suit:ImageButton(ui.res.tab_left_quads,tab_pick_opt,s_win.x-64,s_win.y+44,70,43)
  local drop_st = suit:ImageButton(ui.res.tab_left_quads,tab_drop_opt,s_win.x-64,s_win.y+90,70,43)
  if is_pickingup then tab_pick_opt.state ="active" else  tab_drop_opt.state ="active" end
  local takeall_st
  
  if is_pickingup then takeall_st =suit:S9Button(takeall_btn_opt.name,takeall_btn_opt,s_win.x+s_win.w-120,s_win.y+34,110,28) end
  
  
  local maxCatrgories = #ui.res.categories
  if is_pickingup then 
    maxCatrgories = 1 
  end
  
  for i=1,maxCatrgories do
    local cateTab = suit:ImageButton(ui.res.tab_quads,ui.res.categories[i],s_win.x+8 +(i-1)*80,s_win.y+36,80,30)
    if curCategory ==i then  ui.res.categories[i].state = "active" end
    if cateTab.hit then
      curCategory = i --点击切换条目。重载
      loadCurrentList()
    end
  end
  
  
  hoveredIndex = nil
  myScroll.h = (s_win.h-78)/myScroll.itemYNum * #curList
  suit:List(myScroll,oneItem,myScroll.opt,s_win.x+8,s_win.y+70,s_win.w-16,s_win.h-78)
  --物品info，鼠标指针优先，没有则键盘焦点
  local see_item
  if hoveredIndex and curList[hoveredIndex] then
    see_item = curList[hoveredIndex]
  else
    see_item = curList[curSelectIndex]
  end
  if see_item then ui.iteminfo(see_item,s_win.x+s_win.w,s_win.y,330,s_win.h)end--存在item则
  
  
  if close_st.hit or close_at_end then winClose();return end
  if pick_st.hit then changePickOrDrop(true) end
  if drop_st.hit then changePickOrDrop(false) end
  if takeall_st and takeall_st.hit then takeAll() end
  if s_win.popout then s_win.popout() end
  
end

local new_win = ui.new_window()
new_win.window_do = window_do
new_win.win_open = self_open
new_win.win_close = self_close
new_win.keyinput = keyinput

ui.pickupOrDropWin = new_win

function winClose()--替换
  new_win:Close()
end
