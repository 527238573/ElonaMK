

data.class ={}
data.race ={}
data.unit ={}
data.face ={}

local flagsTable =data.flagsTable

local function loadClass()
  local file = assert(io.open(c.source_dir.."data/unit/class.csv","r"))
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
    setmetatable(dataT,data.dataMeta)
    dataclass[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load class Nubmer:"..(index-1))
  file:close()
  
end



local function loadRace()
  
  local file = assert(io.open(c.source_dir.."data/unit/race.csv","r"))
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
      elseif  key=="dodge_mod" then
        dataT[key] = math.min(0.5,math.max(-0.5, tonumber(val) or 0))
      elseif  key=="melee_mod" then
        dataT[key] = math.min(0.5,math.max(-0.5, tonumber(val) or 0))
      elseif  key=="range_mod" then
        dataT[key] = math.min(0.5,math.max(-0.5, tonumber(val) or 0))
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
    setmetatable(dataT,data.dataMeta)
    datarace[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load race Nubmer:"..(index-1))
  file:close()
  
  
  --loadname
  file = assert(io.open(c.source_dir.."data/unit/race_name.csv","r"))
  line = file:read()
  attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = nil
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT = datarace[val]
      elseif  key=="name" then
        dataT[key] = val
      end
    end
    line = file:read()
  end    
  file:close()
end

local function checkSkillType(skills)
  for k,v in pairs(skills) do
    if g.skills[k]==nil then error("wrong skillname:"..k) end
  end
end


local function loadUnitType()
  local file = assert(io.open(c.source_dir.."data/unit/unit.csv","r"))
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
        if val =="" then val = dataT.id end --与单位id一致
        dataT.animMale = data.unitAnim[val]
        if dataT.animMale ==nil then debugmsg("emptyUnitAnim id:"..val)  end
      elseif key == "animFemale" then
        if val =="" then 
          dataT.animFemale = dataT.animMale 
        else
          dataT.animFemale = data.unitAnim[val]
        end 
        if dataT.animFemale ==nil then debugmsg("emptyUnitAnim id:"..dataT.id)  end
      elseif key == "flags" then
        dataT.flags = flagsTable(val)
      elseif key == "rarity" then 
        dataT[key] = tonumber(val) or 1
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
    
    if data.unit[dataT.id]~=nil then
      error("repetitive unit id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.unit[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load unit Nubmer:"..(index-1))
  file:close()
end

local function loadUnitFace()
  local lovefs = require("file/lovefs")
  --debugmsg("source:"..love.filesystem.getSource())
  local fs = lovefs(love.filesystem.getSource().."/data/pic/face")
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.png") then
      local fname = string.sub(v,1,-5)
      --debugmsg("load face:"..fname)
      data.face[fname]= love.graphics.newImage("/data/pic/face/"..v) 
    end
  end
end

return function ()
  loadClass()
  loadRace()
  loadUnitType()
  loadUnitFace()
  
  data.race["eulderna"].dodge_mod =0.1
  data.race["eulderna"].melee_mod =-0.1
end