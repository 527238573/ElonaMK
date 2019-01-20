editor={}
require"file/saveTAdv"
local MapClass = require"elona/map/map"
local OvermapClass = require"elona/map/overmap"
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


local function brushRiverEdge(x,y)
  
  local function isRiver(x,y)
    if (not editor.map:inbounds(x,y)) then return false end
    return data.oter[editor.map:getLayer1(x,y)].flags["RIVER"]
  end
  
  local function riverEdge(x,y)
    if (not editor.map:inbounds(x,y)) then return end
    if isRiver(x,y) then return end
    local up = isRiver(x,y+1)
    local right = isRiver(x+1,y)
    local down = isRiver(x,y-1)
    local left = isRiver(x-1,y)
    if up and right then 
      editor.map:setLayer1(50,x,y)
    elseif up and left then 
      editor.map:setLayer1(49,x,y)
    elseif down and right then 
      editor.map:setLayer1(52,x,y)
    elseif down and left then 
      editor.map:setLayer1(51,x,y)
    elseif up then 
      editor.map:setLayer1(47,x,y)
    elseif down then 
      editor.map:setLayer1(41,x,y)
    elseif right then 
      editor.map:setLayer1(43,x,y)
    elseif left then 
      editor.map:setLayer1(45,x,y) 
    elseif isRiver(x-1,y+1) then --upleft
      editor.map:setLayer1(48,x,y) 
    elseif isRiver(x+1,y+1) then --upright
      editor.map:setLayer1(46,x,y) 
    elseif isRiver(x-1,y-1) then --downleft
      editor.map:setLayer1(42,x,y) 
    elseif isRiver(x+1,y-1) then --downright
      editor.map:setLayer1(40,x,y) 
    end
  end
  riverEdge(x+1,y)
  riverEdge(x-1,y)
  riverEdge(x,y+1)
  riverEdge(x,y-1)
  riverEdge(x+1,y+1)
  riverEdge(x-1,y+1)
  riverEdge(x+1,y-1)
  riverEdge(x-1,y-1)
end


local function brushOter(x,y)
  if editor.erase then
    if(editor.map:inbounds(x,y)) then
      editor.map:setLayer2(1,x,y)
      render.oterDirty()
    end
    return
  end
  if editor.selctOterInfo ==nil then return end
  if(editor.map:inbounds(x,y)) then
    if editor.selctOterInfo.layer ==1 then
      if love.keyboard.isDown("lshift") then
        for sx = -2,2 do
          for sy = -2,2 do
            if editor.map:inbounds(x+sx,y+sy) then
              editor.map:setLayer1(editor.selctOterInfo.index,x+sx,y+sy)
            end
          end
        end
      else
        
        editor.map:setLayer1(editor.selctOterInfo.index,x,y)
        if editor.selctOterInfo.flags["RIVER"] then
          brushRiverEdge(x,y)
        end
      end
    elseif editor.selctOterInfo.layer ==2 then
      editor.map:setLayer2(editor.selctOterInfo.index,x,y)
    end
    render.oterDirty()
  end
end


function editor.brushSquare(x,y)
  if editor.overmapMode  then
    brushOter(x,y)
  else
    if editor.curPainterSelct ==1 then
      brushTerrain(x,y)
    elseif editor.curPainterSelct ==2 then
      brushBlock(x,y)
    end
  end
end


function editor.changeMapSize(w,h,edge,id)
  if editor.overmapMode == false then 
    if w~=editor.map.w or h~=editor.map.h or edge~=editor.map.edge then
      local omap = MapClass.new(w,h,edge)
      omap:copyFrom(editor.map)
      editor.repalceMap(omap)
    end
  else
    if w~=editor.map.w or h~=editor.map.h then
      local omap = OvermapClass.new(w,h)
      omap:copyFrom(editor.map)
      editor.repalceMap(omap)
    end
  end
  editor.map.id = id
end
function editor.repalceMap(result)
  if result.saveType =="Map" then
    editor.overmapMode = false
    editor.map = result
    editor.size_str = "map:长宽:"..editor.map.w.."×"..editor.map.h.." edge:"..editor.map.edge
    editor.camera:updateRect(editor.map)
    render.terDirty()
  elseif result.saveType =="Overmap" then
    editor.overmapMode = true
    editor.map = result
    editor.size_str = "Overmap:长宽:"..editor.map.w.."×"..editor.map.h
    editor.camera:updateRect(editor.map)
    render.oterDirty()
  else
    error("type error :editor.repalceMap")
  end
end 

function editor.copyOvermap(result)
  local copyOv = editor.copyOv
  editor.copyOv = nil
  if result.saveType ~="Overmap" then
    debugmsg("copy overmap error")
    return 
  end
  editor.map:copyFrom(result,copyOv[1],copyOv[2])
  render.oterDirty()
end


local curFileName = nil
local curFilePath = nil

function editor.newFile()
  curFileName = nil
  curFilePath = nil
  love.window.setTitle("MapEditor")
  editor.map = MapClass.new(20,20,0)
  editor.size_str = "map:长宽:"..editor.map.w.."×"..editor.map.h.." edge:"..editor.map.edge
  editor.camera:updateRect(editor.map)
  editor.overmapMode = false
  render.terDirty()
end

function editor.newOvermapFile()
  curFileName = nil
  curFilePath = nil
  love.window.setTitle("MapEditor")
  editor.map = OvermapClass.new(20,20)
  editor.size_str = "Overmap:长宽:"..editor.map.w.."×"..editor.map.h
  editor.camera:updateRect(editor.map)
  editor.overmapMode = true
  render.oterDirty()
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
  if result and type(result)=="table" and result.w then

    if editor.copyOv then 
      editor.copyOvermap(result)
    else
      debugmsg("replace")
      curFileName = name
      love.window.setTitle("MapEditor-"..name)
      editor.repalceMap(result)
    end
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
