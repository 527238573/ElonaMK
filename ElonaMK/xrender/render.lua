render = {}

require"xrender/map/drawAll"
require"xrender/map/drawTer"
require"xrender/map/grid"
require"xrender/map/drawBlock"
require"xrender/map/drawShadow"
require"xrender/map/drawItem"
require"xrender/map/drawField"
require"xrender/map/drawUnit"
require"xrender/overmap/drawOvermap"
function render.init()
  render.initDrawTerrain()
  render.initDrawOvermap()
  render.initDrawShadow()
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
    render.drawTer(camera,map)

    if editor.showBlock  then 
      
      render.drawGround(camera,map)
      render.drawSolid(camera,map)
    end
    if editor.showEdgeShadow then
      render.drawEditorEdgeShadow(camera,map)
    end
  end
  
  if editor.showGrid then render.drawMapDebugMesh(camera,map) end

  render.drawEditorRightMouse(camera)
end


function render.drawMainGame()
  local camera = g.camera
  local x,y = camera.centerX,camera.centerY
  camera:clampXY()
  local map = cmap
  --love.graphics.setColor(1,1,1)
  render.setTerrainColor()
  render.drawTer(camera,map)

  render.drawGround(camera,map)
  render.drawShadow(camera,map)
  render.drawSolid(camera,map)
  --camera.centerX,camera.centerY = x,y
end
