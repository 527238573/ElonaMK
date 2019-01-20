

--输入坐标为模型坐标
local function drawLine(sx,sy,ex,ey,camera)
  if (sx>=camera.seen_minX and sx<=camera.seen_maxX) or (sy>=camera.seen_minY and sy<=camera.seen_maxY) then
  
    sx,sy = camera:modelToScreen(sx,sy)
    ex,ey = camera:modelToScreen(ex,ey)
  
    love.graphics.line(sx,sy,ex,ey)
  end
end





function render.drawMapDebugMesh(camera,map)--绘制网格
  
  local edge = map.edge or 0
  local startx = -edge
  local starty = -edge
  local endx = map.w+edge
  local endy = map.h+edge
  love.graphics.setColor(240/255,240/255,240/255,150/255)
  for x= startx,endx do
    drawLine(x*64,starty*64,x*64,endy*64,camera)
  end
  for y= starty,endy do
    drawLine(startx*64,y*64,endx*64,y*64,camera)
  end
  love.graphics.setColor(240/255,110/255,110/255,1)
  drawLine(0,0,map.w*64,0,camera)
  drawLine(0,0,0,map.h*64,camera)
  drawLine(map.w*64,0,map.w*64,map.h*64,camera)
  drawLine(0,map.h*64,map.w*64,map.h*64,camera)
  love.graphics.setColor(1,1,1)
end


function render.drawEditorRightMouse(camera)
  if editor.brushPos then
    local x,y = 64*editor.brushPos[1], 64*(editor.brushPos[2]+1)
    x,y = camera:modelToScreen(x,y)
    love.graphics.setColor(200/255,200/255,120/255,120/255) 
    love.graphics.rectangle("fill",x,y,64*camera.workZoom,64*camera.workZoom)
  end
  
end



function render.drawEditorEdgeShadow(camera,map)
  if map.edge<=0 then return end
  love.graphics.setColor(0,0,0,0.25) 
  
  local xleft = -map.edge *64
  local xright = (map.w + map.edge )*64
  local ileft = 0
  local iright = map.w*64
  
  local xup = (map.h+map.edge)*64
  local iup = (map.h)*64
  local xdown = -map.edge *64
  local idown = 0
  --rect up
  local sx,sy = camera:modelToScreen(xleft,xup)
  love.graphics.rectangle("fill",sx,sy,(xright-xleft)*camera.workZoom,(xup-iup)*camera.workZoom)
  --rect left
  sx,sy = camera:modelToScreen(xleft,iup)
  love.graphics.rectangle("fill",sx,sy,(ileft-xleft)*camera.workZoom,(iup-idown)*camera.workZoom)
  --rect right
  sx,sy = camera:modelToScreen(iright,iup)
  love.graphics.rectangle("fill",sx,sy,(xright-iright)*camera.workZoom,(iup-idown)*camera.workZoom)
  --rect down
  sx,sy = camera:modelToScreen(xleft,idown)
  love.graphics.rectangle("fill",sx,sy,(xright-xleft)*camera.workZoom,(idown-xdown)*camera.workZoom)
  
end