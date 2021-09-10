render = {}

require"xrender/map/drawAll"
require"xrender/map/drawTer"
require"xrender/map/grid"
require"xrender/map/drawBlock"
require"xrender/map/drawShadow"
require"xrender/map/drawItem"
require"xrender/map/drawField"
require"xrender/map/drawUnit"
require"xrender/map/drawFrames"
require"xrender/map/drawUI"
require"xrender/overmap/drawOvermap"
require"xrender/overmap/drawPlayer"

local canvas
function render.init()
  render.initDrawTerrain()
  render.initDrawOvermap()
  render.initDrawShadow()
  
  canvas = love.graphics.newCanvas(2*(c.win_W-c.RightPanel_W),c.win_H*2)--宽高各两倍，方便缩放
end


function render.drawEditor()
  local camera = editor.camera
  local x,y = camera.centerX,camera.centerY
  camera:clampXY()
  local map = editor.map

  if editor.overmapMode  then
    render.drawOvermap(camera,map)
  else
    
    
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    render.drawTer(camera,map)

    if editor.showBlock  then 
      
      render.drawGround(camera,map)
      render.drawSolid(camera,map)
    end
    if editor.showEdgeShadow then
      render.drawEdgeShadow(camera,map)
    end
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas()
    love.graphics.draw(canvas,camera.canvas_Xoffset,camera.canvas_Yoffset,0,camera.workZoom,camera.workZoom)
  end
  
  if editor.showGrid then render.drawMapDebugMesh(camera,map) end

  render.drawEditorRightMouse(camera)
end


function render.drawMainGame()
  local camera = g.camera
  --local x,y = camera.centerX,camera.centerY
  --camera:clampXY()
  local map = cmap
  love.graphics.setColor(1,1,1)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  
  map:buildSeenCache()--重建seencache 除了刚进入地图或只在这里
  render.setTerrainColor()
  render.drawTer(camera,map)
  render.drawGround(camera,map)
  render.drawShadow(camera,map)
  render.drawSolid(camera,map)
  render.drawFrames(camera,map)
  render.drawProjectiles(camera,map)
  
  love.graphics.setColor(1,1,1)
  love.graphics.setCanvas()
  love.graphics.draw(canvas,camera.canvas_Xoffset,camera.canvas_Yoffset,0,camera.workZoom,camera.workZoom)
  
  
  render.drawUILayer(camera,map)
  --camera.centerX,camera.centerY = x,y
end


function render.drawOverMapScene()
  local camera = g.wcamera
  local x,y = camera.centerX,camera.centerY
  camera:clampXY()
  local map = wmap
  render.drawOvermap(camera,map)
  render.drawPlayer(camera,p)
end