local suit = require"ui/suit"




--old










local quads =  ui.res.wait_quads 
local blockScreen_id = newid()
local cancel_opt = {id = newid(),text = tl("取消","Cancel"),font=c.font_c16}
local no_cancel_text = tl("无法主动取消","Can not be canceled")
local query_pause

local function drawBack(activity,x,y,w,h)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(quads,x,y,w,h)
  
  
  local rate = math.min(1,math.max(0,activity.timePast / activity.totalTime))
  
  local barw,barh = 430,23
  local barx,bary = x+(w-barw)/2,y+80
  suit.theme.drawScale9Quad(ui.res.common_pbackS9,barx,bary,barw,barh)
  if rate>0 then
    local length = rate*barw
    suit.theme.drawScale9Quad(ui.res.common_pfrontS9,barx,bary,length,barh)
  end
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c20)
  love.graphics.printf(activity.name, x+16, y+5,w-32,"center")
  
  love.graphics.setFont(c.font_c16)
  love.graphics.printf(activity:getPastTimeStr(), x+16, bary-30,300,"left")
  love.graphics.printf(activity.totalTime_str, x+w-316, bary-30,300,"right")
  if not activity.manuallyCancel then
    love.graphics.printf(no_cancel_text, x+50, bary+30,w-100,"center")
  end
end



function ui.actitvityWin()
  
  
  local activity = player.activity

  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  
  local w,h = 550,180
  local x,y = (c.win_W-w)/2-50,(c.win_H-h)/2+150
  
  suit:registerDraw(drawBack,activity,x,y,w,h)
  if activity.manuallyCancel then
    local btn_state = suit:S9Button(cancel_opt.text,cancel_opt,x+w/2-60,y+110,120,35) 
    if btn_state.hit then
      player:cancel_activity()--点击取消
    end
  end
  
  if activity.pause then
    --弹出询问窗口
    query_pause(activity)
  end
  
  
end


--询问
local blockScreen_id2 = newid()
local s_win = {d_name=tl("中断活动","interrupt activity"),startx= c.win_W/2-250,starty =c.win_H/2-70, w= 400,h =160,dragopt = {id= newid()}}
local okbtn_opt = {name =tl("停止","Stop"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("继续","Continue"),font=c.font_c16,id= newid()}
local ignorebtn_opt = {name =tl("忽略","Ignore"),font=c.font_c16,id= newid()}

function query_pause(activity)
  suit:registerHitFullScreen(nil,blockScreen_id2)--全屏遮挡
  suit:Dialog(s_win.d_name,s_win.startx,s_win.starty,s_win.w,s_win.h)
  local function drawText()
    love.graphics.oldColor(22,22,22)
    love.graphics.setFont(c.font_c18)
    love.graphics.printf(activity.pause_msg, s_win.startx+10, s_win.starty+40,s_win.w-20,"center") --改成一次性的读取翻译
  end
  suit:registerDraw(drawText)
  
  
  local ok_st,cancel_st,ignore_st
  if not activity.pause.canIgnore then
    ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.startx+75,s_win.starty+110,100,30)
    cancel_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.startx+230,s_win.starty+110,100,30)
  else
    ok_st = suit:S9Button(okbtn_opt.name,okbtn_opt,s_win.startx+25,s_win.starty+110,100,30)
    cancel_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.startx+152,s_win.starty+110,100,30)
    ignore_st = suit:S9Button(ignorebtn_opt.name,ignorebtn_opt,s_win.startx+280,s_win.starty+110,100,30)
  end
  
  if ok_st.hit then 
    activity.pause = nil
    player:cancel_activity()--点击取消
  end
  if cancel_st.hit then
    activity.pause = nil
  end
  
  if ignore_st and ignore_st.hit then
    activity.pause = nil
    activity.ignore = true
  end
end

