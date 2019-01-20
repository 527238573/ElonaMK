


local batch
local lastSX
local lastSY
local lastEX
local lastEY
local terDirty 

function render.initDrawOvermap()
  batch = love.graphics.newSpriteBatch(data.overmapImg)

end


function render.oterDirty()
  terDirty = true
end

local function getsquare(overmap,x,y,layer)
  if overmap:inbounds(x,y) then
    if layer ==1 then 
      return overmap:getLayer1(x,y)
    else
      return overmap:getLayer2(x,y)
    end
  else
    return nil
  end
end
local r0 = math.rad(0)
local r9 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------1   2   3   4  5  6   7   8   9  A  B   C  D  E  F
local htileIndex= {4,  4,  3,  4, 5, 3,  6,  4,  3, 5, 6,  3, 6, 6, 2 }
local htileRad=   {r18,r9,r27,r0,r0,r18,r18,r27,r0,r9,r27,r9,r0,r9,r0}

-------------------0  1  2   3  4   5   6  7  8  9   A  B  C   D   E   F
--up---------------n  n  n   n  n   n   n  n  y  y   y  y  y   y   y   y
--right------------n  n  n   n  y   y   y  y  n  n   n  n  y   y   y   y
--down-------------n  n  y   y  n   n   y  y  n  n   y  y  n   n   y   y
--left-------------n  y  n   y  n   y   n  y  n  y   n  y  n   y   n   y
local roadInex =  {6, 5, 5,  2, 5,  1,  2, 3, 5, 2,  1, 3, 2,  3,  3,  4}
local roadRad  =  {r0,r0,r27,r9,r18,r0,r0,r27,r9,r18,r9,r0,r27,r9,r18,r0}


local function drawLayerToBatch(map,x,y,layer)
  local tid= getsquare(map,x,y,layer)
  if tid ==nil or tid ==1 then return end --1也要return
  local up  = getsquare(map,x,y+1,layer)
  local right = getsquare(map,x+1,y,layer)
  local down  = getsquare(map,x,y-1,layer)
  local left  = getsquare(map,x-1,y,layer)
  
  
  local dx,dy = x-lastSX,y-lastSY
  local sx,sy = dx*64,(-dy-1)*64 --左上角相对坐标
  
  local info = data.oter[tid]
  if info.type=="road" then
    local statecode = 1
    local function checkRoad(edge,state)
      if edge==nil then return end
      if edge== tid or data.oter[edge].flags["ROAD"]  then 
        statecode = statecode+state
      end
    end
    checkRoad(up,8);checkRoad(right,4);checkRoad(down,2);checkRoad(left,1)
    local sx,sy = dx*64+32,(-dy-1)*64+32 --中心点坐标
    local rotation = roadRad[statecode]
    local quad = info[roadInex[statecode]]
    local ox = 32 --一半，取中心点旋转
    local oy = 32 
    batch:add(quad,sx,sy,rotation,1,1,ox,oy) 
  else
    local sx,sy = dx*64+32,(-dy-1)*64+32 --中心点坐标
    local ox = info.anchorX
    local oy = info.h - info.anchorY
    batch:add(info[1],sx,sy,0,1,1,ox,oy)
  end
  
  --drawHierarchy
  local edgelist
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local edge_ter_info = data.oter[edge]
    if(edge_ter_info.type =="hierarchy") and (edge_ter_info.priority > info.priority) then
      --add edge
      if(edgelist==nil) then edgelist = {}end
      for i = 1,4 do 
        if(edgelist[i]==nil) then 
          edgelist[i] = {index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info}
          break
        elseif edgelist[i].index == edge then
          edgelist[i].val = edgelist[i].val+direction
          break
        elseif edgelist[i].p>edge_ter_info.priority then
          table.insert(edgelist,i,{index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info})
          break
        end
      end
    end
  end
  checkEdge(up,8);checkEdge(right,4);checkEdge(down,2);checkEdge(left,1)
  if edgelist~=nil then 
    for _,v in ipairs(edgelist) do
      local to_render_info = v.info
      local rotation = htileRad[v.val]
      local quad = to_render_info[htileIndex[v.val]]
      local ox = 32 --一半，取中心点旋转
      local oy = 32 
      batch:add(quad,sx+32,sy+32,rotation,1,1,ox,oy) --直接使用常数
    end
  end
  
end








function render.drawOvermap(camera,overmap)
  love.graphics.setColor(1,1,1)
  local zoom  = camera.workZoom
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-1
  local endx = math.floor(camera.seen_maxX/squareL) +1
  local endy = math.floor(camera.seen_maxY/squareL)+1
  if terDirty or startx~=lastSX or starty~=lastSY or endx~=lastEX or endy~=lastEY then
    --build batch
    terDirty = false
    lastSX = startx
    lastSY = starty
    lastEX = endx
    lastEY = endy
    batch:clear()
    
    for sy = endy,starty,-1 do
      for sx = startx,endx do
        drawLayerToBatch(overmap,sx,sy,1)
      end
    end
    for sy = endy,starty,-1 do
      for sx = startx,endx do
        drawLayerToBatch(overmap,sx,sy,2)
      end
    end
  end
  local x,y = camera:modelToScreen(startx*squareL,starty*squareL)
  love.graphics.draw(batch,x,y,0,zoom,zoom)
end