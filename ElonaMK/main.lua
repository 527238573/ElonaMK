require "strict" --
--require "console/cupid"
require "file/saveT"

--载入图片之前需预设置此项，如果延后设置对之前载入的图片无效
love.graphics.setDefaultFilter("linear","nearest")--linear nearest
--载入主要模块代码（主要为建立全局变量 函数等，后续仍需load）
require "init/init"
local suit = require"ui/suit"





function love.load()
  --debug模式才有效
  c.initDebug()
  --后续的载入，调用初始化函数
  data.init()
  
  
  --love.graphics.setFont(c.font_c14)
  --love.graphics.setBackgroundColor(70/255,70/255,70/255) 
  love.graphics.setBackgroundColor(0,0,0) 
  
  g.runScene(require"Scenes/mainMenu")
end


function love.update(dt)
  g.checkNextScene()--在一帧开始时检查切换scene
  g.current_Scene.update(dt)
end

function love.draw()
  g.current_Scene.draw()
end


function love.wheelmoved(dx,dy)
  suit:updateMouseWheel(dx,dy)
end

function love.textinput(t)
  suit:textinput(t)
end

function love.keypressed(key)
  suit:keypressed(key)
  g.current_Scene.keypressed(key)
  --debugmsg("key press:"..key)
  
end





