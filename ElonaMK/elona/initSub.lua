SubThread = true--子线程
--init在load之前，init主要是声明所有使用的代码，load是读取游戏数据建立各个表及数据结构。
require"elona/zinit/common" --子线程主线程共通的common变量
require"file/saveTAdv"


--game部分
require"elona/gameSub"
--主线程子线程共通的初始化部分
local LoadInitCommon = require"elona/zinit/initCommon"

--多线程
--待添加

function data.init()
  LoadInitCommon()
end

g.main()