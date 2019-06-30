local suit = require "ui/suit"


local dlg = {x=400,y=130,font = c.btn_font, dragopt = {id={}}}
local closeBtn_Opt = {id ={}}
local close_quads = c.pic.close_quads

local w_input_info = {text = "",opt = {id={}}}
local h_input_info = {text = "",opt = {id={}}}
local edge_input_info = {text = "",opt = {id={}}}
local textinput_info = {text = "",opt = {id={}}}
local weight_input_info = {text = "100",opt = {id={}}}

local confirm_opt = {id={}}
local cancel_opt = {id={}}
local label_opt = {color={33/255,33/255,33/255}}

local read_value = false

return function()
  
  if not read_value then 
    read_value = true
    local map = editor.map
    w_input_info.text = tostring(map.w); h_input_info.text = tostring(map.h);
    edge_input_info.text = tostring(map.edge)
    textinput_info.text = map.id or ""
    --weight_input_info.text = tostring(map.weight)
    
    debugmsg("map.id:"..map.id)
  end
  
  suit:DragArea(dlg,true,dlg.dragopt)
  suit:Dialog("调整地图尺寸",dlg,dlg.x,dlg.y, 400,270)
  suit:DragArea(dlg,false,dlg.dragopt,dlg.x,dlg.y,400,30)
  
  local close_st = suit:ImageButton(close_quads,closeBtn_Opt,dlg.x+369,dlg.y+3,30,24)
  
  suit:Label("W:",label_opt,dlg.x+30,dlg.y+60,50,22)
  suit:Input(w_input_info, w_input_info.opt,dlg.x+80,dlg.y+60,185,22)
  suit:Label("H:",label_opt,dlg.x+30,dlg.y+90,50,22)
  suit:Input(h_input_info, h_input_info.opt,dlg.x+80,dlg.y+90,185,22)
  suit:Label("edge:",label_opt,dlg.x+30,dlg.y+120,50,22)
  suit:Input(edge_input_info, edge_input_info.opt,dlg.x+80,dlg.y+120,185,22)
  
  suit:Label("Map name id:",label_opt,dlg.x+30,dlg.y+150,130,22)
  suit:Input(textinput_info, textinput_info.opt,dlg.x+190,dlg.y+150,185,22)
  
  suit:Label("weight:",label_opt,dlg.x+30,dlg.y+180,130,22)
  suit:Input(weight_input_info, weight_input_info.opt,dlg.x+190,dlg.y+180,185,22)
  
  
  local s_confirm = suit:S9Button("Confirm",confirm_opt,dlg.x+70,dlg.y+220,80,26)
  local s_cancel = suit:S9Button("Cancel",cancel_opt,dlg.x+250,dlg.y+220,80,26)
  
  if(s_cancel.hit or close_st.hit) then
    read_value = false
    editor.popwindow = nil
  end
  if s_confirm.hit then
    read_value = false
    editor.popwindow = nil
    editor.changeMapSize(tonumber(w_input_info.text) or 20,tonumber(h_input_info.text) or 20,tonumber(edge_input_info.text) or 0,textinput_info.text)
  end
end