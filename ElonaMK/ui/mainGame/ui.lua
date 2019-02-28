local suit = require"ui/suit"



function ui.uiInit()
  g.popwindow = nil--弹出窗口
  
  
end


local rightPanel = require"ui/mainGame/rightPanel"


function ui.uiLayer()
  p.mc:camera_Focus()
  rightPanel()
  if g.popwindow then g.popwindow() end--弹出窗口，最上层
  
end