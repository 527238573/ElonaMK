



local function drawOneSquareUnit(camera,x,y,map)
  if not map:inbounds(x,y) then return end 
  local unit = map:unit_at(x,y)
  if unit ==nil then return end
  
  local status = unit:get_anim_status()--包含rate,dx ,dy ,face ,rot ,scaleX,scaleY,
  local anim = unit:get_unitAnim() --anim数据
  
  local ox = anim.anchorX
  local oy = anim.anchorY --以中心为点
  local sacleFactor = anim.scalefactor
  
  local sx = x*64 +32 --格子中心点
  local sy = y*64 +32+oy*sacleFactor --格子中心点+上移图片中心点
  local scaleX = status.scaleX * sacleFactor *camera.workZoom
  local scaleY = status.scaleY * sacleFactor *camera.workZoom
  local rotation = status.rot
  --屏幕坐标
  local screenx,screeny = camera:modelToScreen(sx+status.dx,sy+status.dy)
  
  
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




function render.drawLineUnit(startx,endx,y,camera,map)
  love.graphics.setColor(1,1,1)
  for x = startx,endx do
    drawOneSquareUnit(camera,x,y,map)
  end
end