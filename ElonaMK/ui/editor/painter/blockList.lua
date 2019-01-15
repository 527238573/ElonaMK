local suit = require "ui/suit"

local tiles_info = {w=266 , h= 10*38,opt ={id={}},scrollrect_opt={id={},vertical = true}}
local label_opt = {align = "left"}

local block_data = data.block
local typeTable = {}
local block_select 

local IconButton = require"ui/component/editor/iconButton"

function editor.blockList_init()
  for i=1,#block_data do
    local info = block_data[i]
    local typename = info.type
    if typeTable[typename] == nil then
      typeTable[typename] = {}
    end
    table.insert(typeTable[typename],i)
  end
  
  local perLine = 7
  tiles_info.h = 0
  for _,v in pairs(typeTable) do
    v.height = math.ceil(#v/perLine) *38
    tiles_info.h =  tiles_info.h +22 + v.height
    
  end
end


return function (x,y,w,h)
  local opt = tiles_info.opt
  
  suit:ScrollRect(tiles_info,tiles_info.scrollrect_opt,x,y,w,h)
  suit:registerHitbox(opt,opt.id, x,y,w-17,h) -- 底板
  
  y=tiles_info.y
  local itemstates = suit:standardState(opt.id)
  for k,v in pairs(typeTable) do
    suit:Label(k,label_opt,x,y,120,22)
    y=y+22
    for i=1,#v do
      local xoff = (i-1)%7*38
      local yoff = math.floor((i-1)/7)*38
      local index = v[i]
      local memberState = IconButton(block_data[index],x+xoff,y+yoff,block_select ==index)
      if memberState.hit then 
        block_select = index
        editor.selctBlockInfo = block_data[index]
      end
      suit:mergeState(itemstates,memberState)
    end
    y=y+v.height
  end
  
  
  suit:endScissor()
  suit:wheelRoll(itemstates,tiles_info)
  
  
end