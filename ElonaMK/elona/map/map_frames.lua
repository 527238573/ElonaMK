

--这里的dxdy和frame里的dxdy无关系，只是精细偏移量
function Map:addSquareFrame(framec,x,y,dx,dy)
  dx= dx or 0
  dy = dy or 0
  framec.squarex = x --坐标
  framec.squarey = y
  framec.x = x*64+32+dx
  framec.y = y*64+32+dy
  for i=1,#self.frames do
    if self.frames[i].priority>framec.priority then--按优先级插入，同优先级后来的排在后
      table.insert(self.frames,i,framec)
      return
    end
  end
  table.insert(self.frames,framec)
end


function Map:updateFrames(dt)
  local list = self.frames
  local i=1
  while i<=#list do
    local frame = list[i]
    frame:updateAnim(dt)
    if frame:isFinish() then
      table.remove(list,i)
      --debugmsg("end frame:"..frame.id)
    else
      i = i+1
    end
  end
end

function Map:addProjectile(proj)
  table.insert(self.projectiles,proj)
end

function Map:updateProjectiles(dt)
  local list = self.projectiles
  local i=1
  while i<=#list do
    local proj = list[i]
    proj:updateAnim(dt,self)
    if proj:isFinish() then
      table.remove(list,i)
      --debugmsg("end frame:"..frame.id)
    else
      i = i+1
    end
  end
end

