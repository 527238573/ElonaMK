editor={}
require"file/saveTAdv"
local MapClass = Map
local OvermapClass = Overmap
local CameraClass = require"game/camera/camera"

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

local function shiftBrush(func,x,y)
  if love.keyboard.isDown("lshift") then
    for sx = -2,2 do
      for sy = -2,2 do
        func(x+sx,y+sy)
      end
    end
  else
    func(x,y)
  end
end





local function brushTerrain(x,y)
  if editor.erase then
    if(editor.map:inbounds_edge(x,y) and editor.default_ter) then
      editor.map:setTer(editor.default_ter.index,x,y)
      render.terDirty()
    end
    return
  end
  if editor.selctTileInfo ==nil then return end
  if( editor.map:inbounds_edge(x,y)) then
    editor.map:setTer(editor.selctTileInfo.index,x,y)
    render.terDirty()
  end
end

local stairsDx = {-1,1,0,0}
local stairsDy = {0,0,1,-1}

local function brushStairs(x,y,si)
  local map = editor.map
  local dx = stairsDx[si]
  local dy = stairsDy[si]
  if (not map:inbounds_edge(x+dx,y+dy)) then return end
  
  local cid,h = map:getCliffInfo(x,y)
  local cid2,h2 = map:getCliffInfo(x+dx,y+dy)
  if h<=0 then return end
  
  if (h2 -h)==1 then
    map:setCliff(cid,h,x,y,si)
    render.terDirty()
  end
end

local function brushRandomStairs(map,x,y)
  local targetCalls = {}
  for si=1,4 do
    local dx = stairsDx[si]
    local dy = stairsDy[si]
    if (map:inbounds_edge(x+dx,y+dy)) then
      local cid,h = map:getCliffInfo(x,y)
      local cid2,h2 = map:getCliffInfo(x+dx,y+dy)
      if (h>0) and ((h2 -h)==1) then
        local function tcall()
          map:setCliff(cid,h,x,y,si)
          render.terDirty()
        end
        targetCalls[#targetCalls+1] = tcall--加入队列
      end
    end
  end
  
  if #targetCalls>1 then
    targetCalls[rnd(1,#targetCalls)]()
  elseif #targetCalls>0 then
    targetCalls[1]()
  end
end





local function smoothCliff(map,x,y)
  local cid,h,pat = map:getCliffInfo(x,y)
    --if h<1 then return end
    --先检测pattern是否合法
    if pat >0 then
      local dx = stairsDx[pat]
      local dy = stairsDy[pat]
      if (not map:inbounds_edge(x+dx,y+dy)) then 
        pat = 0--不允许靠外侧的斜坡
      else
        local cid2,h2 = map:getCliffInfo(x+dx,y+dy)
        if (h2 -h)~=1 then pat = 0 end --消除斜坡
      end
    end
    
    --再检测高度是否平滑
    local function checkLow(dx,dy)
      if map:inbounds_edge(x+dx,y+dy) then
        local did,downh,dpattern = map:getCliffInfo(x+dx,y+dy)
        downh = downh+ (dpattern>0 and 1 or 0)--计算高度时有斜坡的地方算高处
        if (downh-1>h) then 
          cid = did
          h = downh-1 
          pat = 0 --被迫抬升后消除斜坡
        end
      end
    end
    checkLow(1,1)
    checkLow(0,1)
    checkLow(-1,1)
    checkLow(1,0)
    checkLow(-1,0)
    checkLow(1,-1)
    checkLow(0,-1)
    checkLow(-1,-1)
    map:setCliff(cid,h,x,y,pat)
    render.terDirty()
  
end


local function brushCliff(x,y)
  local pattern = editor.erase  and 3 or (editor.selctCliffPattern or 3)
  
  local alt = pattern -1
  local selctIndex = 1
  if editor.selctCliffInfo  then selctIndex = editor.selctCliffInfo.index end
  local map = editor.map
  if (not map:inbounds_edge(x,y)) then return end
  
  if pattern <=7 then --普通悬崖
    if alt >=0 then
      map:setCliff(selctIndex,alt,x,y)
      map:setTer(17,x,y) --empty——ter
      
      render.terDirty()
      return
    end
  elseif pattern ==8 then --清除悬崖
    local cid,h,pat = map:getCliffInfo(x,y)
    if pat >0 then
      map:setCliff(cid,h,x,y,0)
      render.terDirty()
    end
  elseif pattern == 9 then --平滑悬崖
    smoothCliff(map,x,y)
  elseif pattern ==10 then --更换悬崖类型
    local cid,h,pat = map:getCliffInfo(x,y)
    if selctIndex~= cid then
      map:setCliff(selctIndex,h,x,y,pat)
      render.terDirty()
    end
  elseif pattern >=11 and pattern<=14 then
    brushStairs(x,y,pattern-10)
  elseif pattern == 15 then --平滑造坡
    brushRandomStairs(map,x,y)
    smoothCliff(map,x,y)
  elseif pattern == 16 then --平滑背后悬崖
    local cid,h = map:getCliffInfo(x,y)
    local did,downh = cid,h
    if map:inbounds_edge(x,y-1) then
      did,downh = map:getCliffInfo(x,y-1)
    end
    if downh-1>h then
      map:setCliff(cid,downh-1,x,y)
      render.terDirty()
    end
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



local function brushItem(x,y)
  if editor.erase then
    if(editor.map:inbounds(x,y)) then
      editor.map:clearSquareItem(x,y)
    end
    return
  end
  if editor.selctItemInfo ==nil then return end
  if(editor.map:inbounds(x,y)) then
    local item = ItemFactory.create(editor.selctItemInfo.id)
    editor.map:spawnItem(item,x,y)
  end
end

local function brushField(x,y)
  if editor.erase then
    if(editor.map:inbounds(x,y)) then
      editor.map:clearSquareField(x,y)
    end
    return
  end
  if editor.selctFieldInfo ==nil then return end
  if(editor.map:inbounds(x,y)) then
    local field = Field.new(editor.selctFieldInfo.id)
    editor.map:spawnField(field,x,y)
  end
end


function editor.brushSquare(x,y)
  if editor.overmapMode  then
    brushOter(x,y)
  else
    if editor.curPainterSelct ==1 then
      shiftBrush(brushTerrain,x,y)
    elseif editor.curPainterSelct ==2 then
      shiftBrush(brushCliff,x,y)
    elseif editor.curPainterSelct ==3 then
      brushBlock(x,y)
    elseif editor.curPainterSelct ==4 then
      brushItem(x,y)
    elseif editor.curPainterSelct ==5 then
      brushField(x,y)
    end
  end
end


function editor.changeMapSize(w,h,edge,id,offsetX,offsetY)
  local hasOffset = offsetX~=0 or offsetY ~=0

  if editor.overmapMode == false then 
    if w~=editor.map.w or h~=editor.map.h or edge~=editor.map.edge or hasOffset then
      local omap = MapClass.new(w,h,edge)
      omap:copyFrom(editor.map,offsetX,offsetY)
      omap:fetchFieldsFrom(editor.map,offsetX,offsetY)
      omap:fetchItemsFrom(editor.map,offsetX,offsetY)
      editor.repalceMap(omap)
    end
  else
    if w~=editor.map.w or h~=editor.map.h or hasOffset then
      local omap = OvermapClass.new(w,h)
      omap:copyFrom(editor.map,offsetX,offsetY)
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
  local result,err = c.LoadFile(curFilePath)
  print("load",result,err)
  io.flush()
  --for k,v in pairs(result) do debugmsg("k:"..k.." v:"..tostring(v)) end
  if result and type(result)=="table" and result.w then
    print("load map Template meta:",getmetatable(result))
    io.flush()

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

  if not(#name > 4 and name:sub(-4,-1) == ".bsr") then--以后优先bsr了
    name = name..".bsr"
  end
  curFilePath = path..name
  editor.internalSave(name,curFilePath)
end

function editor.internalSave(name,fullpath)
  local result,err  = c.SaveFile(  editor.map,curFilePath )
  print("save",result,err)
  io.flush()


  if result ==1 then
    curFileName = name
    love.window.setTitle("MapEditor-"..name)
  end
end
