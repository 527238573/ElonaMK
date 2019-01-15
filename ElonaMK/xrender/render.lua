render = {}

require"xrender/map/drawTer"
require"xrender/map/grid"
require"xrender/map/drawGround"
function render.init()
  render.initDrawTerrain()
  
end


function render.drawEditor()
  local camera = editor.camera
  local map = editor.map
  render.drawTer(camera,map)
  
  
  if editor.showBlock  then 
    render.drawGroundBlock(camera,map)
    render.drawAllSolidBlock(camera,map) 
  end
  
  if editor.showEdgeShadow then
    render.drawEditorEdgeShadow(camera,map)
  end
  
  if editor.showGrid then render.drawMapDebugMesh(camera,map) end
  
  render.drawEditorRightMouse(camera)
end