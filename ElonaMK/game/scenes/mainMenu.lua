local mainMenu  = Scene.new()
local loadmain = love.graphics.newImage("data/pic/mainScreen.png")
local leaf = love.graphics.newImage("assets/ui/dp3.png")

local music = love.audio.newSource("assets/music/orc01.mp3","stream")
local suit = require"ui/suit"
local parchment = c.pic.parchment
local kuang = c.pic.titleKuang

local btnLoad_opt = {id = newid(),font = c.font_c20}
local btnNewStart_opt = {id = newid(),font = c.font_c20}
local btnFastStart_opt = {id = newid(),font = c.font_c20}
local btnConfig_opt = {id = newid(),font = c.font_c20}
local btnMapEditor_opt = {id = newid(),font = c.font_c20}
local btnQuit_opt = {id = newid(),font = c.font_c20}

local win_menu = {x = 200,y=300}

music:setLooping(true)

local particle


function mainMenu.enter()
  music:play()
  
  particle = love.graphics.newParticleSystem(leaf, 64)
  particle:setParticleLifetime(15, 30) -- Particles live at least 2s and at most 5s.
	particle:setEmissionRate(2)
  particle:setSizes(1,1.5)
	particle:setSizeVariation(0.5)
	--particle:setLinearAcceleration(-5, 30, 5, 30) -- Random movement in all directions.
	--particle:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
  particle:setSpeed( 80, 150 )
  particle:setEmissionArea( "uniform", c.WIN_W, 0, 0, false )
  particle:setDirection( 2.1 )
  particle:setRotation( 0, math.pi*2 )
  particle:setSpin( 0.8, 3 )
  particle:setSpread( 0.5 )
  for i=1,20 do  particle:update(0.5) end
end

function mainMenu.leave()
  music:stop()
  particle = nil
end





function mainMenu.update(dt)
  particle:update(dt)
  local fastStart = suit:S9Button("快速开始",btnFastStart_opt,win_menu.x+80,win_menu.y+80,200,40)
  local loadgame = suit:S9Button("继续冒险之旅",btnLoad_opt,win_menu.x+80,win_menu.y+140,200,40)
  local newgame = suit:S9Button("新的冒险之旅",btnNewStart_opt,win_menu.x+80,win_menu.y+200,200,40)
  local gameconfig= suit:S9Button("设定",btnConfig_opt,win_menu.x+80,win_menu.y+260,200,40)
  local mapeditor = suit:S9Button("地图编辑",btnMapEditor_opt,win_menu.x+80,win_menu.y+320,200,40)
  local quit = suit:S9Button("退出",btnQuit_opt,win_menu.x+80,win_menu.y+380,200,40)
  
  
  if fastStart.hit then
    g.fastStart()
    debugmsg("fastStart game")
    
  end
  
  if mapeditor.hit then
    Scene.runScene(require"game/scenes/mapEditor")
  end
  
  if quit.hit then
    love.event.push("quit")
  end
  
end

function mainMenu.draw()
  local w,h = loadmain:getDimensions()
  local scaleX,scaleY = c.WIN_W/w,c.WIN_H/h
  local scaleMax = math.max(scaleX,scaleY)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(loadmain,0,0,0,scaleMax,scaleMax)
  love.graphics.draw(particle, c.WIN_W * 0.5+100, 0)
  
  
  suit.theme.drawScale9Quad(parchment,win_menu.x,win_menu.y,360,500)
  suit.theme.drawScale9Quad(kuang,win_menu.x+40,win_menu.y-10,280,50)
  love.graphics.setColor(0,0,0)
  love.graphics.printf("冒险的路标",win_menu.x+41,win_menu.y+6, 280, "center")
  love.graphics.setColor(0.7,0.7,0.7)
	love.graphics.setFont(c.font_c20)
	love.graphics.printf("冒险的路标",win_menu.x+40,win_menu.y+5, 280, "center")
  
  suit:draw()
end



return mainMenu