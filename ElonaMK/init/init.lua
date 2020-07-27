
--init在load之前，init主要是声明所有使用的代码，load是读取游戏数据建立各个表及数据结构。
require"init/common"
require"init/pic"
require"ui/suit"
require"file/saveT"
require"file/saveTAdv"

--数据
require"init/datainit"
local loadTerdata = require"elona/map/terdata"
local loadAnimdata = require"elona/anim/animdata"
local loadFramesdata = require"elona/anim/framedata"
local loadUnitdata = require"elona/unit/unitdata"
local loadAnimClip = require"elona/unit/animClip/animMethod"
local loadItemdata = require"elona/item/itemdata"
local loadFielddata = require"elona/field/fielddata"
local loadAudiodata = require"elona/audio/sounddata"
local loadAbilitydata = require"elona/unit/ability/abilitydata"
local loadEffectdata = require"elona/unit/effect/effectdata"
local loadTraitdata = require"elona/unit/effect/traitdata"
--scene
require"Scenes/Scene"
require"Scenes/mainMenu"
require"Scenes/mainGame"
require"Scenes/overMap"
--game部分
require"elona/game"
require"elona/map/map"
require"elona/map/map_terrain"
require"elona/map/map_cache"
require"elona/map/map_items"
require"elona/map/map_field"
require"elona/map/map_unit"
require"elona/map/map_enter"
require"elona/map/map_frames"
require"elona/map/mapFactory"
require"elona/map/mapBuffer"
require"elona/map/overmap"
require"elona/map/overmap_ter"
require"elona/unit/unit"
require"elona/unit/unit_check"
require"elona/unit/attribute/unit_baseAttr"
require"elona/unit/attribute/unit_bonusAttr"
require"elona/unit/attribute/unit_compositeAttr"
require"elona/unit/attribute/unit_skill"
require"elona/unit/unit_action"
require"elona/unit/unit_death"
require"elona/unit/unit_anim"
require"elona/unit/unit_equip"
require"elona/unit/unit_faction"
require"elona/unit/unit_turn"
require"elona/unit/unitfactory"
require"elona/unit/animClip/animClip"
require"elona/unit/fight/damage"
require"elona/unit/fight/projectile"
require"elona/unit/fight/unit_fight"
require"elona/unit/fight/unit_fightMelee"
require"elona/unit/fight/unit_fightMeleeAnim"
require"elona/unit/fight/unit_fightRange"
require"elona/unit/fight/unit_weapon"
require"elona/unit/brain/unit_brain"
require"elona/unit/brain/unit_target"
require"elona/unit/ability/ability"
require"elona/unit/ability/actionBar"
require"elona/unit/ability/unit_ability"
require"elona/unit/effect/effect"
require"elona/unit/effect/unit_effect"
require"elona/unit/effect/unit_effectCreate"
require"elona/unit/effect/trait"
require"elona/unit/effect/unit_trait"
require"elona/anim/FrameClip"
require"elona/anim/frameFactory"
require"elona/item/item"
require"elona/item/item_check"
require"elona/item/item_equipment"
require"elona/item/item_weapon"
require"elona/item/itemfactory"
require"elona/item/inventory"
require"elona/field/field"
require"elona/field/fieldList"
require"elona/player/player"
require"elona/player/player_team"
require"elona/player/player_item"
require"elona/player/player_action"
require"elona/player/player_overmap"
require"elona/player/calendar"
--声音
require"elona/audio/audio"

require"elona/newgame/fastStart"
require"elona/test/test1"
--ui部分
ui = {}
require"ui/control/key"
require"ui/control/turboKey"
require"ui/mainGame/ui"
--绘制部分
require"xrender/render"



function data.init()
  loadTerdata()
  loadAnimdata()
  loadFramesdata()
  loadUnitdata()
  loadAnimClip()
  loadItemdata()
  loadFielddata()
  loadAudiodata()
  loadAbilitydata()
  loadEffectdata()
  loadTraitdata()
  data.loadComplete = true
  
  render.init()
  ItemFactory.initItemFactory()
  MapFactory.initMapBuffer()
  Unit.initUnitFactions()
  UnitFactory.initUnitFactory()
  ui.uiInit()--虽然还未进入主游戏，但需要一次载入。
end