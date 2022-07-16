local ffi = require("ffi")
local vertexcode = [[ 
    attribute float ZPosition;
    varying number fzpos;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        
        vec4 ret = transform_projection * vertex_position;
        ret.z = ZPosition;
        fzpos = ZPosition;
        return ret;
    }
]]
local pixelcode = [[
    varying number fzpos;
    extern vec4 bottomColor;
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        if (texcolor.a ==0) {
         discard;
        }
        number waterVal = smoothstep(0.05,0.1,fzpos);
        texcolor = mix(texcolor,bottomColor,waterVal);
        
        
        return texcolor * color;
    }
]]

local TerShader = love.graphics.newShader(pixelcode, vertexcode)
local water_vertexcode = [[ 
    attribute float ZPosition;
    extern number timePast;
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        
        
        
        vec4 ret = transform_projection * vertex_position;
        ret.z = ZPosition;
        ret.z -= sin(timePast*1) * 0.0015;
        return ret;
    }
]]
local water_pixelcode = [[
    extern number timePast;
    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
    
        vec2 flowDir = vec2(1.5,1.5);
        texture_coords.x += sin(timePast*1) *0.01*flowDir.x;
        texture_coords.y += sin(timePast*1) *0.03*flowDir.y;
        
        
        number modt = mod(timePast/3.0,3.0);
        number oIndex = floor(modt);
        number oNext = mod(oIndex+1,3.0);
        number oPast = fract(modt);
        
        number xadd = 1.0/3.0;
        vec4 orgColor = Texel(tex, vec2(texture_coords.x + xadd *oIndex,texture_coords.y));
        vec4 nextColor = Texel(tex, vec2(texture_coords.x + xadd *oNext,texture_coords.y));
        
        vec4 texcolor = mix(orgColor, nextColor,oPast);
        texcolor.a = 0.4;
        return texcolor * color;
    }
]]
local WaterShader = love.graphics.newShader(water_pixelcode, water_vertexcode)
local WaterImage = love.graphics.newImage("data/terrain/waterQuads.png")
WaterImage:setWrap("repeat")
WaterImage:setFilter("linear")
local water_quad = love.graphics.newQuad(0,0,32,32,WaterImage:getWidth(),WaterImage:getHeight())


local attachformat = {
  {"ZPosition", "float", 1}, -- The z position of each vertex.
}
local batchCount = 10000;--batch数量
local vertexData = love.data.newByteData(batchCount*4*4)
local vertexsArray = ffi.cast('float*', vertexData:getFFIPointer()) --数组，下标从0开始，总数batchCount*4，不能超出
local mesh = love.graphics.newMesh(attachformat, batchCount*4)

local waterBatchCount = 3000;
local waterVData = love.data.newByteData(waterBatchCount*4*4)
local waterVArray = ffi.cast('float*', waterVData:getFFIPointer())
local water_mesh = love.graphics.newMesh(attachformat, waterBatchCount*4)

local batch
local waterBatch

local spriteCount =0;
local waterCount = 0;


local lastSX
local lastSY
local lastEX
local lastEY
local terDirty 

local terScale = 2/data.terScale

local _cliffHigh = c.cliffHeight --固定常量，悬崖像素偏移值
local OneLayerZ = -0.05
local terUp = -0.000001
local empty_ter_id =17 --空地面，如果等于空，就不绘制ter

local bottomColor = {0.1,0.2,0.7,1}


function render.initDrawTerrain()
  --图片载入比较滞后
  batch = love.graphics.newSpriteBatch(data.terImg,batchCount)
  batch:attachAttribute("ZPosition",mesh)
  waterBatch = love.graphics.newSpriteBatch(WaterImage,waterBatchCount)
  waterBatch:attachAttribute("ZPosition",water_mesh)
end

function render.terDirty()
  terDirty = true
end


local function addToBatch(quad,x,y,z,rot,ox,oy,isWall)
  if (spriteCount >=batchCount) then
    debugmsg("spriteCount oversize!!!!!")
    return
  end
  local z2 = isWall and (z-OneLayerZ) or z
  batch:add(quad,x,y,rot,terScale,terScale,ox/terScale,oy/terScale)
  vertexsArray[spriteCount*4] = z    --lefttop
  vertexsArray[spriteCount*4+1] = z2  -- leftbottom
  vertexsArray[spriteCount*4+2] = z  --righttop
  vertexsArray[spriteCount*4+3] = z2 -- rightbottom
  spriteCount =spriteCount+1
end

local function addToWaterBatch(x,y)
  if (waterCount >=waterBatchCount) then
    debugmsg("waterCount oversize!!!!!")
    return
  end
  y=y+8
  local z = 0.03
  waterBatch:add(water_quad,x,y,0,2,2,0,0)
  waterVArray[waterCount*4] = z    --lefttop
  waterVArray[waterCount*4+1] = z  -- leftbottom
  waterVArray[waterCount*4+2] = z  --righttop
  waterVArray[waterCount*4+3] = z -- rightbottom
  waterCount =waterCount+1
end


local function addStairsToBatch(quad,x,y,z,left_l,right_l,top_l,bottom_l,isFlip)--四个bool值代表是否下沉
  if (spriteCount >=batchCount) then
    debugmsg("spriteCount oversize!!!!!")
    return
  end
  local z2 = z-OneLayerZ
  
  local xScale = isFlip and -terScale or terScale
  batch:add(quad,x,y,0,xScale,terScale)
  vertexsArray[spriteCount*4] =   (left_l or top_l) and z2 or z  --lefttop
  vertexsArray[spriteCount*4+1] = (left_l or bottom_l) and z2 or z  -- leftbottom
  vertexsArray[spriteCount*4+2] = (right_l or top_l) and z2 or z  --righttop
  vertexsArray[spriteCount*4+3] = (right_l or bottom_l) and z2 or z -- rightbottom
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
  local cid2,h2,pattern2
  if map:inbounds_edge(x,y) then
    cid2,h2,pattern2 = map:getCliffInfo(x,y)
    return cid2==cid,h2,pattern2,cid2
  else
    return true,curh,0,cid --外部为true
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

  local up_same,   up_h ,up_pattern,up_cid    =                         checkDirContinue(map,x,y+1,cliff_id,cliff_h)
  local right_same,right_h,right_pattern,right_cid  =                   checkDirContinue(map,x+1,y,cliff_id,cliff_h)
  local down_same, down_h,down_pattern,down_cid   =                     checkDirContinue(map,x,y-1,cliff_id,cliff_h)
  local left_same, left_h,left_pattern,left_cid   =                     checkDirContinue(map,x-1,y,cliff_id,cliff_h)
  local downleft_same, downleft_h,downleft_pattern,downleft_cid  =      checkDirContinue(map,x-1,y-1,cliff_id,cliff_h)
  local downright_same, downright_h,downright_pattern,downright_cid  =  checkDirContinue(map,x+1,y-1,cliff_id,cliff_h)
  --if down_id == nil then down_h = 2 end

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


  local function drawOneLayer(layer_h)
    local draw_quad =layer_h>=down_h  --是否否
    local draw_top = (layer_h == cliff_h) and  cliff_h>=(down_h-1)
    if not draw_quad and not draw_top then return end

    --测定悬崖与周边连接性
    local cliff_left = (left_pattern == 2  and  left_h == layer_h-1)
    local cliff_right = (right_pattern == 1 and right_h == layer_h-1)
    local cliff_down = (down_pattern ==3 and down_h == layer_h-1) 
    
    local c_up = up_h>=layer_h  or (up_pattern ==4 and up_h == layer_h-1) 
    local c_right = right_h>=layer_h or cliff_right
    local c_down = down_h>=layer_h  or cliff_down
    local c_left = left_h>=layer_h or cliff_left
    local c_dl = downleft_h>=layer_h or ( downleft_h == layer_h-1 and ((cliff_left and downleft_pattern == 2 ) or (cliff_down and downleft_pattern == 3)))
    local c_dr = downright_h>=layer_h or (downright_h == layer_h-1 and ((cliff_right and downright_pattern == 1) or (cliff_down and downright_pattern == 3)))
    if down_id==nil then c_dl,c_dr = c_left,c_right end--地图底边变化


    local dy  = -_cliffHigh* (layer_h-3) --layer h从0开始
    local layerZ = OneLayerZ * (layer_h-2)


    --绘制该layer的ter
    local function drawLayerTer()
      if layer_h == 0 then --draw最底部颜色
        --batch:setColor(bottomColor)
        --addToBatch(data.terWhiteQuad,sx,sy+dy-32,layerZ+terUp,0,0,0)--底部颜色
        --batch:setColor(1,1,1)
        return
      end


      local isEdge = map:isCliffEdge(x,y,layer_h)
      local dy  = -_cliffHigh* (layer_h-2)
      if not isEdge  and not (tid == empty_ter_id) then
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

        if up_h>=layer_h then 
          checkEdge(up_id,8,upColor,x,y+1) 
        end
        if (right_h>=layer_h) then 
          checkEdge(right_id,4,rightColor,x+1,y) 
        end
        if  down_h>=layer_h then
          checkEdge(down_id,2,downColor,x,y-1);
        end
        if (left_h>=layer_h) then
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
  
  
    local function drawStairs()
      if cliff_pattern == 0 then return end
      local stairs_info = cliff_info.slope
      
      local stairZ = OneLayerZ * (layer_h-1)
      local dy  = -_cliffHigh* (layer_h-2)
      
      local stair_h  = cliff_h+1
      if cliff_pattern == 1 then --
        --左高右低的楼梯
        
        local up_c = up_pattern == cliff_pattern and up_h == layer_h
        local down_c = down_pattern == cliff_pattern and down_h == layer_h or (down_h> layer_h and downleft_h> layer_h)
        local up_quad  = up_c and  14 or 13
        local down_quad  = down_c and  15 or 16
        addStairsToBatch(stairs_info[up_quad],sx+64,sy+dy-32,stairZ,true,false,false,false,true)
        addStairsToBatch(stairs_info[down_quad],sx+64,sy+dy,stairZ,true,false,false,not down_c,true)
        
      elseif cliff_pattern == 2 then
        --右高左低
        local up_c = up_pattern == cliff_pattern and up_h == layer_h 
        local down_c = down_pattern == cliff_pattern and down_h == layer_h or (down_h> layer_h and downright_h> layer_h)
        local up_quad  = up_c and  10 or 9
        local down_quad  = down_c and  11 or 12
        addStairsToBatch(stairs_info[up_quad],sx,sy+dy-32,stairZ,true,false,false,false,false)
        addStairsToBatch(stairs_info[down_quad],sx,sy+dy,stairZ,true,false,false,not down_c,false)
      
      elseif cliff_pattern == 3 then
        --上高下低
        local left_c = left_pattern == cliff_pattern and left_h ==layer_h
        local right_c = right_pattern == cliff_pattern and right_h == layer_h
        local t_quad = left_c and (right_c and 2 or 3) or (right_c and 1 or 4)
        addStairsToBatch(stairs_info[t_quad+4],sx,sy+dy-32,stairZ,false,false,false,true,false)
      
      elseif cliff_pattern == 4 then
        --下高上低
        local left_c = left_pattern == cliff_pattern and left_h ==layer_h
        local right_c = right_pattern == cliff_pattern and right_h == layer_h
        local t_quad = left_c and (right_c and 2 or 3) or (right_c and 1 or 4)
        addStairsToBatch(stairs_info[t_quad],sx,sy+dy,stairZ,false,false,true,false,false)
        
      end
    end-- end drawStairs
  
  


    local bottomIndex = {4,3,1,2,8,7,5,6}
    local topIndex = {12,11,9,10,16,15,13,14}

    local bottomCode = 1
    local topCode = 1+ (c_up and 4 or 0) + (c_left and 1 or 0) + (c_right and 2 or 0)

    if c_down then 
      bottomCode = 1 + ((c_dl and  c_left) and 1 or 0) + ((c_dr and c_right) and 2 or 0)
    else
      bottomCode = 5 + (c_left and 1 or 0) + (c_right and 2 or 0)
    end

    local useCliffInfo = cliff_info
    if layer_h<cliff_h and layer_h == down_h then useCliffInfo = data.cliff[down_cid] end
    if layer_h == cliff_h and cliff_pattern>0 then
      if layer_h == down_h and down_pattern==0 then  
        useCliffInfo = data.cliff[down_cid]
      elseif cliff_pattern ==1  and layer_h == right_h and right_pattern ==0 then --左侧适应
        useCliffInfo = data.cliff[right_cid]
      elseif cliff_pattern ==2 and layer_h == left_h  and left_pattern ==0 then --右侧适应
        useCliffInfo = data.cliff[left_cid]
      end
    end
    

    if draw_quad then addToBatch(useCliffInfo[bottomIndex[bottomCode]],sx+32,sy+dy,layerZ,0,32,0,not c_down) end--绘制主cord
    if draw_top then addToBatch(useCliffInfo[topIndex[topCode]],sx+32,sy+dy-32,layerZ,0,32,0) end--绘制主quad上半部分变换，为了拼接
    if cliff_h>layer_h and down_h == layer_h then
      drawLayerTer() --绘制低层裸漏出来的ter
    end
    if layer_h == cliff_h then
      drawLayerTer() --绘制顶部ter
      drawStairs()
    end
  end-- end drawOneLayer


  for i=0,math.min(6,cliff_h) do
    drawOneLayer(i)
  end
  
  if cliff_h<2 then
    addToWaterBatch(sx,sy)
    if down_id ==nil then
      addToWaterBatch(sx,sy+64)
    end
  end
end


function render.drawTer(camera,map)

  --love.graphics.setColor(1,1,1)

  local zoom  = 1
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)
  local starty = math.floor(camera.seen_minY/squareL)-3 --扩张的距离在0-6级高度有效
  local endx = math.floor(camera.seen_maxX/squareL) 
  local endy = math.floor(camera.seen_maxY/squareL)+2
  if terDirty or startx~=lastSX or starty~=lastSY or endx~=lastEX or endy~=lastEY then
    --build batch
    terDirty = false
    lastSX = startx
    lastSY = starty
    lastEX = endx
    lastEY = endy
    spriteCount = 0
    waterCount = 0
    batch:clear()
    waterBatch:clear()
    for sx = startx,endx do
      for sy = starty,endy do
        drawSquareToBatch(map,sx,sy)
      end
    end
    mesh:setVertices(vertexData,1, 4*spriteCount)
    mesh:flush()
    if(waterCount>0) then
      water_mesh:setVertices(waterVData,1,4*waterCount)
      water_mesh:flush()
    end
  end


  love.graphics.setDepthMode( "lequal", true)
  love.graphics.setShader(TerShader)
  TerShader:sendColor("bottomColor",bottomColor)
  local x,y = camera:modelToCanvas(startx*squareL,starty*squareL)

  love.graphics.draw(batch,x,y,0,1,1)
  
  love.graphics.setDepthMode( "lequal", false)
  love.graphics.setShader(WaterShader)
  WaterShader:send("timePast",love.timer.getTime())
  love.graphics.draw(waterBatch,x,y,0,1,1)
  love.graphics.setShader()
  love.graphics.setDepthMode( "always", false)
end




