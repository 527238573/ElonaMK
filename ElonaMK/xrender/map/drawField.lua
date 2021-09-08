

local function drawOneField(field,camera,x,y,map)
  local info= field.type
  local img = info.img
  if img==nil then return end --没有图的field，不画。

  local color = field.color
  love.graphics.setColor(color[1],color[2],color[3],color[4])
  local scale = 1 *info.scalefactor
  local ox = info.anchorX --锚点
  local oy = info.h - info.anchorY
  local sx = x*64+32
  local sy = y*64+32
  if info.drawType =="ground" then
    sy = y*64
  elseif info.drawType =="air" then
    sy = y*64+22
  end
  local screenx,screeny = camera:modelToCanvas(sx,sy)
  local quad 
  if info.type=="anim" then
    local totalTime = info.frameInterval*info.frameNum
    local ctime = (love.timer.getTime()+field.startRnd) % totalTime
    local frame = math.floor(ctime/info.frameInterval)
    quad = info[frame+1]
    love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,ox,oy)
  elseif info.type =="density" then
    local density = c.clamp(field.density,1,#info)
    quad= info[density]
    love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,ox,oy)
  elseif info.type =="edge" then
    local field_id = info.id
    local up = map:hasField(field_id,x,y+1)
    local down = map:hasField(field_id,x,y-1)
    local left = map:hasField(field_id,x-1,y)
    local right = map:hasField(field_id,x+1,y)
    if not (up or down or left or right) then
      quad= info[1]
      love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,ox,oy)
    else
      --左上角
      if up then
        if left then
          if map:hasField(field_id,x-1,y+1) then quad = info[6] else quad = info[14] end
        else
          quad = info[5]
        end
      else
        if left then quad = info[3] else quad = info[2] end
      end
      screenx,screeny = camera:modelToCanvas( x*64,y*64+64)
      love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,0,0)
      --右上角
      if up then
        if right then
          if map:hasField(field_id,x+1,y+1) then quad = info[6] else quad = info[13] end
        else
          quad = info[7]
        end
      else
        if right then quad = info[3] else quad = info[4] end
      end
      screenx,screeny = camera:modelToCanvas( x*64+32,y*64+64)
      love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,0,0)
      --左下角
      if down then
        if left then
          if map:hasField(field_id,x-1,y-1) then quad = info[6] else quad = info[12] end
        else
          quad = info[5]
        end
      else
        if left then quad = info[9] else quad = info[8] end
      end
      screenx,screeny = camera:modelToCanvas( x*64,y*64+32)
      love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,0,0)
      --右下角
      if down then
        if right then
          if map:hasField(field_id,x+1,y-1) then quad = info[6] else quad = info[11] end
        else
          quad = info[7]
        end
      else
        if right then quad = info[9] else quad = info[10] end
      end
      screenx,screeny = camera:modelToCanvas( x*64+32,y*64+32)
      love.graphics.draw(img,quad,screenx,screeny,0,scale,scale,0,0)
    end
  end
end


function render.drawLineFieldWithType(startx,endx,y,camera,map,drawType)
  for x = startx,endx do
    if map:inbounds(x,y) then 
      local list = map:getFieldList(x,y,false)
      if list then
        for i=1,#list do
          local field = list[i]
          if field:drawType() == drawType then
            drawOneField(field,camera,x,y,map)
          end
        end
      end
    end 
  end
end