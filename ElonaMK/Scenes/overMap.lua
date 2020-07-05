local overMap  = Scene.new()

local suit = require"ui/suit"



function overMap.enter()
  
  
end

function overMap.leave()
  
  
end

function overMap.update(dt)
  g.updateOvermap(dt)
  ui.overmapUILayer(dt)
  g.updateSound(dt)
end

function overMap.draw()
  render.drawOverMapScene()
  suit:draw()
end

function overMap.keypressed(key)
  ui.keypressedOvermap(key)
end

return overMap