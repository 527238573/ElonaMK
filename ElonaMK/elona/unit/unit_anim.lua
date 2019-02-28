

function Unit:get_anim_status()
  return self.status
end

--使相机聚焦单位
function Unit:camera_Focus()
  local x = self.x*64+32+self.status.camera_dx
  local y = self.y*64+32+self.status.camera_dy
  
  g.camera:setCenter(x,y)
end


function Unit:get_unitAnim()
  return self.anim
end

function Unit:get_unitAnim_playSpeed()
  return self.anim.playSpeed
end



function Unit:addClip(clip)
  for i=1,#self.clips do
    if self.clips[i].priority>clip.priority then--按优先级插入，同优先级后来的排在后
      table.insert(self.clips,i,clip)
      return
    end
  end
  table.insert(self.clips,clip)
end


function Unit:clips_update(dt)
  --刷新位置。
  local status = self.status
  status.rot = 0;
  status.dx = 0;status.dy =0;
  status.scaleX = 1;status.scaleY =1;
  status.camera_dx = 0;status.camera_dy = 0
  
  local clips_list = self.clips
  local i=1
  while i<=#clips_list do
    local clip = clips_list[i]
    if clip.createFrame ~= g.curFrame  then --当前帧创建的对象不会时间经过。
      clip.time = clip.time+dt
    end
    if clip.time> clip.totalTime then
      table.remove(clips_list,i)
    else
      clip.type.updateStatus(dt,clip,status,self)
      i = i+1
    end
  end
end