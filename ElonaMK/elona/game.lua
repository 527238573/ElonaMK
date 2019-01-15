g={
  current_Scene= 0,
  
}

function g.runScene(scene)
  if g.current_Scene~=nil and g.current_Scene~=0 then g.current_Scene.leave() end
  g.current_Scene = scene
  scene.enter()
end