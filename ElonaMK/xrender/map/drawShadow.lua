


local lastSX
local lastSY
local lastEX
local lastEY
local lastSeen
local oldSeen
local oldSX
local oldSY

local sun_light = 50

local batch1
local batchshow
local batchfade

local shadow_img = love.graphics.newImage("data/terrain/shadow2.png")
local shadow_qaud = {}
for i=1,6 do table.insert(shadow_qaud,love.graphics.newQuad((i-1)*64,0,64,64,shadow_img:getWidth(),shadow_img:getHeight())) end


local r0 = math.rad(0)
local r9 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------1   2   3   4  5  6   7   8   9  A  B   C  D  E  F
local htileIndex= {4,  4,  3,  4, 5, 3,  6,  4,  3, 5, 6,  3, 6, 6, 2 }
local htileRad=   {r18,r9,r27,r0,r0,r18,r18,r27,r0,r9,r27,r9,r0,r9,r0}


function render.initDrawShadow()

  batch1 = love.graphics.newSpriteBatch(shadow_img)
  batchshow = love.graphics.newSpriteBatch(shadow_img)
  batchfade = love.graphics.newSpriteBatch(shadow_img)
end

local function CanSee(map,x,y,seen)
  if not map:inbounds(x,y) then return true end
  return map:isMCSeen(x,y,seen)
end



local function getStateCode(map,x,y,seen)
  if not map:inbounds(x,y) then return 0 end --地图外不画
  local cursq = CanSee(map,x,y,seen)
  local up  = CanSee(map,x,y+1,seen)
  local right  = CanSee(map,x+1,y,seen)
  local down  = CanSee(map,x,y-1,seen)
  local left  = CanSee(map,x-1,y,seen)

  if not cursq then
    return -1
  else
    --drawHierarchy
    local statecode = 0
    if not up then statecode = statecode+8 end
    if not right then statecode = statecode+4 end
    if not down then statecode = statecode+2 end
    if not left then statecode = statecode+1 end
    return statecode
  end
end



local function drawToBatch(x,y,batch,statecode)
  local dx,dy = x-lastSX,y-lastSY
  local sx,sy = dx*64,(-dy-1)*64 --左上角相对坐标

  if statecode ==-1 then
    batch:add(shadow_qaud[1],sx,sy,0,1,1)
  elseif statecode>0 then
    local rotation = htileRad[statecode]
    local quad = shadow_qaud[htileIndex[statecode]]
    local ox = 32 --一半，取中心点旋转
    local oy = 32 
    batch:add(quad,sx+32,sy+32,rotation,1,1,ox,oy) --直接使用常数
  end
end



local function drawSquareToBatch(map,x,y)
  if not map:inbounds(x,y) then return end --地图外不画

  local stateNow = getStateCode(map,x,y,lastSeen)
  local stateLast = getStateCode(map,x,y,oldSeen)


  if stateNow == stateLast then
    drawToBatch(x,y,batch1,stateNow)
  else
    drawToBatch(x,y,batchshow,stateNow)
    drawToBatch(x,y,batchfade,stateLast)
  end
end


--光照明亮相关
local maxLightr =1
local maxLightg =1
local maxLightb =1

local midLightr =0.9
local midLightg =0.8
local midLightb =0.4

local minLightr =0.5
local minLightg =0.5
local minLightb =0.8
local curLightr = 1
local curLightg = 1
local curLightb = 1
local curMinlightr = 0.7
local curMinlightg = 0.7
local curMinlightb = 0.7
local shadow_d = 0.3
local changeTime = 0.44
--设置当前帧的光线数据
local function setupLight()
  sun_light = p.calendar:sun_light()
  if p.calendar.hour>12 then --黄昏变化
    if sun_light>50 then
      curLightr = (maxLightr-midLightr)*(sun_light-50)/50 +midLightr
      curLightg = (maxLightg-midLightg)*(sun_light-50)/50 +midLightg
      curLightb = (maxLightb-midLightb)*(sun_light-50)/50 +midLightb
    else
      curLightr = (midLightr-minLightr)*sun_light/50 +minLightr
      curLightg = (midLightg-minLightg)*sun_light/50 +minLightg
      curLightb = (midLightb-minLightb)*sun_light/50 +minLightb
    end 
  else
    curLightr = (maxLightr-minLightr)*sun_light/100 +minLightr --黎明变化
    curLightg = (maxLightg-minLightg)*sun_light/100 +minLightg
    curLightb = (maxLightb-minLightb)*sun_light/100 +minLightb
  end
  shadow_d = (0.1)*sun_light/100 +0.3
  curMinlightr = (1-shadow_d)*curLightr
  curMinlightg = (1-shadow_d)*curLightg
  curMinlightb = (1-shadow_d)*curLightb
end











function render.drawShadow(camera,map)
  map:buildSeenCache()
  setupLight()

  local zoom  = camera.workZoom
  local squareL = 64
  local startx = math.floor(camera.seen_minX/squareL)-2
  local starty = math.floor(camera.seen_minY/squareL)-2
  local endx = math.floor(camera.seen_maxX/squareL) +2
  local endy = math.floor(camera.seen_maxY/squareL)+2
  local seen = map.seen

  if lastSeen ~= seen or startx~=lastSX or starty~=lastSY or endx~=lastEX or endy~=lastEY then
    --build batch
    --if lastSeen ~= seen then debugmsg("seen change") end
    --if startx~=lastSX then debugmsg("sx change") end
    --if starty~=lastSY then debugmsg("sy change") end
    --if endx~=lastEX then debugmsg("ex change") end
    --if endy~=lastEY then debugmsg("ey change") end
    batch1:clear()
    batchshow:clear()
    batchfade:clear()
    --覆盖新的。

    if lastSeen ~= seen then
      changeTime = seen.changeTime
      oldSeen = lastSeen --存储旧的数据。
      lastSeen = seen
    end
    lastSX = startx
    lastSY = starty
    lastEX = endx
    lastEY = endy
    for sx = startx,endx do
      for sy = starty,endy do
        drawSquareToBatch(map,sx,sy)
      end
    end
  end

  --love.graphics.setBlendMode("subtract")
  if oldSeen~=nil and seen.time<changeTime  then
    local new_rate = seen.time/changeTime
    local x,y= camera:modelToScreen(startx*squareL,starty*squareL)

    local old_color = shadow_d*(1-new_rate)
    love.graphics.setColor(1,1,1,old_color)
    love.graphics.draw(batchfade,x,y,0,zoom,zoom)

    local new_color = shadow_d*new_rate

    love.graphics.setColor(1,1,1,new_color)
    love.graphics.draw(batchshow,x,y,0,zoom,zoom)
    love.graphics.setColor(1,1,1,shadow_d)
    love.graphics.draw(batch1,x,y,0,zoom,zoom)
  else
    love.graphics.setColor(1,1,1,shadow_d)
    local x,y = camera:modelToScreen(startx*squareL,starty*squareL)
    love.graphics.draw(batch1,x,y,0,zoom,zoom)
    love.graphics.draw(batchshow,x,y,0,zoom,zoom)
  end
  --love.graphics.setBlendMode("alpha")
  render.drawEditorEdgeShadow(camera,map)
end


function render.setTerrainColor()
  love.graphics.setColor(curLightr,curLightg,curLightb,1)
end

function render.setUnitShadowColor()
  love.graphics.setColor(1,1,1,1-(0.3)*sun_light/100)
end

function render.setSolidColor(map,x,y)
  local seen =lastSeen
  if oldSeen~=nil and seen.time<changeTime  then
    local rate = seen.time/changeTime
    if map:isMCSeen(x,y) then
      if map:isMCSeen(x,y,oldSeen) then
        love.graphics.setColor(curLightr,curLightg,curLightb,1)
      else
        local r = curMinlightr+(curLightr - curMinlightr)*rate
        local g = curMinlightg+(curLightg - curMinlightg)*rate
        local b = curMinlightb+(curLightb - curMinlightb)*rate
        love.graphics.setColor(r,g,b,1)
      end
    else
      if map:isMCSeen(x,y,oldSeen) then
        local r = curLightr-(curLightr - curMinlightr)*rate
        local g = curLightg-(curLightg - curMinlightg)*rate
        local b = curLightb-(curLightb - curMinlightb)*rate
        love.graphics.setColor(r,g,b,1)
      else
        love.graphics.setColor(curMinlightr,curMinlightg,curMinlightb,1)
      end
    end

  else
    if map:isMCSeen(x,y) then
      love.graphics.setColor(curLightr,curLightg,curLightb,1)
    else
      love.graphics.setColor(curMinlightr,curMinlightg,curMinlightb,1)
    end
  end
end