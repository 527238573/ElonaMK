local suit = require"ui/suit"

local panel_img = ui.res.msg_panel_img
local quads =  ui.res.msg_panel_quads
ui.res.msgWin = quads --一些共享资源

local colortable=
{
  npc = {200,200,200},
  info = {200,200,200},
  good = {150,250,150},
  bad = {250,150,150},
  warning = {230,230,130},
}

local mFont = c.font_c16
local lineHigh = 18

local function defaultDraw(x,y,w,h)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(quads,x,y,w,h)
  love.graphics.setFont(mFont)
  local edge = 4
  local lineNum = math.floor((h-2*edge)/lineHigh)
  local lineWidth = w - 2*edge
  local line_starty = y +h-edge
  local line_startx = x +edge
  local curLine = 1
  local curMsg = 1
  local mlist = g.message.message_list
  while(curLine<= lineNum) do
    local msg = mlist[curMsg]
    if msg ==nil then break end
    --颜色
    local ccolor = colortable[msg.msgtype]
    if ccolor then
      love.graphics.oldColor(ccolor[1],ccolor[2],ccolor[3])
    else
      love.graphics.oldColor(200,200,200)
    end--还需加入时间渐变，以及跳出
    --断行
    if msg.warpped_mwin ==nil then
      local msgtext=  msg.msg
      if msg.count then msgtext= msgtext.."x"..msg.count end
      local wn,wt = mFont:getWrap( msgtext, lineWidth)
      msg.warpped_mwin = wt
    end
    --开始画
    for i=1,#msg.warpped_mwin do
      local oneline = msg.warpped_mwin[#msg.warpped_mwin-i+1]
      if curLine+i-1>lineNum  then break end
      local thisy = line_starty -(curLine+i-1)*lineHigh
      love.graphics.print(oneline,line_startx,thisy)
    end
    curLine = curLine + #msg.warpped_mwin
    curMsg = curMsg+1
  end
end

function ui.messageWin(x,y,w,h)
  suit:registerDraw(defaultDraw,x,y,w,h)
end