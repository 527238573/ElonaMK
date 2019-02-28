
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




return function ()
  for k,v in pairs(data.animClip) do
    v.id = k
    setmetatable(v,data.dataMeta)--作为不保存类型。
  end
end