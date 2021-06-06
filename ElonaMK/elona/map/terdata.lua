

--先创建好表结构
data.ter = {} --index的数组
local terImg = love.graphics.newImage("data/terrain/terrain.png")
data.terImg = terImg
data.terScale = 1 --默认放大倍数

local twidth = terImg:getWidth()
local theight = terImg:getHeight()

data.blockImgs = {}

data.blockImgs["wall"] = love.graphics.newImage("data/terrain/walls.png")
data.blockImgs["block"] = love.graphics.newImage("data/terrain/block.png")
data.block ={} --index的数组

data.overmapImg = love.graphics.newImage("data/terrain/overmap.png")
--data.overmapImg:setFilter( "nearest", "nearest" )
data.oter = {} --index 的数组


return function()
  
  --id到ter的表，其他需要后续生成
  local linkF,ter_indexList = data.LoadCVS("terID","data/terrain/ter.csv",nil)
  local linkBlock,block_indexList = data.LoadCVS("blockID","data/terrain/block.csv",nil)
  local _,oter_indexList = data.LoadCVS("oterID","data/terrain/overmap.csv",nil)
  
  linkBlock()
  
  --整理ter
  local ter = {}
  local terIndex = {}
  data.ter = ter
  data.terIndex = terIndex
  for i=1,#ter_indexList do
    local dataT = ter_indexList[i]
    --插入新表
    assert(ter[dataT.index]==nil)
    ter[dataT.index] = dataT
    terIndex[dataT.id]=dataT.index
    --读取quad
    local function loadQuad(x,y,size,tt)
      local scale = data.terScale/2
      table.insert(tt.__source,love.graphics.newQuad(x*64*scale,y*64*scale,size*scale,size*scale,twidth,theight))
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
  end
  
  
  --整理block
  local block = {}
  local blockIndex = {}
  data.block = block
  data.blockIndex = blockIndex
  for i=1,#block_indexList do
    local dataT = block_indexList[i]
    --插入新表
    assert(block[dataT.index]==nil)
    block[dataT.index] = dataT
    blockIndex[dataT.id]=dataT.index
    --anchorX
    if dataT.anchorX<0 then
      dataT.anchorX = math.floor(dataT.w/2)
    end
    --img
    local img = data.blockImgs[dataT.img]
    assert(img,"error block img name")
    dataT.img = img
    --读取quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt.__source,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
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
  end
  
  --整理oter
  local imgw = data.overmapImg:getWidth()
  local imgh = data.overmapImg:getHeight()
  
  local oter = {}
  local oterIndex = {}
  data.oter = oter
  data.oterIndex = oterIndex
  for i=1,#oter_indexList do
    local dataT = oter_indexList[i]
    --插入新表
    assert(oter[dataT.index]==nil)
    oter[dataT.index] = dataT
    oterIndex[dataT.id]=dataT.index
    --anchorX Y
    dataT.anchorX = dataT.anchorX>=0 and dataT.anchorX  or math.floor(dataT.w/2)
    dataT.anchorY = dataT.anchorY>=0 and dataT.anchorY  or math.floor(dataT.h/2)
    --move_cost
    if dataT.move_cost==-666 then --默认值
      if dataT.layer==1 then
        dataT.move_cost = 100
      else
        dataT.move_cost = 0
      end
    end
    
    --读取quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt.__source,love.graphics.newQuad(x*32,y*32,w,h,imgw,imgh))
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

  end
  
end