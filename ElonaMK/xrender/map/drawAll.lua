


function render.drawGround(camera,map)
  
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-1
  local endx = math.floor(camera.seen_maxX/squareL)+1
  local endy = math.floor(camera.seen_maxY/squareL)+1 --多看一格，有溢出的部分。
  
  --从后向前，从左向右，
  
  for y = endy,starty,-1 do
    render.drawLineGroundBlock(startx,endx,y,camera,map)
    render.drawLineFieldWithType(startx,endx,y,camera,map,"ground")
  end
end



function render.drawSolid(camera,map)
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-2 --多看2格，有的物体非常高
  local endx = math.floor(camera.seen_maxX/squareL)+1
  local endy = math.floor(camera.seen_maxY/squareL)+1 
  
  --从后向前，从左向右，
  
  for y = endy,starty,-1 do
    render.drawLineSolidBlock(startx,endx,y,camera,map)
    render.drawLineItem(startx,endx,y,camera,map)
    render.drawLineFieldWithType(startx,endx,y,camera,map,"solid")
    render.drawLineUnit(startx,endx,y,camera,map)
    render.drawLineFieldWithType(startx,endx,y,camera,map,"air")
  end
end