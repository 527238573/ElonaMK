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

function Item:getMeleeDFB()
  local itype = self.type
  if itype.meleeWeapon then
    return itype.diceNum_m,itype.diceFace_m,itype.baseAtk_m
  end
  return 0,0,0 
end

--还有要加上子弹的伤害。
function Item:getRangeDFB()
  local itype = self.type
  if itype.rangeWeapon then
    return itype.diceNum_r,itype.diceFace_r,itype.baseAtk_r
  end
  return 0,0,0 
end

--攻击等级
function Item:getAttackLevel()
  return self.level
end
--命中加成
function Item:getHitBonus()
  return self.type.hit
end
--暴击加成
function Item:getCritBonus()
  return self.type.crit
end


function Item:getWeaponSkill(isMelee)
  local skill1,skill2
  if isMelee then
      skill1 = self.type.melee_skill_a[1] or "martial_arts" --不能为空。
      skill2 = self.type.melee_skill_a[2] --最多两个。多了不算在内。
  else
      skill1 = self.type.range_skill_a[1] or "throw" --不能为空。
      skill2 = self.type.range_skill_a[2] --最多两个。多了不算在内。
  end
  return skill1,skill2
end

--枪械类武器不使用外部的攻击等级加成
function Item:UseAttakLevelBonus()
  return self.type.fixShotCost~= true
end


function Item:getRangeWeaponDmgType()
  if self:hasFlag("ENERGYGUN") then return "fire" end
  return "stab"--枪弹弓箭默认穿刺伤害
end