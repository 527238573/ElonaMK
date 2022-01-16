local ffi = require("ffi")
local vertexcode = [[ 
    attribute float ZPosition;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        
        vec4 ret = transform_projection * vertex_position;
        ret.z = ZPosition;
        return ret;
    }
]]
local pixelcode = [[
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        if (texcolor.a ==0) {
         discard;
        }
        
        return texcolor * color;
    }
]]

local TerShader = love.graphics.newShader(pixelcode, vertexcode)

local attachformat = {
    {"ZPosition", "float", 1}, -- The z position of each vertex.
}
local batchCount = 10000;--batch数量
local vertexCount = batchCount*4
local vertexData = love.data.newByteData(vertexCount*4)
local vertexsArray = ffi.cast('float*', vertexData:getFFIPointer()) --数组，下标从0开始，总数vertexCount，不能超出
local mesh = love.graphics.newMesh(attachformat, batchCount*4)
local batch

local lastSX
local lastSY
local lastEX
local lastEY
local terDirty 

local terScale = 2/data.terScale
local spriteCount =0;

local _cliffHigh = c.cliffHeight --固定常量，悬崖像素偏移值
local OneLayerZ = -0.05
local terUp = -0.000001


function render.initDrawTerrain()
  --图片载入比较滞后
  batch = love.graphics.newSpriteBatch(data.terImg,batchCount)
  batch:attachAttribute("ZPosition",mesh)
end

function render.terDirty()
  terDirty = true
end


local function addToBatch(quad,x,y,z,rot,ox,oy)
  if (spriteCount >=batchCount) then
    debugmsg("spriteCount oversize!!!!!")
    return
  end
  
  batch:add(quad,x,y,rot,terScale,terScale,ox/terScale,oy/terScale)
  vertexsArray[spriteCount*4] = z
  vertexsArray[spriteCount*4+1] = z
  vertexsArray[spriteCount*4+2] = z
  vertexsArray[spriteCount*4+3] = z
  spriteCount =spriteCount+1
end








local function getsquare(map,x,y)
  if map:inbounds_edge(x,y) then
    return map:getTer(x,y),{map:getTerColor(x,y)}
  else
    return nil,nil
  end
end


local function checkDirContinue(map,x,y,cid,curh)
  local cid2,h2
  if map:inbounds_edge(x,y) then
    cid2,h2 = map:getCliffInfo(x,y)
    return cid2==cid,h2
  else
    return true,curh --外部为true
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


--绘制一个地格
local function drawSquareToBatch(map,x,y)
  local tid,tColor= getsquare(map,x,y)
  if tid ==nil then return end
  local sx,sy = (x-lastSX)*64,(-(y-lastSY)-1)*64 --左上角相对坐标
  
  --获取本地格cliff信息
  local cliff_id,cliff_h,cliff_pattern = map:getCliffInfo(x,y)
  
  local up_id,    upColor     =   getsquare(map,x,y+1)
  local right_id, rightColor  =   getsquare(map,x+1,y)
  local down_id,  downColor   =   getsquare(map,x,y-1)
  local left_id,  leftColor   =   getsquare(map,x-1,y)
  
  local up_same,   up_h     =   checkDirContinue(map,x,y+1,cliff_id,cliff_h)
  local right_same,right_h  =   checkDirContinue(map,x+1,y,cliff_id,cliff_h)
  local down_same, down_h   =   checkDirContinue(map,x,y-1,cliff_id,cliff_h)
  local left_same, left_h   =   checkDirContinue(map,x-1,y,cliff_id,cliff_h)
  local downleft_same, downleft_h  = checkDirContinue(map,x-1,y-1,cliff_id,cliff_h)
  local downright_same, downright_h  = checkDirContinue(map,x+1,y-1,cliff_id,cliff_h)
  
  
  local cliff_info = data.cliff[cliff_id]
  local ter_info = data.ter[tid]
  --上色。
  batch:setColor(tColor)
  
  local function drawOneTer(tsx,tsy,tsz)
    if ter_info.type=="edged" then
      --左上角
      local edgeCode = {1,2,4,5}
      local code = ((up_id== tid) and 2 or 0) + ((left_id ==tid) and 1 or 0)+1
      addToBatch(ter_info[edgeCode[code]],tsx,tsy,tsz,0,0,0)
      
      --右上角
      edgeCode = {3,2,6,5}
      code = ((up_id== tid) and 2 or 0) + ((right_id ==tid) and 1 or 0)+1
      addToBatch(ter_info[edgeCode[code]],tsx+32,tsy,tsz,0,0,0)
      
      
      --左下角
      edgeCode = {7,8,4,5}
      code = ((down_id== tid) and 2 or 0) + ((left_id ==tid) and 1 or 0)+1
      addToBatch(ter_info[edgeCode[code]],tsx,tsy+32,tsz,0,0,0)
      
      
      --右下角
      edgeCode = {9,8,6,5}
      code = ((down_id== tid) and 2 or 0) + ((right_id ==tid) and 1 or 0)+1
      addToBatch(ter_info[edgeCode[code]],tsx+32,tsy+32,tsz,0,0,0)
    else
      addToBatch(ter_info[1],tsx,tsy,tsz,0,0,0)
    end
  end-- end darwOneTer
  
  local function drawHierarchyEdge(tsx,tsy,tsz,cur_priority)
    --drawHierarchy
    local edgelist
    
    local function checkEdge(edge,direction,color)
      if edge==nil then return end
      local edge_ter_info = data.ter[edge]
      if(edge_ter_info.type =="hierarchy") and (edge_ter_info.priority > cur_priority) then
        --add edge
        if(edgelist==nil) then edgelist = {}end
        for i = 1,4 do 
          if(edgelist[i]==nil) then 
            edgelist[i] = {index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info,color = color}
            break
          elseif edgelist[i].index == edge then
            edgelist[i].val = edgelist[i].val+direction
            break
          elseif edgelist[i].p>edge_ter_info.priority then
            table.insert(edgelist,i,{index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info,color = color})
            break
          end
        end
      end
    end
    checkEdge(up_id,8,upColor);checkEdge(right_id,4,rightColor);checkEdge(down_id,2,downColor);checkEdge(left_id,1,leftColor)
    if edgelist~=nil then 
      for _,v in ipairs(edgelist) do
        local to_render_info = v.info
        local rotation = htileRad[v.val]
        local quad = to_render_info[htileIndex[v.val]]
        batch:setColor(v.color)
        addToBatch(quad,tsx+32,tsy+32,tsz,rotation,32,32)--一半，取中心点旋转
      end
    end
  end -- end drawHierarchyEdge
  
  local function drawOneLayer(layer_h)
    local draw_quad = layer_h>=down_h  --是否否
    local draw_top = (layer_h == cliff_h) and  cliff_h>=(down_h-1)
    if not draw_quad and not draw_top then return end
    
    --测定悬崖与周边连接性
    local c_up = up_h>=layer_h and up_same
    local c_right = right_h>=layer_h and right_same
    local c_down = down_h>=layer_h and down_same 
    local c_left = left_h>=layer_h and left_same
    local c_dl = downleft_h>=layer_h and downleft_same 
    local c_dr = downright_h>=layer_h and downright_same
    
    local dy  = -_cliffHigh* (layer_h-3) --layer h从0开始
    local layerZ = OneLayerZ * (layer_h-2)
    
    
    --绘制该layer的ter
    local function drawLayerTer()
      local isEdge = map:isCliffEdge(x,y,layer_h)
      local dy  = -_cliffHigh* (layer_h-2)
      if not isEdge then
        drawOneTer(sx,sy+dy,layerZ+terUp) --terup，深度稍微偏移一点点
      end
      
      --绘制
      local function drawHierarchyEdge(tsx,tsy,tsz,cur_priority)
        --drawHierarchy
        local edgelist
        
        local function checkEdge(edge,direction,color,tx,ty)
          if edge==nil then return end
          if map:isCliffEdge(tx,ty,layer_h) then return end
          
          local edge_ter_info = data.ter[edge]
          if(edge_ter_info.type =="hierarchy") and (edge_ter_info.priority > cur_priority) then
            --add edge
            if(edgelist==nil) then edgelist = {}end
            for i = 1,4 do 
              if(edgelist[i]==nil) then 
                edgelist[i] = {index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info,color = color}
                break
              elseif edgelist[i].index == edge then
                edgelist[i].val = edgelist[i].val+direction
                break
              elseif edgelist[i].p>edge_ter_info.priority then
                table.insert(edgelist,i,{index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info,color = color})
                break
              end
            end
          end
        end
        
        if up_same and up_h>=layer_h then 
          checkEdge(up_id,8,upColor,x,y+1) 
        end
        if right_same and (right_h==layer_h or (downright_same and downright_h == layer_h and right_h>layer_h)) then 
          checkEdge(right_id,4,rightColor,x+1,y) 
        end
        if down_same and down_h==layer_h then
          checkEdge(down_id,2,downColor,x,y-1);
        end
        if left_same and (left_h==layer_h or (downleft_same and downleft_h == layer_h and left_h>layer_h) ) then
          checkEdge(left_id,1,leftColor,x-1,y);
        end
        
        if edgelist~=nil then 
          for _,v in ipairs(edgelist) do
            local to_render_info = v.info
            local rotation = htileRad[v.val]
            local quad = to_render_info[htileIndex[v.val]]
            batch:setColor(v.color)
            addToBatch(quad,tsx+32,tsy+32,tsz,rotation,32,32)--一半，取中心点旋转
          end
        end
      end -- end drawHierarchyEdge
      
      drawHierarchyEdge(sx,sy+dy,layerZ+terUp,isEdge and 0 or ter_info.priority)
      
      
    end -- end drawLayerTer
    
    if draw_quad then
      local state_code = 1 --绘制quad的state
      local tophalf_code =1 --上半部分，可能需要
      
      if c_down then 
        if c_dl then 
          state_code = state_code+1 
          if c_left then tophalf_code = tophalf_code+1 end
        end
        if c_dr then 
          state_code = state_code+2 
          if c_right then tophalf_code = tophalf_code+2 end
        end
      else
        state_code = state_code+4 
        if c_left then state_code = state_code+1 end
        if c_right then state_code = state_code+2 end
      end
      
      local wallIndex= {4,3,1,2,8,7,5,6}
      local topHalfIndex = {15,14,13,15}
      
      addToBatch(cliff_info[wallIndex[state_code]],sx+32,sy+dy,layerZ,0,32,0)--绘制主cord
      if (c_down and tophalf_code ~= state_code) then
        addToBatch(cliff_info[topHalfIndex[tophalf_code]],sx+32,sy+dy,layerZ,0,32,0)--绘制主quad上半部分变换，为了拼接
      end
      if cliff_h>layer_h and down_h == layer_h then
        drawLayerTer()
      end
    end
    if draw_top and not c_up then
      local top_state = 1 + (c_down and 4 or 0) + (c_left and 1 or 0)+ (c_right and 2 or 0)
      local topWallIndex = {12,11,9,10,12,11,9,10}
      addToBatch(cliff_info[topWallIndex[top_state]],sx+32,sy+dy,layerZ,0,32,32)--绘制top衔接
    end
    
    if layer_h == cliff_h then
      drawLayerTer()
    end
  end-- end drawOneLayer
  
  
  --drawOneTer(sx,sy,0)
  --drawHierarchyEdge(sx,sy,0,ter_info.priority)
  for i=0,math.min(6,cliff_h) do
    drawOneLayer(i)
  end
end


function render.drawTer(camera,map)

  --love.graphics.setColor(1,1,1)
  
  local zoom  = 1
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)
  local starty = math.floor(camera.seen_minY/squareL)-2
  local endx = math.floor(camera.seen_maxX/squareL) 
  local endy = math.floor(camera.seen_maxY/squareL)+1
  if terDirty or startx~=lastSX or starty~=lastSY or endx~=lastEX or endy~=lastEY then
    --build batch
    terDirty = false
    lastSX = startx
    lastSY = starty
    lastEX = endx
    lastEY = endy
    spriteCount = 0
    batch:clear()
    for sx = startx,endx do
      for sy = starty,endy do
        drawSquareToBatch(map,sx,sy)
      end
    end
    mesh:setVertices(vertexData,1, 4*spriteCount)
    mesh:flush()
    
  end
  
  
  love.graphics.setDepthMode( "lequal", true)
  love.graphics.setShader(TerShader)
  
  local x,y = camera:modelToCanvas(startx*squareL,starty*squareL)
  
  love.graphics.draw(batch,x,y,0,1,1)
  love.graphics.setShader()
  
  local rx,ry = camera:modelToCanvas(-map.edge*squareL,0)
  local erx,ery = camera:modelToCanvas((map.w+map.edge)*squareL,_cliffHigh)
  --love.graphics.setDepthMode( "always", false)
  --love.graphics.setColor(0,0,0)
  --love.graphics.rectangle("fill",rx,ry,erx -rx,ry-ery);
  
  
  love.graphics.setDepthMode( "lequal", false)
end




