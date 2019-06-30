
--init在load之前，init主要是声明所有使用的代码，load是读取游戏数据建立各个表及数据结构。
require"init/common"
require"init/pic"
require"ui/suit"
require"file/saveTAdv"

--数据
require"init/datainit"
local loadTerdata = require"elona/map/terdata"
local loadAnimdata = require"elona/anim/animdata"
local loadUnitdata = require"elona/unit/unitdata"
local loadAnimClip = require"elona/unit/animClip/animMethod"
local loadItemdata = require"elona/item/itemdata"
local loadFielddata = require"elona/field/fielddata"
local loadAudiodata = require"elona/audio/sounddata"
--game部分
require"elona/game"
Map = require"elona/map/map"
require"elona/map/map_terrain"
require"elona/map/map_cache"
require"elona/map/map_items"
require"elona/map/map_field"
require"elona/map/map_unit"
require"elona/map/mapFactory"
require"elona/unit/unit"
require"elona/unit/unit_check"
require"elona/unit/unit_attr"
require"elona/unit/unit_action"
require"elona/unit/unit_anim"
require"elona/unit/unitfactory"
require"elona/unit/animClip/animClip"
require"elona/item/item"
require"elona/item/item_check"
require"elona/item/item_equipment"
require"elona/item/itemfactory"
require"elona/item/inventory"
require"elona/field/field"
require"elona/field/fieldList"
require"elona/player/player"
require"elona/player/player_team"
require"elona/player/player_item"
require"elona/player/player_action"
require"elona/player/calendar"
--声音
require"elona/audio/audio"

require"elona/newgame/fastStart"
--ui部分
require"Scenes/Scene"
require"Scenes/mainMenu"
require"Scenes/mainGame"
ui = {}
require"ui/control/key"
require"ui/control/turboKey"
require"ui/mainGame/ui"
--绘制部分
require"xrender/render"



function data.init()
  loadTerdata()
  loadAnimdata()
  loadUnitdata()
  loadAnimClip()
  loadItemdata()
  loadFielddata()
  loadAudiodata()
  
  
  render.init()
  Item.initItemFactory()
  
  ui.uiInit()--虽然还未进入主游戏，但需要一次载入。
end