local Overmap = {
    w = 10,--宽
    h = 10, --高默认值，
    id = "null",
    refreshMiniMap = false,
  }
saveMetaType("Overmap",Overmap)--注册保存类型

Overmap.__index = Overmap
Overmap.__newindex = function(o,k,v)
  if Overmap[k]==nil then error("使用了Overmap的意料之外的值。") else rawset(o,k,v) end
end

function Overmap.new(x,y)
  assert(type(x)=="number" and type(y)=="number" and x>8 and y>8)
  x = math.floor(x)--保证整数
  y = math.floor(y)
  
  local o = {}
  o.w = x;o.h = y
  o.layer1 = {} --地面
  o.layer2 = {} --地面上的物体  
  o.mark = {} --地面上的？？
  for i=1,x*y do
    o.layer1[i] = 2 --土地
    o.layer2[i] = 1 --空
    --mark动态，不填满
  end
  
  setmetatable(o,Overmap)
  return o
end

function Overmap:inbounds(x,y)
  return x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1
end

function Overmap:copyFrom(omap,sx,sy)
  if getmetatable(omap) ~= Overmap then
    error("copy map error")
  end
  sx =sx or 0
  sy =sy or 0
  self.id =omap.id
  for x = sx,self.w-1 do
    for y = sy,self.h-1 do
      if omap:inbounds(x-sx,y-sy) then
        self:setLayer1(omap:getLayer1(x-sx,y-sy),x,y)
        self:setLayer2(omap:getLayer2(x-sx,y-sy),x,y)
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



function Overmap:getLayer1(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  return self.layer1[y*self.w+x+1]
end

function Overmap:setLayer1(index,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  self.layer1[y*self.w+x+1] = index
end

function Overmap:getLayer2(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  return self.layer2[y*self.w+x+1]
end

function Overmap:setLayer2(index,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  self.layer2[y*self.w+x+1] = index
end

return Overmap