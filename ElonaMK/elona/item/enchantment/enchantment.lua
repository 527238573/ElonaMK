Enchantment = {
    --一些默认值
    
    type = nil,--类型数据。
    id = "null", --type的id
    value = 0,--
    source = "material", --material，equipment，enchantment，blacksmith等等，自生，强化等多种来源
    
    
  }
saveMetaType("Enchantment",Enchantment)--注册保存类型
Enchantment.__newindex = function(o,k,v)
  if Enchantment[k]==nil then error("使用了Enchantment的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
end




function Enchantment.new(typeid)
  local o= {}
  local itype = assert(data.enchantment[typeid])
  o.id = typeid
  o.type = itype
  setmetatable(o,Enchantment)
  return o
end


--根据物品等级随机附魔。
function Enchantment:rollLevel(level)
  self.value = 1
  
end

