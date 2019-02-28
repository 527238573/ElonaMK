--多种多样的创建方式




function Unit.create(id,level)
  
  
  
  
end


function Unit.createMC(id,classid)
  
  local unit = Unit.new(id)
  local unitType = unit.type
  local classType = assert(data.class[classid])
  rawset(unit,"transferClass",classType) --转职改变职业，
  local raceType = unitType.race
  unit:initAttr(raceType,classType,1,1) --初始化1级属性。
  
  
  return unit
end