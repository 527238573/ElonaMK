local suit = require"ui/suit"


ui.message = {}


local message_list = {}
local max_length = 100
ui.message.message_list = message_list

function ui.message.addmsg(msg,msgtype)
  msgtype = msgtype or "info"
  if message_list[1] then
    if msg == message_list[1].msg and msgtype == message_list[1].msgtype then
      message_list[1].count = (message_list[1].count or 1)+1 --增加count
      message_list[1].warpped_mwin = nil--清除缓存
      return
    end
  end
  
  local msg_t = {msg = msg, msgtype = msgtype}
  --还有时间戳
  table.insert(message_list,1,msg_t)
  if #message_list>max_length then message_list[max_length+1] = nil end --清除末尾
end
addmsg = ui.message.addmsg



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
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(c.pic["msg_quads"],x,y,w,h)
  love.graphics.setFont(mFont)
  local edge = 4
  local lineNum = math.floor((h-2*edge)/lineHigh)
  local lineWidth = w - 2*edge
  local line_starty = y +h-edge
  local line_startx = x +edge
  local curLine = 1
  local curMsg = 1
  local mlist = message_list
  while(curLine<= lineNum) do
    local msg = mlist[curMsg]
    if msg ==nil then break end
    --颜色
    local ccolor = colortable[msg.msgtype]
    if ccolor then
      love.graphics.setColor(ccolor[1]/255,ccolor[2]/255,ccolor[3]/255)
    else
      love.graphics.setColor(200/255,200/255,200/255)
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

return function(x,y,w,h)
  suit:registerDraw(defaultDraw,x,y,w,h)
end