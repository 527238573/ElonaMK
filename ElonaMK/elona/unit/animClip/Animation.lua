Animation = {} --保存创建初始化的函数
AnimClip.updates = {}--保存update的函数
local updates = AnimClip.updates

--move基本移动
function Animation.Move(totalTime,start_dx,start_dy,playSpeed)
  local clip = AnimClip.new("Move",totalTime)
  clip.priority =1
  clip.playSpeed = playSpeed
  --clip.playSpeed = 0.5
  clip.start_dx = start_dx
  clip.start_dy = start_dy
  if start_dx>0 then start_dx=1 elseif start_dx<0 then start_dx =-1 end --标准化为1
  if start_dy>0 then start_dy=1 elseif start_dy<0 then start_dy =-1 end
  clip.turn_face = c.face(-start_dx,-start_dy)
  if start_dx~= 0 and start_dy~=0 then clip.playSpeed = clip.playSpeed*1.3 end
  return clip
end

function updates.Move(clip,dt,status,unit)
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


function Animation.MoveAndBack(totalTime,midRate,target_x,target_y)
  local clip = AnimClip.new("MoveAndBack",totalTime)
  clip.priority =2
  clip.midRate = midRate
  --clip.playSpeed = 0.5
  clip.target_x = target_x
  clip.target_y = target_y
  return clip
end

function updates.MoveAndBack(clip,dt,status,unit)
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

function Animation.Impact(totalTime,midRate,tdx,tdy,delay) 
  local clip = AnimClip.new("Impact",totalTime)
  clip.priority =4
  clip.delay = delay or 0
  clip.midRate = midRate
  clip.totalTime = clip.delay+clip.totalTime
  clip.tdx = tdx
  clip.tdy = tdy
  return clip
end

function updates.Impact(clip,dt,status,unit)
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

function Animation.TurnFlat(totalTime,midRate,t_scaleY,delay) 
  local clip = AnimClip.new("TurnFlat",totalTime)
  clip.priority =4
  clip.delay = delay or 0
  clip.midRate = midRate
  clip.totalTime = clip.delay+clip.totalTime
  clip.t_scaleY = t_scaleY
  return clip
end

function updates.TurnFlat(clip,dt,status,unit)
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

function Animation.JumpSlash(totalTime,midRate,tdx,tdy,tdz,backTime) 
  local clip = AnimClip.new("JumpSlash",totalTime)
  clip.priority =2
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
  return clip
end

function updates.JumpSlash(clip,dt,status,unit)
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

function Animation.RoundSlash(totalTime,turnTime,backTime,r,startRot,face)
  local clip = AnimClip.new("RoundSlash",totalTime)
  clip.priority =2
  clip.stage1t = clip.totalTime
  clip.stage2t = turnTime
  clip.stage3t = backTime
  clip.totalTime = clip.totalTime +backTime +turnTime
  clip.r = r
  clip.startRot= startRot
  clip.turn_face = face
  return clip
end

function updates.RoundSlash(clip,dt,status,unit)
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

function Animation.Charge(totalTime,startx,starty,tarX,tarY,fdx,fdy) 
  local clip = AnimClip.new("Charge",totalTime)
  clip.priority =1
  clip.startx_acoord = startx*64
  clip.starty_acoord = starty*64
  clip.sX_acoord  = tarX *64 +fdx - startx*64
  clip.sY_acoord = tarY *64 +fdy - starty*64
  clip.tarX = tarX
  clip.tarY = tarY
  clip.playSpeed = 2
  return clip
end

function updates.Charge(clip,dt,status,unit)
  local rate = clip.time/clip.totalTime
  rate = c.clamp(rate,0,1)
  
  local coordx = clip.startx_acoord + rate*clip.sX_acoord
  local coordy = clip.starty_acoord + rate*clip.sY_acoord
  
  local tx = math.floor((coordx+32)/64)
  local ty = math.floor((coordy+32)/64)
  
  if tx== clip.tarX and ty ==clip.tarY then
    tx,ty = unit.x,unit.y
    
  elseif tx ~=unit.x or ty ~= unit.y then
    unit.map:unitMove(unit,tx,ty)
  end
  status.dx = coordx - tx*64 
  status.dy = coordy - ty*64 
  status.camera_dx = status.dx
  status.camera_dy = status.dy
  
  local drate = dt/clip.totalTime*clip.playSpeed

  status.rate = status.rate+drate
  if status.rate>1 then status.rate = status.rate-1 end
end

function Animation.RecoverPos(totalTime,startx,starty,fdx,fdy,tarX,tarY) 
  local clip = AnimClip.new("RecoverPos",totalTime)
  clip.priority =1
  clip.move_coordx = startx*64+fdx -tarX*64
  clip.move_coordy = starty*64+fdy -tarY*64
  
  clip.playSpeed = 0.5
  return clip
end

function updates.RecoverPos(clip,dt,status,unit)
  local rate = clip.time/clip.totalTime
  rate = 1-c.clamp(rate,0,1)
  
  status.dx = rate * clip.move_coordx
  status.dy = rate * clip.move_coordy
  status.camera_dx = status.dx
  status.camera_dy = status.dy
  
  local drate = dt/clip.totalTime*clip.playSpeed

  status.rate = status.rate+drate
  if status.rate>1 then status.rate = status.rate-1 end
end

function Animation.Pushed(totalTime,delay,start_dx,start_dy,playSpeed)
  local clip = AnimClip.new("Pushed",totalTime)
  clip.priority =2
  clip.delay = delay
  clip.totalTime = clip.delay+clip.totalTime
  
  clip.playSpeed = playSpeed
  clip.start_dx = start_dx
  clip.start_dy = start_dy
  if start_dx>0 then start_dx=1 elseif start_dx<0 then start_dx =-1 end --标准化为1
  if start_dy>0 then start_dy=1 elseif start_dy<0 then start_dy =-1 end
  if start_dx~= 0 and start_dy~=0 then clip.playSpeed = clip.playSpeed*1.3 end
  return clip
end

function updates.Pushed(clip,dt,status,unit)
  if clip.time<clip.delay then 
    status.dx =status.dx+clip.start_dx;
    status.dy =status.dy+clip.start_dy;
    status.camera_dx = status.camera_dx+clip.start_dx
    status.camera_dy = status.camera_dy+clip.start_dy
    return 
  end
  local ctime = clip.time - clip.delay
  local pushtime = clip.totalTime-clip.delay
  
  local rate = ctime/pushtime
  rate = c.clamp(rate,0,1)
  local dx = clip.start_dx*(1-rate)
  local dy = clip.start_dy*(1-rate)
  status.dx =status.dx+dx;
  status.dy =status.dy+dy;
  status.camera_dx = status.camera_dx+dx
  status.camera_dy = status.camera_dy+dy

  local drate = dt/pushtime*clip.playSpeed

  status.rate = status.rate+drate
  if status.rate>1 then status.rate = status.rate-1 end
end

function Animation.BurstPunch(dx,dy,time1,time2,time3)
  local totalTime  =time1 +time2 +time3
  local clip = AnimClip.new("BurstPunch",totalTime)
  clip.priority =2
  
  clip.stage1 = time1
  clip.stage2 = time1+time2
  
  local nx,ny = dx,dy
  if dx~=0 and dy ~=0 then
    --nx,ny = nx/1.4,ny/1.4 --距离均等化
  end
  clip.nx = nx
  clip.ny = ny
  return clip
end
function updates.BurstPunch(clip,dt,status,unit)
  local back1 = 18
  local front = 28
  if clip.time<clip.stage1 then  
    local rate = clip.time/clip.stage1
    local dx,dy = clip.nx*-back1 * rate,clip.ny*-back1 * rate
    status.dx =status.dx+dx;
    status.dy =status.dy+dy;
  elseif clip.time < clip.stage2 then
    local rate = (clip.time-clip.stage1)/(clip.stage2-clip.stage1)
    local golen = -back1+ (back1+front)*rate
    local dx,dy = clip.nx*golen,clip.ny*golen
    status.dx =status.dx+dx;
    status.dy =status.dy+dy;
  else
    local rate = (clip.time-clip.stage2)/(clip.totalTime-clip.stage2)
    local golen = front-front*rate
    local dx,dy = clip.nx*golen,clip.ny*golen
    status.dx =status.dx+dx;
    status.dy =status.dy+dy;
    
  end
end

--自由选定点的move
function Animation.FreeMove(totalTime,startdx,startdy,enddx,enddy)
  local clip = AnimClip.new("FreeMove",totalTime)
  clip.priority =2
  
  
  clip.sx = startdx
  clip.sy = startdy
  clip.ex = enddx
  clip.ey = enddy
  return clip
end

function updates.FreeMove(clip,dt,status,unit)
  local rate = clip.time/clip.totalTime
  local dx = clip.sx + (clip.ex-clip.sx)*rate
  local dy = clip.sy + (clip.ey-clip.sy)*rate
  status.dx =status.dx+dx;
  status.dy =status.dy+dy;
end