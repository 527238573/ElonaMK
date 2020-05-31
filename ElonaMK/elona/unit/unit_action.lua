

local function walk_out_of_map_callback(leave)
  if leave then
    g.playSound("exitmap1")
    local wx,wy = p.x,p.y
    if cmap.wmap_cord then
      wx,wy = cmap.wmap_cord[1],cmap.wmap_cord[2]
    end
    Map.enterWorldMap(wx,wy)
  end
end

function Unit:walk_out_of_map(dest_x,dest_y)
  local map = assert(self.map)
  if self == p.mc and not map:inbounds(dest_x,dest_y) and  map.can_exit then
    ui.ynAskWin:Open(walk_out_of_map_callback,tl("离开地图？","Do you want to leave?"))
    return true
  end
  return false
end




function Unit:attak_to(dest_x,dest_y,destunit)
  if destunit ==nil then destunit = self.map:unit_at(dest_x,dest_y) end
  if destunit==nil then return false end
  if not self:isHostile(destunit) then return false end
  self:melee_attack(destunit)
  return true
end


--尝试走到x，y点，不行则返回false。行则返回true
function Unit:walk_to(dest_x,dest_y)
  local map = assert(self.map)
  
  if not map:can_pass(dest_x,dest_y) then return false end --不能移动的地形。
  if map:unit_at(dest_x,dest_y) then return false end --有单位占据了。如果友方单位占据则可以交换，但不在此函数。
  
  local dx = self.x-dest_x
  local dy = self.y-dest_y
  
  local costtime  = map:move_cost(dest_x,dest_y)/self:getSpeed()
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/c.timeSpeed 
  map:unitMove(self,dest_x,dest_y) --更换地图上的位置。
  --设置动画。
  
  --local dx = self.x-dest_x
  --local dy = self.y-dest_y
  local clip  = AnimClip.new("move",costtime,dx*64,dy*64,self:get_unitAnim_playSpeed())
  self:addClip(clip)
  self:add_delay(costtime,"walk")
  return true
end


--操作move
function Unit:moveAction(dx,dy)
  self:set_face(dx,dy)
  local dest_x,dest_y = self.x+dx,self.y+dy
  
  local mdo = self:walk_out_of_map(dest_x,dest_y)
  if mdo then return end
  
  local destunit = self.map:unit_at(dest_x,dest_y)
  if destunit then
    mdo = self:attak_to(dest_x,dest_y,destunit)
    if mdo then return end
  end
  
  
  
  mdo = self:walk_to(self.x+dx,self.y+dy)
  
end

--将item装入背包。已经经过检查，去除之前的联系。

local pickupStr = tl("%s捡起%s。","%s picks up %s.")
function Unit:pickUpItem(item,nosound)
  local playerPick = false
  for i=1,4 do if self ==p.team[i] then playerPick = true; break end end --是玩家控制的单位。
  if playerPick then
    p.inv:addItem(item)
    addmsg(string.format(pickupStr,self:getName(),item:getDisplayName()),"info")
  else
    self.inv:addItem(item)
  end
  self:short_delay(0.4,"pickItem") --差不多一回合时间。
  if not nosound then g.playSound("get1",self.x,self.y) end
end

local dropStr = tl("%s将%s放下。","%s puts %s down.")
function Unit:dropItem(item)
  local playerPick = false
  for i=1,4 do if self ==p.team[i] then playerPick = true; break end end --是玩家控制的单位。
  local map = self.map or cmap
  local success =map:dropItem(item,self.x,self.y)
  if not success then
    if item.parent~= nil then
      item.parent:removeItem(item) --没添加成功，也从原始包内移除。
    end
  end
  self:short_delay(0.3,"dropItem")
  g.playSound("drop1",self.x,self.y)
  if playerPick then
    addmsg(string.format(dropStr,self:getName(),item:getDisplayName()),"info")
    if not success then
      addmsg(tl("丢下的物品找不到了！","The item just dropped is lost!"),"info")
    end
  end
end



