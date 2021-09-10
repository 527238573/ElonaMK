require "strict" --
--require "console/cupid"
require "file/saveT"

--载入图片之前需预设置此项，如果延后设置对之前载入的图片无效
love.graphics.setDefaultFilter("linear","nearest")--linear nearest
--载入主要模块代码（主要为建立全局变量 函数等，后续仍需load）
require "game/init"
local suit = require"ui/suit"





function love.load()
  --debug模式才有效
  c.initDebug() --在commonMain里有debugON OFF，对开启的代码段Debug
  --后续的载入，调用初始化函数
  data.init()
  
  
  --love.graphics.setFont(c.font_c14)
  --love.graphics.setBackgroundColor(70/255,70/255,70/255) 
  love.graphics.setBackgroundColor(0,0,0) 
  
  Scene.runScene(require"game/scenes/mainMenu")
end


function love.update(dt)
  Scene.checkNextScene()--在一帧开始时检查切换scene
  Scene.current_Scene.update(dt)
end

function love.draw()
  Scene.current_Scene.draw()
end


function love.wheelmoved(dx,dy)
  suit:updateMouseWheel(dx,dy)
end

function love.textinput(t)
  suit:textinput(t)
end

function love.keypressed(key)
  suit:keypressed(key)
  Scene.current_Scene.keypressed(key)
  --debugmsg("key press:"..key)
  
end


function love.threaderror(thread, errorstr)
  error("Thread error! "..errorstr)
  --debugmsg("Thread error!\n"..errorstr)
  -- thread:getError() will return the same error string now.
end


