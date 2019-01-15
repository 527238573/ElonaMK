
local suit = require"ui/suit"

local btnFastStart_opt = {id = newid()}
local btnStart_opt = {id = newid()}
local btnLoad_opt = {id = newid()}
function ui.enterMainMenu()
  
  
  
  local faststart = suit:S9Button("fast start",btnFastStart_opt,300,300,130,30)
  local start = suit:S9Button("start",btnStart_opt,300,360,130,30)
  local load_state = suit:S9Button("load",btnLoad_opt,300,420,130,30)
  
  if faststart.hit then
    ui.showMainMenu = false
    g.createGame()
    g.profileName = "defaultProfile" --默认存档的文件夹啊
    ui.waitingMessage(tl("创建游戏中...","creating game..."))
    --love.timer.sleep(0.4)
    
  end
  
  if load_state.hit then
    if g.loadGame("defaultProfile") then
      ui.showMainMenu = false
    end
  end
  
  
end