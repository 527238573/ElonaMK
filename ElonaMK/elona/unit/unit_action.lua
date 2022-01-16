




function Unit:attak_to(dest_x,dest_y,destunit)
  if destunit ==nil then destunit = self.map:unit_at(dest_x,dest_y) end
  if destunit==nil then return false end
  if not self:isHostile(destunit) then return false end
  self:melee_attack(destunit)
  return true
end

--与相邻格子坐标的单位交换位置
function Unit:swap_to(dest_x,dest_y,destunit)
  local map = assert(self.map)
  if destunit ==nil then destunit = map:unit_at(dest_x,dest_y) end
  if destunit==nil then return false end
  --敌对目标不能换位。boss除外。boss的情况还没做
  if self:isHostile(destunit) then return false end
  --mc不能被推。boss除外
  if destunit == p.mc then return false end
  --霸体状态不能换位。霸体可能正在播动画，
  if not destunit:canPush() then return false end
  
  if not map:can_pass(dest_x,dest_y) then return false end --不能移动的地形。就算有单位占据不能移动的地形，也不能交换位置。
  
  
  local dx = self.x-dest_x
  local dy = self.y-dest_y
  local costtime  = map:move_cost(dest_x,dest_y)/self:getSpeed()
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/c.timeSpeed 
  
  --先移动destunit
  map:unitMove(destunit,self.x,self.y)
  
  
  map:unitMove(self,dest_x,dest_y) --更换地图上的位置。
  --设置动画。
  
  local clip  = Animation.Move(costtime,dx*64,dy*64,self:get_unitAnim_playSpeed())
  self:addClip(clip)
  self:short_delay(costtime,"walk")
  
  
  local destTime = 0.7*costtime
  local destclip  = Animation.Pushed(destTime,0,-dx*64,-dy*64,destunit:get_unitAnim_playSpeed())
  destunit:addClip(destclip)
  destunit:short_delay(destTime,"pushed")
  
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
  local clip  = Animation.Move(costtime,dx*64,dy*64,self:get_unitAnim_playSpeed())
  self:addClip(clip)
  self:short_delay(costtime,"walk")
  return true
end

--不播放动画，只移动
function Unit:teleport_to(dest_x,dest_y)
  local map = assert(self.map)
  --类似spawn
  for nx,ny in c.closest_xypoint_rnd(dest_x,dest_y,4) do--9*9的方框内。够大了
    if map:can_pass(nx,ny) then
      if map:unit_at(nx,ny) ==nil then
        --找到合理的放置点
        map:unitMove(self,nx,ny) --更换地图上的位置。
        return true
      end
    end
  end
  return false
end

--被动地被推挤了。默认目标点可通行。
function Unit:push_to(dest_x,dest_y,delay,pushtime)
  delay = delay or 0
  pushtime = pushtime or 0.4
  
  local map = assert(self.map)
  local dx = self.x-dest_x
  local dy = self.y-dest_y
  map:unitMove(self,dest_x,dest_y) --更换地图上的位置。
  local clip  = Animation.Pushed(pushtime,delay,dx*64,dy*64,self:get_unitAnim_playSpeed())
  self:addClip(clip)
  self:short_delay(pushtime+delay,"pushed")
end





--将item装入背包。已经经过检查，去除之前的联系。

local pickupStr = tl("%s捡起%s。","%s picks up %s.")
function Unit:pickUpItem(item,nosound)
  local playerPick = false
  for i=1,#p.team do if self ==p.team[i] then playerPick = true; break end end --是玩家控制的单位。
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
  for i=1,#p.team do if self ==p.team[i] then playerPick = true; break end end --是玩家控制的单位。
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



