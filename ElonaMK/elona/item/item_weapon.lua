function Item:getShotCost()
  return self.type.shotCost
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