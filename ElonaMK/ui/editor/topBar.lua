local suit = require "ui/suit"
local back_img = love.graphics.newImage("assets/ui/greybar.png")
local back_s9t = suit.createS9Table(back_img,0,0,96,27,3,3,3,3)

local filebtn_img = love.graphics.newImage("assets/ui/anniu.png")

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()

local panel_opt = {id={}}
local newfile_opt = {id={},[1] = love.graphics.newQuad(0,0,32,32,32,128),img = filebtn_img}
local open_opt = {id={},[1] = love.graphics.newQuad(0,32,32,32,32,128),img = filebtn_img}
local save_opt = {id={},[1] = love.graphics.newQuad(0,64,32,32,32,128),img = filebtn_img}
local saveas_opt = {id={},[1] = love.graphics.newQuad(0,96,32,32,32,128),img = filebtn_img}
local changeSize_btn_opt = {id={},font = c.btn_font,quads = c.pic["editor_btn_quads"]}
local test_opt = {id={},quads = c.pic["editor_btn_quads"]}

local showSetting_btn = {id={},font = c.btn_font,quads = c.pic["editor_btn_quads"]}
local changesize_dlg = require"ui/editor/changeSizeDlg"
--local floor_setter = require"eui/component/floorSetter"
--local mapfile = require"file/mapfile"

local IconButton = require"ui/component/editor/iconButton"

local blockFullScreen = {}
local showMesh = {text = "showGrid",checked = false}
local showBlock = {text = "showblock",checked = true}
local showEdgeShadow = {text = "showEdgeShadow",checked = true}
local show_setting_opt = {id=newid()}
local function showSetting()
  
  suit:registerHitFullScreen(nil,blockFullScreen)
  
  suit:Panel(show_setting_opt,410,30,140,120)
  
  local showgrid_state = suit:Checkbox(showMesh, 410,32,130,26)
  local showblock_state = suit:Checkbox(showBlock, 410,62,130,26)
  local showEdgeShadow_state = suit:Checkbox(showEdgeShadow, 410,92,130,26)
  
  if suit:mouseReleasedOn(blockFullScreen) then
    editor.popwindow = nil
  end
  
  if(showgrid_state.change) then editor.showGrid = showMesh.checked end
  if(showblock_state.change) then editor.showBlock = showBlock.checked end
  if(showEdgeShadow_state.change) then editor.showEdgeShadow = showEdgeShadow.checked end
end
  




return function()
  local x,y,w,h = 0,0,win_width,30
  suit:Image(back_s9t,panel_opt,x,y,w,h)
  
  local s_newfile  = IconButton(newfile_opt,newfile_opt,4,0,false)
  local s_open  = IconButton(open_opt,open_opt,49,0,false)
  local s_save  = IconButton(save_opt,save_opt,94,0,false)
  local s_saveas  = IconButton(saveas_opt,saveas_opt,139,0,false)
  
  --local showgrid_state = suit.Checkbox(showMesh, 410,2,90,26)
  
  local showSetting_state = suit:S9Button("show menu",showSetting_btn,410,2,90,26)
  
  local s_sizebtn = suit:S9Button(editor.size_str,changeSize_btn_opt,500,2,170,26)
  
  --floor_setter(680,4)
  
  
  --eui.Panel(panel_opt,x,y,w,h)
  
  local tests = suit:S9Button("test",test_opt,1200,2,60,26)
  
  if(s_newfile.hit) then editor.newFile() end
  if(s_open.hit) then editor.popwindow = editor.openFileDialog end
  if(s_save.hit) then editor.saveOld() end
  if(s_saveas.hit) then editor.popwindow = editor.saveFileDialog end
  
  
  if(showSetting_state.hit) then editor.popwindow = showSetting end
  if(s_sizebtn.hit) then editor.popwindow = changesize_dlg end
  
  
  if tests.hit then
    print(love.math.random(0,-17.43))
    io.flush()
  end
end
