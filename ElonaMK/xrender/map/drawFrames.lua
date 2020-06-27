
local shader_rotUV = love.graphics.newShader[[
    extern number sin_r;
    extern number cos_r;
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {
      
      
      vec2 c = vec2(0.0);
      c.x = (tc.x-0.5)*cos_r - (tc.y-0.5)*sin_r +0.5;
      c.y = (tc.x-0.5)*sin_r + (tc.y-0.5)*cos_r +0.5;
      
      return Texel(texture, c);
    }]]

--c.y = (tc.x-0.5)*sin_r + (tc.y-0.5)*cos_r +0.5;


function render.drawOneFrame(frame,acx,acy,camera)
  local img,quad = frame:getImgQuad()
  local screenx,screeny = camera:modelToScreen(acx+frame.dx,acy+frame.dy)
  
  local ftype = frame.type
  local ox = ftype.ox
  local oy = ftype.oy --以中心为点
  local scaleX = ftype.scaleFactor *camera.workZoom*frame.scaleX
  local scaleY = ftype.scaleFactor *camera.workZoom*frame.scaleY
  if frame.flipX then scaleX = scaleX*-1 end
  if frame.flipY then scaleY = scaleY*-1 end
  local rot = frame.rotation
  local useRotUv = frame.rot_uv ~=0
  if useRotUv then
    love.graphics.setShader(shader_rotUV)
    shader_rotUV:send('cos_r', math.cos(frame.rot_uv))
    shader_rotUV:send('sin_r', math.sin(frame.rot_uv))
  end
  
  love.graphics.draw(img,quad,screenx,screeny,rot,scaleX,scaleY,ox,oy,frame.shearX,frame.shearY)--绘制
  
  if useRotUv then
    love.graphics.setShader()
  end
end



function render.drawFrames(camera,map)
  love.graphics.setColor(1,1,1)
  local list = map.frames
  for _,frame in ipairs(list) do
    if frame.time>=0 then
      render.drawOneFrame(frame,frame.x,frame.y,camera)
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



