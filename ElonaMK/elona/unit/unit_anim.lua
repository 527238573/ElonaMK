

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
  status.dx = 0;status.dy =0;status.dz = 0; --dz表示是否飞起。影子不考虑dz。dz单位和dy都是一样会上移相同像素。
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
    if face>=2 and face<=5 then flip = true end
  end
  local quad = anim[useframe]
  
  return anim.img,quad,flip
end


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
  local anim = self:get_unitAnim() --anim数据
  local status = self.status
  local dx=status.dx
  local dy=(anim.h-anim.anchorY)*anim.scalefactor +status.dy+status.dz
  
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

-- update延迟调用。。。。
function Unit:updateAnimDelayFunc(dt)
  local list = self.animdelay_list
  for i= #list,1,-1 do
    local onet = list[i]
    onet.delay = onet.delay-dt
    if onet.delay <=0 then
      onet.f(unpack(onet.args))
      table.remove(list,i)
    end
  end
end

-- 新 延迟调用。。。。
function Unit:insertAnimDelayFunc(delay,func,...)
  local onet = {delay = delay, args = {...},f= func}
  local list = self.animdelay_list
  list[#list+1] = onet
end
--清理 延迟调用。。。。
function Unit:clearAnimDelayFunc()
  self.animdelay_list = {noSave = true}
end