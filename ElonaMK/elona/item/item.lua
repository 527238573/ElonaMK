Item = {
    --一些默认值
    
    type = nil,--类型数据。
    id = "null", --type的id
    name = "noname",
    displayName = "",
    num = 1, --堆叠数量。需要用函数修改。
    weight = 0.1, --重量 。 改变重量或数量，导致重量变化需要通知parent
    parent = nil, --item，必在一个inventory中。
    index = 0,--在parent内身处的位置。parent专用。
    
    --equipment
    level = 1,
    quality = 1,--装备稀有度 LV1=白装 0附魔 总附魔3 LV2 = 优秀1～2附魔 总5  LV3= 奇迹3～4额外附魔 总8 LV4 = 神器 5～6 附魔 总12。
    
    
    
    ammoNum = 0, --剩余子弹数，只对能装弹的远程武器有效
    useReload = false,--只对能装弹的远程武器为true
    
  }
saveMetaType("Item",Item)--注册保存类型
Item.__newindex = function(o,k,v)
  if Item[k]==nil and k~="parent" then error("使用了Item的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
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
    self.weight = self.type.weight*num
    if self.parent then
      self.parent.weight_dirty = true
    end
  end
end


function Item:canStack()
  return self.type.canStack
end


function Item:try_to_stack_with(oitem)
  if self.type~= oitem.type then return false end
  if not self.type.canStack then return false end
  --还要其他检查。
  self:set_num(self.num+oitem.num)
  return true
end

--分割物品。
function Item:slice(num)
  if not self:canStack() or num ==0 then return nil end
  if num >= self.num then return self end
  local newitem = ItemFactory.create(self.type.id)
  self:set_num(self.num-num)
  newitem:set_num(num)
  return newitem
end
