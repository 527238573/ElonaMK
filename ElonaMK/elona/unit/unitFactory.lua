--多种多样的创建方式




function Unit.create(id,level)
  
  
  
  
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
  
  
  unit.hp = unit:getMaxHP()
  unit.mp = unit:getMaxMP()
  
  return unit
end