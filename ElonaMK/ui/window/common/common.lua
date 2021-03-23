local suit = require "ui/suit"
function ui.drawFix(x,y,w,h)
  
  local mc = p.mc
  love.graphics.setFont(c.font_c18)
  love.graphics.setColor(0.25,0.25,0.25)
  local lineH = 20
  local nline = 0
  local meleeList = mc.weapon_list.melee
  for i=1,#meleeList do
    nline = nline+1
    local oneWeapon = meleeList[i]
    local name,dmgstr=mc:getWeaponDamStr(oneWeapon)
    love.graphics.print(string.format(tl("近战%d","Melee%d"),i), x+53, y+480+lineH*(nline-1)) 
    love.graphics.print(name, x+133, y+480+lineH*(nline-1)) 
    love.graphics.print(dmgstr, x+233, y+480+lineH*(nline-1)) 
  end
  
  local rangeList = mc.weapon_list.range
  for i=1,#rangeList do
    nline = nline+1
    local oneWeapon = rangeList[i]
    local name,dmgstr=mc:getWeaponDamStr(oneWeapon)
    love.graphics.print(string.format(tl("远程%d","Range%d"),i), x+53, y+480+lineH*(nline-1)) 
    love.graphics.print(name, x+133, y+480+lineH*(nline-1)) 
    love.graphics.print(dmgstr, x+233, y+480+lineH*(nline-1)) 
  end
  
  
  love.graphics.printf(string.format(tl("闪避等级:%d","Dodge Level:%d"),mc:getDodgeLevel()), x+543, y+480+lineH*0,200,"right") 
  love.graphics.printf(string.format(tl("护甲等级:%d","Armor Level:%d"),mc:getDEF()), x+543, y+480+lineH*1,200,"right") 
  love.graphics.printf(string.format(tl("魔抗等级:%d","Magic Resist Lv:%d"),mc:getMGR()), x+543, y+480+lineH*2,200,"right") 
  love.graphics.printf(string.format(tl("生命回复每秒:%.1f","HP regeneration:%.1f"),mc.hp_regen), x+543, y+480+lineH*3,200,"right") 
  love.graphics.printf(string.format(tl("魔法回复每秒:%.1f","MP regeneration:%.1f"),mc.mp_regen), x+543, y+480+lineH*4,200,"right") 
end


function ui.drawBar(value,style,x,y,w,h,border)
  local pb = c.pic.progressBar
  local xb, yb, wb, hb -- size of the progress bar
  xb, yb, wb, hb = x+border,y+ border, (w-2*border)*value, h-2*border
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(pb[1],x,y,w,h)
  if value>0 then
    suit.theme.drawScale9Quad(pb[style],xb,yb,wb,hb) 
  end
end