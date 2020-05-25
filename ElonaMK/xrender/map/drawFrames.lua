








local function drawOneFrame(frame,map,camera)
  local img,quad = frame:getImgQuad()
  local screenx,screeny = camera:modelToScreen(frame.x+frame.dx,frame.y+frame.dy)
  
  local ftype = frame.type
  local ox = ftype.ox
  local oy = ftype.oy --以中心为点
  local scaleX = ftype.scaleFactor *camera.workZoom
  local scaleY = ftype.scaleFactor *camera.workZoom
  if frame.flipX then scaleX = scaleX*-1 end
  if frame.flipY then scaleY = scaleY*-1 end
  local rot = frame.rotation
  love.graphics.draw(img,quad,screenx,screeny,rot,scaleX,scaleY,ox,oy)--绘制
end



function render.drawFrames(camera,map)
  love.graphics.setColor(1,1,1)
  local list = map.frames
  for _,frame in ipairs(list) do
    if frame.time>=0 then
      drawOneFrame(frame,map,camera)
    end
  end
end


local function drawOneProjectile(proj,map,camera)
  local img,quad = proj:getImgQuad()
  local screenx,screeny = camera:modelToScreen(proj.x,proj.y)
  
  local ftype = proj.type
  local ox = ftype.ox
  local oy = ftype.oy --以中心为点
  local scaleX = ftype.scaleFactor *camera.workZoom
  local scaleY = ftype.scaleFactor *camera.workZoom
  local rot = proj.rotation
  love.graphics.draw(img,quad,screenx,screeny,rot,scaleX,scaleY,ox,oy)--绘制
end


function render.drawProjectiles(camera,map)
  love.graphics.setColor(1,1,1)
  local list = map.projectiles
  for _,proj in ipairs(list) do
    drawOneProjectile(proj,map,camera)
  end
end



