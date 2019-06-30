local suit = require"ui/suit"
--先声明本体
local traitsWin = {name = tl("特性和效果","Traits/Buffs"),icon_index = 12}



function traitsWin.keyinput(key)
  
end

function traitsWin.win_open()
end

function traitsWin.win_close()
  
end


function traitsWin.window_do(dt,s_win)
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
end

return traitsWin