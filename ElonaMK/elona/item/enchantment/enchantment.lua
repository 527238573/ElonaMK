Enchantment = {
    --一些默认值
    
    type = nil,--类型数据。
    id = "null", --type的id
    value = 0,--
    source = "material", --material，equipment，enchantment，blacksmith等等，自生，强化等多种来源
    
    
  }
saveClass["Enchantment"] = Enchantment --注册保存类型

Enchantment.__index = Enchantment
Enchantment.__newindex = function(o,k,v)
  if Enchantment[k]==nil then error("使用了Enchantment的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
end

--读取完成后自动调用。不再使用index。id是字符串，永不变化。
function Enchantment:loadfinish()
  rawset(self,"type",assert(data.enchantment[self.id]))
  --如果新版增加字段，则需要补充。
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
