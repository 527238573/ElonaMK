


function g.playSound(id,x,y)
  local sound = data.sound[id]
  if sound ==nil then 
    debugmsg("cant find sound:"..id)
    return;
  end
  local dist = 0
  if x then 
    dist = c.dist_2d(x,y,p.mc.x,p.mc.y)
  end
  if dist>20 then return end
  local dataplay = sound.data:clone()
  dataplay:setVolume( sound.volume*(20-dist)/20)
  love.audio.play(dataplay)
end