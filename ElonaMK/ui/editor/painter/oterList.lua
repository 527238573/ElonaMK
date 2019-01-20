local suit = require "ui/suit"

local tile_data = data.oter
local tiles_info = {w=266 , h= 10*38,opt ={id=newid()},scrollrect_opt={id=newid(),vertical = true}}
local label_opt = {align = "left"}
local terImg = data.overmapImg


local tile_select --选择的index在tile_data中
local layer1List = {}
local layer2List = {}
local OtherList = {}

local IconButton = require"ui/component/editor/iconButton"


function editor.oterList_init()
  for i=1,#tile_data do
    local info = tile_data[i]
    if info.layer==1 then 
      table.insert(layer1List,i)
    elseif info.layer==2 then 
      table.insert(layer2List,i)
    else
      table.insert(OtherList,i)
    end
  end
  local perLine = 7
  layer1List.height = math.ceil(#layer1List/perLine) *38
  layer2List.height = math.ceil(#layer2List/perLine)*38
  OtherList.height = math.ceil(#OtherList/perLine)*38
  tiles_info.h = 22*3+layer1List.height +layer2List.height +OtherList.height 
end



return function (x,y,w,h)
  local opt = tiles_info.opt
  
  suit:ScrollRect(tiles_info,tiles_info.scrollrect_opt,x,y,w,h)
  suit:registerHitbox(opt,opt.id, x,y,w-17,h) -- 底板
  
  y = tiles_info.y
  local itemstates = suit:standardState(opt.id)
  suit:Label("Layer1 Tile:",label_opt,x,y,180,22)
  y=y+22
  for i=1,#layer1List do
    
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = layer1List[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctOterInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+layer1List.height
  suit:Label("Layer2 Tile:",label_opt,x,y,120,22)
  y=y+22
  for i=1,#layer2List do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = layer2List[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctOterInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+layer2List.height
  suit:Label("Other Tile:",label_opt,x,y,120,22)
  y=y+22
  for i=1,#OtherList do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = OtherList[i]
    local memberState = IconButton(tile_data[index],x+xoff,y+yoff,tile_select ==index,terImg)
    if memberState.hit then 
      tile_select = index
      editor.selctOterInfo = tile_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end
  
  
  suit:endScissor()
  suit:wheelRoll(itemstates,tiles_info)
end
