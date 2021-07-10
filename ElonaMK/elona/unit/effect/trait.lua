Trait = {
  id = "null", --type的id
  type = nil,
  level = 1,--等级(可能有部分)
  innate = true,--为true表明来源是先天的，来自种族职业，不是后天附加的。更换职业就会删除。
  good = true,--默认为good。坏的用红色显示。
}
saveMetaType("Trait",Trait)--注册保存类型




function Trait.new(typeid)
  local ttype = assert(data.trait[typeid])
  local o= {type = ttype,id = typeid}
  setmetatable(o,Trait)
  
  return o
end

function Trait:getName()
  local ttype = self.type
  if ttype.levels then
    local lv_t = ttype.levels[self.level]
    if lv_t and lv_t.name then
      return lv_t.name
    end
  end
  return ttype.name
end

function Trait:getDescription()
  local ttype = self.type
  local des = self.description or ttype.description
  if ttype.levels then
    local lv_t = ttype.levels[self.level]
    if lv_t and lv_t.description then
      des = lv_t.description
    end
  end
  if type(des)=="function" then
    return des(self)
  end
  return des
end

function Trait:isGood()
  local ttype = self.type
  if ttype.levels then
    local lv_t = ttype.levels[self.level]
    if lv_t and lv_t.good~= nil then
      return lv_t.good
    end
  end
  if ttype.good~=nil then
    return ttype.good
  end
  return self.good 
end

function Trait:calculate_bonus(bonus)
  local mod_t = self.mod_t or self.type.mod_t
  if mod_t ==nil then return end
  for k,v in pairs(mod_t) do
    bonus[k] = bonus[k] + v
  end
end