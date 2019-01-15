require "strict" --
--require "console/cupid"
require "file/saveT"

--载入图片之前需预设置此项，如果延后设置对之前载入的图片无效
love.graphics.setDefaultFilter("linear","nearest")--linear nearest
--载入主要模块代码（主要为建立全局变量 函数等，后续仍需load）
require "init/init"
local suit = require"ui/suit"
--require "game/common"
--require "game/game"
--require "ui/ui"
--require "render/render"
--local suit = require"ui/suit"
--require "ztest/test"
function love.load()
  --debug模式才有效
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  --后续的载入，调用初始化函数
  --g.init()--game model(roguelike ) init
  --ui.init() -- userinterface init
  --render.init()  --rendering system init
  data.init()
  
  
 
  --love.graphics.setFont(c.font_c14)
  love.graphics.setBackgroundColor(150/255,150/255,150/255) 
  
  
  g.runScene(require"Scenes/mainMenu")
end


function love.update(dt)
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
  
  --ui.keypressed(key)
  
  
  
   --if not suit.anyKeyboardFocus() then eui.handleKeyPressed(key) end
   --[[
   
  if key=="l" then
     --test.testAdd1()
     test.testnew()
    --g.message.addmsg("我欲成仙，快乐齐天！")
    --testSeeSpeed()
  --elseif key=="f" then
    --test.testF()
  elseif key=="k" then
    test.testAdd2()
    test.testnew2()
  elseif key=="j" then
    
    --test.testfastForward()
    test.spawn_v()
  elseif key=="h" then  
    --test.print_v()
    test.printLight()
  elseif key=="i" then  
    test.testfastForward()
  elseif key=="o" then  
    test.testfastForwardSlow()
  end
  --]]
end





