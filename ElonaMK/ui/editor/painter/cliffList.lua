local suit = require "ui/suit"

local tiles_info = {w=266 , h= 10*38,opt ={id={}},scrollrect_opt={id={},vertical = true}}
local label_opt = {align = "left"}

local cliffImg = data.terImg
local cliff_data = data.cliff
local typeTable = {}
local cliff_select 
local height_select
local pattern_select
local IconButton = require"ui/component/editor/iconButton"

local altTude = {}

local patternImg = love.graphics.newImage("assets/ui/cliff_pattern.png")

function editor.cliffList_init()
  for i=1,7 do
    altTude[i] = {img = patternImg ,[1] = love.graphics.newQuad((i-1)*32,0,32,32,patternImg:getWidth(),patternImg:getHeight())}
  end
  
  for i=8,14 do
    altTude[i] = {img = patternImg ,[1] = love.graphics.newQuad((i-8)*32,32*1,32,32,patternImg:getWidth(),patternImg:getHeight())}
  end
  for i=15,15 do
    altTude[i] = {img = patternImg ,[1] = love.graphics.newQuad((i-15)*32,32*2,32,32,patternImg:getWidth(),patternImg:getHeight())}
  end
  


  local perLine = 7
  tiles_info.h = 0

  tiles_info.h = tiles_info.h +22 +38 *3 --cliff_pattern

  tiles_info.h =  tiles_info.h +22 + math.ceil(#cliff_data/perLine) *38

end


return function (x,y,w,h)
  local opt = tiles_info.opt

  suit:ScrollRect(tiles_info,tiles_info.scrollrect_opt,x,y,w,h)
  suit:registerHitbox(opt,opt.id, x,y,w-17,h) -- 底板

  y=tiles_info.y
  local itemstates = suit:standardState(opt.id)
  
  suit:Label("高度height",label_opt,x,y,120,22)
  y=y+22
  for i=1,#altTude do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = i
    local memberState = IconButton(altTude[index],x+xoff,y+yoff,height_select ==index)
    if memberState.hit then 
      height_select = index
      editor.selctCliffPattern = i
    end
    suit:mergeState(itemstates,memberState)
  end
  y=y+38*3
  
  suit:Label("cliff",label_opt,x,y,120,22)
  y=y+22
  for i=1,#cliff_data do
    local xoff = (i-1)%7*38
    local yoff = math.floor((i-1)/7)*38
    local index = i
    local memberState = IconButton(cliff_data[index],x+xoff,y+yoff,cliff_select ==index,cliffImg)
    if memberState.hit then 
      cliff_select = index
      editor.selctCliffInfo = cliff_data[index]
    end
    suit:mergeState(itemstates,memberState)
  end

  suit:endScissor()
  suit:wheelRoll(itemstates,tiles_info)
end