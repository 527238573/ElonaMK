--SubThread = false
--init在load之前，init主要是声明所有使用的代码，load是读取游戏数据建立各个表及数据结构。
require"elona/zinit/logic_common" --子线程主线程共通的common变量
require"game/zinit/game_common"
require"game/zinit/pic"
require"ui/suit"
require"file/saveT"
require"file/saveTAdv"


--scene
require"game/scenes/Scene"
require"game/scenes/mainMenu"
require"game/scenes/mainGame"
require"game/scenes/overMap"
--game 
require"game/game"
--逻辑部分
local LoadInitLogic = require"elona/zinit/logic_init"

require"game/player/player"
require"game/player/player_team"
require"game/player/player_item"
require"game/player/player_action"
require"game/player/player_overmap"


require"game/newgame/fastStart"
require"game/test/test1"
--ui部分
ui = {}
require"ui/control/key"
require"ui/control/turboKey"
require"ui/mainGame/ui"
--绘制部分
require"xrender/render"


function data.init()
  LoadInitLogic()
  
  render.init()
  ui.uiInit()--虽然还未进入主游戏，但需要一次载入。
end