g={
  current_Scene= 0,
  overMap_scene =require"Scenes/overMap",
  mainGame_scene =require"Scenes/mainGame",
  
  enterWmap = false,--状态
}

cmap = nil --当前地图
wmap = nil --大世界地图。
p = nil --当前player数据

function g.runScene(scene) 
  if scene~=g.current_Scene then g.next_Scene = scene end  --在新一帧开始时候切换scene。
end
function g.checkNextScene()
  if g.current_Scene ==g.overMap_scene or g.current_Scene == g.mainGame_scene then Map.checkNextMap() end --检查地图切换。此时是切换地图的时机。
  if g.next_Scene then --在一帧开始时检查切换scene
    if g.current_Scene~=nil and g.current_Scene~=0 then g.current_Scene.leave() end
    g.current_Scene = g.next_Scene
    g.next_Scene.enter()
    g.next_Scene = nil
  end
end

function g.inOvermapMode()
  return g.current_Scene == g.overMap_scene
end


local CameraClass = require"elona/camera/camera"
function g.initCamera()
  
  --editor.topbar_H = 30
  g.rightPanel_W = 300--只有右侧主面板
  g.camera = CameraClass.new(0,0,c.win_W-g.rightPanel_W,c.win_H)--工作区域在屏幕上的起始坐标
  g.wcamera = CameraClass.new(0,0,c.win_W-g.rightPanel_W,c.win_H)--大地图下的camera
end

g.curFrame = 1

function g.update(dt)
  if p.mc.delay<=0 then
    --检查操作。
    ui.mainGameKeyCheck(dt)
  end
  g.curFrame = g.curFrame+1
  if p.mc.delay>0 then
    g.updateRL(dt)
  end
  g.updateAnim(dt)
  
end


function g.updateRL(dt)
  p.calendar:updateRL(dt) --日期更新
  cmap:updateRL(dt)
end

function g.updateAnim(dt)
  cmap:updateAnim(dt)
end

--overmap模式更新入口
function g.updateOvermap(dt)
  if p.delay<=0 then
    --检查操作。
    ui.overmapKeyCheck(dt)
  end
  if p.delay>0 then
    p:updateOM(dt)
  end
end
