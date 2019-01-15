


local function getblock(map,x,y)
  if map:inbounds_edge(x,y) then
    return map:getBlock(x,y)
  else
    return nil
  end
end


local function getBlockQuad(info)
  if info.type=="anim" then
    local totalTime = info.frameInterval*info.frameNum
    local ctime = love.timer.getTime() % totalTime
    local frame = math.floor(ctime/info.frameInterval)
    return info[frame+1]
  else
    return info[1]
  end
end




local function drawOneGroundBlock(camera,x,y,map)
  if not map:inbounds_edge(x,y) then return end 
  local bid = map:getBlock(x,y)
  if bid ==1 then return end --地格block为空
  local info = data.block[bid]
  if info.ground == false then return end 
  
  local scale = camera.workZoom
  local ox = info.anchorX --锚点
  local oy = info.h - info.anchorY
  local quad = getBlockQuad(info)
  local screenx,screeny = camera:modelToScreen(x*64+32,y*64)
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放
end



local wallIndex= {2,1,3,4,7,6,8,9}

local function drawOneSolidBlock(camera,x,y,map)
  if not map:inbounds_edge(x,y) then return end 
  local bid = map:getBlock(x,y)
  if bid ==1 then return end --地格block为空
  local info = data.block[bid]
  if info.ground == true then return end 
  
  
  if info.type=="wall" then
    local up  = getblock(map,x,y+1)
    local right  = getblock(map,x+1,y)
    local down  = getblock(map,x,y-1)
    local left  = getblock(map,x-1,y)
    local state_code = 1
    
    if left~=bid then state_code = state_code+1 end
    if right~=bid then state_code = state_code+2 end
    if down~=bid then state_code = state_code+4 end
    local quad = info[wallIndex[state_code]]
    local scale = camera.workZoom
    local ox = 32 --锚点
    local oy = 64- info.anchorY
    local screenx,screeny = camera:modelToScreen(x*64+32,y*64+32)
    love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)
    if up~=bid then 
      screenx,screeny = camera:modelToScreen(x*64,y*64+96- info.anchorY)
      love.graphics.draw(info.img,info[5],screenx,screeny,0,scale,scale)
    end
    
  else--普通物件
    local scale = camera.workZoom
    local ox = info.anchorX --锚点
    local oy = info.h - info.anchorY
    local quad = getBlockQuad(info)
    local screenx,screeny = camera:modelToScreen(x*64+32,y*64+32-10)
    love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)
  end
end


function render.drawGroundBlock(camera,map)
  love.graphics.setColor(1,1,1)
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-1
  local endx = math.floor(camera.seen_maxX/squareL)+1
  local endy = math.floor(camera.seen_maxY/squareL)+1 --多看一格，有溢出的部分。
  
  --从后向前，从左向右，
  
  for y = endy,starty,-1 do
    for x = startx,endx do
      drawOneGroundBlock(camera,x,y,map)
    end
  end
  
end


function render.drawAllSolidBlock(camera,map)
  love.graphics.setColor(1,1,1)
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-2 --多看2格，有的物体非常高
  local endx = math.floor(camera.seen_maxX/squareL)+1
  local endy = math.floor(camera.seen_maxY/squareL)+1 
  
  --从后向前，从左向右，
  
  for y = endy,starty,-1 do
    for x = startx,endx do
      drawOneSolidBlock(camera,x,y,map)
    end
  end
  
end


