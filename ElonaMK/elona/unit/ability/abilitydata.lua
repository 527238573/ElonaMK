local lovefs = require("file/lovefs")

data.ability ={}
data.ability_icon = {}

local strToBoolean =data.strToBoolean

local function loadAbilityIcons()
  local fs = lovefs(c.source_dir.."data/ability/icon")
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.png") then
      local fname = string.sub(v,1,-5)
      --debugmsg("load face:"..fname)
      data.ability_icon[fname]= love.graphics.newImage("/data/ability/icon/"..v) 
    end
  end
end



local function loadAbilities()
  local file = assert(io.open(c.source_dir.."data/ability/ability.csv","r"))
  local data_type_t= data.ability
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
      elseif  key=="icon" then
        local img = data.ability_icon[val]
        if img ==nil then error("ability_icon error:"..val) end
        dataT[key] = img
      elseif key == "isMagic" then
        dataT[key] = strToBoolean(val,false)
      elseif key == "main_attr" then
        if g.main_attr[val]==nil then error("error mainattr:"..val) end
        dataT[key] = val
      elseif key == "baseLevel" then
        dataT[key] = tonumber(val) or 0
      elseif key == "difficulty" then
        dataT[key] = tonumber(val) or 1
      elseif key == "costMana" then
        dataT[key] = tonumber(val) or 0
      elseif key == "cooldown" then
        dataT[key] = tonumber(val) or 1
      elseif key == "description" then
        dataT[key] = val
      elseif key == "target_type" then
        dataT[key] = val
      elseif key == "range" then
        dataT[key] = val
      else
        error("error key:"..key)
      end
    end
    if data_type_t[dataT.id]~=nil then
      error("repetitive ability id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data_type_t[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load abilities Nubmer:"..(index-1))
  file:close()

  --loadname
  file = assert(io.open(c.source_dir.."data/ability/ability_name.csv","r"))
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
        dataT = data_type_t[val]
      elseif  key=="name" then
        --debugmsg(string.format("orgin:%s utf8:%s convert:%s",dataT[key],val,convert2))
        dataT[key] = val
      elseif  key=="description" then
        dataT[key] = val
      end
    end
    line = file:read()
  end    
  file:close()
end


return function ()
  loadAbilityIcons()
  loadAbilities()
  local aloadfunc = assert(loadfile(c.source_dir.."elona/unit/ability_call/ability1.lua"))
  aloadfunc()
end