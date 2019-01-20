

data.class ={}
data.race ={}
data.unit ={}
data.unitIndex = {}


local function flagsTable(flagstr)
  if flagstr =="" then return {} end
  local t1 = string.split(flagstr,"|")
  local ret = {}
  for i=1,#t1 do
    ret[t1[i]] = true
  end
  return ret
end





local function loadClass()
  local file = assert(io.open("data/unit/class1.csv","r"))
  local dataclass= data.class
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      
      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="str" or key=="con" or key=="dex" or key=="per" or key=="ler"or key=="wil" or key=="mag"or key=="chr"then
        val = tonumber(val) or 0
        assert(val>=0 and val<=15)
        dataT[key] = val
      elseif key == "weapon_skills" then
        dataT.weapon_skills = flagsTable(val)
      elseif key == "profession_skills" then
        dataT.profession_skills = flagsTable(val)
      elseif key == "traits" then
        dataT.traits = flagsTable(val)
      else
        error("error key:"..key)
      end
    end
    if dataclass[dataT.id]~=nil then
      error("repetitive class id :"..dataT.id)
    end
    dataclass[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load class Nubmer:"..(index-1))
  file:close()
  
end



local function loadRace()
  
  local file = assert(io.open("data/unit/race1.csv","r"))
  local datarace= data.race
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      
      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="life" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="mana" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="speed" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="height" then
        dataT[key] = tonumber(val) or 150
      elseif  key=="weight" then
        dataT[key] = tonumber(val) or 50
      elseif  key=="male_ratio" then
        dataT[key] = tonumber(val) or 50
      elseif  key=="startfactor" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="str" or key=="con" or key=="dex" or key=="per" or key=="ler"or key=="wil" or key=="mag"or key=="chr"then
        val = tonumber(val) or 0
        assert(val>=0 and val<=15)
        dataT[key] = val
      elseif key == "weapon_skills" then
        dataT.weapon_skills = flagsTable(val)
      elseif key == "profession_skills" then
        dataT.profession_skills = flagsTable(val)
      elseif key == "traits" then
        dataT.traits = flagsTable(val)
      else
        error("error key:"..key)
      end
    end
    if datarace[dataT.id]~=nil then
      error("repetitive race id :"..dataT.id)
    end
    datarace[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load race Nubmer:"..(index-1))
  file:close()
end

local function checkSkillType(skills)
  for k,v in pairs(skills) do
    if g.skills[k]==nil then error("wrong skillname:"..k) end
  end
end


local function loadUnitType()
  local file = assert(io.open("data/unit/unit1.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      
      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="sex" then
        if val =="" then val = "random" end
        dataT[key] = val
      elseif  key=="race" then
        local race = data.race[val]
        if race ==nil then error("wrong race id:"..val)  end
        dataT.race = race
      elseif  key=="class" then
        local class = data.class[val]
        if class ==nil then error("wrong class id:"..val)  end
        dataT.class = class
      elseif  key=="attrFactor" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="level" then
        dataT[key] = tonumber(val) or 1
      elseif key == "weapon_skills" then
        dataT.weapon_skills = flagsTable(val)
      elseif key == "profession_skills" then
        dataT.profession_skills = flagsTable(val)
      elseif key == "traits" then
        dataT.traits = flagsTable(val)
      elseif key == "animMale" then
        --待添加  寻找anim
      elseif key == "animFemale" then
        --待添加
      else
        error("error unit key:"..key)
      end
    end
    --整理skill 
    local skill={}
    for k,v in pairs( dataT.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.profession_skills) do skill[k]=v  end
    for k,v in pairs( dataT.race.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.race.profession_skills) do skill[k]=v  end
    for k,v in pairs( dataT.class.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.class.profession_skills) do skill[k]=v  end
    checkSkillType(skill)
    dataT.skill = skill
    --checktrait,待以后
    
    if data.unitIndex[dataT.id]~=nil then
      error("repetitive unit id :"..dataT.id)
    end
    data.unitIndex[dataT.id] = index
    data.unit[index] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load unit Nubmer:"..(index-1))
  file:close()
end



return function ()
  loadClass()
  loadRace()
  loadUnitType()
  
end