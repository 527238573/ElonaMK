local suit = require"ui/suit"

local shortCutWin = Window.new()
ui.shortCutWin = shortCutWin
local small_parchment = love.graphics.newImage("assets/ui/small_parchment.png")


local blockScreen_id = newid()
local s_win = {id=newid(),startx= c.win_W/2-250,starty =c.win_H/2-120, w= small_parchment:getWidth()*2,h =small_parchment:getHeight()*2}
local clearbtn_opt = {name =tl("清除绑定键","Clear binding"),font=c.font_c16,id= newid()}
local cancelbtn_opt = {name =tl("取消(esc)","Cancel(esc)"),font=c.font_c16,id= newid()}
local label_opt = {font =c.font_c20 }
local mstr = tl("按下快捷键1~8 绑定到动作条指定位置...","Press the shortcut 1~8 to bind to the position specified in the action bar...")
local callback = nil



local function drawWin(x,y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(small_parchment,x,y,0,2,2)
end



function shortCutWin:keyinput(key)
  if key=="cancel" then self:Close(false) return end--
  local shortcut = ui.keyToActionIndex(key)
  if shortcut then
    self:Close(false,shortcut)
  end
end

function shortCutWin:win_open(endcall)
  g.playSound("pop2")
  callback = endcall
  s_win.x =  s_win.startx
  s_win.y =  s_win.starty
end





function shortCutWin:win_close(clear,shortcut)
  g.playSound("unpop1")
  callback(clear,shortcut)
end


function shortCutWin:window_do(dt)
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  suit:registerDraw(drawWin,s_win.x,s_win.y)
  local state = suit:registerHitbox(nil,s_win.id,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:Label(mstr,label_opt,s_win.x+30,s_win.y+40,250,32)
  local clear_st = suit:S9Button(clearbtn_opt.name,clearbtn_opt,s_win.x+30,s_win.y+155,120,35)
  local ce_st = suit:S9Button(cancelbtn_opt.name,cancelbtn_opt,s_win.x+170,s_win.y+155,120,35)
  if clear_st.hit then self:Close(true)end
  if ce_st.hit then self:Close(false)end
end