
data.animClip = {}


data.animClip["move"] = {}
function data.animClip.move.init(clip,start_dx,start_dy,playSpeed) 
  clip.priority = 1
  clip.playSpeed = playSpeed
  --clip.playSpeed = 0.5
  clip.start_dx = start_dx
  clip.start_dy = start_dy
  
  if start_dx>0 then start_dx=1 elseif start_dx<0 then start_dx =-1 end --标准化为1
  if start_dy>0 then start_dy=1 elseif start_dy<0 then start_dy =-1 end
  clip.turn_face = c.face(-start_dx,-start_dy)
  if start_dx~= 0 and start_dy~=0 then clip.playSpeed = clip.playSpeed*1.3 end
  
end

function data.animClip.move.updateStatus(dt,clip,status,unit)
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

data.animClip["moveAndBack"] = {}
function data.animClip.moveAndBack.init(clip,midTime,target_x,target_y) 
  clip.priority = 2
  clip.midRate = midTime/clip.totalTime
  --clip.playSpeed = 0.5
  clip.target_x = target_x
  clip.target_y = target_y
  
end

function data.animClip.moveAndBack.updateStatus(dt,clip,status,unit)
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

data.animClip["impact"]={}
function data.animClip.impact.init(clip,tdx,tdy,delay,midTime,backTime) 
  clip.priority = 4
  clip.delay = delay or 0
  clip.midTime = midTime or 0.05
  clip.backTime = backTime or 0.15
  clip.totalTime = clip.delay+clip.midTime+clip.backTime
  clip.tdx = tdx
  clip.tdy = tdy
end


function data.animClip.impact.updateStatus(dt,clip,status,unit)
  if clip.time<clip.delay then return end
  local ctime = clip.time - clip.delay
  local rate
  if ctime<clip.midTime then
    rate = ctime/clip.midTime
  else
    rate = 1-(ctime-clip.midTime)/clip.backTime
  end
  rate = c.clamp(rate,0,1)
  status.dx =status.dx+clip.tdx*rate;
  status.dy =status.dy+clip.tdy*rate;
end


return function ()
  for k,v in pairs(data.animClip) do
    v.id = k
    setmetatable(v,data.dataMeta)--作为不保存类型。
  end
end