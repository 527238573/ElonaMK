--unit ai 相关的检查

--检查地格是否危险。危险的地格尽量不走
--0不危险，1危险战斗情况忽视 2 危险战斗没其他路才走 3没有其他路也不走
function Unit:squareDangerLevel(x,y,map)
  map = map or self.map
  
  return 0
end