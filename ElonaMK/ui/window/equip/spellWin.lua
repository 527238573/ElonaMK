local suit = require"ui/suit"
--先声明本体
local spellWin = {name = tl("招式/魔法","Skills/Spells"),icon = 15,opt = {id= newid()}}


function spellWin.keyinput(key)
  
end

function spellWin.win_open()
end

function spellWin.win_close()
  
end


function spellWin.window_do(dt,s_win)
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
end

return spellWin