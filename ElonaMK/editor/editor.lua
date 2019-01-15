editor={}
require"file/saveTAdv"
local MapClass = require"elona/map/map"
local CameraClass = require"elona/camera/camera"

editor.home = love.filesystem.getSourceBaseDirectory().."/map"

function editor.init()

  debugmsg(editor.home)
  editor.topbar_H = 30
  editor.painterPanel_W = 300
  
  editor.camera = CameraClass.new(0,editor.topbar_H,c.win_W-editor.painterPanel_W,c.win_H-editor.topbar_H)--工作区域在屏幕上的起始坐标
  editor.newFile()
  editor.showBlock = true
  editor.showEdgeShadow = true
end


local function setTerRange(terid,x,y)
  if love.keyboard.isDown("lshift") then
    editor.map:setTer(terid,x,y)
    for sx = -2,2 do
      for sy = -2,2 do
        if editor.map:inbounds_edge(x+sx,y+sy) then
          editor.map:setTer(terid,x+sx,y+sy)
        end
      end
    end
  else
    editor.map:setTer(terid,x,y)
  end
end



local function brushTerrain(x,y)
  if editor.erase then
    if(editor.map:inbounds_edge(x,y) and editor.default_ter) then
      setTerRange(editor.default_ter.index,x,y)
      render.terDirty()
    end
    return
  end
  if editor.selctTileInfo ==nil then return end
  if( editor.map:inbounds_edge(x,y)) then
    setTerRange(editor.selctTileInfo.index,x,y)
    render.terDirty()
  end
end

local function brushBlock(x,y)
  if editor.erase then
    if(editor.map:inbounds_edge(x,y)) then
      editor.map:setBlock(1,x,y)
    end
    return
  end
  if editor.selctBlockInfo ==nil then return end
  if(editor.map:inbounds_edge(x,y)) then
    editor.map:setBlock(editor.selctBlockInfo.index,x,y)
  end
end
function editor.brushSquare(x,y)
  if editor.curPainterSelct ==1 then
    brushTerrain(x,y)
  elseif editor.curPainterSelct ==2 then
    brushBlock(x,y)
  end
end


function editor.changeMapSize(w,h,edge,id)
  if w~=editor.map.w or h~=editor.map.h or edge~=editor.map.edge then
    local omap = MapClass.new(w,h,edge)
    omap:copyFrom(editor.map)
    editor.repalceMap(omap)
  end
  editor.map.id = id
end
function editor.repalceMap(result)
  editor.map = result
  editor.size_str = "长宽:"..editor.map.w.."×"..editor.map.h.." edge:"..editor.map.edge
  editor.camera:updateRect(editor.map)
  render.terDirty()
end 



local curFileName = nil
local curFilePath = nil

function editor.newFile()
  curFileName = nil
  curFilePath = nil
  love.window.setTitle("MapEditor")
  editor.map = MapClass.new(20,20,0)
  editor.size_str = "长宽:"..editor.map.w.."×"..editor.map.h.." edge:"..editor.map.edge
  editor.camera:updateRect(editor.map)
end

function editor.saveOld()
  if curFileName == nil then 
    editor.popwindow = editor.saveFileDialog
  else
    editor.internalSave(curFileName,curFilePath)
  end
end

--传递的name带后缀   path为目录+sep
function editor.openFile(name,path)
  curFilePath = path..name
  local result,err = table.loadAdv(curFilePath)
  print("load",result,err)
  io.flush()
  --for k,v in pairs(result) do debugmsg("k:"..k.." v:"..tostring(v)) end
  if result and type(result)=="table" and result.edge then
    
    debugmsg("replace")
    curFileName = name
    love.window.setTitle("MapEditor-"..name)
    editor.repalceMap(result)
  end
end

--可能不带后缀，也可能带  path为目录+sep
function editor.saveFile(name,path)
  
  if not(#name > 4 and name:sub(-4,-1) == ".lua") then
    name = name..".lua"
  end
  curFilePath = path..name
  editor.internalSave(name,curFilePath)
end

function editor.internalSave(name,fullpath)
  local result,err  = table.saveAdv(  editor.map,curFilePath )
  print("save",result,err)
  io.flush()
  if result ==1 then
    curFileName = name
    love.window.setTitle("MapEditor-"..name)
  end
end
