Ability = {
  id = "null", --type的id
  type = nil,
  level = 1,--技能等级
}
saveMetaType("Ability",Ability)--注册保存类型
local niltable = { --默认值为nil的成员变量
  }

Ability.__newindex = function(o,k,v)
  if Ability[k]==nil and niltable[k]==nil then error("使用了Ability的意料之外的值。") else rawset(o,k,v) end
end

function Ability:loadfinish()
  rawset(self,"type",assert(data.ability[self.id])) 
end


function Ability.new(typeid)
  local etype = assert(data.ability[typeid])
  local o= {type = etype,id = typeid}
  setmetatable(o,Ability)
  return o
end

function Ability:getName()
  return self.type.name
end

local default_quad = love.graphics.newQuad(0,0,24,24,24,24)
function Ability:getImgAndQuad()
  return self.type.icon,default_quad
end