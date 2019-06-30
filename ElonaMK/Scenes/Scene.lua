
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