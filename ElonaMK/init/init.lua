
--init在load之前，init主要是声明所有使用的代码，load是读取游戏数据建立各个表及数据结构。
require"init/common"
require"init/pic"
require"ui/suit"
require"file/saveTAdv"

--数据
data = {}
local loadTerdata = require"elona/map/terdata"



--game部分
require"elona/game"
require"elona/map/map"

--ui部分
require"Scenes/Scene"
require"Scenes/mainMenu"


--绘制部分
require"xrender/render"

function data.init()
  loadTerdata()
  render.init()
end