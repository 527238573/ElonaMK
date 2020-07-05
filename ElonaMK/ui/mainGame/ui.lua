local suit = require"ui/suit"
ui.right_w = 300
ui.bottom_h = 64
require"ui/window/Window"
require"ui/window/child/numberAskWin"
require"ui/window/child/itemChooseWin"
require"ui/window/child/shortCutWin"
require"ui/window/child/ynAskWin"
require"ui/window/common/common"
require"ui/window/status/statusWin"
require"ui/window/equip/equipWin"
require"ui/window/item/inventoryWin"
require"ui/window/item/pickDropWin"
require"ui/window/item/itemUseWin"
require"ui/window/test/testWin"
require"ui/mainGame/cameraMove"
function ui.uiInit()
  ui.initKeyMapping()
  
end


local rightPanel = require"ui/mainGame/rightPanel"
local bottomPanel = require"ui/mainGame/bottom/bottomPanel"
local clock = require"ui/mainGame/clock"
local touch = require"ui/mainGame/touch"


--主界面ui
function ui.uiLayer(dt)
  ui.updateTurboKey(dt) --UI界面按键连发
  p.mc:camera_Focus()--先定位镜头到主角位置
  ui.cameraMove(dt) --移动镜头渐变 
  
  touch()--鼠标控制。--受镜头影响，放在镜头移动后
  clock() --时钟UI
  rightPanel() --右侧面板UI
  bottomPanel() --底部数个ui组件
  Window.windowRoot(dt) --窗口UI
end

--大地图模式下ui
function ui.overmapUILayer(dt)
  ui.updateTurboKey(dt) --UI界面按键连发
  p:camera_Focus() --定位镜头
  ui.overmapCameraMove(dt) --镜头渐变
  rightPanel() --右侧UI
  Window.windowRoot(dt) --窗口UI
end


--操作焦点在主界面（没有弹出窗口）
function ui.isKeyfocusMainGame()
  return Window.getRoot()==nil
end

local function callb(out)
  debugmsg("out:"..tostring(out))
end
--游戏主界面按键
local function mainKeypressed(key)
  if key=="f1" then  p:changeMC(1) 
  elseif key=="f2" then  p:changeMC(2)
  elseif key=="f3" then  p:changeMC(3)
  elseif key=="f4" then  p:changeMC(4) 
  elseif key=="character" then  ui.statusWin:Open() 
  elseif key=="inventory" then  ui.inventoryWin:Open() 
  elseif key=="ability" then ui.equipWin:Open(3) 
  elseif key=="pickup" then  p:pickup_action() 
  elseif key=="drop" then  p:drop_action() 
  elseif key=="useItem" then p:useItem_action()
  elseif key=="fire" then p:fire_action() 
  elseif key=="reload" then p:reload_action() 
  elseif key=="esc" then p:esc_action()
  elseif key=="j" then g.test1() 
  elseif key=="k" then ui.testWin:Open() 
  else
    for i=1,8 do if key ==c.key_action_id[i] then p:useActionBar(i) end end--table装了action1~8字符串
  end
  
end

--主界面下按下按键
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


local function overmapKeypressed(key)
  if key=="character" then  ui.statusWin:Open() end
  if key=="inventory" then  ui.inventoryWin:Open() end
  if key=="space" then  p:enterMap()end
end
--大地图模式下按下按键
function ui.keypressedOvermap(key)
  local winroot = Window.getRoot()
  if winroot then 
    key = ui.convertKey_UI(key)
    winroot:keypressed(key)
    return
  else
    key = ui.convertKey_Game(key)
    overmapKeypressed(key)
  end
end
