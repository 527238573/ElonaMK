
local shadow_img = c.pic["unit_shadow"] 
function render.drawPlayer(camera,pl)
  
  local x,y = pl.x,pl.y
  local unit = pl.mc
  local status = pl.status--包含rate,dx ,dy ,face ,rot ,scaleX,scaleY,
  local anim = unit:get_unitAnim() --anim数据
  local overmapsacle = 1/2
  --画影子
  local shadow_x,shadow_y  = camera:modelToScreen(x*64 +32+status.dx,y*64+25+status.dy) --中心点
  local shadow_scale = 2*anim.shadowSize*overmapsacle
  love.graphics.setColor(1,1,1,0.7)
  love.graphics.draw(shadow_img,shadow_x,shadow_y,0,shadow_scale,shadow_scale,16,10)--绘制
  love.graphics.setColor(1,1,1,1)
  --画人物
  
  local ox = anim.anchorX
  local oy = anim.anchorY --以中心为点
  local sacleFactor = anim.scalefactor*overmapsacle
  
  local sx = x*64 +32 --格子中心点
  local sy = y*64 +25+oy*sacleFactor --格子中心点+上移图片中心点
  local scaleX = status.scaleX * sacleFactor *camera.workZoom
  local scaleY = status.scaleY * sacleFactor *camera.workZoom
  local rotation = status.rot
  --屏幕坐标
  local screenx,screeny = camera:modelToScreen(sx+status.dx,sy+status.dy+status.dz)
  
  local img,quad,flip = unit:getImgQuad(status)
  if flip then --水平翻转 
    scaleX =scaleX*-1
  end
  
  love.graphics.draw(img,quad,screenx,screeny,rotation,scaleX,scaleY,ox,oy)--绘制
end