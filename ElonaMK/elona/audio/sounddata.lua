
local lovefs = require("file/lovefs")
data.sound = {}


local function loadSound()
  --debugmsg("source:"..love.filesystem.getSource())
  local soundNum = 0
  local fs = lovefs(love.filesystem.getSource().."/data/sound")
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.wav") or string.match(v,".%.ogg") then
      soundNum = soundNum +1
      local fname = string.sub(v,1,-5)
      local one_sound = {id = fname}
      one_sound.data= love.audio.newSource("data/sound/"..v,"static")
      one_sound.volume  = 0.5 --默认值
      data.sound[fname] = one_sound
    end
  end
  debugmsg("load sound Nubmer:"..(soundNum))
end


return function()
  loadSound()
end