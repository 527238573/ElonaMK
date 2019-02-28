Item = {
    --一些默认值
    
    type = nil,--类型数据。
    id = "null", --type的id
    name = "noname",
    saveType = "Item",--注册保存类型
    num = 1, --堆叠数量。需要用函数修改。
    weight = 0.1, --重量 。 改变重量或数量，导致重量变化需要通知parent
    parent = nil, --item除了被装填的子弹以外，必在一个inventory中。
    index = 0,--在parent内身处的位置。parent专用。
  }
saveClass["Item"] = Item --注册保存类型

Item.__index = Item
Item.__newindex = function(o,k,v)
  if Item[k]==nil and k~="parent" then error("使用了Item的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
end

--读取完成后自动调用。不再使用index。id是字符串，永不变化。
function Item:loadfinish()
  rawset(self,"type",assert(data.item[self.id]))
  --self.type = assert(data.item[self.id])
  --如果新版增加字段，则需要补充。
end


function Item.new(typeid)
  local o= {}
  local itype = assert(data.item[typeid])
  
  o.id = typeid
  o.type = itype
  o.name = itype.name
  o.num = itype.initNum
  o.weight = itype.weight --重量
  setmetatable(o,Item)
  return o
end


function Item:getWeight()
  return self.weight
end

function Item:set_num(num)
  if not self.type.canStack then return end
  if self.num~=num then
    self.num = num
    o.weight = self.type.weight*num
    if self.parent then
      self.parent.weight_dirty = true
    end
  end
end


function Item:try_stack_with(oitem)
  if self.type~= oitem.type then return false end
  if not self.type.canStack then return false end
  --还要其他检查。
  self:set_num(self.num+oitem.num)
  return true
end
