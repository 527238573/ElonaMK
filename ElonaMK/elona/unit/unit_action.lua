



--尝试走到x，y点，不行则返回false。行则返回true
function Unit:walk_to(dest_x,dest_y)
  local map = assert(self.map)
  
  if not map:can_pass(dest_x,dest_y) then return false end --不能移动的地形。
  if map:unit_at(dest_x,dest_y) then return false end --有单位占据了。如果友方单位占据则可以交换，但不在此函数。
  
  local dx = self.x-dest_x
  local dy = self.y-dest_y
  local fx = self.x*64
  local fy = self.y*64+map:getAltitude(self.x,self.y)
  local tx = dest_x*64
  local ty = dest_y*64+map:getAltitude(dest_x,dest_y)
  
  
  local costtime  = map:move_cost(dest_x,dest_y)/self:getSpeed()
  costtime = (dx~=0 and dy~=0) and costtime*1.4 or costtime
  costtime = costtime/c.timeSpeed *0.7
  map:unitMove(self,dest_x,dest_y) --更换地图上的位置。
  --设置动画。
  
  --local dx = self.x-dest_x
  --local dy = self.y-dest_y
  local clip  = AnimClip.new("move",costtime,dx*64,dy*64,self:get_unitAnim_playSpeed())
  self:addClip(clip)
  self:add_delay(costtime,"walk")
  return true
end


--操作move
function Unit:moveAction(dx,dy)
  self:set_face(dx,dy)
  self:walk_to(self.x+dx,self.y+dy)
end