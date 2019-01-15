local Overmap = {
    w = 10,--宽
    h = 10, --高默认值，
    saveType = "Overmap",--注册保存类型
  }

saveClass["Overmap"] = Overmap --注册保存类型

Overmap.__index = Overmap
Overmap.__newindex = function(o,k,v)
  if Overmap[k]==nil then error("使用了Overmap的意料之外的值。") else rawset(o,k,v) end
end

function Overmap.new(x,y)
  assert(type(x)=="number" and type(y)=="number" and x>8 and y>8)
  x = math.floor(x)--保证整数
  y = math.floor(y)
  
  local o = {}
  o.w = x;o.h = y
  
end