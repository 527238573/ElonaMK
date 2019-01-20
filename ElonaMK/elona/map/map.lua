local Map = {
    --一些默认值
    w = 10,--宽
    h = 10, --高默认值，
    edge = 0,
    id = "null",
    saveType = "Map",--注册保存类型
    refreshMiniMap = false --刷新小地图
  }
  saveClass["Map"] = Map --注册保存类型
  
Map.__index = Map
Map.__newindex = function(o,k,v)
  if Map[k]==nil then error("使用了Map的意料之外的值。") else rawset(o,k,v) end
end

local empty = 0--{saveType = 0}
function Map.new(x,y,edge)
  edge = edge or 0 --默认0
  assert(type(x)=="number" and type(y)=="number" and x>3 and y>3)
  assert(edge>=0)
  x = math.floor(x)--保证整数
  y = math.floor(y)
  edge = math.floor(edge) --edge表示多出的无效区域的宽度。
  
  local o = {}
  o.w = x;o.h = y
  o.edge = edge
  o.realw = x+2*edge;o.realh = y+2*edge
  
  
  
  o.ter = {} --地型
  o.block = {} --地面上的物体 树，块等等。 trap合并入这一层。
  o.field = {} --地形效果。烟雾，火，一滩水，立场等等。
  
  o.unit = {} --单位，所站地格之上的。
  o.items = {} -- itemlist.一个list，包含多个物品。
  
  o.activeUnits = {} --活跃中的单位列表。
  --其他npc列表
  
  for i=1,o.realw*o.realh do --无效区域内只有ter 和block，做装饰用。
    o.ter[i] = 1 --默认为index为1 的类型 ，是泥土实地，最基本的ter类型
    o.block[i] = 1 --block为1代表空气，无东西，但block类型里存在这一类型。也就是说block也必须有值
  end
  for i=1,x*y do
    o.field[i] = empty --field是一个list，列出了地形上的所有field。按绘制优先级顺序。empty为空占位
    o.unit[i] = empty --unit指具体的unit。 empty空占位
    o.items[i] = empty --items是物品的列表。
  end
  
  
  
  setmetatable(o,Map)
  return o
end


function Map:inbounds(x,y)
  return x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1
end

function Map:inbounds_edge(x,y)
  return x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1
end



function Map:copyFrom(omap)
  if getmetatable(omap) ~= Map then
    error("copy map error")
  end
  
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

function Map:setTer(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.ter[y*self.realw+x+1] = index
end



function Map:getBlock(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.block[y*self.realw+x+1]
end

function Map:setBlock(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.block[y*self.realw+x+1] = index
end




return Map