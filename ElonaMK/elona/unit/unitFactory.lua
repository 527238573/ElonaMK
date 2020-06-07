--多种多样的创建方式

local levelList ={}

function Unit.initUnitFactory()
  --初始化levellist
  local function sort(utype1,utype2)
    return utype1.level < utype2.level
  end
  for id,utype in pairs(data.unit) do
    if not utype.flags["NORANDOM"] then
      table.insert(levelList,utype)
    end
  end
  table.sort(levelList,sort) --按等级排序。
end



function Unit.create(id,level,faction)
  
  local unit = Unit.new(id)
  local unitType = unit.type
  local classType = unit.class
  local raceType = unitType.race
  if level ==nil then level = unitType.level end
  unit.level = level
  
  unit:initAttr(raceType,classType,level,unitType.attrFactor*raceType.startfactor) 
  local skills = unitType.skill
  unit:initSkills(skills,level) 
  
  if faction then  unit:setFaction(faction) end
  
  unit:on_equip_change()--刷新装备数据
  unit:resetMaxHPMP()--上面一条已经刷过，保险起见
  unit.hp = unit.max_hp
  unit.mp = unit.max_mp
  return unit
end


function Unit.createMC(id,classid)
  
  local unit = Unit.new(id)
  local unitType = unit.type
  local classType = assert(data.class[classid])
  
  unit.class_id = classid
  rawset(unit,"class",classType) --转职改变职业，
  local raceType = unitType.race
  unit:initAttr(raceType,classType,1,1) --初始化1级属性。
  local skills = {}
  for k,v in pairs( unitType.weapon_skills) do skills[k]=v  end
  for k,v in pairs( unitType.profession_skills) do skills[k]=v  end
  for k,v in pairs( raceType.weapon_skills) do skills[k]=v  end
  for k,v in pairs( raceType.profession_skills) do skills[k]=v  end
  for k,v in pairs( classType.weapon_skills) do skills[k]=v  end
  for k,v in pairs( classType.profession_skills) do skills[k]=v  end
  unit:initSkills(skills,1) --初始化1级属性。
  
  unit:setFaction("player")
  unit:on_equip_change()--刷新装备数据
  unit:resetMaxHPMP()--上面一条已经刷过，保险起见
  unit.hp = unit.max_hp
  unit.mp = unit.max_mp
  return unit
end


function Unit.randomUnitTypeByLevel(maxLevel)
  --先查找最大index
  local left = 1
  local right = #levelList
  while left < right do
      local mid = math.floor((left + right+1)/2)
      if levelList[mid].level<=maxLevel  then
        left = mid
      else 
        right = mid-1
      end
  end
  local max_range =right 
  
  local function randomUnitType()
    local one = levelList[rnd(1,max_range)]
    if one.rarity<1 and rnd()>one.rarity then
      return randomUnitType()
    end
    return one
  end
  
  local function randomHighLevel()
    local one = levelList[rnd(1,max_range)]
    local two = levelList[rnd(1,max_range)]
    if two.level>one.level then one = two end
    if one.rarity<1 and rnd()>one.rarity then
      return randomHighLevel()
    end
    return one
  end
  
  return randomUnitType,randomHighLevel
end

