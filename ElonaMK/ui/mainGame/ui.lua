local suit = require"ui/suit"
ui.right_w = 300
ui.bottom_h = 64
require"ui/window/Window"
require"ui/window/child/numberAskWin"
require"ui/window/status/statusWin"
require"ui/window/equip/equipWin"
require"ui/window/item/inventoryWin"
require"ui/window/item/pickDropWin"
require"ui/window/item/itemUseWin"
function ui.uiInit()
  --g.popwindow = nil--弹出窗口
  ui.initKeyMapping()
  
end


local rightPanel = require"ui/mainGame/rightPanel"
local clock = require"ui/mainGame/clock"
local cameraMove = require"ui/mainGame/cameraMove"




function ui.uiLayer(dt)
  ui.updateTurboKey(dt) --UI界面按键连发
  p.mc:camera_Focus()--先定位镜头到位置
  cameraMove(dt) --移动镜头渐变 
  clock() --时钟UI
  rightPanel() --右侧面板UI
  Window.windowRoot(dt) --窗口UI
end

function ui.isKeyfocusMainGame()
  return Window.getRoot()==nil
end

--游戏主界面按键
local function mainKeypressed(key)
  if key=="f1" then  p:changeMC(1) end
  if key=="f2" then  p:changeMC(2) end
  if key=="f3" then  p:changeMC(3) end
  if key=="f4" then  p:changeMC(4) end
  if key=="character" then  ui.statusWin:Open() end
  if key=="inventory" then  ui.inventoryWin:Open() end
  if key=="pickup" then  p:pickup_action() end
  if key=="drop" then  p:drop_action() end
  if key=="useItem" then p:useItem_action() end
end

function ui.keypressed(key)
  local winroot = Window.getRoot()
  if winroot then 
    key = ui.convertKey_UI(key)
    winroot:keypressed(key)
    return
  else
    key = ui.convertKey_Game(key)
    mainKeypressed(key)
  end
end
