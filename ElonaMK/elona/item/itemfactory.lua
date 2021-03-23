
ItemFactory = {}

function ItemFactory.initItemFactory()
  Item.manyItems= ItemFactory.create("many_items")
  
end



--标准创建。
function ItemFactory.create(id)
  local itype = data.item[id]
  if itype==nil then error("使用了不存在的itemid:"..id) end
  if itype.type == "equipment" then
    return ItemFactory.createEquipment(id,itype.sLevel,1)
  end
  local o = Item.new(id)
  
  return o
end


function ItemFactory.createEquipment(id,level,quality)
  local itype = data.item[id]
  if itype==nil then error("使用了不存在的itemid:"..id) end
  if itype.type ~= "equipment" then error("使用了非equipment id:"..id) end
  level = math.max(1,level)--最小为1
  local o = Item.new(id)
  o.level = level
  o:initEquipment(level)
  o:randomEnchantment(level,quality)
  o:resetEquipmentName()
  return o
end





