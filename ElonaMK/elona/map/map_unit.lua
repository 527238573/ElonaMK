


--新加入map。因为会插入列表，所以只能在不在地图时加。
function Map:unitEnter(unit,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  assert(unit.map ==nil)
  if unit:is_dead() then
    debugmsg("Warning:dead unit cant enter map")
    return 
  end
  if self.unit[y*self.w+x+1]~= c.empty then
    debugmsg("Warning:unit enter another unit's position")
  end
  unit.x = x
  unit.y = y
  self.unit[y*self.w+x+1] = unit
  unit.map = self
  table.insert(self.activeUnits,unit)
end

function Map:unitLeave(unit)
  unit.map = nil
  local x = unit.x
  local y = unit.y
  if not(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) then
    debugmsg("Warning:Leaving unit out of map")
    return
  end
  if self.unit[y*self.w+x+1]== unit then
    self.unit[y*self.w+x+1] = c.empty
  else
    debugmsg("Warning:Leaving unit with wrong coordinate")
    return
  end
end

function Map:unitMove(unit,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) --不检查位置不能调用此函数
  assert(unit.map ==self) --必须已在地图上。
  local sx = unit.x
  local sy = unit.y
  if self.unit[sy*self.w+sx+1]== unit then
    self.unit[sy*self.w+sx+1] = c.empty
  else
    debugmsg("Warning:Leaving unit with wrong coordinate")
  end
  
  if self.unit[y*self.w+x+1]~= c.empty then
    debugmsg("Warning:unit enter another unit's position")
  end
  unit.x = x
  unit.y = y
  self.unit[y*self.w+x+1] = unit
end



--取得定点上的unit
function Map:unit_at(x,y)
  if not (x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) then return nil end
  local unit = self.unit[y*self.w+x+1]
  if unit== c.empty then unit =nil end
  return unit
end