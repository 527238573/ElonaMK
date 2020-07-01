
local suit = require "ui/suit"


local fragpaper = love.graphics.newImage("assets/ui/fragpaper.png")
local bulletIconImg = love.graphics.newImage("assets/ui/bulletIcon.png")

local type2index = {
    arrow = 3,
    l_bullet = 1,
    h_bullet = 1,
    lazer = 2,
  }

local ammoStr2 = tl("通常弹:∞","Normal Ammo:∞")
local function oneRangeWeapon(oneWeapon,x,y)
  local weaponItem = oneWeapon.item
  local ammoStr=nil
  local curAmmo
  local maxAmmo 
  if weaponItem.useReload then
    curAmmo = weaponItem.ammoNum
    maxAmmo = weaponItem:getMaxAmmo()
    ammoStr=string.format("%d/%d",curAmmo,maxAmmo)
  end
  local iconIndex = type2index[weaponItem:getAmmoType()] or 1
  local iconlist =  c.pic.bulletIcon
  
  suit:registerDraw(function() 
      love.graphics.setColor(1,1,1)
      love.graphics.draw(fragpaper,x,y,0,2,2)
      love.graphics.draw(iconlist.img,iconlist[iconIndex],x,y,0,2,2)
      
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.setFont(c.font_c18)
      if ammoStr then
        if curAmmo<=0.05*maxAmmo then
          love.graphics.setColor(0.7,0.1,0.1)
          love.graphics.print(ammoStr, x+48, y+10) 
          love.graphics.setColor(0.1,0.1,0.1)
        else
          love.graphics.print(ammoStr, x+48, y+10)
        end
        love.graphics.setFont(c.font_c14)
        love.graphics.print(ammoStr2, x+45, y+30) 
      else
        love.graphics.setFont(c.font_c14)
        love.graphics.print(ammoStr2, x+45, y+20) 
      end
    end)
end

return function(x,y)
  local rangelist = p.mc.weapon_list.range
  local weaponNum = #rangelist
  if weaponNum<1 then return 0 end
  for i=1,weaponNum do
    oneRangeWeapon(rangelist[i],x,y-(weaponNum+1-i)*50)
  end
  return weaponNum*50
end