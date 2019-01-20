local suit = require "ui/suit"


local dlg = {x=400,y=130,font = c.btn_font, dragopt = {id={}}}
local closeBtn_Opt = {id ={}}
local close_quads = c.pic.close_quads

local x_input_info = {text = "0",opt = {id={}}}
local y_input_info = {text = "0",opt = {id={}}}
local confirm_opt = {id={}}
local cancel_opt = {id={}}
local label_opt = {color={33/255,33/255,33/255}}

local read_value = false

return function()
  
  if not read_value then 
    read_value = true
    x_input_info.text = "0"
    y_input_info.text = "0"
  end
  
  suit:DragArea(dlg,true,dlg.dragopt)
  suit:Dialog("复制overmap到指定坐标",dlg,dlg.x,dlg.y, 400,270)
  suit:DragArea(dlg,false,dlg.dragopt,dlg.x,dlg.y,400,30)
  
  local close_st = suit:ImageButton(close_quads,closeBtn_Opt,dlg.x+369,dlg.y+3,30,24)
  
  suit:Label("W:",label_opt,dlg.x+30,dlg.y+60,50,22)
  suit:Input(x_input_info, x_input_info.opt,dlg.x+80,dlg.y+60,185,22)
  suit:Label("H:",label_opt,dlg.x+30,dlg.y+90,50,22)
  suit:Input(y_input_info, y_input_info.opt,dlg.x+80,dlg.y+90,185,22)
  
  
  local s_confirm = suit:S9Button("Confirm",confirm_opt,dlg.x+70,dlg.y+220,80,26)
  local s_cancel = suit:S9Button("Cancel",cancel_opt,dlg.x+250,dlg.y+220,80,26)
  
  if(s_cancel.hit or close_st.hit) then
    read_value = false
    editor.popwindow = nil
  end
  if s_confirm.hit then
    read_value = false
    local x = tonumber(x_input_info.text) or 0
    local y = tonumber(y_input_info.text) or 0
    editor.copyOv = {x,y}
    editor.popwindow = editor.openFileDialog
  end
end