
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
  
  
  --选取正确的quad。
  local animNum = anim.num--
  local len = animNum
  if(len>2 and anim.pingpong) then len = len*2 -2 end   -- 来回动画,总帧数更长
  local onerate = 1/len
  local userate = onerate *0.5 +status.rate--从第一帧正中分割
  local useframe = (math.floor(userate/onerate)+anim.stillframe-1) % len +1  --计算出正确的帧。如果stillframe～=1 则向前推进对应的帧数。
  if(anim.pingpong and useframe>animNum) then
    useframe = animNum - (useframe - animNum) --得到对应的帧。
  end
  --判断face方向的影响。 face： 123
  --                            884
  --                            765
  local face = status.face 
  if anim.type == "twoside" then 
    if face<=4 then
      useframe = useframe + animNum
      if face<=2 then
        scaleX =scaleX*-1
      end
    elseif face<=6 then
      scaleX =scaleX*-1
    end
  else --"oneside"
    if face>=2 and face<=5 then scaleX =scaleX*-1 end
  end
  local quad = anim[useframe]
  
  
  
  love.graphics.draw(anim.img,quad,screenx,screeny,rotation,scaleX,scaleY,ox,oy)--绘制
  
  
end