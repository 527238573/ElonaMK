
function ui.drawFix(x,y,w,h)
  
  local mc = p.mc
  local weaponlist = mc.weapon_list
  
  love.graphics.setFont(c.font_c18)
  love.graphics.setColor(0.25,0.25,0.25)
  local lineH = 20
  for i=1,#weaponlist do
    love.graphics.print(string.format("近战武器%d",i), x+73, y+480+lineH*(i-1)) 
    local witem = weaponlist[i].item
    local base = mc:getWeaponBaseAtk(witem)
    local modifier = mc:getWeaponMeleeModifier(witem)
    local face = witem.diceFace
    local dice = witem.diceNum
    local dmgstr
    if base ==0 then 
      dmgstr = string.format("%dr%d x%.1f",dice,face,modifier)
    elseif base>0 then
      dmgstr = string.format("%dr%d+%d x%.1f",dice,face,base,modifier)
    elseif base<0 then
      dmgstr = string.format("%dr%d%d x%.1f",dice,face,base,modifier)
    end
    love.graphics.print(dmgstr, x+183, y+480+lineH*(i-1)) 
  end
  
  if #weaponlist ==0 then
    love.graphics.print("格斗", x+73, y+480) 
    local dice,face,base= mc:getUnarmedDice()
    local modifier = mc:getUnarmedModifier()
    love.graphics.print(string.format("%dr%d+%d x%.1f",dice,face,base,modifier), x+183, y+480) 
  end
  
end