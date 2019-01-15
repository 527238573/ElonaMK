
local suit = require"ui/suit"
local bit = require("bit")

local imgdata = love.image.newImageData( 9*16, 9*16 )-- gridlength = 9
local mini_img = love.graphics.newImage( imgdata )


local grid = g.map.grid
local camera = ui.camera
local function draw_miniMap(x,y)
  love.graphics.oldColor(255,255,255)
  love.graphics.setScissor(x,y,129*2,129*2)--实际显示范围
  local offsetX = bit.band(grid.csquareX,15)*2
  local offsetY = (15 - bit.band(grid.csquareY,15))*2
  love.graphics.draw(mini_img,x-offsetX,y-offsetY,0,2,2)
  
  --draw 中心点
  love.graphics.rectangle("fill",x+128,y+128,2,2)
  --draw camera
  if g.cameraLock.locked ==false then
    local camerax,cameray = (camera.centerX- grid.field_minX)/32,(camera.centerY- grid.field_minY)/32
    local camera_halfW,camera_halfH = camera.half_seen_W/32,camera.half_seen_H/32
    love.graphics.rectangle("line",x-offsetX+camerax-camera_halfW,y-offsetY+(288-cameray-camera_halfH),2*camera_halfW,2*camera_halfH)
  else
    local camera_halfW,camera_halfH = camera.half_seen_W/32,camera.half_seen_H/32
    love.graphics.rectangle("line",x+128-camera_halfW,y+128-camera_halfH+2,2*camera_halfW,2*camera_halfH)
  end
  
  love.graphics.setScissor()
end

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
  yellow = {140,140,10,255},
  orange = {158,49,12,255},
  light_cyan = {31,168,168,255},
  cyan = {22,127,127,255},
  dark_cyan = {16,90,90,255},
  light_pink = {159,0,80,255},
  pink = {117,0,58,255},
  dark_pink = {77,0,38,255},
}


local function rebuild_minimap_img()
  local imghight = 143
  local name_info = data.ster
  local block_info = data.block
  
  
  local zcache,rz = g.map.zLevelCache.getCache(camera.cur_Z)
  g.map.zLevelCache.buildSeenCache(zcache,rz)
  
  for sx = 0,8 do
    for sy = 0,8 do
      local submap = grid[(rz)*81+(sx)*9+(sy)+1]
      for x=0,15 do
        for y =0,15 do
          local realx = sx*16+x
          local realy = sy*16+y
          if(zcache.seen[realx][realy]<=0) then
            imgdata:setPixel(sx*16+x,imghight-(sy*16+y),20/255,20/255,20/255,255/255 )--不可见之黑
          else
            local ter = submap.raw:getTer(x,y)
            local block = submap.raw:getBlock(x,y)
            local color 
            if block>1 then
              local blockinfo = block_info[block]
              if blockinfo.color then color = colorTable[blockinfo.color] end
            else
              local terinfo = name_info[ter]
              if terinfo.color then color = colorTable[terinfo.color] end
            end
            if color then imgdata:setPixel(sx*16+x,imghight-(sy*16+y),color[1]/255,color[2]/255,color[3]/255,255/255 ) end
          end
        end
      end
    end
  end
    
  
  
  --imgdata:setPixel( 64,64,255,255,255,255 )
  mini_img:replacePixels(imgdata)
  
  
end

local minimap_id = newid()

function ui.minimap(x,y)
  if g.map.minimap_dirty == true then--在grid cache中，有变动会修改此项，或者ter有变化时
    g.map.minimap_dirty = false
    rebuild_minimap_img()
  end
  suit:registerDraw(draw_miniMap,x,y)
  suit:registerHitbox(nil,minimap_id, x,y,129*2,129*2)
  
  if suit:isActive(minimap_id) then
    local offsetX = bit.band(grid.csquareX,15)*2
    local offsetY = (15 - bit.band(grid.csquareY,15))*2
    local mx,my = love.mouse.getX(),love.mouse.getY()
    mx = (mx - x+offsetX)
    my = 288-(my - y+offsetY)
    ui.camera.setCenter(grid.field_minX+mx*32,grid.field_minY+my*32)
      
  end
  
  
end