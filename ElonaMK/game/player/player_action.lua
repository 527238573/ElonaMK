
local function walk_out_of_map_callback(leave)
  if leave then
    g.playSound("exitmap1")
    local wx,wy = p.x,p.y
    if cmap.wmap_cord then
      wx,wy = cmap.wmap_cord[1],cmap.wmap_cord[2]
    end
    Scene.enterWorldMap(wx,wy)
  end
end

local function walk_out_of_map(unit,dest_x,dest_y)
  local map = assert(unit.map)
  if not map:inbounds(dest_x,dest_y) and  map.can_exit then
    ui.ynAskWin:Open(walk_out_of_map_callback,tl("离开地图？","Do you want to leave?"))
    return true
  end
  return false
end

--玩家控制单位行动（按下方向键）。这是模糊指令，根据情况执行不同的行为。近战攻击，换位，移动，开门，与物体互动，与NPC对话等等
--不同行为具有优先级，依次执行
function Player:mc_move_action(dx,dy)
  local unit = p.mc
  if unit.dead then return end
  unit:set_face(dx,dy)
  local dest_x,dest_y = unit.x+dx,unit.y+dy
  
  local mdo = walk_out_of_map(unit,dest_x,dest_y)
  if mdo then return end
  
  local destunit = unit.map:unit_at(dest_x,dest_y)
  if destunit then
    mdo = unit:attak_to(dest_x,dest_y,destunit)
    if mdo then return end
    
    --未来还有talk_to 
    
    mdo = unit:swap_to(dest_x,dest_y,destunit)
    if mdo then return end
  end
  
  mdo = unit:walk_to(dest_x,dest_y)
  
end

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
--返回使用成功与否。成功就中断按键检测
function Player:useActionBar(index)
  if p.mc:is_dead() then return true end
    --if p.mc.delay>0 then return end --某些技能可以delay中使用
  return p.mc:useActionBar(index)
end

