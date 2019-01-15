local suit = require"ui/suit"

local iteminfo_img = ui.res.iteminfo_img
local iteminfo_quad = ui.res.iteminfo_quad --已被通用化



local tmpinfo ={}
local scroll_info = {opt = {id =newid(),vertical = true}}

local function createSnapshoot(curCtype,w)
  if tmpinfo.ctype == curCtype then 
    return--无变化，不用修改
  end
  
  tmpinfo ={}
  tmpinfo.item = curCtype
  tmpinfo.name = curCtype.name
  
  tmpinfo.img,tmpinfo.quad =  g.vehicle.getComponentTypeFirstQuadAndImg(curCtype)
  
  local textWidth = w-50--默认文字宽
  local length = 0;
  local info_text = love.graphics.newText(c.font_c16)
  local function addOneLineInfo(table)--必须是一行，带换行
    info_text:addf(table,textWidth,"left",0,length)
    length = length+ info_text:getHeight()
  end
  
  addOneLineInfo{{170/255,170/255,170/255},string.format(tl("总耐久:%d","Durability:%d"),curCtype.durability)}
  addOneLineInfo{{210/255,210/255,210/255},string.format(tl("伤害减免:%d%%","Dam reduction:%d%%"),100-curCtype.dmg_mod)}
  tmpinfo.info_text = info_text
  tmpinfo.totalLen = length
end






local function draw_iteminfo(curCtype,x,y,w,h)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,w,h)
  if tmpinfo.img then
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(tmpinfo.img,tmpinfo.quad,x+10,y+4,0,2,2)
  end
  love.graphics.oldColor(225,225,225)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tmpinfo.name, x+79, y+18)
end

local function inter_panel(x,y)
  local function draw_p()
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(tmpinfo.info_text,x,y)
  end
  suit:registerDraw(draw_p)
end

function ui.componentInfo(curCtype,x,y,w,h,reserved_h)
  reserved_h =reserved_h or 10
  createSnapshoot(curCtype,w)
  suit:registerHitbox(nil,iteminfo_quad, x,y,w,h)
  suit:registerDraw(draw_iteminfo,curCtype,x,y,w,h)--等于发送的是缓存的物品指针。源物品可能因为后续的操作逻辑被销毁或改变等。但最多存在本帧内
  ui.scrollContent(x+15,y+74,w-50,h-reserved_h-84,tmpinfo.totalLen,scroll_info,inter_panel)
end

function ui.componentInfo_reset()--强行重置
  tmpinfo.item = nil
end