--切换map时用到的方法

--进入map，当前map设为cmap
function Map:enterMap(x,y)
  local gen_t = data.mapgen[self.gen_id]
  if gen_t then
    if gen_t.enter then
      gen_t.enter(self)
    end
  else
    debugmsg("warning:no gen_t map："..self.id)
  end
  --然后再刷新时间。
  self.lastTurn = p.calendar:getTurnpast()--刷新时间。
  --单位进入。
  self:unitSpawn(p.mc,x,y) --进入地图，mc第一个进入
  for i=1,p.teamNum do 
    local unit = p.team[i]
    if unit  and unit ~= p.mc then self:unitSpawn(unit,x,y) end --进入地图
  end
  addmsg(string.format(tl("你进入了%s。","You entered %s."),self.name))
end




--离开map
function Map:leaveMap()
  local gen_t = data.mapgen[self.gen_id]
  if gen_t then
    if gen_t.leave then
      gen_t.leave(self)
    end
  else
    debugmsg("warning:no gen_t map："..self.id)
  end
  --然后再刷新时间。
  self.lastTurn = p.calendar:getTurnpast()--刷新时间。
  --单位离开
  for i=1,p.teamNum do 
    local unit = p.team[i]
    if unit then self:unitDespawn(unit) end --从地图上解除。
  end
  addmsg(string.format(tl("你离开了%s。","You left %s."),self.name))
end


function Map:getEntrance(face)
  if face ==1 or face==2 then
    if self.south_entrance then return self.south_entrance[1],self.south_entrance[2] end
  elseif face ==3 or face==4 then
    if self.west_entrance then return self.west_entrance[1],self.west_entrance[2] end
  elseif face ==5 or face==6 then
    if self.north_entrance then return self.north_entrance[1],self.north_entrance[2] end
  else
    if self.east_entrance then return self.east_entrance[1],self.east_entrance[2] end
  end
  if self.main_entrance then return self.main_entrance[1],self.main_entrance[2] end
  return math.floor(self.w/2),math.floor(self.h/2)
end


function Map.enterWorldMap(x,y)
  p.x = x
  p.y = y
  g.enterWmap = true --记录下，等到checkNextScene时才切换。
end

function Map.setNextMap(map,enterX,enterY)
  local nextMap = {map = map,x=enterX,y = enterY}
  g.nextMap = nextMap --记录下，等到checkNextScene时才切换。
end

--在checkNextScene时调用此函数。
function Map.checkNextMap()
  
  --如果同一帧调用以上两个方法，优先进入大地图而不是另一张地图。
  if g.enterWmap then
    g.enterWmap = false
    g.nextMap = nil
    if cmap then
      cmap:leaveMap()
      cmap = nil
    end
    debugmsg("enterOvmap")
    g.runScene(g.overMap_scene)
  elseif g.nextMap then
    if cmap then
      cmap:leaveMap()
      cmap = nil
    end
    cmap = g.nextMap.map
    cmap:enterMap(g.nextMap.x,g.nextMap.y)
    g.runScene(g.mainGame_scene)
    g.nextMap = nil
  end
  
end


