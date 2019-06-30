local mainGame  = Scene.new()

local suit = require"ui/suit"



function mainGame.enter()
  
  
end

function mainGame.leave()
  
  
end

function mainGame.update(dt)
  g.update(dt)
  ui.uiLayer(dt)
  
end

function mainGame.draw()
  render.drawMainGame()
  suit:draw()
end

function mainGame.keypressed(key)
  ui.keypressed(key)
end

return mainGame