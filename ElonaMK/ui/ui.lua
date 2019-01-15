
ui={res= {},func = {}}
require "ui/component/base/turboKey"
require "ui/component/commonRes"
require "ui/mainMenu/mainMenu"
require "ui/mainScene/mainView"
require "ui/mainScene/mainScene"
require "ui/overmap/overmapView"
require "ui/overmap/overmapScene"

require "ui/component/waitingMessage"
require "ui/component/item/iteminfo"
require "ui/component/item/itemtypeInfo"
require "ui/component/item/toolLevelInfo"
require "ui/component/item/componentInfo"

require "ui/window/window"
require "ui/component/numberAsk"
require "ui/window/childWin/askNumberWin"
require "ui/window/childWin/chooseItemWin"
require "ui/window/pickupOrDropWin"
require "ui/window/directionSelectWin"
require "ui/window/selectEntryWin"
require "ui/window/status/statusWin"
require "ui/window/inventoryWin"
require "ui/window/AimWin"
require "ui/window/CraftingWin"
require "ui/window/vehicle/vehicleWin"

require "ui/fastForward/activityWin"

function ui.init()
  ui.camera.init()
  ui.overmap.init()
  ui.showMainMenu = true
  
  ui.popout = nil  --弃用
  ui.current_keypressd = nil--弃用
  
end


local function mainSceneUpdate(dt)
  g.preUpdate(dt)
  ui.mainScene(dt)
  ui.windowRoot(dt)--窗口
  if player.activity then 
    ui.actitvityWin(dt)
  end
  
  
  g.update(dt) --game时间经过
  ui.camera.update()
end





function ui.update(dt)
  ui.updateTurboKey(dt)--连发事件，在所有之前本帧开头
  
  if ui.showMainMenu then ui.enterMainMenu();return end --主菜单
  
  if ui.show_overmap then 
    ui.overmapScene(dt)
  else
    mainSceneUpdate(dt)
  end
end


function ui.keyOnWindow() return ui.win_root~=nil end

function ui.keypressed(key)
  if ui.showMainMenu then return end --主菜单
  
  
  
  
  if ui.win_root then
    ui.win_root:keypressed(key)
  elseif ui.show_overmap then 
    ui.overmapSceneKeypressed(key)
  else
    ui.mainKeypressed(key)
  end
  
end



function ui.getCurrentWindow()
  return ui.win_root
end
  

