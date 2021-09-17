--path会保存

Path = {
}
saveMetaType("Path",Path)--注册保存类型

function Path.new()
  local path = {x={},y ={},length = 0}
  setmetatable(path,Path)
  return path
end

--验证单位可通行。如果走到终点，或没有路length<=1  ,或单位不在路上，都是非法路径
function Path:isEnd()
  return self.length<=1
end

--,或单位不在路上，都是非法路径
function Path:isInvalid(unit)
  local l = self.length
  
  --debugmsg(string.format("path len:%d, unitxy(%d,%d) endNode(%d,%d)",l,unit.x,unit.y,self.x[l],self.y[l]))
  
  return l<=1 or unit.x ~= self.x[l] or unit.y~= self.y[l]
end


function Path:walkNext(unit)
  local x,y = self.x[self.length-1],self.y[self.length-1]
  local suc = unit:walk_to(x,y)
  if suc then self.length = self.length -1  end
  return suc
end