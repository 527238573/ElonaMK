--path会保存

Path = {
}
saveMetaType("Path",Path)--注册保存类型

function Path.new()
  local path = {}
  setmetatable(path,Path)
  return path
end

