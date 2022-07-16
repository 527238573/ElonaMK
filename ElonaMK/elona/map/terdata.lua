


local terImg = data.newImage("data/terrain/terrain_wall.png")
data.terImg = terImg


local terImgScale = 1 --默认放大倍数
data.terScale = terImgScale


local twidth = terImg:getWidth()
local theight = terImg:getHeight()
data.terWhiteQuad = love.graphics.newQuad(11*32*terImgScale,16*32*terImgScale,32*terImgScale,32*terImgScale,twidth,theight)


data.blockImgs = {}

data.blockImgs["wall"] = data.newImage("data/terrain/walls.png")
data.blockImgs["block"] = data.newImage("data/terrain/block.png")


data.overmapImg = data.newImage("data/terrain/overmap.png")
--data.overmapImg:setFilter( "nearest", "nearest" )


data.addLoadingCvs("terID","data/terrain/ter.csv",nil)
data.addLoadingCvs("cliffID","data/terrain/cliff.csv",nil)
data.addLoadingCvs("slopeID","data/terrain/slope.csv",nil)
data.addLoadingCvs("blockID","data/terrain/block.csv",nil)
data.addLoadingCvs("oterID","data/terrain/overmap.csv",nil)



return function()
  --获得读取完成后的临时index表
  local ter_indexList = data.GetCVSIndexList("data/terrain/ter.csv")
  local cliff_indexList = data.GetCVSIndexList("data/terrain/cliff.csv")
  local slope_indexList = data.GetCVSIndexList("data/terrain/slope.csv")
  local block_indexList = data.GetCVSIndexList("data/terrain/block.csv")
  local oter_indexList = data.GetCVSIndexList("data/terrain/overmap.csv")


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
      data.insertQuad(tt,x*32*terImgScale,y*32*terImgScale,size*terImgScale,size*terImgScale,twidth,theight)
    end
    if dataT.type =="edged" then
      loadQuad(dataT.quadX,     dataT.quadY,    16,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY,    16,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY,    16,dataT)
      loadQuad(dataT.quadX,     dataT.quadY+0.5,16,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY+0.5,16,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY+0.5,16,dataT)
      loadQuad(dataT.quadX,     dataT.quadY+1,  16,dataT)
      loadQuad(dataT.quadX+0.5, dataT.quadY+1,  16,dataT)
      loadQuad(dataT.quadX+1,   dataT.quadY+1,  16,dataT)
    elseif dataT.type =="hierarchy" then
      loadQuad(dataT.quadX,dataT.quadY,32,dataT)
      loadQuad(dataT.quadX+1,dataT.quadY,32,dataT)
      loadQuad(dataT.quadX+2,dataT.quadY,32,dataT)
      loadQuad(dataT.quadX+3,dataT.quadY,32,dataT)
      loadQuad(dataT.quadX+4,dataT.quadY,32,dataT)
      loadQuad(dataT.quadX+5,dataT.quadY,32,dataT)
    else--single
      loadQuad(dataT.quadX,dataT.quadY,32,dataT)
    end
  end

  --整理cliff
  local cliff = {}
  local cliffIndex = {}
  data.cliff = cliff
  data.cliffIndex = cliffIndex
  for i=1,#cliff_indexList do
    local dataT = cliff_indexList[i]
    --插入新表
    assert(cliff[dataT.index]==nil)
    cliff[dataT.index] = dataT
    cliffIndex[dataT.id]=dataT.index
    --anchorX
    if dataT.anchorX<0 then
      dataT.anchorX = 16 *terImgScale  --w固定为32
    end
    local qx,qy = dataT.quadX,dataT.quadY
    --读取quad
    local function loadQuad(x,y,w,h,tt)
      data.insertQuad(tt,x*32*terImgScale,y*32*terImgScale,w*terImgScale,h*terImgScale,twidth,theight)
    end
    loadQuad(qx,      qy+0.5, 32,16,dataT)
    loadQuad(qx+1,    qy+0.5, 32,16,dataT)
    loadQuad(qx+2,    qy+0.5, 32,16,dataT)
    loadQuad(qx+3,    qy+0.5, 32,16,dataT)
    loadQuad(qx,      qy+1.5, 32,32,dataT)
    loadQuad(qx+1,    qy+1.5, 32,32,dataT)
    loadQuad(qx+2,    qy+1.5, 32,32,dataT)
    loadQuad(qx+3,    qy+1.5, 32,32,dataT)
    loadQuad(qx,      qy,     32,16,dataT)
    loadQuad(qx+1,    qy,     32,16,dataT)
    loadQuad(qx+2,    qy,     32,16,dataT)
    loadQuad(qx+3,    qy,     32,16,dataT)
    loadQuad(qx,      qy+1, 32,16,dataT)
    loadQuad(qx+1,    qy+1, 32,16,dataT)
    loadQuad(qx+2,    qy+1, 32,16,dataT)
    loadQuad(qx+3,    qy+1, 32,16,dataT)
  end
  
  --整理slope
  local slope = {}
  local slopeIndex = {}
  data.slope = slope
  data.slopeIndex = slopeIndex
  for i=1,#slope_indexList do
    local dataT = slope_indexList[i]
    --插入新表
    assert(slope[dataT.index]==nil)
    slope[dataT.index] = dataT
    slopeIndex[dataT.id]=dataT.index
    
    local qx,qy = dataT.quadX,dataT.quadY
    --读取quad
    local function loadQuad(x,y,w,h,tt)
      data.insertQuad(tt,x*32*terImgScale,y*32*terImgScale,w*terImgScale,h*terImgScale,twidth,theight)
    end
    loadQuad(qx,      qy,       32,16,dataT)--1
    loadQuad(qx+1,    qy,       32,16,dataT)--2
    loadQuad(qx+2,    qy,       32,16,dataT)--3
    loadQuad(qx+2,    qy+1.5,   32,16,dataT)--4
    loadQuad(qx,      qy+0.5,   32,32,dataT)--5
    loadQuad(qx+1,    qy+0.5,   32,32,dataT)--6
    loadQuad(qx+2,    qy+0.5,   32,32,dataT)--7
    loadQuad(qx+2,    qy+2,     32,32,dataT)--8
    loadQuad(qx,      qy+1.5,   32,16,dataT)--9
    loadQuad(qx,      qy+2,     32,16,dataT)--10
    loadQuad(qx,      qy+2.5,   32,16,dataT)--11
    loadQuad(qx,      qy+3,     32,32,dataT)--12
    loadQuad(qx+1,    qy+1.5,   32,16,dataT)--13
    loadQuad(qx+1,    qy+2,     32,16,dataT)--14
    loadQuad(qx+1,    qy+2.5,   32,16,dataT)--15
    loadQuad(qx+1,    qy+3,     32,32,dataT)--16
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
      data.insertQuad(tt,x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight())
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
      data.insertQuad(tt,x*32,y*32,w,h,imgw,imgh)
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