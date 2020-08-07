



local function drawUnitFrames(unit,underUnit,acx,acy,camera)
  local list = unit.frames
  for _,frame in ipairs(list) do
    if frame.time>=0 and frame.underUnit == underUnit then
      render.drawOneFrame(frame,acx,acy,camera)
    end
  end
end

local lifebar_q = c.pic["lifebar_quads"]
local function drawUnitLifebar(unit,status,camera,x,y)

  local life_rate = unit:getHPRate()
  if life_rate==1 then return end

  local lifebarquad = lifebar_q.green
  if unit:isInEnemyFaction() then lifebarquad =lifebar_q.red end


  local sx = x*64 +2 --格子中心点
  local sy = y*64 +30
  local lw = camera.workZoom *unit:getHPRate()
  local lh = camera.workZoom
  local acx,acy = sx+status.dx,sy+status.dy+status.dz
  local screenx,screeny = camera:modelToScreen(acx,acy)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(lifebar_q.img,lifebarquad,screenx,screeny,0,lw,lh,0,0)
end

local function drawDelayBar(unit,camera,screenx,screeny)
  if unit.delay_bar<=0 then return end
  local zoom = camera.workZoom
  local precent  = c.clamp(unit.delay_bar/unit.delay_barmax,0,1)
  love.graphics.setColor(0.65,0.65,1)
  love.graphics.rectangle("fill",screenx-32*zoom,screeny+4*zoom,64*zoom,14*zoom)
  love.graphics.setColor(0.4,0.4,1)
  love.graphics.rectangle("fill",screenx-30*zoom,screeny+6*zoom,60*precent*zoom,10*zoom)
  love.graphics.setColor(1,1,1)
  if zoom==1 and unit.delay_barname~="" then
    love.graphics.setFont(c.font_c14)
    love.graphics.printf(unit.delay_barname,screenx-32,screeny+3,64,"center")
  end
end



local shadow_img = c.pic["unit_shadow"] 

local function drawOneSquareUnit(camera,todraw)
  local x,y = todraw.x,todraw.y
  local unit = todraw.unit
  local status = todraw.status--包含rate,dx ,dy ,face ,rot ,scaleX,scaleY,
  local anim = unit:get_unitAnim() --anim数据

  --画影子
  local shadow_x,shadow_y  = camera:modelToScreen(x*64 +32+status.dx,y*64+32+status.dy) --中心点
  local shadow_scale = 2*anim.shadowSize
  render.setUnitShadowColor()
  love.graphics.draw(shadow_img,shadow_x,shadow_y,0,shadow_scale,shadow_scale,16,10)--绘制
  --画人物

  local ox = anim.anchorX
  local oy = anim.anchorY --以中心为点
  local sacleFactor = anim.scalefactor

  local sx = x*64 +32 --格子中心点
  local sy = y*64 +32+(anim.h-oy)*sacleFactor --格子中心点+上移图片中心点
  local scaleX = status.scaleX * sacleFactor *camera.workZoom
  local scaleY = status.scaleY * sacleFactor *camera.workZoom
  local rotation = status.rot
  --屏幕坐标
  local acx,acy = sx+status.dx,sy+status.dy+status.dz
  local screenx,screeny = camera:modelToScreen(acx,acy)

  local img,quad,flip = unit:getImgQuad(status)
  if flip then scaleX =scaleX*-1 end--水平翻转 
  love.graphics.setColor(1,1,1,1)
  drawUnitFrames(unit,true,acx,acy,camera)
  love.graphics.draw(img,quad,screenx,screeny,rotation,scaleX,scaleY,ox,oy)--绘制
  drawUnitFrames(unit,false,acx,acy,camera)
  drawUnitLifebar(unit,status,camera,x,y)
  drawDelayBar(unit,camera,screenx,screeny)
end


function render.drawLineUnit(queue,y,camera,map)
  love.graphics.setColor(1,1,1)
  local drawSequence = queue[y-queue.starty+1]
  for i=#drawSequence,1,-1 do
    drawOneSquareUnit(camera,drawSequence[i])
  end
end

--绘制之前按照dy重排序。
function render.generateUnitQueue(camera,map)
  local queue = {}
  --这些和drawSolid的一致
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-1
  local starty = math.floor(camera.seen_minY/squareL)-2 --多看2格，有的物体非常高
  local endx = math.floor(camera.seen_maxX/squareL)+1
  local endy = math.floor(camera.seen_maxY/squareL)+1 
  queue.starty = starty
  --queue.endy = endy
  for y = endy,starty,-1 do
    table.insert(queue,{lastDy = -999999})
  end

  --获得数据，插入
  local function insertUnit(unit,status,dy,liney)
    if not (liney<= endy and liney>= starty) then return end
    local drawSequence = queue[liney-starty+1]
    local todraw = {unit = unit,x= unit.x,y= unit.y,dy = dy,status = status}
    if dy>= drawSequence.lastDy then
      table.insert(drawSequence,todraw)
      drawSequence.lastDy =dy
    else --找到一个可插入的地方
      for i=1,#drawSequence do
        if drawSequence[i].dy>dy then
          table.insert(drawSequence,i,todraw)
          return
        end
      end
      table.insert(drawSequence,todraw)--罕见的没找到的情况。
    end
  end

  
  local function insertSquare(x,y,map)
    if not map:inbounds(x,y) then return end 
    local unit = map:unit_at(x,y)
    if unit ==nil then return end
    local status = unit:get_anim_status()--包含rate,dx ,dy ,face ,rot ,scaleX,scaleY,
    local dy = status.dy
    local liney = unit.y +math.floor((dy+32)/64)
    local linex= unit.x + math.floor((status.dx+32)/64)
    if  map:isMCSeen(x,y) or map:isMCSeen(linex,liney) then --逻辑处于可见区域或实际处于可见
      insertUnit(unit,status,dy,liney)
    end
  end

  for y = endy,starty,-1 do
    for x = startx,endx do
      insertSquare(x,y,map)
    end
  end
  
  local skewing_list = map.unit_skewing
  for _,unit in ipairs(skewing_list) do
    if unit.x<startx or unit.x>endx or unit.y<starty or unit.y >endy then
      local status = unit:get_anim_status()--包含rate,dx ,dy ,face ,rot ,scaleX,scaleY,
      local dy = status.dy
      local liney = unit.y +math.floor((dy+32)/64)
      local linex= unit.x + math.floor((status.dx+32)/64)
      if map:isMCSeen(linex,liney) then --位移地点
        insertUnit(unit,status,dy,liney) --尝试插入
      end
    end
  end
  
  return queue
end


