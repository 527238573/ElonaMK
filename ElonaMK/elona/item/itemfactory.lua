


function Item.initItemFactory()
  Item.manyItems= Item.create("many_items")
  
end



--标准创建。
function Item.create(id)
  if data.item[id]==nil then error("使用了不存在的itemid:"..id) end
  local o = Item.new(id)
  
  return o
end