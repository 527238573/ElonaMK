function Item:getShotCost()
  return self.type.shotCost
end

function Item:getMeleeCost()
  return self.type.atkCost
end

function Item:getShootSound()
  return self.type.shootSound
end

function Item:getBulletFrames()
  return self.type.bullet
end

function Item:getMaxRange()
  return self.type.maxRange
end

function Item:getDispersion()
  return self.type.dispersion
end

function Item:getMaxAmmo()
  return self.type.maxAmmo
end

function Item:getAmmoType()
  return self.type.ammo_type
end

function Item:getReloadCost()
  return self.type.reloadCost
end

function Item:getReloadSound()
  return self.type.reloadSound
end

function Item:getPellet()
  return self.type.pellet
end

function Item:randomWeaponDamage(isMelee)
  if isMelee then
    local roll = 0
    local dnum = math.max(1,self.diceNum)
    for i=1,dnum do
      roll = roll+rnd()
    end
    roll = roll/dnum
    return self.baseAtk + roll*self.diceFace
  else
    local roll = 0
    local dnum = math.max(1,self.diceNum_range)
    for i=1,dnum do
      roll = roll+rnd()
    end
    roll = roll/dnum
    return self.baseAtk_range + roll*self.diceFace_range
  end
end
