local suit = require"ui/suit"
--先声明本体
local tacticsWin = {name = tl("战术/AI","Tactics/AI"),icon = 23,opt = {id= newid()}}


function tacticsWin.keyinput(key)
  
end

function tacticsWin.win_open()
end

function tacticsWin.win_close()
  
end


function tacticsWin.window_do(dt,s_win)
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
end

return tacticsWin