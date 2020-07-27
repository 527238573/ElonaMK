
local function getSound(id)
  local sound = data.sound[id]
  if sound ==nil then 
    local soundGroup = data.soundGroup[id]
    if soundGroup ==nil then
      debugmsg("cant find sound:"..id)
      return;
    end
    sound = data.sound[soundGroup[rnd(1,#soundGroup)]]
  end
  return sound
end


local mindis = 3
local maxdis =15
local function getVolume(x,y)
  local dist = 0
  if x then 
    dist = c.dist_2d(x,y,p.mc.x,p.mc.y)
  end
  if dist<=mindis then return 1 end
  if dist>= maxdis then return 0 end
  local rate = (dist-mindis)/(maxdis -mindis)
  rate = 1-rate
  return rate*rate
end


function g.playSound(id,x,y,volume)
  volume =volume or 1
  local sound = getSound(id)
  if sound == nil then return end
  local vl =getVolume(x,y)
  if vl<=0 then return end
  
  local dataplay = sound.data:clone()
  dataplay:setVolume( sound.volume*vl*volume)
  love.audio.play(dataplay)
end


local delayList = {}


function g.playSound_delay(id,x,y,delay,volume)
  volume =volume or 1
  if delay<=0 then
    g.playSound(id,x,y,volume)
    return 
  end
  local delaySound = {id =id,x=x,y=y,delay = delay,volume =volume}
  table.insert(delayList,delaySound)
end


local loopingList ={}--持续播放的声音

--以origin做唯一标识符，创建声音。必须每帧持续调用此函数来创建声音。有一帧未调用，下一帧就会清除。
function g.loopSound(origin_id,id,x,y)
  local lsound = loopingList[origin_id]
  if lsound ==nil then
    local sound = getSound(id) --
    if sound == nil then 
      error("no loop sound:"..id)
    end
    local vl =getVolume(x,y)
    local dataplay = sound.data:clone()
    dataplay:setVolume( sound.volume*vl)
    dataplay:setLooping(true) --声音循环不灭
    love.audio.play(dataplay)
    lsound = {sound = sound,dataplay = dataplay,vl =vl,lastFrame = g.curFrame}
    loopingList[origin_id] = lsound
  else
    lsound.lastFrame = g.curFrame --更新活跃的最后一帧计数
    local vl =getVolume(x,y)
    if vl ~= lsound.vl then
      lsound.dataplay:setVolume( lsound.sound.volume*vl)
    end
  end
end


function g.updateSound(dt)
  local i=1
  while i<=#delayList do
    local delaySound = delayList[i]
    if delaySound.delay<=0 then
      g.playSound(delaySound.id,delaySound.x,delaySound.y,delaySound.volume)
      table.remove(delayList,i)
    else
      delaySound.delay =delaySound.delay -dt
      i = i+1
    end
  end
  local toDel = {}
  for key,lsound in pairs(loopingList) do
    if g.curFrame>=(lsound.lastFrame +1) then
      toDel[key] = true
      love.audio.stop(lsound.dataplay)
    end
  end
  for key,_ in pairs(toDel) do
    loopingList[key] = nil
  end
end