render = {}

require"xrender/map/drawTer"
require"xrender/map/grid"
require"xrender/map/drawGround"
require"xrender/overmap/drawOvermap"
function render.init()
  render.initDrawTerrain()
  render.initDrawOvermap()
end


function render.drawEditor()
  local camera = editor.camera
  local map = editor.map

  if editor.overmapMode  then
    render.drawOvermap(camera,map)
  else
    render.drawTer(camera,map)

    if editor.showBlock  then 
      render.drawGroundBlock(camera,map)
      render.drawAllSolidBlock(camera,map) 
    end

    if editor.showEdgeShadow then
      render.drawEditorEdgeShadow(camera,map)
    end
  end
  
  if editor.showGrid then render.drawMapDebugMesh(camera,map) end

  render.drawEditorRightMouse(camera)
end