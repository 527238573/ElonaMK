Ability = {
  id = "null", --type的id
  type = nil,
  level = 1,--技能等级
  cooling = 0,--正在冷却的剩余时间。
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

function Ability:getAbilityIcon()
  return self.type.icon
end

function Ability:isMagic() return self.type.isMagic end
function Ability:getMainAttr() return self.type.main_attr end
function Ability:getLevel() return math.floor(self.level) end
function Ability:getExp() return self.level - math.floor(self.level) end

function Ability:getCostMana()
  return self.type.costMana
end

function Ability:getCooldown()
  return self.type.cooldown
end

function Ability:getCoolRate()
  if self.type.cooldown<=0 then return 0 end
  return self.cooling/self.type.cooldown
end

function Ability:updateRL(dt)
  if self.cooling>0 then
    self.cooling = math.max(0,self.cooling-dt)
  end
end