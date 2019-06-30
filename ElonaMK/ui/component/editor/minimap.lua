
local suit = require"ui/suit"

local mapdata = {}
local mapImg = {}
setmetatable(mapdata,{__mode = "k"})
setmetatable(mapImg,{__mode = "k"})
local minimap_id = newid()


local colorTable = 
{
  light_red = {150,13,13,255},
  red = {116,10,10,255},
  dark_red = {80,6,6,255},
  light_green = {14,160,14,255},
  green = {10,116,10,255},
  dark_green = {7,92,7,255},
  floor = {116,90,58,255},
  light_brown = {128,81,8,255},
  brown = {112,60,11,255},
  dark_brown = {79,31,2,255},
  light_blue = {10,115,160,255},
  blue = {20,70,119,255},
  dark_blue = {25,51,113,255},
  light_grey = {109,109,109,255},
  grey = {78,78,78,255},
  dark_grey = {55,55,55,255},
  black = {33,33,33,255},
  white = {168,168,168,255},
  light_yellow = {236,213,145,255},
  yellow = {140,140,10,255},
  orange = {158,49,12,255},
  light_cyan = {31,168,168,255},
  cyan = {22,127,127,255},
  dark_cyan = {16,90,90,255},
  light_pink = {159,0,80,255},
  pink = {117,0,58,255},
  dark_pink = {77,0,38,255},
}



local function draw_miniMap(img,x,y,w,h,camera)
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",x,y,w,h)
  love.graphics.setColor(1,1,1)

  local imgw = img:getWidth()
  local imgh = img:getHeight()

  local ox = imgw/2
  local oy = imgh/2
  local sx = x+0.5*w
  local sy = y+0.5*h
  local scale = math.min(w/imgw,h/imgh)
  love.graphics.draw(img,sx,sy,0,scale,scale,ox,oy)

  --drawcamera
  love.graphics.setScissor(x,y,w,h)--实际显示范围
  local cw = (camera.seen_maxX -camera.seen_minX)/64 *scale
  local ch = (camera.seen_maxY -camera.seen_minY)/64 *scale
  local cx = (camera.seen_minX/64 - imgw/2)*scale  + sx
  local cy = (imgh -camera.seen_maxY/64 - imgh/2)*scale  + sy
  love.graphics.rectangle("line",cx,cy,cw,ch)
  love.graphics.setScissor()
end


local function rebuild_minimap_img(map,imgdata,img)

  if map.saveType =="Overmap" then
    for sx = 0,map.w-1 do
      for sy = 0,map.h-1 do
        local l1 = map:getLayer1(sx,sy)
        local color
        local info = data.oter[l1]
        if info.flags["RIVER"] then color = "blue"
        elseif l1 ==2 then color = "brown"
        elseif l1 ==3 then color = "green"
        elseif l1 ==4 then color = "light_yellow"
        elseif l1 ==5 then color = "white"
        else color = "grey"
        end
        color = colorTable[color]
        imgdata:setPixel(sx,map.h-sy-1,color[1]/255,color[2]/255,color[3]/255,1)
      end
    end
  else
    for sx = 0,map.w-1 do
      for sy = 0,map.h-1 do
        local tid = map:getTer(sx,sy)
        local bid = map:getBlock(sx,sy)
        local color
        if bid>1 then
          local blockinfo = data.block[bid]
          color = colorTable[blockinfo.color]
        else
          local terinfo = data.ter[tid]
          color = colorTable[terinfo.color]
        end
        imgdata:setPixel(sx,map.h-sy-1,color[1]/255,color[2]/255,color[3]/255,1)
      end
    end
  end

  img:replacePixels(imgdata)

end

return function(map,camera,x,y,w,h)

  local img = mapImg[map]
  if img ==nil or map.refreshMiniMap ==true then 
    map.refreshMiniMap = false
    --biuldMiniMap
    local imgdata = love.image.newImageData( map.w, map.h )
    img = love.graphics.newImage( imgdata )
    rebuild_minimap_img(map,imgdata,img)
    img:setFilter( "linear", "linear" )
    mapdata[map] = imgdata
    mapImg[map] = img
  end
  suit:registerDraw(draw_miniMap,img,x,y,w,h,camera)
  suit:registerHitbox(nil,minimap_id, x,y,w,h)

  if suit:isActive(minimap_id) then
    local scale = math.min(w/img:getWidth(),h/img:getHeight())

    local mapcx = map.w*64/2
    local mapcy = map.h*64/2

    local mx,my = love.mouse.getX(),love.mouse.getY()
    
    mx = (mx - (x+w/2))/scale*64 +mapcx
    my = (-(my - (y+h/2)))/scale*64+mapcy
    camera:setCenter(mx,my)

  end

end