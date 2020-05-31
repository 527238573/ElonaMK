

local batch
local lastSX
local lastSY
local lastEX
local lastEY
local terDirty 

function render.initDrawTerrain()
  batch = love.graphics.newSpriteBatch(data.terImg)

end

function render.terDirty()
  terDirty = true
end


local function getsquare(map,x,y)
  if (x>=-map.edge and x<=map.w+map.edge-1 and y>=-map.edge and y<=map.h+map.edge-1) then
    return map:getTer(x,y)
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
--通过state code 确定使用哪个tile以及对应的rotation
--diretion: up =8 right=4 down =2 left =1

local function drawSquareToBatch(map,x,y)
  local tid= getsquare(map,x,y)
  if tid ==nil then return end
  local up  = getsquare(map,x,y+1)
  local right  = getsquare(map,x+1,y)
  local down  = getsquare(map,x,y-1)
  local left  = getsquare(map,x-1,y)
  
  local dx,dy = x-lastSX,y-lastSY
  local sx,sy = dx*64,(-dy-1)*64 --左上角相对坐标
  local scale = 2/data.terScale
  
  
  local info = data.ter[tid]
  if info.type=="edged" then
    --左上角
    if up== tid then
      if left ==tid then
        batch:add(info[5],sx,sy,0,scale,scale)
      else
        batch:add(info[4],sx,sy,0,scale,scale)
      end
    else
      if left ==tid then
        batch:add(info[2],sx,sy,0,scale,scale)
      else
        batch:add(info[1],sx,sy,0,scale,scale)
      end
    end
    --右上角
    if up== tid then
      if right ==tid then
        batch:add(info[5],sx+32,sy,0,scale,scale)
      else
        batch:add(info[6],sx+32,sy,0,scale,scale)
      end
    else
      if right ==tid then
        batch:add(info[2],sx+32,sy,0,scale,scale)
      else
        batch:add(info[3],sx+32,sy,0,scale,scale)
      end
    end
    --左下角
    if down== tid then
      if left ==tid then
        batch:add(info[5],sx,sy+32,0,scale,scale)
      else
        batch:add(info[4],sx,sy+32,0,scale,scale)
      end
    else
      if left ==tid then
        batch:add(info[8],sx,sy+32,0,scale,scale)
      else
        batch:add(info[7],sx,sy+32,0,scale,scale)
      end
    end
    --右下角
    if down== tid then
      if right ==tid then
        batch:add(info[5],sx+32,sy+32,0,scale,scale)
      else
        batch:add(info[6],sx+32,sy+32,0,scale,scale)
      end
    else
      if right ==tid then
        batch:add(info[8],sx+32,sy+32,0,scale,scale)
      else
        batch:add(info[9],sx+32,sy+32,0,scale,scale)
      end
    end
  else
    batch:add(info[1],sx,sy,0,scale,scale)
  end
  
  --drawHierarchy
  local edgelist
  
  local function checkEdge(edge,direction)
    if edge==nil then return end
    local edge_ter_info = data.ter[edge]
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
      local ox = 32/scale --一半，取中心点旋转
      local oy = 32/scale
      batch:add(quad,sx+32,sy+32,rotation,scale,scale,ox,oy) --直接使用常数
    end
  end
end


function render.drawTer(camera,map)

  --love.graphics.setColor(1,1,1)
  
  local zoom  = camera.workZoom
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)
  local starty = math.floor(camera.seen_minY/squareL)
  local endx = math.floor(camera.seen_maxX/squareL) 
  local endy = math.floor(camera.seen_maxY/squareL)
  if terDirty or startx~=lastSX or starty~=lastSY or endx~=lastEX or endy~=lastEY then
    --build batch
    terDirty = false
    lastSX = startx
    lastSY = starty
    lastEX = endx
    lastEY = endy
    batch:clear()
    for sx = startx,endx do
      for sy = starty,endy do
        drawSquareToBatch(map,sx,sy)
      end
    end
  end
  local x,y = camera:modelToScreen(startx*squareL,starty*squareL)
  love.graphics.draw(batch,x,y,0,zoom,zoom)
end




