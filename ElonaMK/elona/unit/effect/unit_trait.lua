
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
  
  --初始化种族天赋trait
  local tra = Trait.new("native_trait")
  local findnum = 0
  local good=0
  local nativeList ={}
  tra.mod_t = {}
  local function addModAndName(mod_id,name)
    local val = race[mod_id]
    if val~=0 then
      table.insert(nativeList,string.format("%s%+d",name,val))
      findnum = findnum+1
      tra.mod_t[mod_id] = val
      good = good +val
    end
  end
  addModAndName("DEF",tl("护甲","Armor"))
  addModAndName("MGR",tl("魔抗","Magic Resist"))
  addModAndName("atk_lv",tl("攻击","Attack"))
  addModAndName("dodge_lv",tl("闪避","Dodge"))
  addModAndName("block_lv",tl("格挡","Block"))
  addModAndName("hit_lv",tl("命中","Hit"))
  addModAndName("crit_lv",tl("暴击","Crital"))
  if findnum>0 then
    tra.description = table.concat(nativeList,";")
    table.insert(list,tra)
    tra.good = good>0
  end
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
