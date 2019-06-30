

--默认force为false，若为true则强行创建。否则返回nil
function Map:getItemList(x,y,force)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self.items[y*self.w+x+1]
  if list== c.empty then list =nil end
  
  if list==nil and force then 
    list = Inventory.new(true)
    self.items[y*self.w+x+1] = list
  end
  return list
end
--尝试回收itemList节约空间，如果为空的话。
function Map:releaseItemList(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self.items[y*self.w+x+1]
  if list~= c.empty and list:getNum()==0 then 
    self.items[y*self.w+x+1] = c.empty --回收
  end
end

--清除一个地格上的物品。连带list也。
function Map:clearSquareItem(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  self.items[y*self.w+x+1] = c.empty
end

--不检查直接添加
function Map:spawnItem(item,x,y)
  local list = self:getItemList(x,y,true)
  list:addItem(item)
end

function Map:spawnItemById(itemid,x,y)
  local list = self:getItemList(x,y,true)
  local item = Item.create(itemid)
  list:addItem(item)
end



--能从这格地形捡起物品。
function Map:canPickupItems(x,y,showmsg)
  if not self:inbounds(x,y) then return false end
  local blockid = self:getBlock(x,y)
  local binfo = data.block[blockid]
  if not binfo.pass then return false end
  if binfo.flags["CONTAINER"] and  binfo.flags["LOCKED"] then
    if showmsg then addmsg(tl("你不能拾取锁住容器内的物品。","You can't pick up the items in the locked container."),"info") end
    return false
  end
  --可能还有其他不能放置物品的地形。
  return true
end
--判断能从这格扔下物品。包括主动扔下的和掉落的
function Map:canDropItems(x,y,showmsg)
  if not self:inbounds(x,y) then return false end
  local blockid = self:getBlock(x,y)
  local binfo = data.block[blockid]
  if not binfo.pass then return false end
  if binfo.flags["CONTAINER"] and  binfo.flags["LOCKED"] then
    if showmsg then addmsg(tl("你不能将物品放入锁住的容器内。","You can't put items in a locked container."),"info") end
    return false
  end
  --可能还有其他不能放置物品的地形。
  return true
end

--返回是否成功drop.不一定能成功drop
function Map:dropItem(item,x,y)
  if not self:inbounds(x,y) then return false end
  for nx,ny,nz in c.closest_xypoint_first(x,y,3) do--默认为3
    if self:canDropItems(x,y,false) then
      local list = self:getItemList(x,y,true)
      list:addItem(item,true)
      return true
    end
  end
  return false
end 


