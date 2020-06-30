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
    local dice,face,base = mc:getWeaponDisplayData(oneWeapon)
    local modifier = mc:getWeaponModifier(oneWeapon)
    local name = oneWeapon.unarmed and tl("格斗","Unarmed") or oneWeapon.item:getShortName()
    local cost = mc:melee_cost(oneWeapon)
    local dps = (face/2 +base)*modifier /cost
    local hitLevel = mc:getHitLevel(oneWeapon)
    local dmgstr
    if base ==0 then 
      dmgstr = string.format("%dr%d x%.1f (%.1f,%.1f)",dice,face,modifier,dps,hitLevel)
    elseif base>0 then
      dmgstr = string.format("%dr%d+%d x%.1f (%.1f,%.1f)",dice,face,base,modifier,dps,hitLevel)
    elseif base<0 then
      dmgstr = string.format("%dr%d%d x%.1f (%.1f,%.1f)",dice,face,base,modifier,dps,hitLevel)
    end
    love.graphics.print(string.format(tl("近战%d","Melee%d"),i), x+53, y+480+lineH*(nline-1)) 
    love.graphics.print(name, x+133, y+480+lineH*(nline-1)) 
    love.graphics.print(dmgstr, x+233, y+480+lineH*(nline-1)) 
  end
  
  local rangeList = mc.weapon_list.range
  for i=1,#rangeList do
    nline = nline+1
    local oneWeapon = rangeList[i]
    local weaponItem = oneWeapon.item
    local dice,face,base = mc:getWeaponDisplayData(oneWeapon)
    local modifier = mc:getWeaponModifier(oneWeapon)
    local pellet = weaponItem:getPellet()
    local cost = mc:shoot_cost(oneWeapon)
    local dps = (face/2 +base)*modifier /cost *pellet
    local hitLevel = mc:getHitLevel(oneWeapon)
    local name = weaponItem:getShortName()
    local dmgstr
    if base ==0 then 
      dmgstr = string.format("%dr%d",dice,face)
    elseif base>0 then
      dmgstr = string.format("%dr%d+%d",dice,face,base)
    elseif base<0 then
      dmgstr = string.format("%dr%d%d",dice,face,base)
    end
    if pellet>1 then
      dmgstr = string.format("%dx(%s) x%.1f (%.1f,%.1f)",pellet,dmgstr,modifier,dps,hitLevel)
    else
      dmgstr = string.format("%s x%.1f (%.1f,%.1f)",dmgstr,modifier,dps,hitLevel)
    end
    
    love.graphics.print(string.format(tl("远程%d","Range%d"),i), x+53, y+480+lineH*(nline-1)) 
    love.graphics.print(name, x+133, y+480+lineH*(nline-1)) 
    love.graphics.print(dmgstr, x+233, y+480+lineH*(nline-1)) 
  end
  
  
  local dodgeLevel = mc:getDodgeLevel()
  local ar = mc:getAR()
  local mr = mc:getMR()
  love.graphics.printf(string.format(tl("闪避等级:%d","Dodge Level:%d"),dodgeLevel), x+543, y+480+lineH*0,200,"right") 
  love.graphics.printf(string.format(tl("护甲:%d","Armor:%d"),ar), x+543, y+480+lineH*1,200,"right") 
  love.graphics.printf(string.format(tl("魔抗:%d","Magic Resist:%d"),mr), x+543, y+480+lineH*2,200,"right") 
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