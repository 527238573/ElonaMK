






local function getItemQuad(info)
  if info.useAnim then
    local totalTime = info.frameInterval*info.frameNum
    local ctime = love.timer.getTime() % totalTime
    local frame = math.floor(ctime/info.frameInterval)
  
    
    return info[frame+1]
  else
    return info[1]
  end
end





local function drawOneSquareItem(camera,x,y,map)
  if not map:inbounds(x,y) then return end 
  local list = map:getItemList(x,y,false)
  if list==nil then
    return 
  end --没有，物品，不用画
  local item1,item2,item3  = list:getLastThreeItem()
  
  if item1==nil then return end

  local altitude = map:getAltitude(x,y)


  local info
  local ax,ay
  local scale = camera.workZoom
  local ox,oy
  local quad
  local screenx,screeny

  if item1~= Item.manyItems then
    info = item1.type
    ax,ay = x*64+32,y*64+22+altitude
    if info.hanging then 
      ay= y*64+64 
    end
    ox = info.w/2 --锚点
    oy = info.h
    quad = getItemQuad(info)
    screenx,screeny = camera:modelToScreen(ax,ay)
    love.graphics.setColor(item1:getDrawColor())
    love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放
  end
  if item2==nil then return end
  info = item2.type
  ax,ay = x*64+32,y*64+22+altitude+12
  if info.hanging then 
    ay= y*64+64 
  end
  ox = info.w/2 --锚点
  oy = info.h
  quad = getItemQuad(info)
  screenx,screeny = camera:modelToScreen(ax,ay)
  love.graphics.setColor(item2:getDrawColor())
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放
  if item3==nil then return end
  info = item3.type
  ax,ay = x*64+32,y*64+22+altitude+24
  if info.hanging then 
    ay= y*64+64 
  end
  ox = info.w/2 --锚点
  oy = info.h
  quad = getItemQuad(info)
  screenx,screeny = camera:modelToScreen(ax,ay)
  love.graphics.setColor(item3:getDrawColor())
  love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放

  if item1== Item.manyItems then
    info = item1.type
    ax,ay = x*64+32,y*64+22+altitude
    if info.hanging then 
      ay= y*64+64 
    end
    ox = info.w/2 --锚点
    oy = info.h
    quad = getItemQuad(info)
    screenx,screeny = camera:modelToScreen(ax,ay)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放
  end

end



function render.drawLineItem(startx,endx,y,camera,map)
  love.graphics.setColor(1,1,1)
  for x = startx,endx do
    drawOneSquareItem(camera,x,y,map)
  end
end


