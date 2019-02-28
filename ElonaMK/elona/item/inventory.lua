--一共三种：地面的，个人背包，队伍背包（玩家专用。）
Inventory = { 
  --一些默认值
  saveType = "Inventory",--注册保存类型
  maxWeight = 100,
  maxNum = 400,
  weight = 0,
}

saveClass["Inventory"] = Inventory --注册保存类型

Inventory.__index = Inventory
Inventory.__newindex = function(o,k,v)
  if Inventory[k]==nil then error("使用了Inventory的意料之外的值。") else rawset(o,k,v) end
end



--默认ground为true
function Inventory.new(ground)
  ground = ground or true --默认是地面的
  local o= {}
  o.list = {}
  o.ground = ground
  if ground then
    o.maxWeight = 100000
    o.maxNum = 300
  else
    o.maxWeight = 100
    o.maxNum = 400
  end
  o.weight = 0
  o.weight_dirty = false
  o.unsorted = false
  setmetatable(o,Inventory)
  return o
end



function Inventory:setMaxWeight(maxweight)
  self.maxWeight = maxweight
end


--必须成功，成功后返回item，可能是堆叠后的（会改变）
function Inventory:addItem(item)
  --不考虑重量体积等，直接加入。
  if not self.ground then --只有非地面的才会尝试堆叠
    for i=1,#self.list do --尝试堆叠
      if self.list[i]:try_to_stack_with(item) then
        self.weight_dirty = true --不改变排序
        return self.list[i]
      end
    end
  end
  local index = #self.list+1
  self.list[index] = item ---直接加入
  item.parent = self
  item.index = index
  self.weight_dirty = true
  self.unsorted  = true
  return item
end

--整个物品移除，不考虑部分stack
function Inventory:removeItem(item)
  if item.parent~= self then 
    debugmsg("temp to remove item not in inv")
    return
  end
  if self.list[item.index] ==item then
    table.remove(item,item.index)
    for i=item.index,#self.list do
      self.list[i].index = i
    end
    item.parent = nil 
    self.weight_dirty = true
    return item
  else
    error("remove item index error")
  end
end



function Inventory:recalculateWeight()
  self.weight_dirty = false
  local weight = 0
  for i=1,#self.list do
    weight = weight +self.list[i]:getWeight()
  end
  self.weight = weight
end

function Inventory:getWeight()
  if  self.weight_dirty then self:recalculateWeight() end
  return self.weight
end

function Inventory:getNum()
  return #self.list
end


local function itemcompare(item1,item2)
  --先比较categories  后面再定
  return item1.type.id<item2.type.id --最终比较type id
end
function Inventory:sort()
  if not self.unsorted then return end
  self:restack()
  table.sort(self.items,itemcompare)
  self.unsorted = false
  for i=1,#self.list do
    self.list[i].index =i --重定位。
  end
end

--重新堆叠，比较繁琐
function Inventory:restack()
  local olditems = self.list
  local newitems = {}
  local haschange = false
  for i=1,#olditems do
    local toadd = olditems[i]
    local stacked = false
    for j=1,#newitems do
      if newitems[j]:try_to_stack_with(toadd) then
        toadd.parent = nil
        stacked = true
        haschange = true
        break;
      end
    end
    if not stacked then
      newitems[#newitems+1] = toadd
    end
  end 
  if haschange then --有变化时才改
    self.list = newitems
  end
end


--作为绘制的
function Inventory:getLastThreeItem()
  local list = self.list
  local length = #list
  if length<=3 then
    return list[1],list[2],list[3]
  else
    return Item.manyItems,list[length-1],list[length]
  end
end

