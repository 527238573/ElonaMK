


--新加入map。并插入活跃列表
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
  self.activeUnits[unit] = true
end

function Map:unitLeave(unit)
  unit.map = nil
  local x = unit.x
  local y = unit.y
  if not(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) then
    --debugmsg("Warning:Leaving unit out of map")
    return
  end
  if self.unit[y*self.w+x+1]== unit then
    self.unit[y*self.w+x+1] = c.empty
  else
    --debugmsg("Warning:Leaving unit with wrong coordinate")
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


--将新unit放置在x，y位置。
function Map:unitSpawn(unit,x,y,force)
  force = force or true --默认强制生成。
  if not self:inbounds(x,y) then --若超出范围
    x =c.clamp(x,0,self.w-1)
    y =c.clamp(y,0,self.h-1)
  end
  --优先找空位，其次找可通行。再次就是XY原地不可通行。

  local function spawn(nx,ny)
    self:unitEnter(unit,nx,ny)
  end

  local findsec = false --是否找到第二可行
  local sx,sy
  for nx,ny in c.closest_xypoint_rnd(x,y,4) do--9*9的方框内。够大了
    if self:can_pass(nx,ny) then
      if self:unit_at(nx,ny) ==nil then
        --找到合理的放置点
        spawn(nx,ny)
        return true
      else
        if findsec==false then
          findsec = true --找到第二合理点（能行走但有其他单位占据）
          sx,sy = nx,ny
        end
      end
    end
  end
  if force then
    if findsec then
      spawn(sx,sy)
    else
      spawn(x,y)--可能生成至墙内
    end
  end
  return false
end

--从地图上移除。
function Map:unitDespawn(unit)
  self:unitLeave(unit)
  self.activeUnits[unit] = nil
end