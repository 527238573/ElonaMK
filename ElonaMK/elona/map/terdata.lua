

--先创建好表结构
data.ter = {} --index的数组
local terImg = love.graphics.newImage("data/terrain/terrain.png")
data.terImg = terImg

local twidth = terImg:getWidth()
local theight = terImg:getHeight()

data.blockImgs = {}

data.blockImgs["wall"] = love.graphics.newImage("data/terrain/walls.png")
data.blockImgs["block"] = love.graphics.newImage("data/terrain/block.png")
data.block ={} --index的数组

data.overmapImg = love.graphics.newImage("data/terrain/overmap.png")
--data.overmapImg:setFilter( "nearest", "nearest" )
data.oter = {} --index 的数组


local strToBoolean =data.strToBoolean
local flagsTable =data.flagsTable



local function loadTer()

  local file = assert(io.open("data/terrain/ter1.csv","r"))


  local datater= data.ter

  local index = 1
  local line = file:read()
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    --序号
    dataT.index = tonumber(strDH[1])
    assert(dataT.index == index)
    --id
    dataT.id = strDH[2]
    --name
    dataT.name = strDH[3]
    --type --默认single
    dataT.type = strDH[4]
    if dataT.type=="" then dataT.type =  "single" end
    --color
    dataT.color = strDH[5]
    if dataT.color=="" then dataT.color =  "grey" end
    --priority
    dataT.priority = tonumber(strDH[6]) or 24
    --quadX
    dataT.quadX = assert(tonumber(strDH[7]))
    --quadY
    dataT.quadY = assert(tonumber(strDH[8]))
    --quadSize
    dataT.quadSize = tonumber(strDH[9]) or 64
    --move_cost
    dataT.move_cost = tonumber(strDH[10]) or 100

    --flags
    dataT.flags = flagsTable(strDH[11])

    --读取quad
    local function loadQuad(x,y,size,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,size,size,twidth,theight))
    end
    if dataT.type =="edged" then
      loadQuad(dataT.quadX,     dataT.quadY,    32,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY,    32,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY,    32,dataT)
      loadQuad(dataT.quadX,     dataT.quadY+0.5,32,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY+0.5,32,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY+0.5,32,dataT)
      loadQuad(dataT.quadX,     dataT.quadY+1,  32,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY+1,  32,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY+1,  32,dataT)
    elseif dataT.type =="hierarchy" then
      loadQuad(dataT.quadX,dataT.quadY,64,dataT)
      loadQuad(dataT.quadX+1,dataT.quadY,64,dataT)
      loadQuad(dataT.quadX+2,dataT.quadY,64,dataT)
      loadQuad(dataT.quadX+3,dataT.quadY,64,dataT)
      loadQuad(dataT.quadX+4,dataT.quadY,64,dataT)
      loadQuad(dataT.quadX+5,dataT.quadY,64,dataT)
    else--single
      loadQuad(dataT.quadX,dataT.quadY,64,dataT)
    end

    setmetatable(dataT,data.dataMeta)
    datater[dataT.index] = dataT
    index = index+1
    line = file:read()
  end

  debugmsg("load terNubmer:"..(index-1))
  file:close()


end

local function loadBlock()
  local file = assert(io.open("data/terrain/block1.csv","r"))


  local datablock= data.block
  local index = 1
  local line = file:read()
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    --序号
    dataT.index = tonumber(strDH[1])
    assert(dataT.index == index)
    --id
    dataT.id = strDH[2]
    --name
    dataT.name = strDH[3]
    --type --默认single
    dataT.type = strDH[4]
    if dataT.type=="" then dataT.type =  "single" end
    --color
    dataT.color = strDH[5]
    if dataT.color=="" then dataT.color =  "brown" end
    --img
    local img = data.blockImgs[strDH[6]]
    assert(img,"error block img name")
    dataT.img = img
    --quadX
    dataT.quadX = assert(tonumber(strDH[7]))
    --quadY
    dataT.quadY = assert(tonumber(strDH[8]))
    --w
    dataT.w = tonumber(strDH[9]) or 64
    --h
    dataT.h = tonumber(strDH[10]) or 64
    --anchorX
    dataT.anchorX = tonumber(strDH[11]) or math.floor(dataT.w/2)
    --anchorY
    dataT.anchorY = tonumber(strDH[12]) or 0
    --altitude
    dataT.altitude = tonumber(strDH[13]) or 0
    --pass
    dataT.pass = strToBoolean(strDH[14],true)
    --transparent
    dataT.transparent = strToBoolean(strDH[15],true)
    --move_cost
    dataT.move_cost = tonumber(strDH[16]) or 0
    --flags
    dataT.flags = flagsTable(strDH[17])
    --ground
    dataT.ground = strToBoolean(strDH[18],false)
    --frameNum
    dataT.frameNum =tonumber(strDH[19]) --后续检查
    --frameInterval
    dataT.frameInterval = tonumber(strDH[20])--后续检查
    --turnTo
    dataT.turnTo = strDH[21]
    if  dataT.turnTo =="" then  dataT.turnTo =nil end --后续检查

    --读取quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
    end
    if dataT.type =="wall" then
      loadQuad(dataT.quadX,       dataT.quadY,    64,64,dataT)
      loadQuad(dataT.quadX+1,     dataT.quadY,    64,64,dataT)
      loadQuad(dataT.quadX+2,     dataT.quadY,    64,64,dataT)
      loadQuad(dataT.quadX+3,     dataT.quadY,    64,64,dataT)
      loadQuad(dataT.quadX+4,     dataT.quadY,    64,32,dataT)
      loadQuad(dataT.quadX,       dataT.quadY+1,  64,96,dataT)
      loadQuad(dataT.quadX+1,     dataT.quadY+1,  64,96,dataT)
      loadQuad(dataT.quadX+2,     dataT.quadY+1,  64,96,dataT)
      loadQuad(dataT.quadX+3,     dataT.quadY+1,  64,96,dataT)
    elseif dataT.type =="anim" then
      if type(dataT.frameNum)~="number"  or  type(dataT.frameInterval)~="number" then
        error("animError index:"..dataT.index)
      end

      for i=1,dataT.frameNum do
        loadQuad(dataT.quadX+(i-1)*dataT.w/64,dataT.quadY,dataT.w,dataT.h,dataT)
      end
    else--single
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end

    setmetatable(dataT,data.dataMeta)
    datablock[dataT.index] = dataT
    index = index+1
    line = file:read()
  end

  debugmsg("load blockNubmer:"..(index-1))
  file:close()


end


local function loadOvermapTer()
  
  local file = assert(io.open("data/terrain/overmap1.csv","r"))
  local imgw = data.overmapImg:getWidth()
  local imgh = data.overmapImg:getHeight()


  local dataOter= data.oter
  local index = 1
  local line = file:read()
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    --序号
    dataT.index = tonumber(strDH[1])
    assert(dataT.index == index)
    --id
    dataT.id = strDH[2]
    --name
    dataT.name = strDH[3]
    --type --默认single
    dataT.type = strDH[4]
    if dataT.type=="" then dataT.type =  "single" end
    --layer
    dataT.layer = assert(tonumber(strDH[5]))
    --quadX
    dataT.quadX = assert(tonumber(strDH[6]))
    --quadY
    dataT.quadY = assert(tonumber(strDH[7]))
    --w
    dataT.w = tonumber(strDH[8]) or 64
    --h
    dataT.h = tonumber(strDH[9]) or 64
    --anchorX
    dataT.anchorX = tonumber(strDH[10]) or math.floor(dataT.w/2)
    --anchorY
    dataT.anchorY = tonumber(strDH[11]) or math.floor(dataT.h/2)
    --pass
    dataT.pass = strToBoolean(strDH[12],true)
    --move_cost
    dataT.move_cost = tonumber(strDH[13])
    if dataT.move_cost==nil then
      if dataT.layer==1 then
        dataT.move_cost = 100
      else
        dataT.move_cost = 0
      end
    end
    --flags
    dataT.flags = flagsTable(strDH[14])
    --targetMap
    dataT.targetMap = strDH[15]
    if  dataT.targetMap =="" then  dataT.targetMap =nil end --需要检查
    --priority
    dataT.priority = tonumber(strDH[16]) or 1

    --读取quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*32,y*32,w,h,imgw,imgh))
    end
    if dataT.type =="hierarchy" then
      loadQuad(dataT.quadX,dataT.quadY,64,64,dataT)
      loadQuad(dataT.quadX+2,dataT.quadY,64,64,dataT)
      loadQuad(dataT.quadX+4,dataT.quadY,64,64,dataT)
      loadQuad(dataT.quadX+6,dataT.quadY,64,64,dataT)
      loadQuad(dataT.quadX+8,dataT.quadY,64,64,dataT)
      loadQuad(dataT.quadX+10,dataT.quadY,64,64,dataT)
    elseif dataT.type =="road" then
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
      loadQuad(dataT.quadX+2,dataT.quadY,dataT.w,dataT.h,dataT)
      loadQuad(dataT.quadX+4,dataT.quadY,dataT.w,dataT.h,dataT)
      loadQuad(dataT.quadX+6,dataT.quadY,dataT.w,dataT.h,dataT)
      loadQuad(dataT.quadX+8,dataT.quadY,dataT.w,dataT.h,dataT)
      loadQuad(dataT.quadX+10,dataT.quadY,dataT.w,dataT.h,dataT)
    else--single
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end

    setmetatable(dataT,data.dataMeta)
    dataOter[dataT.index] = dataT
    index = index+1
    line = file:read()
  end

  debugmsg("load oterNubmer:"..(index-1))
  file:close()
  
  
end




local function linkId()
  data.terIndex={}
  for i=1,#data.ter do
    local id = data.ter[i].id
    if data.terIndex[id]~=nil then debugmsg("repetitive ter id:"..id) end
    data.terIndex[id] = i
  end
  data.blockIndex={}
  for i=1,#data.block do
    local id = data.block[i].id
    if data.blockIndex[id]~=nil then debugmsg("repetitive block id:"..id) end
    data.blockIndex[id] = i
  end

  --turnTo 转index
  for i=1,#data.block do
    local block = data.block[i]
    if block.turnTo then
      block.turnTo = data.blockIndex[block.turnTo]
      if block.turnTo==nil then
        error("turnTo error index:"..block.index)
      end
    end
  end
end



return function()
  loadTer()
  loadBlock()
  loadOvermapTer()
  linkId()
end