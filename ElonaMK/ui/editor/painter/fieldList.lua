local suit = require "ui/suit"


local tiles_info = {w=266 , h= 10*38,opt ={id={}},scrollrect_opt={id={},vertical = true}}
local label_opt = {align = "left"}


local field_data = data.field
local typeTable = {}
local field_select 

local IconButton = require"ui/component/editor/iconButton"


function editor.fieldList_init()
  for _,v in pairs(field_data) do
    local info = v
    local typename = "all" --数量少，统一到一个里
    if typeTable[typename] == nil then
      typeTable[typename] = {}
    end
    table.insert(typeTable[typename],info)
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
      local info = v[i]
      local memberState = IconButton(info,x+xoff,y+yoff,field_select ==info)
      if memberState.hit then 
        field_select = info
        editor.selctFieldInfo = info
      end
      suit:mergeState(itemstates,memberState)
    end
    y=y+v.height
  end
  suit:endScissor()
  suit:wheelRoll(itemstates,tiles_info)
end
