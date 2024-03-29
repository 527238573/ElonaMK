local suit = require "ui/suit"


local tile_data = data.ter
local tiles_info = {w=266 , h= 10*38,opt ={id={}},scrollrect_opt={id={},vertical = true}}
local label_opt = {align = "left"}
local terImg = data.terImg

local tile_select --选择的index在tile_data中
local hierarchyList = {}
local edgeList = {}
local singleList = {}
local walltopList = {}

local IconButton = require"ui/component/editor/iconButton"

function editor.terrainList_init()
  for i=1,#tile_data do
    local info = tile_data[i]
    if info.type=="hierarchy" then 
      table.insert(hierarchyList,i)
    elseif info.type=="edged" then 
      table.insert(edgeList,i)
      
    elseif info.type=="single" then 
      table.insert(singleList,i)
    elseif info.type=="walltop" then 
      table.insert(walltopList,i)
    end
  end
  
  
  local perLine = 7
  hierarchyList.height = math.ceil(#hierarchyList/perLine) *38
  edgeList.height = math.ceil(#edgeList/perLine)*38
  singleList.height = math.ceil(#singleList/perLine)*38
  walltopList.height = math.ceil(#walltopList/perLine)*38
  tiles_info.h = 22*4+hierarchyList.height +edgeList.height +singleList.height +walltopList.height
  
  
end

return function (x,y,w,h)
  local opt = tiles_info.opt
  
  suit:ScrollRect(tiles_info,tiles_info.scrollrect_opt,x,y,w,h)
  suit:registerHitbox(opt,opt.id, x,y,w-17,h) -- 底板
  
  y = tiles_info.y
  local itemstates = suit:standardState(opt.id)
  suit:Label("Hierarchical Tile:",label_opt,x,y,180,22)
  y=y+22
  for i=1,#hierarchyList do
    
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = hierarchyList[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctTileInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+hierarchyList.height
  suit:Label("Edged Tile:",label_opt,x,y,120,22)
  y=y+22
  for i=1,#edgeList do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = edgeList[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctTileInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+edgeList.height
  suit:Label("Single Tile:",label_opt,x,y,120,22)
  y=y+22
  for i=1,#singleList do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = singleList[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctTileInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+singleList.height
  suit:Label("Walltop Tile:",label_opt,x,y,120,22)
  y=y+22
  for i=1,#walltopList do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = walltopList[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctTileInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  
  
  
  suit:endScissor()
  suit:wheelRoll(itemstates,tiles_info)
end