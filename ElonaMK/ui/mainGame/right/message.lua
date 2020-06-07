local suit = require"ui/suit"


ui.message = {}

local colortable=
{
  npc = {200/255,200/255,200/255},
  info = {200/255,200/255,200/255},
  good = {150/255,250/255,150/255},
  bad = {250/255,150/255,150/255},
  warning = {230/255,230/255,130/255},
}
local window_width =296
local maxLen = 600
local old_text =nil
local msg_text = love.graphics.newText(c.font_c16)
local textTable = {}
local lastMsg = nil
local lastCount = 0
local lastIndex = 0
local lastTime = -1
local needFlush = false
local function flushText()
  if needFlush then
    needFlush = false
    msg_text:clear()
    msg_text:addf(textTable,window_width,"left",0,0)
  end
end



function ui.message.addmsg(msg,msgtype)
  msgtype = msgtype or "info"
  if msg == nil then return end
  if msg ==lastMsg then
    if love.timer.getTime() - lastTime<0.4 then
      return --时间太短不跟新
    end
    lastCount =lastCount +1
    textTable[lastIndex] = string.format("%sx%d",lastMsg,lastCount)
    needFlush = true
    lastTime = love.timer.getTime()
    return
  end
  if msg_text:getHeight()>maxLen then
    flushText()
    old_text = msg_text
    msg_text = love.graphics.newText(c.font_c16)
    textTable = {}
    lastMsg = nil
    lastCount = 0
    lastIndex = 0
    lastTime = -1
  end
  local colorT = assert(colortable[msgtype])
  table.insert(textTable,colorT)
  table.insert(textTable,msg)
  lastMsg = msg
  lastCount =1
  lastIndex = #textTable
  lastTime = love.timer.getTime()
  needFlush = true
end
addmsg = ui.message.addmsg



local mFont = c.font_c16
local lineHigh = 18

local function defaultDraw(x,y,w,h)
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(c.pic["msg_quads"],x,y,w,h)
  flushText()
  love.graphics.setFont(mFont)
  local edge = 4
  local lineNum = math.floor((h-2*edge)/lineHigh)
  local lineWidth = w - 2*edge
  local line_starty = y +h-edge
  local line_startx = x +edge
  local hight = msg_text:getHeight()
  love.graphics.setScissor(x,y,w,h)
  love.graphics.draw(msg_text,line_startx,line_starty-hight)
  if old_text then
    local hight2 = old_text:getHeight()
    love.graphics.draw(old_text,line_startx,line_starty-hight-hight2)
  end
  love.graphics.setScissor()
  
end

return function(x,y,w,h)
  suit:registerDraw(defaultDraw,x,y,w,h)
end