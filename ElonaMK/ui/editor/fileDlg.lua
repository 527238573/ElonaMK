local suit = require "ui/suit"
local lovefs = require "file/lovefs"
local fs = lovefs()
if not fs:cd(editor.home) then fs:makedir(editor.home) end
fs:cd(editor.home)


local textinput_img = love.graphics.newImage("ui/suit/assets/textback.png")
local blockFullScreen = {}
local dlg = {x=300,y=150,font = c.btn_font, dragopt = {id={}}}
local closeBtn_Opt = {id ={}}
local close_quads = c.pic.close_quads
local choseDrive = {data = fs.drives,select= 1,opt= {id={},titleText = "Change Dirve"}}
local curDir_opt = {color={33,33,33},font = c.cn12_font,align = "left"}
local filelist = {w= 480,h = 400,itemYNum= 12,opt ={id={}}} 
local up_fitem = {name = "..",ftype = "up"}
local confirm_opt = {id={}}
local cancel_opt = {id={}}
local textFilename_opt = {id={}}
local textinput_info = {text = "",opt = {id={}}}

local filters = {'MapFile | *.lua', 'All | *.*'}
local filter_combo = {data = filters,select= 1,opt= {id={}}}
fs:setFilter(filters[1])

local curFileName =""
local curSelect 


local fileButton = require"ui/editor/fileButton"

local function buildDirAndFile()
  local list = {}
  table.insert(list,up_fitem)
  for _, v in ipairs(fs.dirs) do
    table.insert(list,{name =v, ftype = "dir"})
  end
  for _, v in ipairs(fs.files) do
    table.insert(list,{name =v, ftype = "file"})
  end
  filelist.list= list
  filelist.h = #list * 26
end
buildDirAndFile()

local function fileDialog(isopen)
  suit:registerHitFullScreen(nil,blockFullScreen)
  suit:DragArea(dlg,true,dlg.dragopt)
  if isopen then suit:Dialog("open file",dlg,dlg.x,dlg.y, 500,420)
  else suit:Dialog("save file",dlg,dlg.x,dlg.y, 500,420) end
  suit:DragArea(dlg,false,dlg.dragopt,dlg.x,dlg.y,500,30)
  local s_close =  suit:ImageButton(close_quads,closeBtn_Opt,dlg.x+469,dlg.y+3,30,24)
  
  
  local s_confirm = suit:S9Button("OK",confirm_opt,dlg.x+330,dlg.y+387,80,26)
  local s_cancel = suit:S9Button("Cancel",cancel_opt,dlg.x+415,dlg.y+387,80,26)
  local s_filter = suit:ComboBox(filter_combo,filter_combo.opt,dlg.x+10,dlg.y+387,120,24)
  
  local s_input
  if isopen then
    suit:Image(textinput_img,textFilename_opt,dlg.x+133,dlg.y+387,195,26)
    suit:Label(curFileName,curDir_opt,dlg.x+138,dlg.y+387,185,26)
  else
    s_input = suit:Input(textinput_info, textinput_info.opt,dlg.x+138,dlg.y+387,185,26)
  end

  
  local item_hit=false
  suit:List(filelist,function(num,x,y,w,h)
      if num>#(filelist.list) then return end
      local state = fileButton(filelist.list[num], x,y,w,h,curSelect==num)
      if state.hit then item_hit = true;curSelect = num end
      return state
    end,filelist.opt,dlg.x+10,dlg.y+70,480,312)
  
  
  local s_drives =suit:ComboBox(choseDrive,choseDrive.opt,dlg.x+10,dlg.y+30,120,24)
  suit:Label(fs.current,curDir_opt,dlg.x+135,dlg.y+30,360,24)
  
  if item_hit then
    if curSelect==1 then 
      --向上
      curFileName =""
      curSelect =nil
      fs:up()
      buildDirAndFile()
    else
      local fitem =  filelist.list[curSelect]
      if fitem.ftype== "dir" then
        --打开文件夹
        curFileName =""
        curSelect =nil
        fs:cd(fitem.name)
        buildDirAndFile()
      else
        --选中文件
        curFileName = fitem.name
        if not isopen then
          textinput_info.text = curFileName
        end
      end
    end
  end
  if s_drives.changed then
    curFileName =""
    curSelect =nil
    fs:cd(choseDrive.data[choseDrive.select])
    buildDirAndFile()
  end
  if s_filter.changed then
    curFileName =""
    curSelect =nil
    fs:setFilter(filters[filter_combo.select])
    buildDirAndFile()
  end
  
  if(s_close.hit or s_cancel.hit) then
    editor.popwindow = nil
    curFileName =""
    curSelect =nil
    textinput_info.text = ""
  end
  if(s_confirm.hit) then
    if isopen then
      if curFileName~= "" then
        editor.openFile(curFileName,fs.current..fs.sep)
        editor.popwindow = nil
        curFileName =""
        curSelect =nil
      end
    else
      if textinput_info.text ~=""then 
        editor.saveFile(textinput_info.text,fs.current..fs.sep)
        editor.popwindow = nil
        curFileName =""
        curSelect =nil
        textinput_info.text = ""
      end
    end
  end
end

function editor.openFileDialog()
  fileDialog(true)
end

function editor.saveFileDialog()
  fileDialog(false)
end

