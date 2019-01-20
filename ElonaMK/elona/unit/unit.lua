Unit = {
    --一些默认值
    
    index = 1,--type的编号。每次都要重分配。以id为准。
    id = "null", --type的id
    name = "noname",
    x=0, --位置。
    y=0,
    saveType = "Unit",--注册保存类型
  }
saveClass["Unit"] = Unit --注册保存类型

Unit.__index = Unit
Unit.__newindex = function(o,k,v)
  if Unit[k]==nil then error("使用了Unit的意料之外的值。") else rawset(o,k,v) end
end


function Unit.new(typeid,level)
  local o= {}
  o.id = typeid
  o.index = assert(data.unitIndex[typeid])
  Unit.unitInitAttrAndBouns(o)
  setmetatable(o,Unit)
  
  return o
end

--读取完成后自动调用。防止万一index发生变化。id是字符串，永不变化。
function Unit:loadfinsh()
  self.index = assert(data.unitIndex[self.id])
end

function Unit:type()
  return data.unit[self.index]
end