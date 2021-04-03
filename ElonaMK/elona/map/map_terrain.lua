local bit = require("bit")
--ter，block等在此文件外不可访问
local NumToColor,ColorToNum,Color_111--提前声明，local function ，常量

--初始化Map的一部分
function Map.initTerAndBlock(o)
  o.ter = {} --地型
  o.block = {} --地面上的物体 树，块等等。 trap合并入这一层。
  o.terColor ={} --染色地格，block染色
  o.blockColor = {}
  
  for i=1,o.realw*o.realh do --无效区域内只有ter 和block，做装饰用。
    o.ter[i] = 1 --默认为index为1 的类型 ，是泥土实地，最基本的ter类型
    o.block[i] = 1 --block为1代表空气，无东西，但block类型里存在这一类型。也就是说block也必须有值
    o.terColor[i]  =Color_111--默认填为白色
    o.blockColor[i] = Color_111
  end
end

function Map:reloadOldVersionTer()
  if self.terColor ==nil then
    self.terColor ={} --染色地格，block染色
    self.blockColor = {}
    for i=1,self.realw*self.realh do 
      self.terColor[i]  =Color_111--默认填为白色
      self.blockColor[i] = Color_111
    end
  end
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



function Map:copyFrom(omap)
  if getmetatable(omap) ~= Map then
    error("copy map error")
  end
  self.transparent_dirty = true
  
  self.id =omap.id
  for x = -self.edge,self.w+self.edge-1 do
    for y = -self.edge,self.h+self.edge-1 do
      if omap:inbounds_edge(x,y) then
        self:setTer(omap:getTer(x,y),x,y)
        self:setBlock(omap:getBlock(x,y),x,y)
      end
    end
  end
  --[[
  for x = 0,self.w-1 do
    for y = 0,self.h-1 do
      if omap:inbounds(x,y) then
        
      end
    end
  end
  --]]
  
end


--坐标，0，0为左下角。向上是Y正，向右是X正
function Map:getTer(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.ter[y*self.realw+x+1]
end

function Map:getBlock(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.block[y*self.realw+x+1]
end

--set，运行时使用。editor也在用
function Map:setTer(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.ter[y*self.realw+x+1] = index
end

function Map:setBlock(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.block[y*self.realw+x+1] = index
  self.transparent_dirty = true
end

--地图生成专用。坐标是real坐标。可以不做检查。
function Map:genTer(id,x,y)
   assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
   self.ter[y*self.realw+x+1] = id
end
function Map:genAllTer(id)
  for i=1,self.realw*self.realh do self.ter[i] = id end
end


function Map:genBlock(id,x,y)
   assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
   self.block[y*self.realw+x+1] = id
end

function Map:getBlock_real(x,y) --生成时候的读取
  assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
  return self.block[y*self.realw+x+1]
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
  x = x+self.edge
  y= y+self.edge
  local r,g,b = NumToColor(self.terColor[y*self.realw+x+1])
  return r,g,b
end
function Map:getBlockColor(x,y)
  x = x+self.edge
  y= y+self.edge
  local r,g,b = NumToColor(self.blockColor[y*self.realw+x+1])
  return r,g,b
end
function Map:setTerColor(r,g,b,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.terColor[y*self.realw+x+1] = ColorToNum(r,g,b)
end
function Map:setBlockColor(r,g,b,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.blockColor[y*self.realw+x+1] = ColorToNum(r,g,b)
end





function Map:getAltitude(x,y)
  local bid = self:getBlock(x,y)
  return data.block[bid].altitude
end




function Map:can_pass(x,y)
  if not self:inbounds(x,y) then return false end
  x = x+self.edge
  y= y+self.edge
  local tid = self.ter[y*self.realw+x+1]
  local bid = self.block[y*self.realw+x+1]
  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  return binfo.pass
end


function Map:move_cost(x,y)
  if not self:inbounds(x,y) then return -1 end
  x = x+self.edge
  y= y+self.edge
  local tid = self.ter[y*self.realw+x+1]
  local bid = self.block[y*self.realw+x+1]
  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  --if bid==nil then error("x,y:"..x.." "..y) end
  
  if not binfo.pass then return -1 end
  local cost = tinfo.move_cost + binfo.move_cost
  return cost
end

--CONTAINER
--LOCKED --
function Map:hasFlag(flag,x,y)
  
  
end
