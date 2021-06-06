


--使相机聚焦单位
function Unit:camera_Focus()
  local x = self.x*64+32+self.status.camera_dx
  local y = self.y*64+24+self.status.camera_dy
  g.camera:setCenter(x,y)
end

--算上dxdy后估计的XY值。用于确定大概位置等
function Unit:getLineXY()
  local dx,dy = self.status.dx,self.status.dy
  local liney = self.y + math.floor((dy+32)/64)
  local linex = self.x + math.floor((dx+32)/64)
  return linex,liney
end

--获得当前动画偏移值dxdy
function Unit:get_anim_dxdy()
  local anim = self:get_unitAnim() --anim数据
  local status = self.status
  local dx=status.dx
  local dy=(anim.h-anim.anchorY)*anim.scalefactor +status.dy+status.dz
  return dx,dy
end


--对于挂在身上中心点的frame，获得脚根位置的偏移。
function Unit:get_foot_offset()
  local anim = self:get_unitAnim() --anim数据
  local status = self.status
  
  local dh = anim.scalefactor*(anim.h - anim.anchorY)
  return dh --如果计算跳起还要加上status.dz，以获得地面offset
end


function Unit:get_unitAnim()
  return self.anim
end

function Unit:get_unitAnim_playSpeed()
  return self.anim.playSpeed
end



function Unit:addClip(clip)
  local p = clip:getPriority()
  for i=1,#self.clips do
    if self.clips[i]:getPriority()>p then--按优先级插入，同优先级后来的排在后
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
  status.dx = 0;status.dy =0;status.dz = 0; --dz表示是否飞起。影子不考虑dz。dz单位和dy都是一样会上移相同像素。
  status.scaleX = 1;status.scaleY =1;
  status.camera_dx = 0;status.camera_dy = 0
  local clips_list = self.clips
  local i=1
  while i<=#clips_list do
    local clip = clips_list[i]
    clip:updateAnim(dt,status,self)
    if clip:isFinished() then
      table.remove(clips_list,i)
    else
      i = i+1
    end
  end
end

--根据status状态返回img quad filp（是否翻转）
function Unit:getImgQuad(status)
  status = status or self.status
  local anim = self:get_unitAnim()
  
  --选取正确的quad。
  local animNum = anim.num--
  local len = animNum
  if(len>2 and anim.pingpong) then len = len*2 -2 end   -- 来回动画,总帧数更长
  local onerate = 1/len
  local userate = onerate *0.5 +status.rate--从第一帧正中分割
  local useframe = (math.floor(userate/onerate)+anim.stillframe-1) % len +1  --计算出正确的帧。如果stillframe～=1 则向前推进对应的帧数。
  if(anim.pingpong and useframe>animNum) then
    useframe = animNum - (useframe - animNum) --得到对应的帧。
  end
  --判断face方向的影响。 face： 123
  --                            884
  --                            765
  
  local flip = false 
  local face = status.face 
  if anim.type == "twoside" then 
    if face<=4 then
      useframe = useframe + animNum
      if face<=2 then
        flip = true
      end
    elseif face<=6 then
      flip = true
    end
  else --"oneside"
    if face>2 and face<=6 then flip = true end
  end
  local quad = anim[useframe]
  
  return anim.img,quad,flip
end

--注意不能在updateFrame时插入，其他还好(updateFrame 不允许逻辑代码，只能允许改变frame本身的代码)
function Unit:addFrameClip(framec)
  for i=1,#self.frames do
    if self.frames[i].priority>framec.priority then--按优先级插入，同优先级后来的排在后
      table.insert(self.frames,i,framec)
      return
    end
  end
  table.insert(self.frames,framec)
end


function Unit:updateFrameClips(dt)
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

--单位死亡时，有些特效会掉落。
function Unit:drop_frames_to_map()
  local list = self.frames
  if #list==0 then return end
  local dx,dy = self:get_anim_dxdy()
  
  local i=1
  while i<=#list do
    local frame = list[i]
    if frame.drop_to_map then
      table.remove(list,i)
      --debugmsg("drop frame:"..frame.id)
      if self.map then
        self.map:addSquareFrame(frame,self.x,self.y,dx,dy)--加入
      end
    else
      i = i+1
    end
  end
end


function Unit:hitImpact(hit_rotation,dis)
  hit_rotation = hit_rotation+rnd()-0.5
  local tTime =  0.2
  if dis>8 then tTime = tTime*dis/8 end
  local dx = dis *math.cos(hit_rotation)
  local dy = -dis *math.sin(hit_rotation) 
  local clip  = Animation.Impact(tTime,0.25,dx,dy,0)
  self:addClip(clip)
end

function Unit:recoilImpact(shot_rotation,dis)
  local tTime =  0.2
  if dis>8 then tTime = tTime*dis/8 end
  local dx = -dis *math.cos(shot_rotation)
  local dy = dis *math.sin(shot_rotation) 
  local clip  = Animation.Impact(tTime,0.25,dx,dy,0)
  self:addClip(clip)
end
