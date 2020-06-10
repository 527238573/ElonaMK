
--武器攻击倍乘系数。
function Unit:getWeaponModifier(weapon)
  local m_attr = 0
  if weapon.unarmed then
    m_attr = self:cur_str()
  else
    local weaponItem  =weapon.item
    local attr1 
    local weaponskill
    if weapon.isMelee  then
      weaponskill = weaponItem.type.weapon_skill_a[1] or "martial_arts" --不能为空。
      attr1 = self:cur_str()
    else
      weaponskill = weaponItem.type.weapon_skill_range_a[1] or "throw" --不能为空。
      attr1 = self:cur_per()
    end
    local attr2 = self:cur_main_attr(g.skills[weaponskill].main_attr)
    m_attr = attr1*0.6 +attr2*0.4 
  end
  if m_attr<20 then
    return 0.95+m_attr*(m_attr+1)/2*0.005
  else
    return m_attr*0.1
  end
end

function Unit:getWeaponBaseBonus(weapon)
  local skill1,skill2 --最多关联两个skill
  local weaponItem --可能为空。
  if weapon.unarmed then
    skill1 = "martial_arts"--格斗技能
  else
    weaponItem = weapon.item
    if weapon.isMelee then
      skill1 = weaponItem.type.weapon_skill_a[1] or "martial_arts" --不能为空。
      skill2 = weaponItem.type.weapon_skill_a[2] --最多两个。多了不算在内。
    else
      skill1 = weaponItem.type.weapon_skill_range_a[1] or "throw" --不能为空。
      skill2 = weaponItem.type.weapon_skill_range_a[2] --最多两个。多了不算在内。
    end
  end
  local skill_level=self:getSkillLevel(skill1)
  if skill2 then
    local l = self:getSkillLevel(skill2)
    skill_level = (skill_level+l)/2
  end
  return math.floor(skill_level *0.2)
end


--获取命中等级。传输的是装备的武器条目。
function Unit:getHitLevel(weapon)
  --根据武器类型取得等级来决定命中等级。
  local skill1,skill2 --最多关联两个skill
  local weaponItem --可能为空。
  if weapon.unarmed then
    skill1 = "martial_arts"--格斗技能
  else
    weaponItem = weapon.item
    if weapon.isMelee then
      skill1 = weaponItem.type.weapon_skill_a[1] or "martial_arts" --不能为空。
      skill2 = weaponItem.type.weapon_skill_a[2] --最多两个。多了不算在内。
    else
      skill1 = weaponItem.type.weapon_skill_range_a[1] or "throw" --不能为空。
      skill2 = weaponItem.type.weapon_skill_range_a[2] --最多两个。多了不算在内。
    end
  end
  
  local skill_level,exp=self:getSkillLevel(skill1)
  if skill2 then
    local l = self:getSkillLevel(skill2)
    skill_level = (skill_level+l)/2
  end
  local hitLevel = skill_level--基本
  --todo，算上装备和buff的
  return math.max(1,skill_level+2)
end

function Unit:getWeaponRandomHitEffect(weapon)
  if weapon.unarmed then 
    return self:get_unarmed_hit_effect() 
  else
    return weapon.item:getRandomHitEffect()
  end
end

--当前单位的格斗攻击效果。一般是拳，可能是爪，咬。
function Unit:get_unarmed_hit_effect()
  return "unarmed"
end

function Unit:getWeaponRandomDamage(weapon)
  if weapon.unarmed then 
    return self:randomUnarmedDamage()
  else
    return weapon.item:randomWeaponDamage(weapon.isMelee)
  end
end



function Unit:randomUnarmedDamage()
  local dice_num,dice_face,base_atk = self:getUnarmedAtkData()
  local roll = 0
  for i=1,dice_num do
    roll = roll+rnd()
  end
  roll = roll/dice_num
  return base_atk + roll*dice_face
end

function Unit:getUnarmedAtkData()
  local str = self:base_str()
  local skillLevel = self:getSkillLevel("martial_arts")
  local dice_num =2
  local dice_face = math.floor(3 +skillLevel*0.6*c.unarmed_cost*2.25*2)
  local base_atk = math.floor(2+skillLevel*0.3*c.unarmed_cost*2.25)
  return dice_num,dice_face,base_atk
end

--显示的数据。
function Unit:getWeaponDisplayData(weapon)
  local dice,face,base
  if weapon.unarmed then
    dice,face,base = self:getUnarmedAtkData()
    base = base +self:getWeaponBaseBonus(weapon)
  else
    local weaponItem = weapon.item
    if weapon.isMelee then
      dice = weaponItem.diceNum
      face = weaponItem.diceFace
      base = weaponItem.baseAtk +self:getWeaponBaseBonus(weapon)
    else
      dice = weaponItem.diceNum_range
      face = weaponItem.diceFace_range
      base = weaponItem.baseAtk_range +self:getWeaponBaseBonus(weapon)
    end
  end
  return dice,face,base
end



c.unarmed_cost = 0.5 --定义为常数
--攻击耗时，返回实际delay时间单位。
function Unit:melee_cost(weapon)
  local weaponItem = weapon.item
  local scost = c.unarmed_cost
  if weaponItem then scost = weaponItem:getMeleeCost() end
  local speed = self:getSpeed()
  return c.clamp(scost*70/speed,0.1,3)
end

--指定远程武器射击耗时。
function Unit:shoot_cost(weapon)
  local weaponItem = weapon.item
  local scost = weaponItem:getShotCost()
  local speed = 70
  if weaponItem.type.fixShotCost == false then
    speed = self:getSpeed()
  end
  return c.clamp(scost*70/speed,0.1,3)
end

function Unit:reload_cost(weapon)
  local weaponItem = weapon.item
  return weaponItem:getReloadCost()
end


function Unit:train_weapon_skill(weapon,fix,level)
  local skill1,skill2 --最多关联两个skill
  if weapon.unarmed then
    skill1 = "martial_arts"--格斗技能
  else
    local weaponItem = weapon.item
    if weapon.isMelee then
      skill1 = weaponItem.type.weapon_skill_a[1] or "martial_arts" --不能为空。
      skill2 = weaponItem.type.weapon_skill_a[2] --最多两个。多了不算在内。
    else
      skill1 = weaponItem.type.weapon_skill_range_a[1] or "throw" --不能为空。
      skill2 = weaponItem.type.weapon_skill_range_a[2] --最多两个。多了不算在内。
    end
  end
  if skill2 then
    exp=exp/2
    self:train_skill(skill2,rnd(10,20)*fix,level)
  end
  self:train_skill(skill1,rnd(10,20)*fix,level)
  self:train_attr(g.skills[skill1].main_attr,rnd(6,11)*fix,level)--训练次属性
end

function Unit:train_melee_attack(fix,level)
  self:train_attr("str",rnd(10,16)*fix,level)--获取经验的速度，与攻速无关。
end
function Unit:train_range_attack(fix,level)
  self:train_attr("per",rnd(10,16)*fix,level)--获取经验的速度，与攻速无关。
end