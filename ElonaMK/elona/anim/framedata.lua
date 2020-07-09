

data.frames = {} --使用字符串id作为key







--自动切割
local function load1f(fileid,w,h,secPerFrame,scaleFactor,ox,oy)
  w=w or 32;h=h or 32
  secPerFrame = secPerFrame or 0.1; scaleFactor =scaleFactor or 2 ;ox=ox or (w/2) ;oy =oy or (h/2)
  local frameT = {id= fileid,w=w,h=h,secPerFrame=secPerFrame,scaleFactor=scaleFactor,ox=ox,oy=oy}
  --自动切割
  local img = love.graphics.newImage("data/frames/"..fileid..".png")
  local imgw,imgh = img:getDimensions()
  local fw,fh = math.floor(imgw/w),math.floor(imgh/h)
  if fw<1 or fh<1 then error("Frames wh error"..fileid) end
  local frameNum = 0
  for j=1,fh do
    for i=1,fw do
      frameNum= frameNum+1
      table.insert(frameT,love.graphics.newQuad((i-1)*w,(j-1)*h,w,h,imgw,imgh))
    end
  end
  frameT.img = img
  frameT.frameNum = frameNum
  setmetatable(frameT,data.dataMeta)
  if data.frames[frameT.id]~=nil then
    error("repetitive frameT id :"..frameT.id)
  end
  data.frames[frameT.id] = frameT
end







local function loadFrames()

  load1f("bash1",32,32,0.05)
  load1f("quanhit",32,32,0.05)
  load1f("light_bash_hit",32,32,0.06)
  load1f("bash_hit",40,40,0.05)
  load1f("cut_hit1",32,32,0.05)
  load1f("cut_hit2",32,32,0.05)
  load1f("cut_hit3",48,48,0.05)
  load1f("stab_hit",32,32,0.05,2,10,10)
  load1f("spear_hit",64,32,0.05,2,29,16)
  load1f("clawhit",32,32,0.06)
  load1f("bitehit",32,32,0.07)
  load1f("crush",80,48)
  load1f("red_dead",86,56)
  load1f("green_dead",84,48)
  load1f("miss",25,11,0.5)
  load1f("bullet1",32,32,0.05)
  load1f("bullet2",32,32,0.05)
  load1f("bullet3",40,32,0.05)
  load1f("bullet4",32,32,0.05)
  load1f("arrow_wood",32,32,0.06)
  load1f("lazerbullet",32,32,0.05)
  
  
  --ability
  load1f("magic_circle",32,32,0.15)
  load1f("small_magic",32,32,0.10)
  load1f("single_circle",64,64,0.3)
  
  load1f("fire_ball",32,32,0.065)
  load1f("jump_cut",64,64,0.05,2,24,40)
end



return function ()
  loadFrames()
end