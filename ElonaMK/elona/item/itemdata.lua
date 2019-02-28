

data.item ={}

data.itemImgs = {}
data.itemImgs["item1"] = love.graphics.newImage("data/item/item1.png")


local strToBoolean =data.strToBoolean

local function loadItemType()
  
  local file = assert(io.open("data/item/item_generic1.csv","r"))
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
        if val =="" then val = "generic" end
        dataT[key] = val
      elseif  key=="img" then
        local img = data.itemImgs[val]
        if img ==nil then error("wrong itemImg id:"..val)  end
        dataT.img = img
      elseif  key=="quadX" then
        dataT.quadX = assert(tonumber(val))
      elseif  key=="quadY" then
        dataT.quadY = assert(tonumber(val))
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="hanging" then
        dataT.hanging = strToBoolean(val,false)
      elseif  key=="frameNum" then
        dataT.frameNum = tonumber(val) or 1
        dataT.useAnim = dataT.frameNum>1 
      elseif  key=="frameInterval" then
        dataT.frameInterval = tonumber(val) or 0.2
      elseif  key=="weight" then
        dataT[key] = tonumber(val) or 0.1
      elseif  key=="price" then
        dataT[key] = tonumber(val) or 100
      elseif key =="description" then
        dataT[key] = val
      elseif key =="canStack" then
        dataT[key] = strToBoolean(val,true)
      elseif key =="initNum" then
        dataT[key] = tonumber(val) or 1
        if not dataT.canStack then dataT[key]=1 end 
      else
        error("error item key:"..key)
      end
    end
    --quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
    end
    if dataT.useAnim then
      for i=1,dataT.frameNum do
        loadQuad(dataT.quadX+(i-1)*dataT.w/64,dataT.quadY,dataT.w,dataT.h,dataT)
      end
    else
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end
    
    
    if data.item[dataT.id]~=nil then
      error("repetitive item id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.item[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load item Nubmer:"..(index-1))
  file:close()
end


return function ()
  loadItemType()
end