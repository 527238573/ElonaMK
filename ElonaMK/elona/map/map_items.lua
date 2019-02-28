

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

