local suit = require"ui/suit"

local numberAskWin = Window.new()
ui.numberAskWin = numberAskWin


local blockScreen_id = newid()
local s_win = {d_name = tl("多少个?","How many?"),id=newid(),startx= c.win_W/2-200,starty =c.win_H/2-120, w= 300,h =160,dragopt = {id= newid()}}
local okbtn_opt = {name =tl("确定(e)","OK(e)"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("取消(q)","Cancel(q)"),font=c.font_c16,id= newid()}
local slider_info ={min = 1,max =2,step=1,value=2,opt = {id = newid()}} 
local label_opt = {font =c.font_c20 }
local callback = nil

function numberAskWin:keyinput(key)
  if key=="comfirm" then self:Close();g.playSound("unpop1") end
  if key=="cancel" then self:Close(true) end
end

function numberAskWin:win_open(endcall,min,max,defalut_value,x,y,nameinfo)
  g.playSound("pop2")
  callback = endcall
  slider_info.min = min
  slider_info.max = max
  slider_info.value = defalut_value
  if x and y then
    s_win.x =  x-80
    s_win.y =  y-125
  else
    s_win.x =  s_win.startx
    s_win.y =  s_win.starty
  end
  if nameinfo then --可选名称
    s_win.name = nameinfo
  else
    s_win.name = s_win.d_name
  end
end





function numberAskWin:win_close(quit)
  if quit then
    callback(0) --回调
  else
    local intval = math.floor(slider_info.value+0.5)
    callback(intval)
  end
end


function numberAskWin:window_do(dt)
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  local intval = math.floor(slider_info.value+0.5)
  suit:Label(string.format("%d/%d",intval,slider_info.max),label_opt,s_win.x+30,s_win.y+40,240,32)
  suit:Slider(slider_info,slider_info.opt,s_win.x+30,s_win.y+64,240,32)
  local ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.x+30,s_win.y+110,100,30)
  local ce_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.x+170,s_win.y+110,100,30)
  if ok_st.hit then self:Close();g.playSound("unpop1")end
  if ce_st.hit then self:Close(true)end
end