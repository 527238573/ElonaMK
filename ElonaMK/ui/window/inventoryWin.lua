require "ui/component/item/iteminfo"
local suit = require"ui/suit"
local close_quads = ui.res.close_quads
local tab_quads = ui.res.tab_quads


local tlnames ={zweight =tl("重量:","Weight:"),zvolume =tl("体积:","Volume:") } 
local s_inv = {name = tl("背包","Backpack"),x= c.win_W/2-500,y =c.win_H/2-300, w= 800,h =590,dragopt = {id= newid()}}
local close_opt = {id= newid()}
local myScroll = {w= s_inv.w-16,h = s_inv.h-174,itemYNum= 16,opt ={id= newid()}}

local categories = {
  {"all",text= tl("全部","All"),id = newid(),font = c.font_c16},
  {"weapon",text= tl("武器","Weapon"),id = newid(),font = c.font_c16},
  {"armor",text= tl("护甲","Armor"),id = newid(),font = c.font_c16},
  {"comestible",text= tl("消耗品","Comestible"),id = newid(),font = c.font_c16},
  {"tool",text= tl("工具","Tool"),id = newid(),font = c.font_c16},
  {"book",text= tl("书籍","Book"),id = newid(),font = c.font_c16},
  {"other",text= tl("其他","Others"),id = newid(),font = c.font_c16},
  checkInCategory = function(self,category,item)
    if category=="all" then return true end
    local this_category = item.type.category
    if category=="other" then 
      for i=2,#self-1 do
        if this_category == self[i][1] then return false end
      end
      return true
    end
    return category== this_category
  end,
}
ui.res.categories = categories--转为通用

local curCategory = 1 -- 开始默认为1（all，全部）
local curList = {} --当前catagory的所有需要显示的物品。 
local curSelectIndex = 1

local function drawBack()
  love.graphics.oldColor(218,218,218)
  love.graphics.rectangle("fill",s_inv.x+8,s_inv.y+66,s_inv.w-16,s_inv.h-74)
  love.graphics.oldColor(30,30,30)
  love.graphics.rectangle("fill",s_inv.x+8,s_inv.y+64,s_inv.w-16,2)

  --Weight and Volume
  if s_inv.cur_weight>s_inv.max_weight then
    love.graphics.oldColor(176,23,43)
  else
    love.graphics.oldColor(22,22,22)
  end
  love.graphics.setFont(c.font_c16)
  love.graphics.print(s_inv.weight_info, s_inv.x+580, s_inv.y+42)
  if s_inv.cur_volume>s_inv.max_volume then
    love.graphics.oldColor(176,23,43)
  else
    love.graphics.oldColor(22,22,22)
  end
  love.graphics.print(s_inv.volume_info, s_inv.x+700, s_inv.y+42)
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
  
  local  item_img,item_quad = curItem:getImgAndQuad()
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(item_img,item_quad,x+4,y,0,1,1)
  local name = curItem:getName()
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(name, x+45, y+8)
  love.graphics.setFont(c.font_c14)
  love.graphics.print(string.format("%.2f",curItem:getWeight()/100), x+580, y+10)
  love.graphics.print(string.format("%d",curItem:getVolume()), x+700, y+10)
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
    curSelectIndex = num
    --ui.iteminfo_reset()--重置物品信息
  end

  -- suit:S9Button("testb"..num,x,y,w,h)
end


local function loaddCategory()
  player.inventory:sort()--预sort
  local payeritemlist = player.inventory.items --直接操作items
  curList = {}
  local cur_cateName = categories[curCategory][1]
  for i=1,#payeritemlist do
    local curitem = payeritemlist[i]
    if categories:checkInCategory(cur_cateName,curitem) then
      curList[#curList+1] = curitem
    end
  end
  if curList[curSelectIndex] ==nil then curSelectIndex = 1 end--默认为1

end
local function loadWeightAndVolume()
  local inv = player.inventory
  s_inv.cur_weight = inv:getWeight()
  s_inv.max_weight = inv.maxWeight
  s_inv.cur_volume = inv:getVolume()
  s_inv.max_volume = inv.maxVolume
  s_inv.weight_info = string.format("%s %.1f/%.1f",tlnames.zweight,s_inv.cur_weight/100,s_inv.max_weight/100)
  s_inv.volume_info = string.format("%s %d/%d",tlnames.zvolume,s_inv.cur_volume,s_inv.max_volume)
end



local function winClose()
  ui.inventoryWin:Close()
end--提前声明。keyinput要用（esc退出）

local function keyinput(key)
  if key=="escape" then  winClose()end
end

local function self_open()
  --打开背包
  loaddCategory()
  loadWeightAndVolume()

end

local function window_do()
  suit:DragArea(s_inv,true,s_inv.dragopt)

  --和drag同步。。仍在dialog前面，
  local curItem = curList[curSelectIndex]
  if curItem then
    ui.iteminfo(curItem,s_inv.x+s_inv.w,s_inv.y,330,s_inv.h)--等于发送的是缓存的物品指针。源物品可能因为后续的操作逻辑被销毁或改变等。但最多存在本帧内
  end
  

  suit:Dialog(s_inv.name,s_inv.x,s_inv.y,s_inv.w,s_inv.h)
  suit:DragArea(s_inv,false,s_inv.dragopt,s_inv.x,s_inv.y,s_inv.w,32)
  local close_st = suit:ImageButton(close_quads,close_opt,s_inv.x+s_inv.w-34,s_inv.y+4,30,24)
  suit:registerDraw(drawBack)

  for i=1,#categories do
    local cateTab = suit:ImageButton(tab_quads,categories[i],s_inv.x+8 +(i-1)*80,s_inv.y+36,80,30)
    if curCategory ==i then  categories[i].state = "active" end
    if cateTab.hit then
      curCategory = i --点击切换条目。重载
      loaddCategory()
    end
  end

  myScroll.h = (s_inv.h-78)/myScroll.itemYNum * #curList
  suit:List(myScroll,oneItem,myScroll.opt,s_inv.x+8,s_inv.y+70,s_inv.w-16,s_inv.h-78)
  if close_st.hit then winClose() end
end

local new_win = ui.new_window()
new_win.window_do = window_do
new_win.win_open = self_open
new_win.keyinput = keyinput

ui.inventoryWin = new_win
