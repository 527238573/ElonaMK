
Scene = {
  enter = function() end,
  leave = function() end,
  update = function() end,
  draw = function() end,
  keypressed = function() end
}
Scene.__index = Scene
Scene.__newindex = function(o,k,v)
  if Scene[k]==nil then error("使用了Scene的意料之外的值。") else rawset(o,k,v) end
end
function Scene.new()
  local o = {}
  setmetatable(o,Scene)
  return o
end

Scene.current_Scene= 0
Scene.overMap_scene =require"game/scenes/overMap"
Scene.mainGame_scene =require"game/scenes/mainGame"
Scene.enterWmap = false--状态
--在这里掌管地图切换等

function Scene.inOvermapMode()
  return Scene.current_Scene == Scene.overMap_scene
end

function Scene.enterWorldMap(x,y)
  p.x = x
  p.y = y
  Scene.enterWmap = true --记录下，等到checkNextScene时才切换。
end

function Scene.setNextMap(map,enterX,enterY)
  local nextMap = {map = map,x=enterX,y = enterY}
  Scene.nextMap = nextMap --记录下，等到checkNextScene时才切换。
end


function Scene.runScene(scene) 
  if scene~=Scene.current_Scene then Scene.next_Scene = scene end  --在新一帧开始时候切换scene。
end


function Scene.checkNextScene()
  if Scene.current_Scene ==Scene.overMap_scene or Scene.current_Scene == Scene.mainGame_scene then 
    --如果同一帧调用以上两个方法，优先进入大地图而不是另一张地图。
    if Scene.enterWmap then
      Scene.enterWmap = false
      Scene.nextMap = nil
      if cmap then
        cmap:leaveMap()
        cmap = nil
      end
      debugmsg("enterOvmap")
      Scene.runScene(Scene.overMap_scene)
    elseif Scene.nextMap then
      if cmap then
        cmap:leaveMap()
        cmap = nil
      end
      cmap = Scene.nextMap.map
      cmap:enterMap(Scene.nextMap.x,Scene.nextMap.y)
      Scene.runScene(Scene.mainGame_scene)
      Scene.nextMap = nil
    end
  end --检查地图切换。此时是切换地图的时机。
  if Scene.next_Scene then --在一帧开始时检查切换scene
    if Scene.current_Scene~=nil and Scene.current_Scene~=0 then Scene.current_Scene.leave() end
    Scene.current_Scene = Scene.next_Scene
    Scene.next_Scene.enter()
    Scene.next_Scene = nil
  end
end

