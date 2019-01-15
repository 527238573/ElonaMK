local suit = require"ui/suit"

local blockScreen_id = newid()
local s_win = {d_name=tl("多少个?","How many?"),startx= c.win_W/2-200,starty =c.win_H/2-120, w= 300,h =160,dragopt = {id= newid()}}
local okbtn_opt = {name =tl("确定(e)","OK(e)"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("取消(q)","Cancel(q)"),font=c.font_c16,id= newid()}
local slider_info ={min = 1,max =2,step=1,value=2,opt = {id = newid()}} 
local label_opt = {font =c.font_c20 }
local callback = nil

local askNumberWin = ui.new_window()
ui.askNumberWin = askNumberWin


function askNumberWin.keyinput(key)
  if key=="e" or key=="return" then askNumberWin:Close(true) end
  if key=="q" or key=="escape" then askNumberWin:Close() end
end


--仅仅是修改初始状态
function askNumberWin.win_open(endcall,min,max,defalut_value,x,y,nameinfo)
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

function askNumberWin.win_close(confirm)
  if confirm then
    local intval = math.floor(slider_info.value+0.5)
    callback(intval)
  else
    --不再回调，取消。为了正常关闭。或者给回调输入0
  end
end


function askNumberWin.window_do()
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  local intval = math.floor(slider_info.value+0.5)
  suit:Label(string.format("%d/%d",intval,slider_info.max),label_opt,s_win.x+30,s_win.y+40,240,32)
  
  suit:Slider(slider_info,slider_info.opt,s_win.x+30,s_win.y+64,240,32)
  
  local ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.x+30,s_win.y+110,100,30)
  local ce_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.x+170,s_win.y+110,100,30)
  if ok_st.hit then askNumberWin:Close(true)end
  if ce_st.hit then askNumberWin:Close()end
end
