
--内部添加。
local function addTraitById(unit,trait_id)
  local list = unit.traits
  for _,o_tra in ipairs(list) do
    if o_tra.id == trait_id then
      return o_tra
    end
  end
  local tra = Trait.new(trait_id)
  table.insert(list,tra)
  return tra
end--添加之后要重计 bonus

--一般不用这个。
function Unit:getTraitById(trait_id)
  local list = self.traits
  for _,o_tra in ipairs(list) do
    if o_tra.id == trait_id then
      return o_tra
    end
  end
end

--初始化所有traits，根据种族职业。 没有重计 bonus，需要手动重记。
function Unit:initTraits(race,class)
  --三大基础数值
  local list = self.traits
  local utype = self.type
  local function baseTrait(baseid)
    if race[baseid]~=0 then
      local tra = Trait.new(baseid)
      tra.mod_t = {[baseid] = race[baseid]}
      tra.level = race[baseid]>0 and 1 or 2
      table.insert(list,tra)
    end
  end
  baseTrait("dodge_mod")
  baseTrait("melee_mod")
  baseTrait("range_mod")
  local all_tra = {}
  for tra_id,_ in pairs(utype.traits) do
    all_tra[tra_id] = true
  end
  for tra_id,_ in pairs(race.traits) do
    all_tra[tra_id] = true
  end
  for tra_id,_ in pairs(class.traits) do
    all_tra[tra_id] = true
  end
  for tra_id,_ in pairs(all_tra) do
    local tra = Trait.new(tra_id)
    table.insert(list,tra)
  end
end
