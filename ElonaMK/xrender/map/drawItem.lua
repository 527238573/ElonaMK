
--绘制UI上的item
--物品中心点的屏幕坐标
function render.drawUIItem(curItem,screenX,screenY,scale)
  local  item_img,item_quad,qw,qh,scaleFactor = curItem:getImgAndQuad()
  love.graphics.setColor(curItem:getDrawColor())
  love.graphics.draw(item_img,item_quad,screenX,screenY,0,scale*scaleFactor,scale*scaleFactor,qw/2,qh/2) --因为默认64×64
end



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


local function drawOneItem(camera,item,x,y,dy)
  
    local info = item.type
    local ax,ay = x*64+32,y*64+22+dy
    if info.hanging then 
      ay= y*64+64 
    end
    local scale = camera.workZoom*info.scaleFactor
    local ox = info.w/2 --锚点
    local oy = info.h
    local quad = getItemQuad(info)
    local screenx,screeny = camera:modelToScreen(ax,ay)
    love.graphics.setColor(item:getDrawColor())
    love.graphics.draw(info.img,quad,screenx,screeny,0,scale,scale,ox,oy)--绘制，根据位置（锚点默认正中底边）和缩放
  
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
    drawOneItem(camera,item1,x,y,altitude)
  end
  if item2==nil then return end
  drawOneItem(camera,item2,x,y,altitude+12)
  if item3==nil then return end
  drawOneItem(camera,item3,x,y,altitude+24)

  if item1== Item.manyItems then
    drawOneItem(camera,item1,x,y,altitude)
  end
end



function render.drawLineItem(startx,endx,y,camera,map)
  love.graphics.setColor(1,1,1)
  for x = startx,endx do
    drawOneSquareItem(camera,x,y,map)
  end
end


