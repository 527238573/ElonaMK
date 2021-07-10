local mapEditor  = Scene.new()

local suit = require"ui/suit"
require"editor/editor"
require"ui/editor/eui"
require"editor/captureAPI"

function mapEditor.enter()
  editor.init()
  editor.uiInit()
  
end


function mapEditor.leave()
  
  
end


function mapEditor.update(dt)
  editor.uiLayer()
end

function mapEditor.draw()
  render.drawEditor()
  suit:draw()
  
end


function mapEditor.keypressed(key)
  
  editor.handleKeyPressed(key)
end


return mapEditor