
local suit = require"ui/suit"
editor.painterPanel = require"ui/editor/painterPanel"
editor.topbar = require"ui/editor/topbar"
editor.touch = require"ui/editor/touch"
require"ui/editor/fileDlg"
function editor.uiInit()
  editor.popwindow = nil--弹出窗口
  editor.terrainList_init()
  editor.blockList_init()
  editor.oterList_init()
  editor.itemList_init()
  editor.fieldList_init()
end


function editor.uiLayer()
  editor.touch()
  editor.topbar()
  editor.painterPanel()

  if editor.popwindow then editor.popwindow() end--弹出窗口，最上层
end


function editor.handleKeyPressed(key)
  if not suit:anyKeyboardFocus() then
    if(key == 'e') then 
      editor.erase=true
    elseif (key == 'q') then 
      editor.erase=false
    elseif key=='f' then
      editor.map.refreshMiniMap = true
      
    elseif key=='w' then
      editor.rollLayer(-1)
    elseif key=='s' then
      editor.rollLayer(1)
    end
  end
end