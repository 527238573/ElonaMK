

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


local function strToBoolean(str,default)
  if str =="" then
    return default
  elseif str =="FALSE" then
    return false
  elseif str =="TRUE" then
    return true
  else
    error("invalid booleanStr")
  end
end


local function loadTer()

  local file = assert(io.open("data/terrain/ter1.csv","r"))
  debugmsg("load: ter data")


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

    --flag
    dataT.flag = strDH[11] --还未改好

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


    datater[dataT.index] = dataT
    index = index+1
    line = file:read()
  end

  debugmsg("load terNubmer:"..(index-1))
  file:close()


end

local function loadBlock()
  local file = assert(io.open("data/terrain/block1.csv","r"))
  debugmsg("load: block data")


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
    dataT.flags = strDH[17] --还未改好
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


    datablock[dataT.index] = dataT
    index = index+1
    line = file:read()
  end

  debugmsg("load blockNubmer:"..(index-1))
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
  linkId()
end