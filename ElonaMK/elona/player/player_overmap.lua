

function Player:setPosition(x,y)
  self.x =x
  self.y=y
end

function Player:set_face(dx,dy)
  self.status.face = c.face(dx,dy)
end

function Player:getTravelSpeed()
  return 70
end

--使大地图相机聚焦单位
function Player:camera_Focus()
  local x = self.x*64+32+self.status.camera_dx
  local y = self.y*64+32+self.status.camera_dy
  g.wcamera:setCenter(x,y)
end

--尝试走到x，y点，不行则返回false。行则返回true
function Player:walk_to(dest_x,dest_y)
  local map = wmap
  
  if not map:can_pass(dest_x,dest_y) then return false end --不能移动的地形。
  
  local dx = self.x-dest_x
  local dy = self.y-dest_y
  
  local costtime  = 150/self:getTravelSpeed()
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/c.timeSpeed 
  self.x = dest_x --更换地图上的位置。
  self.y= dest_y
  --设置动画。 
  self.clip = AnimClip.new("move",costtime,dx*64,dy*64,self.mc:get_unitAnim_playSpeed()*2.1)
  self.delay = costtime
  return true
end



function Player:moveAction(dx,dy)
  self:set_face(dx,dy)
  self:walk_to(self.x+dx,self.y+dy)
end

function Player:updateOM(dt)
  self.delay = math.max(0,self.delay -dt)
  local status = self.status
  status.rot = 0;
  status.dx = 0;status.dy =0;status.dz = 0; --dz表示是否飞起。影子不考虑dz。dz单位和dy都是一样会上移相同像素。
  status.scaleX = 1;status.scaleY =1;
  status.camera_dx = 0;status.camera_dy = 0
  local clip = self.clip
  if clip~= nil and clip~=0 then
    clip.time = clip.time+dt
    if clip.time> clip.totalTime then
      self.clip=0
    else
      clip.type.updateStatus(clip,dt,status,self)
    end
  end
end

function Player:enterMap()
  if self.delay>0.1 then return end
  if not wmap:can_enter(self.x,self.y,true) then return end
  local map = MapFactory.getrOrCreateWmapSquare(self.x,self.y)
  local face = self.status.face
  self.mc.status.face = face--朝向变化
  
  local ex,ey = map:getEntrance(face)
  Map.setNextMap(map,ex,ey)
  g.playSound("exitmap1")
end

