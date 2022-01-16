local bit = require("bit")
local ffi = require("ffi")

--ter，block等在此文件外不可访问
local NumToColor,ColorToNum,Color_111--提前声明，local function ，常量

--初始化Map的一部分
function Map.initTerAndBlock(o)
  o.ter = ffi.new("uint16_t[?]",o.realw*o.realh) --地型
  o.block = ffi.new("uint16_t[?]",o.realw*o.realh)--地面上的物体 树，块等等。 trap合并入这一层。
  o.cliff = ffi.new("uint8_t[?]",o.realw*o.realh) --悬崖类型
  o.height = ffi.new("uint8_t[?]",o.realw*o.realh) --高度类型 前五位bit 记录 高度，后三位bit记录 （=0平地，>0 斜坡)
  
  for i=0,o.realw*o.realh-1 do --无效区域内只有ter 和block，做装饰用。
    o.ter[i] = 1 --默认为index为1 的类型 ，是泥土实地，最基本的ter类型
    o.block[i] = 1 --block为1代表空气，无东西，但block类型里存在这一类型。也就是说block也必须有值
    o.cliff[i] = 1--悬崖
    o.height[i] = 2*8 --平地默认2级高度
  end
  
  for x=2,5 do
    for y =2,5 do
      o.height[y*o.realw+x] = 3 *8
    end
  end
  
  for x=3,4 do
    for y =2,5 do
      o.height[y*o.realw+x] = 4 *8
    end
  end
  
end

function Map:writeCdata(filehandle,cobj,valname)
  if valname == "ter" or valname == "block" then
    filehandle:write("\"")
    for i=0,self.realw*self.realh-1 do
      local uint16 = cobj[i]
      filehandle:write(string.format("%04X",uint16))
    end
    filehandle:write("\"")
  else
    error("unknow Cdata:"..valname)
  end
end

function Map:decodeTerrainCdata()
  --debugmsg("maploaded")
  if self.blockColor then self.blockColor = nil end
  if self.terColor then self.terColor = nil end
  --self.blockColor = nil
  --self.terColor = nil
  if type(self.ter)~="string" then return end--不需要decode，已经是cdata
  
  local s_ter = self.ter
  local s_block = self.block
  assert(string.len(s_ter) == self.realw*self.realh*4)
  assert(string.len(s_block) == self.realw*self.realh*4)
  
  self.ter = ffi.new("uint16_t[?]",self.realw*self.realh) --地型
  self.block = ffi.new("uint16_t[?]",self.realw*self.realh)--地面上的物体 树，块等等。 trap合并入这一层。
  
  for i=0,self.realw*self.realh-1 do 
    self.ter[i] = tonumber(string.sub(s_ter,1+4*i,4+4*i),16)
    self.block[i] = tonumber(string.sub(s_block,1+4*i,4+4*i),16)
  end
  
end

function Map:reloadOldVersionTer()
  --兼容性代码，待有新变化就修改
  
end


function Map:inbounds(x,y)
  return x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1
end

function Map:inbounds_edge(x,y)
  return x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1
end

function Map:inbounds_real(x,y)
  return x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1
end

function Map:clampBounds(x,y)
  return c.clamp(math.floor(x),0,self.w-1),c.clamp(math.floor(y),0,self.h-1)
end



function Map:copyFrom(omap,offsetX,offsetY)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  if omap.saveType ~= "Map" then
    error("copy map error")
  end
  self.squareInfo_dirty = true
  
  self.id =omap.id
  for x = -self.edge,self.w+self.edge-1 do
    for y = -self.edge,self.h+self.edge-1 do
      local destX = x+ offsetX
      local destY = y+offsetY
      
      if omap:inbounds_edge(destX,destY) then
        self:setTer(omap:getTer(destX,destY),x,y)
        self:setBlock(omap:getBlock(destX,destY),x,y)
      end
    end
  end
end


--坐标，0，0为左下角。向上是Y正，向右是X正
function Map:getTer(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.ter[y*self.realw+x]
end

function Map:getBlock(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.block[y*self.realw+x]
end

--set，运行时使用。editor也在用
function Map:setTer(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.ter[y*self.realw+x] = index
  self.squareInfo_dirty = true
end

function Map:setBlock(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.block[y*self.realw+x] = index
  self.squareInfo_dirty = true
end

--地图生成专用。坐标是real坐标。可以不做检查。
function Map:genTer(id,x,y)
   assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
   self.ter[y*self.realw+x] = id
end
function Map:genAllTer(id)
  for i=0,self.realw*self.realh-1 do self.ter[i] = id end
end


function Map:genBlock(id,x,y)
   assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
   self.block[y*self.realw+x] = id
end

function Map:getBlock_real(x,y) --生成时候的读取
  assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
  return self.block[y*self.realw+x]
end

--返回clipid和高度 和样式
function Map:getCliffInfo(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  local sq_index = y*self.realw+x
  local cliff = self.cliff[sq_index]
  local o_height =  self.height[sq_index]
  
  return cliff,bit.rshift(o_height,3),o_height%8
end


function Map:setCliff(index,height,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1 and height>=0 and height<16)
  x = x+self.edge
  y= y+self.edge
  self.cliff[y*self.realw+x] = index
  self.height[y*self.realw+x] = height *8
  self.squareInfo_dirty = true
end
--只返回高度偏移（模型空间）
local _cliffHight = c.cliffHeight
function Map:getCliffDiffHigh(x,y)
  assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
  return (bit.rshift(self.height[y*self.realw+x],3) -2)*_cliffHight
end


local checkAltList = {
  x={-1,-1,-1,0,0,1,1,1},
  y={-1,0,1,-1,1,-1,0,1},
}
--返回是否是悬崖边缘。只有周围有比其低的地面，或者不同的cliff，算是cliffedge
function Map:isCliffEdge(x,y,h)
  local height = self.height
  local cliff = self.cliff
  local this_cid = cliff[y*self.realw+x]
  
  local function getA(x,y)
    if x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1 then
      return bit.rshift(height[y*self.realw+x],3),cliff[y*self.realw+x]
    end
    return h,this_cid
  end
  for i=1,8 do 
    local dx,dy = checkAltList.x[i],checkAltList.y[i]
    local alt,cid = getA(x+dx,y+dy)
    if alt<h or cid~= this_cid then
      return true
    end
  end
  return false
end


--Color部分
function NumToColor(num)
  local r =bit.band(bit.arshift(num,16), 0xff)/255
  local g =bit.band(bit.arshift(num,8), 0xff)/255
  local b =bit.band(num, 0xff)/255
  return r,g,b
end

function ColorToNum(r,g,b)
  r = bit.lshift(bit.band(r*255, 0xff),16)
  g = bit.lshift(bit.band(g*255, 0xff),8)
  b = bit.band(b*255, 0xff)
  return r+g+b
end
Color_111 = ColorToNum(1,1,1)

--不用检查因为用的很少
function Map:getTerColor(x,y)
  --x = x+self.edge
  --y= y+self.edge
  --local r,g,b = NumToColor(self.terColor[y*self.realw+x])
  return 1,1,1
end
function Map:getBlockColor(x,y)
  --x = x+self.edge
  --y= y+self.edge
  --local r,g,b = NumToColor(self.blockColor[y*self.realw+x])
  return 1,1,1
end

function Map:getTerInfo(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y = y+self.edge
  return data.ter[self.ter[y*self.realw+x]]
end

function Map:getBlockInfo(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y = y+self.edge
  return data.block[self.block[y*self.realw+x]]
end





function Map:getAltitude(x,y)
  local bid = self:getBlock(x,y)
  return data.block[bid].altitude
end



--CONTAINER
--LOCKED --
function Map:hasFlag(flag,x,y)
  
  
end

--攻击地格，
function Map:bash_square(x,y,power)
  
  
end
