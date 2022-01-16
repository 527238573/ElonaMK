

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


function render.drawEditorRightMouse(camera,map)
  if editor.brushPos then
    local bx,by = editor.brushPos[1],editor.brushPos[2]
    local x,y = 64*bx, 64*(by+1)
    local diff = 0
    if map:inbounds_edge(bx,by) then
      diff = map:getCliffDiffHigh(bx,by)
    end
    
    local sx,sy = camera:modelToScreen(x,y)
    love.graphics.setColor(200/255,200/255,120/255,120/255) 
    love.graphics.rectangle("fill",sx,sy,64*camera.workZoom,64*camera.workZoom)
    if diff~=0 then
      sx,sy = camera:modelToScreen(x,y+diff)
      love.graphics.setColor(120/255,120/255,200/255,120/255) 
      love.graphics.rectangle("fill",sx,sy,64*camera.workZoom,64*camera.workZoom)
    end
    
  end
  
end

