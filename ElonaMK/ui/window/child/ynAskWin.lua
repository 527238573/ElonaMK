local suit = require"ui/suit"

local ynAskWin = Window.new()
ui.ynAskWin = ynAskWin



local blockScreen_id = newid()
local s_win = {d_name = tl("多少个?","How many?"),id=newid(),startx= c.win_W/2-200,starty =c.win_H/2-120, w= 300,h =160,dragopt = {id= newid()}}
local okbtn_opt = {name =tl("是(y/e)","Yes(y/e)"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("否(n/q)","No(n/q)"),font=c.font_c16,id= newid()}
local label_opt = {font =c.font_c20 }
local callback = nil
local ask_msg

function ynAskWin:keyinput(key)
  if key=="comfirm" then self:Close(true);g.playSound("unpop1") end
  if key=="cancel" then self:Close(false) end
  if key=="y" then self:Close(true) end
  if key=="n" then self:Close(false) end
  if key=="space" then self:Close(true) end
end

function ynAskWin:win_open(endcall,showmsg)
  g.playSound("pop2")
  callback = endcall
  s_win.name = " "
  s_win.x =  s_win.startx
  s_win.y =  s_win.starty
  ask_msg = showmsg or " "
end





function ynAskWin:win_close(yes)
  g.playSound("unpop1")
  callback(yes==true)
end


function ynAskWin:window_do(dt)
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  
  suit:Label(ask_msg,label_opt,s_win.x+30,s_win.y+40,240,32)
  local ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.x+30,s_win.y+110,100,30)
  local ce_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.x+170,s_win.y+110,100,30)
  if ok_st.hit then self:Close(true);g.playSound("unpop1")end
  if ce_st.hit then self:Close(false)end
end