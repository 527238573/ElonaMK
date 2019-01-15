local suit = require "ui/suit"

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()
local panel_opt = {id=newid()}
local squre_layer = {data={"terrain","block","field","item"},select= 1,opt= {id={}}}

local terrain_list = require "ui/editor/painter/terList"
local block_list = require "ui/editor/painter/blockList"

local eraseImg = love.graphics.newImage("assets/ui/erase.png")
local IconButton = require"ui/component/editor/iconButton"
local miniMap = require"ui/component/editor/minimap"


function editor.rollLayer(dx)
  squre_layer.select = squre_layer.select+dx
  if squre_layer.select<=0 then squre_layer.select = #squre_layer.data end
  if squre_layer.select>#squre_layer.data then squre_layer.select = 1 end
  
end


return function()
  local x,y,w,h = win_width-300,30,300,win_height-30
  
  suit:Panel(panel_opt,x,y,w,h)
  
  miniMap(editor.map,editor.camera,x+25,y+25,250,250)
  
  y=y+300

  if squre_layer.select == 1 then
    terrain_list(x+10,y+60,266,500)
  elseif squre_layer.select == 2 then
    block_list(x+10,y+60,266,500)
  end
  suit:ComboBox(squre_layer,squre_layer.opt,x+10,y+30,140,24)
  
  if editor.erase then
    if squre_layer.select ==1  and editor.default_ter then
      IconButton(editor.default_ter,x+180,y+10,false,data.terImg)
    end
    
    
    local er = suit:Image(eraseImg,x+200,y+10,64,64)
    
    if er.hit  and squre_layer.select ==1 then
      editor.default_ter = editor.selctTileInfo
    end
    
  end
  
  
  editor.curPainterSelct = squre_layer.select
end