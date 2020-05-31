


--按下G键。
function Player:pickup_action()
  if p.mc:is_dead() then return end
  if p.mc.delay>0 then return end
  local x,y= p.mc.x,p.mc.y
  if not cmap:canPickupItems(x,y,true) then return end--不能拾取。
  
  local singleitem = nil
  
  local itemlist = cmap:getItemList(x,y,false)
  if itemlist ==nil then return end--没有可捡取的物品。
  local list = itemlist.list
  for i=1,#list do
    if (not list[i]:isHidden()) then
      if singleitem ~=nil then
        --多于两个物品需要捡取。
        ui.pickDropWin:Open(true,itemlist)
        return
      end
      singleitem = list[i]
    end
  end
  if singleitem == nil then 
    return --没有可捡取的物品。全是隐藏物品。
  else --只有一个可捡取的物品，直接捡取。
    if not p:canPickupItem(singleitem,true) then
      g.playSound("fail1")--不能捡取。
      return 
    end
    p.mc:pickUpItem(singleitem)--成功捡取
    cmap:releaseItemList(x,y) --尝试释放
  end
end

--按下q键
function Player:drop_action()
  if p.mc:is_dead() then return end
  if p.mc.delay>0 then return end
  local x,y= p.mc.x,p.mc.y
  if not cmap:canDropItems(x,y,true) then return end--不能拾取。
  
  local itemlist = cmap:getItemList(x,y,true)
  ui.pickDropWin:Open(false,itemlist)
  
end

function Player:useItem_action()
  if p.mc:is_dead() then return end
  if p.mc.delay>0 then return end
  ui.itemUseWin:Open()
end

--按下f键，或 持续按下f键
function Player:fire_action()
  if p.mc.delay>0 then return end
  if p.mc:is_dead() then return end
  p.mc:fastShootAction(true)
end

function Player:reload_action()
  if p.mc.delay>0 then return end
  if p.mc:is_dead() then return end
  p.mc:reloadAction(true)
end

--取消目标
function Player:esc_action()
  if p.mc.target then
    p.mc.target = nil
    g.playSound("click1")
  end
  
end
