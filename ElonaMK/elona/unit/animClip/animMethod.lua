
data.animClip = {}
local clip
local function addClip(clip)
  assert(data.animClip[clip.id]==nil)
  setmetatable(clip,data.dataMeta)
  data.animClip[clip.id] = clip
end

clip =  {id ="move",priority = 1,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,start_dx,start_dy,playSpeed)
  clip.playSpeed = playSpeed
  --clip.playSpeed = 0.5
  clip.start_dx = start_dx
  clip.start_dy = start_dy
  if start_dx>0 then start_dx=1 elseif start_dx<0 then start_dx =-1 end --标准化为1
  if start_dy>0 then start_dy=1 elseif start_dy<0 then start_dy =-1 end
  clip.turn_face = c.face(-start_dx,-start_dy)
  if start_dx~= 0 and start_dy~=0 then clip.playSpeed = clip.playSpeed*1.3 end
end
function clip.updateStatus(dt,clip,status,unit)
  status.face = clip.turn_face
  local rate = clip.time/clip.totalTime
  rate = c.clamp(rate,0,1)
  local dx = clip.start_dx*(1-rate)
  local dy = clip.start_dy*(1-rate)
  status.dx =dx;status.camera_dx = dx
  status.dy =dy;status.camera_dy = dy

  local drate = dt/clip.totalTime*clip.playSpeed

  status.rate = status.rate+drate
  if status.rate>1 then status.rate = status.rate-1 end
end

clip =  {id ="moveAndBack",priority = 2,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,midRate,target_x,target_y) 
  clip.midRate = midRate
  --clip.playSpeed = 0.5
  clip.target_x = target_x
  clip.target_y = target_y

end

function clip.updateStatus(dt,clip,status,unit)
  local rate = clip.time/clip.totalTime
  rate = c.clamp(rate,0,1)
  local crate
  if rate<clip.midRate then
    crate = rate/clip.midRate--中间值
  else
    crate =1- (rate-clip.midRate)/(1 - clip.midRate)
  end
  local dx = clip.target_x*crate
  local dy = clip.target_y*crate
  status.dx =status.dx+dx;
  status.dy =status.dy+dy;
  status.rate = rate
end

clip =  {id ="impact",priority = 4,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,midRate,tdx,tdy,delay) 
  clip.delay = delay or 0
  clip.midRate = midRate
  clip.totalTime = clip.delay+clip.totalTime
  clip.tdx = tdx
  clip.tdy = tdy
end


function clip.updateStatus(dt,clip,status,unit)
  if clip.time<clip.delay then return end
  local ctime = clip.time - clip.delay

  local rate = ctime/(clip.totalTime-clip.delay)
  if rate<clip.midRate then
    rate = rate/clip.midRate--中间值
  else
    rate =1- (rate-clip.midRate)/(1 - clip.midRate)
  end
  rate = c.clamp(rate,0,1)
  status.dx =status.dx+clip.tdx*rate;
  status.dy =status.dy+clip.tdy*rate;
end

clip =  {id ="turnFlat",priority = 4,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,midRate,t_scaleY,delay) 
  clip.delay = delay or 0
  clip.midRate = midRate
  clip.totalTime = clip.delay+clip.totalTime
  clip.t_scaleY = t_scaleY
end


function clip.updateStatus(dt,clip,status,unit)
  if clip.time<clip.delay then return end
  local ctime = clip.time - clip.delay

  local rate = ctime/(clip.totalTime-clip.delay)
  if rate<clip.midRate then
    rate = rate/clip.midRate--中间值
  else
    rate =1- (rate-clip.midRate)/(1 - clip.midRate)
  end
  rate = c.clamp(rate,0,1)
  local nscale = 1+ rate*(clip.t_scaleY-1)
  status.scaleY =nscale *status.scaleY
  --status.dz =status.dz - 16*(1-clip.t_scaleY)*rate
end

clip =  {id ="jump_slash",priority = 2,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,midRate,tdx,tdy,tdz,backTime) 
  clip.stage1t = clip.totalTime
  clip.totalTime = clip.totalTime +backTime
  clip.midRate = midRate
  clip.tdx = tdx
  clip.tdy = tdy
  clip.tdz = tdz
  if tdx>0 then tdx=1 elseif tdx<0 then tdx =-1 end --标准化为1
  if tdy>0 then tdy=1 elseif tdy<0 then tdy =-1 end
  clip.turn_face = c.face(tdx,tdy)
  local isRight = clip.turn_face>2 and clip.turn_face<7--左或右
  clip.rot = isRight and -0.2 or 0.2
end


function clip.updateStatus(dt,clip,status,unit)
  status.face = clip.turn_face
  if clip.time<clip.stage1t then
    local rate = clip.time/clip.stage1t
    rate = c.clamp(rate,0,1)
    local zrate
    if rate<clip.midRate then
      zrate = rate/clip.midRate--中间值
    else
      zrate =1- (rate-clip.midRate)/(1 - clip.midRate)
    end
    zrate = 1-(zrate-1)*(zrate-1)
    status.dz = zrate*clip.tdz
    status.dx =status.dx+clip.tdx*rate;
    status.dy =status.dy+clip.tdy*rate;
    status.rot = clip.rot*rate
  else
    local rate = 1-(clip.time-clip.stage1t)/(clip.totalTime-clip.stage1t)
    status.dx =status.dx+clip.tdx*rate;
    status.dy =status.dy+clip.tdy*rate;
    status.rate = rate/2
  end
end

clip =  {id ="round_slash",priority = 2,}--默认priority，可以覆写
addClip(clip)
function clip.init(clip,turnTime,backTime,r,startRot,face) 
  clip.stage1t = clip.totalTime
  clip.stage2t = turnTime
  clip.stage3t = backTime
  clip.totalTime = clip.totalTime +backTime +turnTime
  clip.r = r
  clip.startRot= startRot
  clip.turn_face = face
end


function clip.updateStatus(dt,clip,status,unit)
  if clip.time<clip.stage1t then
     status.face = clip.turn_face
    local rate = clip.time/clip.stage1t
    status.dx =status.dx+math.cos(clip.startRot)*rate*clip.r;
    status.dy =status.dy+math.sin(clip.startRot)*rate*clip.r;
  elseif clip.time<(clip.stage1t+clip.stage2t) then
    local rate = (clip.time - clip.stage1t)/clip.stage2t
    local rot = clip.startRot+2*math.pi*rate
    status.dx =status.dx+math.cos(rot)*clip.r;
    status.dy =status.dy+math.sin(rot)*clip.r;
    status.face = (clip.turn_face-1 -math.floor(rate*8+0.5))%8+1
  else
     status.face = clip.turn_face
    local rate = 1-(clip.time - clip.stage1t-clip.stage2t)/clip.stage3t
    status.dx =status.dx+math.cos(clip.startRot)*rate*clip.r;
    status.dy =status.dy+math.sin(clip.startRot)*rate*clip.r;
  end
end

return function ()
  for k,v in pairs(data.animClip) do
    v.id = k
    setmetatable(v,data.dataMeta)--作为不保存类型。
  end
end