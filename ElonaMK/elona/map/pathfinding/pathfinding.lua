
local ffi = require("ffi")
ffi.cdef[[
typedef struct { float g, f; void* parent; bool closed;int x,y;  } node_t;
]]


local huge = 999999
local Heap = require"elona/map/pathfinding/bheap"


local nodemap
local openlist = Heap()


local cur_w,cur_h
local toClear

local function getOrCreateMapNodes(map)
  if map.tmp_pathNodes ~=nil then return map.tmp_pathNodes end
  local nodes  = {}
  for i=0,map.w-1 do
    nodes[i] = {}
    for j= 0,map.h-1 do
      local one_node =ffi.new("node_t")
      one_node.g = huge
      one_node.f =0
      one_node.x =i
      one_node.y =j
      one_node.parent = nil
      one_node.closed = false
      nodes[i][j] =one_node--{f=0,g=huge,parent = nil,closed =false,x=i,y=j}
    end
  end
  map.tmp_pathNodes = nodes
  return nodes
end





local abs = math.abs
local max, min = math.max, math.min


local function heuristic(pos1x,pos1y,pos2x,pos2y) --启发性搜索
  local dx, dy = abs(pos1x-pos2x), abs(pos1y-pos2y)
  return min(dx,dy) * 1.414 + max(dx,dy) - min(dx,dy)
end




local function getNeighbours(curNode,map)
		local neighbours = {}
    local costs = {}
    local nx,ny = curNode.x,curNode.y
    
    local function addoffset(ox,oy)
      local cost = map:move_cost(ox,oy)
      if cost<=0 then return end
      neighbours[#neighbours+1] = nodemap[ox][oy]
      if curNode.g< 10 then --考虑单位绕行
        local m_unit = map:unit_at(ox,oy)
        if m_unit then
          
          cost = cost +13-curNode.g
        end
      end
      costs[#costs+1] = cost/100
      
      
      
      
    end
    addoffset(nx-1,ny)
    addoffset(nx+1,ny)
    addoffset(nx,ny-1)
    addoffset(nx,ny+1)
    addoffset(nx-1,ny+1)
    addoffset(nx-1,ny-1)
    addoffset(nx+1,ny+1)
    addoffset(nx+1,ny-1)
    
    return neighbours,costs
  end


local function findway(map,startNode,endNode,maxG)
  --返回值，true找到精准路线，并返回node false，未找到精准点，返回f最小点
  --maxG代表最远走出的步数
  
  
  startNode.g = 0
  startNode.f = heuristic(startNode.x,startNode.y,endNode.x,endNode.y)
  startNode.parent = nil
  openlist:push(startNode)
  toClear[startNode] = true
  --debugmsg("push node:"..startNode.x..","..startNode.y)
  local nearestNode = startNode
  local nearestF = startNode.f
  
  
  while not openlist:empty() do
    
    local curNode= openlist:pop()
    --debugmsg("pop node:"..curNode.x..","..curNode.y)
    
    curNode.closed = true
    if curNode == endNode then --找到路
      return 2,curNode
    end
    if curNode.g>maxG then--找了一半
      return 1,curNode,nearestNode
    end
    
    
    if curNode.f<nearestF then
      nearestNode = curNode
    end
    
    
    local neighbours,costs = getNeighbours(curNode,map)
    for i, neighbour in ipairs(neighbours) do
      if not neighbour.closed then
        local cost = costs[i]
        if (curNode.g + cost) < neighbour.g then
          neighbour.g= curNode.g + cost
          neighbour.parent =curNode
          neighbour.f = neighbour.g +heuristic(neighbour.x,neighbour.y,endNode.x,endNode.y)
          --debugmsg("push node:"..neighbour.x..","..neighbour.y.." f:"..neighbour.f)
          
          toClear[neighbour] = true
          openlist:push(neighbour)--可能被push多次，但会被close
        end
      end			
    end	
  end		
  return 0,nearestNode --没有路
end



--nearDis 可接受的接近距离
function Map:pathFind(x1,y1,x2,y2,maxG,nearDis)
  assert(self:inbounds(x1,y1))
  x2,y2 = self:clampBounds(x2,y2)
  
  
  nodemap = getOrCreateMapNodes(self)
  cur_w,cur_h = self.w,self.h
  toClear = {}
  openlist:clear()
  
  local res,resNode,nearestNode = findway(self,nodemap[x1][y1],nodemap[x2][y2],maxG)
  if res ==1 then
    
    if maxG>2*c.dist_2d(x1,y1,x2,y2) and nearDis then
      if nearDis>0 then
        local nearDistance =  c.dist_2d(nearestNode.x,nearestNode.y,x2,y2)
        if nearDistance<=nearDis then
          resNode = nearestNode
        end
      end
    else
      
    end
  end
  
  if res ==0 then
    debugmsg(string.format("没找到路:%d,%d -> %d,%d",x1,y1,resNode.x,resNode.y))
  elseif res==1 then
    debugmsg(string.format("找了一半:%d,%d -> %d,%d",x1,y1,resNode.x,resNode.y))
  elseif res ==2 then
    debugmsg(string.format("找到了路:%d,%d -> %d,%d",x1,y1,resNode.x,resNode.y))
  end
  
  --
  local path  = Path.new()
  local xlist,ylist= path.x,path.y
  xlist[1] = resNode.x
  ylist[1] = resNode.y
  while not (resNode.parent==nil) do
    resNode = ffi.cast("node_t*", resNode.parent)
    local x,y = resNode.x,resNode.y
    xlist[#xlist+1] = x
    ylist[#ylist+1] = y
  end
  path.length = #xlist
  --清除
  for k,v in pairs(toClear) do
    k.g =huge
    k.closed = false
    k.parent = nil
  end
  
  return res,path
end
