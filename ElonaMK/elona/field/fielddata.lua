

data.field ={}

local strToBoolean =data.strToBoolean
local flagsTable =data.flagsTable

local function loadFieldType()
  
  local picbase = "data/field/anim/"
  
  local file = assert(io.open(c.source_dir.."data/field/field.csv","r"))
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
      elseif  key=="type" then
        if val =="" then val = "anim" end
        dataT[key] = val
      elseif  key=="img" then
        if val =="" then val = dataT.id..".png" end
        local picfile = picbase..val
        dataT.img = love.graphics.newImage(picbase..val) --读取img
      elseif  key=="frameNum" then
        dataT.frameNum = tonumber(val) or 1
      elseif  key=="frameInterval" then
        dataT.frameInterval = tonumber(val) or 0.2
      elseif  key=="autoWH" then
        dataT.autoWH = strToBoolean(val,true)
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 32
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 32
      elseif  key=="anchorX" then
        dataT[key] = tonumber(val) --auto宽高后再添默认值。
      elseif  key=="anchorY" then
        dataT[key] = tonumber(val) or 0
      elseif key == "scalefactor" then
        dataT[key] = tonumber(val) or 2
      elseif  key=="drawType" then
        if val =="" then val = "ground" end
        dataT[key] = val
      elseif  key=="priority" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="flags" then
        dataT.flags = flagsTable(val)
      else
        error("error field key:"..key)
      end
    end
    local imgw,imgh = dataT.img:getDimensions()
    --自动宽高
    if dataT.autoWH  and  (dataT.type == "anim" or dataT.type == "density")then
      dataT.w = imgw/dataT.frameNum
      dataT.h = imgh
    end
    dataT.anchorX = dataT.anchorX or math.floor(dataT.w/2) --重设默认值。
    
    --图片quad。
    if dataT.type == "anim" or dataT.type == "density" then
      for i= 1,dataT.frameNum do
        table.insert(dataT,love.graphics.newQuad(dataT.w*(i-1),0,dataT.w,dataT.h,imgw,imgh))
      end
    elseif dataT.type == "edge" then
      table.insert(dataT,love.graphics.newQuad(5*16,0,32,32,imgw,imgh))
      local function loadQuad(x,y)
        table.insert(dataT,love.graphics.newQuad(x*16,y*16,16,16,imgw,imgh))
      end
      loadQuad(0,0);loadQuad(1,0);loadQuad(2,0);
      loadQuad(0,1);loadQuad(1,1);loadQuad(2,1);
      loadQuad(0,2);loadQuad(1,2);loadQuad(2,2);
      loadQuad(3,0);loadQuad(4,0);
      loadQuad(3,1);loadQuad(4,1);
    else
      error("unknow field type:"..dataT.type)
    end
    
    if data.field[dataT.id]~=nil then
      error("repetitive field id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.field[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load field Nubmer:"..(index-1))
  file:close()
end

return function ()
  loadFieldType()
end
