local suit = require"ui/suit"
--物品详细信息面板
local iteminfo_img = ui.res.iteminfo_img
local iteminfo_quad = ui.res.iteminfo_quad --已被通用化


local tmpinfo ={}
local info_text = love.graphics.newText(c.font_c16)
local scroll_info = {opt = {id =newid(),vertical = true}}

local function createSnapshoot(curItem,w)
  --快照物品信息并保存。有变化时重制
  --可能的变化，物品变。物品里堆叠变化，容器内容变化，腐坏度损坏度变化等
  if tmpinfo.item == curItem and tmpinfo.stack_num == curItem.stack_num then 
    return--无变化，不用修改
  end
  --重置快照
  local itype = curItem.type
  
  tmpinfo ={}
  tmpinfo.item = curItem
  tmpinfo.stack_num = curItem.stack_num
  tmpinfo.name = curItem:getName()
  --tmpinfo.wv_info = string.format("%s%.2fkg %s%d",tl("重量:","Weight:"),curItem:getWeight()/100,tl("体积:","Volume:"),curItem:getVolume())
  tmpinfo.w_info = string.format("%s%.2fkg ",tl("重量:","Weight:"),curItem:getWeight()/100)
  tmpinfo.v_info = string.format("%s%d",tl("体积:","Volume:"),curItem:getVolume())
  tmpinfo.wv_text= love.graphics.newText(c.font_c16)
  tmpinfo.wv_text:add({{170/255,170/255,170/255},tmpinfo.w_info,{210/255,210/255,210/255},tmpinfo.v_info,},79,43)
  
  local textWidth = w-50--默认文字宽
  local length = 0;
  info_text:clear()
  local function addOneLineInfo(table)--必须是一行，带换行
    info_text:addf(table,textWidth,"left",0,length)
    length = length+ info_text:getHeight()
  end
  
  addOneLineInfo{{170/255,170/255,170/255},itype.description,}
  addOneLineInfo{{210/255,210/255,210/255},"仅为了测试换行，",}
  --[[
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，仅为了测试换行，仅为了测试换行，仅为了测试换行，仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  addOneLineInfo{{210,210,210},"仅为了测试换行，",}
  --]]
  tmpinfo.info_text = info_text
  tmpinfo.totalLen = length
end



function ui.scrollContent(x,y,w,h,realH,scroll_info,contentCall)
  local useScroll = realH>h 
  local startx,starty= x,y
  if useScroll then
    scroll_info.w = w
    scroll_info.h = realH
    --使用滚动条
    suit:ScrollRect(scroll_info,scroll_info.opt,x,y,w,h)
    starty = scroll_info.y
  end
  
  contentCall(startx,starty)
  if useScroll then
    
    suit:endScissor()
    suit:wheelRollInRect(x,y,w,h,scroll_info)
  end
  
end


local function draw_iteminfo(curItem,x,y,w,h)
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(iteminfo_quad,x,y,w,h)
  local  item_img,item_quad = curItem:getImgAndQuad()
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(item_img,item_quad,x+10,y+4,0,2,2)
  love.graphics.oldColor(225,225,225)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tmpinfo.name, x+79, y+18)
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(tmpinfo.wv_text,x,y)
  --love.graphics.oldColor(170,170,170)
  --love.graphics.setFont(c.font_c16)
  --love.graphics.print(tmpinfo.wv_info, x+79, y+43)
  
  --love.graphics.draw(tmpinfo.info_text,x+15,y+74)
end

local function inter_panel(x,y)
  local function draw_p()
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(tmpinfo.info_text,x,y)
  end
  suit:registerDraw(draw_p)
end

-- 自由宽高，但要一定最小值，宽太小导致物品名字超出框，长度不够会启用滚动条 reserved_h：底部保留的高度，用于母界面 布置可操作的按钮
function ui.iteminfo(curItem,x,y,w,h,reserved_h)
  reserved_h =reserved_h or 10
  createSnapshoot(curItem,w)
  suit:registerHitbox(nil,iteminfo_quad, x,y,w,h)
  suit:registerDraw(draw_iteminfo,curItem,x,y,w,h)--等于发送的是缓存的物品指针。源物品可能因为后续的操作逻辑被销毁或改变等。但最多存在本帧内
  
  ui.scrollContent(x+15,y+74,w-50,h-reserved_h-84,tmpinfo.totalLen,scroll_info,inter_panel)
end

function ui.iteminfo_reset()--强行重置
  tmpinfo.item = nil
end
