


function g.playSound(id,x,y)
  local sound = data.sound[id]
  if sound ==nil then 
    local soundGroup = data.soundGroup[id]
    if soundGroup ==nil then
      debugmsg("cant find sound:"..id)
      return;
    end
    sound = data.sound[soundGroup[rnd(1,#soundGroup)]]
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


local delayList = {}


function g.playSound_delay(id,x,y,delay)
  if delay<=0 then
    g.playSound(id,x,y)
    return 
  end
  local delaySound = {id =id,x=x,y=y,delay = delay}
  table.insert(delayList,delaySound)
end

function g.updateDelaySound(dt)
  local i=1
  while i<=#delayList do
    local delaySound = delayList[i]
    if delaySound.delay<=0 then
      g.playSound(delaySound.id,delaySound.x,delaySound.y)
      table.remove(delayList,i)
    else
      delaySound.delay =delaySound.delay -dt
      i = i+1
    end
  end
end