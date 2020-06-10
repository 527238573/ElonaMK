
local lovefs = require("file/lovefs")
data.sound = {}
data.soundGroup = {}

local function loadSound()
  --debugmsg("source:"..love.filesystem.getSource())
  local soundNum = 0
  local dir = "data/sound/"
  local function load1sound(v,defaultVolume)
    if string.match(v,".%.wav") or string.match(v,".%.ogg") then
      soundNum = soundNum +1
      local fname = string.sub(v,1,-5)
      local one_sound = {id = fname}
      one_sound.data= love.audio.newSource(dir..v,"static")
      one_sound.volume  = defaultVolume or 0.5 --默认值
      data.sound[fname] = one_sound
    end
  end
  
  
  local fs = lovefs(love.filesystem.getSource().."/data/sound")
  for _, v in ipairs(fs.files) do --
    load1sound(v)
  end
  fs:cd("combat")
  dir = "data/sound/combat/"
  for _, v in ipairs(fs.files) do --
    load1sound(v)
  end
  fs:cd("..")
  fs:cd("gun")
  dir = "data/sound/gun/"
  for _, v in ipairs(fs.files) do --
    load1sound(v,0.1)
  end
  debugmsg("load sound Nubmer:"..(soundNum))
end

local function addSoundGroup(gid,gtable)
  if data.sound[gid] or data.soundGroup[gid] then
    error("error soundGroup id:"..gid)
  end
  
  for i=1,#gtable do
    if data.sound[gtable[i]]==nil then
      error("error sound id:"..gtable[i])
    end
  end
  data.soundGroup[gid] = gtable
end

return function()
  loadSound()
  data.sound["ding1"].volume = 1
  data.sound["ding2"].volume = 1
  data.sound["ding3"].volume = 1
  
  data.sound["pop2"].volume = 1
  data.sound["bash_hit1"].volume = 0.1
  data.sound["bash_hit2"].volume = 0.1
  data.sound["cut_hit1"].volume = 0.1
  data.sound["cut_hit2"].volume = 0.1
  data.sound["cut_hit3"].volume = 0.1
  data.sound["cut_hit4"].volume = 0.1
  data.sound["cut_hit5"].volume = 0.1
  data.sound["cut_hit6"].volume = 0.1
  data.sound["stab_hit_flesh_1"].volume = 0.1
  data.sound["stab_hit_flesh_2"].volume = 0.1
  data.sound["stab_hit_flesh_3"].volume = 0.1
  data.sound["stab_hit_flesh_4"].volume = 0.1
  data.sound["spear_hit_flesh_1"].volume = 0.1
  data.sound["spear_hit_flesh_2"].volume = 0.1
  data.sound["spear_hit_flesh_3"].volume = 0.1
  data.sound["spear_hit_flesh_4"].volume = 0.1
  data.sound["spear_hit_flesh_5"].volume = 0.1
  data.sound["spear_hit_flesh_6"].volume = 0.1
  data.sound["bite_hit1"].volume = 0.1
  data.sound["bite_hit2"].volume = 0.1
  data.sound["bite_hit3"].volume = 0.1
  data.sound["claw_hit1"].volume = 0.1
  data.sound["claw_hit2"].volume = 0.1
  data.sound["claw_hit3"].volume = 0.1
  
  data.sound["swing_heavy_1"].volume = 0.1
  data.sound["swing_heavy_2"].volume = 0.1
  data.sound["swing_heavy_3"].volume = 0.1
  data.sound["swing_mid_1"].volume = 0.1
  data.sound["swing_mid_2"].volume = 0.1
  data.sound["swing_mid_3"].volume = 0.1
  data.sound["swing_mid_4"].volume = 0.1
  data.sound["swing_light_1"].volume = 0.1
  data.sound["swing_light_2"].volume = 0.1
  data.sound["swing_light_3"].volume = 0.1
  data.sound["swing_light_4"].volume = 0.1
  data.sound["miss"].volume = 0.6
  
  --gun目录
--data.sound["weapon_fire_9mm"].volume = 0.2
  --data.sound["weapon_fire_762x39"].volume = 0.2
  --data.sound["weapon_fire_762x51"].volume = 0.2
  --data.sound["weapon_fire_arrow"].volume = 0.2
  data.sound["hit_flesh_1"].volume = 0.05 --gun目录的 hit flesh,文件名可能需要改
  data.sound["hit_flesh_2"].volume = 0.05
  data.sound["hit_flesh_3"].volume = 0.05
  data.sound["shoot_fail"].volume = 0.05
  data.sound["reload_s_nail"].volume = 0.2
  data.sound["reload_s_flare"].volume = 0.3
  data.sound["reload_b_1"].volume = 0.2
  data.sound["ammo"].volume = 0.5
  data.sound["arrow1"].volume = 0.5
  data.sound["bolt1"].volume = 0.5
  data.sound["gun1"].volume = 0.5
  data.sound["laser1"].volume = 0.5
  data.sound["fire_sniper1"].volume = 0.07
  data.sound["fire_shotgun2"].volume = 0.5
  --声音组
  addSoundGroup("bash_hit",{"bash_hit1","bash_hit2"})
  addSoundGroup("cut_hit",{"cut_hit1","cut_hit2","cut_hit3"})
  addSoundGroup("cut2_hit",{"cut_hit4","cut_hit5","cut_hit6"})
  addSoundGroup("stab_hit",{"stab_hit_flesh_1","stab_hit_flesh_2","stab_hit_flesh_3","stab_hit_flesh_4"})
  addSoundGroup("spear_hit",{"spear_hit_flesh_1","spear_hit_flesh_2","spear_hit_flesh_3","spear_hit_flesh_4","spear_hit_flesh_5","spear_hit_flesh_6"})
  addSoundGroup("bite_hit",{"bite_hit1","bite_hit2","bite_hit3"})
  addSoundGroup("claw_hit",{"claw_hit1","claw_hit2","claw_hit3"})
  addSoundGroup("swing_heavy",{"swing_heavy_1","swing_heavy_2","swing_heavy_3"})
  addSoundGroup("swing_mid",{"swing_mid_1","swing_mid_2","swing_mid_3","swing_mid_4"})
  addSoundGroup("swing_light",{"swing_light_1","swing_light_2","swing_light_3","swing_light_4"})
  addSoundGroup("kill",{"kill1","kill2",})
  addSoundGroup("ranged_hit_flesh",{"hit_flesh_1","hit_flesh_2","hit_flesh_3",})
end