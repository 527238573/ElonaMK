


function Item.initItemFactory()
  Item.manyItems= Item.create("many_items")
  
end



--标准创建。
function Item.create(id)
  local itype = data.item[id]
  if itype==nil then error("使用了不存在的itemid:"..id) end
  if itype.type == "equipment" then
    return Item.createEquipment(id,itype.sLevel,1)
  end
  
  
  local o = Item.new(id)
  
  return o
end


function Item.createEquipment(id,level,quality)
  local itype = data.item[id]
  if itype==nil then error("使用了不存在的itemid:"..id) end
  if itype.type ~= "equipment" then error("使用了非equipment id:"..id) end
  level = math.max(1,level)--最小为1
  local o = Item.new(id)
  o.level = level
  o:randomMaterial(level)
  o:initEquipment(level)
  o:randomEnchantment(level,quality)
  o:resetEquipmentName()
  return o
end




--根据等级差值随机选取材质。
function Item.getRandomMaterial(dlevel)
  local mat_list = {val = {},weight={}}
  local maxweight = 0
  
  for i=1,#data.material_seq do
    local mat = data.material_seq[i]
    
    --for k,v in pairs(mat) do
    --  debugmsg("k:"..k.." v:"..tostring(v))
    --end
    
    if dlevel<mat.level then break end--
    if dlevel>=mat.level and dlevel<=mat.level+ mat.range then
      local weight = mat.rare *(1-math.abs(dlevel- mat.level-0.5*mat.range)/(mat.range))
      maxweight = maxweight+weight
      table.insert(mat_list.val,mat)
      table.insert(mat_list.weight,maxweight)
    end
  end
  if maxweight>0 then
    return mat_list.val[c.search_weight(mat_list.weight,rnd(mat_list.weight[#mat_list.weight]))]
  else
    return data.material_seq[2] --paper
  end
end