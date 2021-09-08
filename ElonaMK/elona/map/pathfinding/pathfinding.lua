
local ffi = require("ffi")
ffi.cdef[[
typedef struct { float g,f; int32_t parent;bool closed;} path_node;
]]

local huge = 999999
local Heap = require"elona/map/pathfinding/bheap"
local openlist = Heap()

local function getOrCreateMapNodes(map)
  if map.tmp_pathNodes ~=nil then return map.tmp_pathNodes end
  local nodeNum = map.w * map.h
  local nodes = ffi.new("path_node[?]", nodeNum)
  for i=0,nodeNum do 
    nodes[i].g = huge
    nodes[i].closed = false
  end
  map.tmp_pathNodes = nodes
  return nodes
end


local function indexToCord(map,index)
  local x = index% map.w
  local y = (index -x)/map.w
  return x,y
end

local function cordToIndex(map,x,y)
  return y*map.w+x
end




local abs = math.abs
local sqrt = math.sqrt
local sqrt2 = sqrt(2)
local max, min = math.max, math.min


local function heuristic(map,pos1,pos2) --启发性搜索
  local pos1x,pos1y = indexToCord(map,pos1)
  local pos2x,pos2y = indexToCord(map,pos2)
  local dx, dy = abs(pos1x-pos2x), abs(pos1y-pos2y)
  return min(dx,dy) * 1.414 + max(dx,dy) - min(dx,dy)
end






local function updateVertex(map,nmap,nIndex,neighbourIndex,endIndex,cost)
  if (nmap[nIndex].g + cost) < nmap[neighbourIndex].g then
    if nmap[neighbourIndex].g == huge then--未经过的点
      nmap[neighbourIndex].h = heuristic(map,neighbourIndex,endIndex)
    end
    nmap[neighbourIndex].g = nmap[nIndex].g + cost
    nmap[neighbourIndex].parent =nIndex
    nmap[neighbourIndex].f = nmap[neighbourIndex].g +heuristic(map,neighbourIndex,endIndex)
    openlist:push(neighbourIndex)--可能被push多次，但会被close
  end
end



local function findway(map,startIndex,endIndex)
  local nodemap = getOrCreateMapNodes(map)
  local function compare_min(aindex,bindex)
    return nodemap[aindex].f<nodemap[bindex].f
  end
  openlist:clear()
  openlist.sort = compare_min
  local toClear = {}

  nodemap[startIndex].g = 0
  nodemap[startIndex].f = heuristic(map,startIndex,endIndex)
  nodemap[startIndex].parent = -1
  openlist:push(startIndex)
  table.insert(toClear,startIndex)

  while not openlist:empty() do
    local nodeIndex = openlist:pop()
    nodemap[nodeIndex].closed = true
    if nodeIndex == endIndex then
      return nodeIndex,nodemap
    end
    local neighbours = finder.grid:getNeighbours(node, finder.walkable, finder.allowDiagonal, tunnel)
    for i, neighbour in ipairs(neighbours) do
      if not neighbour.closed then
        toClear[neighbour] = true
        if not neighbour.opened then
          neighbour.g = huge
          neighbour.parent = nil					
        end
        updateVertex(finder, node, neighbour, endNode, heuristic, overrideCostEval)
      end			
    end		
  end		

  return nil

end