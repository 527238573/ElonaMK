local suit = require"ui/suit"

local blockScreen_id = newid()
local close_opt = {id= newid()}
local s_win = {name = tl("选择物品","Choose item"),startx= c.win_W/2-310,starty =c.win_H/2-320, w= 500,h =573,dragopt = {id= newid()}}
local okbtn_opt = {name =tl("确定(e)","OK(e)"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("取消(q)","Cancel(q)"),font=c.font_c16,id= newid()}
local myScroll = {w= s_win.w-16,h = 480,itemYNum= 15,opt ={id= newid()}}
local empty_str = tl("没有符合条件的物品","No items are eligible")

local chooseItemWin = ui.new_window()
ui.chooseItemWin = chooseItemWin

local dialog_name 
local filter_func --筛选物品的函数，传入物品返回true false
local call_back --结束后回调，将选择的物品传入
local curList 
local curSelectIndex = nil --键盘focus
local hoveredIndex = nil
local close_choose = nil --设出这个值就表示要选中关闭了

local function drawBack(curList)
  love.graphics.oldColor(218,218,218)
  love.graphics.rectangle("fill",s_win.x+8,s_win.y+34,s_win.w-16,484)
  if #curList==0 then
    love.graphics.oldColor(150,150,150)
    love.graphics.setFont(c.font_c16)
    love.graphics.printf(empty_str, s_win.x, s_win.y+230, s_win.w-18,"center")
  end
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
  love.graphics.oldColor(22,22,22) 
  love.graphics.setFont(c.font_c16)
  love.graphics.print(name, x+45, y+8)
  love.graphics.setFont(c.font_c14)
  love.graphics.print(string.format("%.2f",curItem:getWeight()/100), x+360, y+10)
  love.graphics.print(string.format("%d",curItem:getVolume()), x+430, y+10)
end




local item_optlist = {}
local function oneItem(num,x,y,w,h)
  local curItem = curList[num]
  if curItem ==nil then return end
  item_optlist[num] = item_optlist[num] or {id = newid()}
  local opt = item_optlist[num]
  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h)
  suit:registerDraw(drawOneItem,num,curItem, opt, x,y,w,h)

  if suit:isHovered(opt.id) and suit:wasHovered(opt.id) then --hovered
    hoveredIndex = num
  end
  if suit:mouseReleasedOn(opt.id) then --hit one item
    if curSelectIndex==num then
      close_choose = curItem--选中并准备关闭
      --chooseItemWin:Close(curItem)--二次点击
    else
      curSelectIndex = num
    end
  end
end


local function loadCurrentList()
  curList = {}
  player.inventory:sort()--预sort
  local playeritemlist = player.inventory.items --直接操作items
  for i=1,#playeritemlist do
    if filter_func(playeritemlist[i]) then 
      table.insert(curList,playeritemlist[i])
    end
  end
end

function chooseItemWin.keyinput(key)
  if key=="escape" then  chooseItemWin:Close() end
end

function chooseItemWin.win_open(win_name,filter,callback) --可能添加选项 是否选择身上穿戴的物品
  dialog_name = win_name or s_win.name
  filter_func= filter
  call_back =callback
  s_win.x,s_win.y =s_win.startx,s_win.starty --每次进入都重置位置
  curSelectIndex = nil
  close_choose= nil
  if type(filter)=="table" then --已经筛选好的列表
    curList = filter
  else
    loadCurrentList() --从背包中筛选
  end
end
--chooseItem为选中的物品，可能为nil（不选择）
function chooseItemWin.win_close(chooseItem)
  call_back(chooseItem)
  close_choose= nil
  filter_func = nil
  call_back = nil
  curList = nil
  curSelectIndex = nil
  hoveredIndex = nil
end

function chooseItemWin.window_do()
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  suit:DragArea(s_win,true,s_win.dragopt)
  
  suit:Dialog(dialog_name,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(ui.res.close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  suit:registerDraw(drawBack,curList)
  
  hoveredIndex = nil
  myScroll.h = 32 * #curList
  suit:List(myScroll,oneItem,myScroll.opt,s_win.x+8,s_win.y+36,s_win.w-16,480)
  
  
  local ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.x+100,s_win.y+s_win.h-45,100,30)
  local ce_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.x+300,s_win.y+s_win.h-45,100,30)
  
  if curSelectIndex and curList[curSelectIndex] then
    ui.iteminfo(curList[curSelectIndex],s_win.x+s_win.w,s_win.y,330,s_win.h)
  end
  
  if ok_st.hit then if curSelectIndex then chooseItemWin:Close(curList[curSelectIndex])end end
  if close_choose then chooseItemWin:Close(close_choose)end
  if ce_st.hit then chooseItemWin:Close()end
  
  if close_st.hit then chooseItemWin:Close() end
end
