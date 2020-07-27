local suit = require"ui/suit"

local backs9 = c.pic["iteminfo_s9"]

local cachedAbi
local cachedUnit
local cachedFrame
local panel_id = newid()
local magstr = tl("技能类型：魔法","Ability Type: Spell")
local skistr = tl("技能类型：招式","Ability Type: Skill")
local magcolor = {0.5,0.5,0.9}
local skicolor = {0.9,0.6,0.3}
local info_text  = love.graphics.newText(c.font_c18)
local cachedH  =10

local function createSnapshoot(abi,unit,w)
  if cachedAbi ==abi and cachedUnit ==unit and g.curFrame- cachedFrame <150 then return end
  cachedFrame = g.curFrame
  cachedAbi = abi
  cachedUnit = unit
  info_text:clear()
  local textWidth = w-20--默认文字宽
  local length = 0;
  local function addOneLineInfo(table)--必须是一行，带换行
    info_text:addf(table,textWidth,"left",0,length)
    length = length+ info_text:getHeight()
  end
  local greyinfo = {0.7,0.7,0.7}
  local gmainattr = g.main_attr[abi:getMainAttr()]
  addOneLineInfo{greyinfo,tl("主属性:","Base Attr:"),gmainattr.color,gmainattr.name}
  addOneLineInfo{greyinfo,tl("法力消耗: ","Cost Mana: "),{0.2,0.7,1},tostring(abi:getCostMana())}
  addOneLineInfo{greyinfo,string.format(tl("冷却时间:%ss","Cool down:%.1fs"),abi:getCooldown())}
  addOneLineInfo(abi:getDescription(unit))
  cachedH = 74+length
end
local function draw_info(x,y,w,h)
  local abi = cachedAbi
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(backs9,x,y,w,h)
  local icon = abi:getAbilityIcon()
  love.graphics.draw(icon,x+10,y+10,0,2,2)
  love.graphics.setColor(0.9,0.9,0.9)
  love.graphics.setFont(c.font_c20)
  love.graphics.printf(abi:getName(), x+68, y+12,w-78,"left")
  love.graphics.setColor(0.6,0.8,1)
  love.graphics.printf(string.format("Lv%d",abi:getLevel()), x+68, y+12,w-78,"right")
  love.graphics.setFont(c.font_c16)
  local isMag = abi:isMagic() 
  love.graphics.setColor(isMag and magcolor or skicolor)
  love.graphics.print(isMag and magstr or skistr, x+70, y+38)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(info_text,x+10,y+64)
end



return function(abi,unit,x,y,w,isTopAlign,minH)
  minH = minH or 10
  createSnapshoot(abi,unit,w)
  
  local h  =math.max(minH,cachedH)
  if not isTopAlign then
    y = y-h
  else
    suit:registerHitbox(nil,panel_id,x,y,w,h)
  end
  suit:registerDraw(draw_info,x,y,w,h)
  
end