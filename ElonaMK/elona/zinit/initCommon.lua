
require"elona/zinit/datainit"
local loadTerdata = require"elona/map/terdata"
local loadAnimdata = require"elona/anim/animdata"
local loadFramesdata = require"elona/anim/framedata"
local loadUnitdata = require"elona/unit/unitdata"
local loadItemdata = require"elona/item/itemdata"
local loadFielddata = require"elona/field/fielddata"
local loadAudiodata = require"elona/audio/sounddata"
local loadAbilitydata = require"elona/unit/ability/abilitydata"


require"elona/map/map"
require"elona/map/mapter/map_terrain"
require"elona/map/mapter/map_cache"
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
require"elona/unit/animClip/Animation"
require"elona/unit/fight/damage"
require"elona/unit/fight/projectile"
require"elona/unit/fight/unit_fight"
require"elona/unit/fight/unit_fightMelee"
require"elona/unit/fight/unit_fightMeleeAnim"
require"elona/unit/fight/unit_fightRange"
require"elona/unit/fight/unit_weapon"
require"elona/unit/brain/brain"
require"elona/unit/brain/unit_aiCheck"
require"elona/unit/brain/unit_brain"
require"elona/unit/brain/unit_target"
require"elona/unit/brain/act_nofight"
require"elona/unit/ability/ability"
require"elona/unit/ability/actionBar"
require"elona/unit/ability/unit_ability"
require"elona/unit/effect/effect"
require"elona/unit/effect/unit_effect"
require"elona/unit/effect/unit_effectCreate"
require"elona/unit/effect/unit_knockBack"
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
require"elona/world/calendar"
--声音
require"elona/audio/audio"

return function()
  
  data.LoadAllCvs()
  
  loadTerdata()
  loadAnimdata()
  loadFramesdata()
  loadUnitdata()
  loadItemdata()
  loadFielddata()
  loadAudiodata()
  loadAbilitydata()
  data.FinishLoad()
  
  ItemFactory.initItemFactory()
  MapFactory.initMapBuffer()
  Unit.initUnitFactions()
  UnitFactory.initUnitFactory()
  
end