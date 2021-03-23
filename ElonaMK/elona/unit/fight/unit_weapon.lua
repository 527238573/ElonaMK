

local function getAtkLevel(unit,weapon)
  local weaponItem = weapon.item
  local atkLevel = 0
  if weapon.unarmed then
    atkLevel = unit:getSkillLevel("martial_arts")
  else
    atkLevel = weaponItem:getAttackLevel()
  end
  --将装备与人物等级约近。
  atkLevel = unit:getBaseRoundLevel(atkLevel)
  --添加装备 buff效果
  --允许使用 外来攻击加成   枪械等自动连发武器不允许。
  if weapon.unarmed or (weaponItem and weaponItem:UseAttakLevelBonus()) then
    atkLevel = atkLevel+unit:getBonus("atk_lv")
  end
  return atkLevel
end

local function getWeaponSkillLevel(unit,weapon)
  --最多关联两个skill
  local skill1,skill2 ="martial_arts",nil
  local weaponItem = weapon.item--可能为空。
  if weaponItem then
    skill1,skill2 = weaponItem:getWeaponSkill(weapon.isMelee)
  end
  
  local skill_level=unit:getSkillLevel(skill1)
  if skill2 then
    local l = unit:getSkillLevel(skill2)
    skill_level = (skill_level+l)/2
  end
  return skill_level
end

local function getCritLevel(unit,weapon)
  local weaponItem = weapon.item
  local critLevel = getWeaponSkillLevel(unit,weapon)
  if weaponItem then
    critLevel = critLevel +weaponItem:getCritBonus()
  end
  critLevel = critLevel+ unit:getBonus("crit_lv")
  
  local ulevel = unit.level
  local dex = unit:cur_dex()
  local ler = unit:cur_ler()
  local attrlv = (dex*0.5+ler*0.5)/c.averageAttrGrow --计算出属性的平均等级
  local val = (attrlv-ulevel)/(ulevel+3) -- -1到2以上  常见-0.5 到1  
  
  critLevel = critLevel + val*10 -- (属性一般 -5到+10， 最大-10到+20以上)val*10的时候
  
  return critLevel
end

local function getHitLevel(unit,weapon)
--获取命中等级。传输的是装备的武器条目。
  --根据武器等级来决定命中等级。
  local hitLevel = getWeaponSkillLevel(unit,weapon)--基本
  --算上装备本身的加成。
  if weapon.item then
    hitLevel = hitLevel +weapon.item:getHitBonus()
  end
  --算上装备和buff的
  hitLevel = hitLevel+ unit:getBonus("hit_lv")
  --可能有其他
  return hitLevel
end

--武器攻击倍乘系数。
local function getWeaponModifier(unit,weapon)
  local m_attr = 0
  if weapon.unarmed then
    m_attr = unit:cur_str()
  else
    
    local weaponskill = weapon.item:getWeaponSkill(weapon.isMelee)--只获取第一个skillid
    local attr1 = weapon.isMelee and unit:cur_str() or unit:cur_per()
    
    local attr2 = unit:cur_main_attr(g.skills[weaponskill].main_attr)
    m_attr = attr1*0.6 +attr2*0.4 
  end
  if m_attr<20 then
    return 0.53+m_attr*(m_attr+1)/2*0.007
  else
    return m_attr*0.1
  end
end
--获得三项
local function getWeaponDFB(unit,weapon)
  if weapon.item then
    if weapon.isMelee then
      return weapon.item:getMeleeDFB()
    else
      return weapon.item:getRangeDFB()
    end
  end
  --空手格斗
  return 2,6,3
end

--取得一个实用的damageins
function Unit:getWeaponDamageInstance(weapon)
  local dam_ins = setmetatable({},Damage)
  dam_ins.hit_lv = getHitLevel(self,weapon)
  dam_ins.atk_lv = getAtkLevel(self,weapon)
  dam_ins.crit_lv = getCritLevel(self,weapon)
     --计算伤害
  local mod = getWeaponModifier(self,weapon)
  local dice,face,base = getWeaponDFB(self,weapon)
  local roll = 0
  if dice>0 then
    for i=1,dice do
      roll = roll+rnd()
    end
    roll = roll/dice
  end
  dam_ins.dam = (base + roll*face) *mod
  return dam_ins
end

--用于UI显示 返回两个str， name dmgstr
function Unit:getWeaponDamStr(weapon)
  local oneWeapon = weapon
  if weapon.isMelee then
    local dice,face,base = getWeaponDFB(self,oneWeapon)
    local modifier = getWeaponModifier(self,weapon)
    local name = oneWeapon.unarmed and tl("格斗","Unarmed") or oneWeapon.item:getShortName()
    local cost = self:melee_cost(oneWeapon)
    local dps = (face/2 +base)*modifier /cost
    local hitLevel = getHitLevel(self,oneWeapon)-self.level
    local dmgstr
    if base ==0 then 
      dmgstr = string.format("%dr%d x%.1f (%.1f,%d)",dice,face,modifier,dps,hitLevel)
    elseif base>0 then
      dmgstr = string.format("%dr%d+%d x%.1f (%.1f,%d)",dice,face,base,modifier,dps,hitLevel)
    elseif base<0 then
      dmgstr = string.format("%dr%d%d x%.1f (%.1f,%d)",dice,face,base,modifier,dps,hitLevel)
    end
    return name,dmgstr
  else
    local weaponItem = oneWeapon.item
    local dice,face,base = getWeaponDFB(self,oneWeapon)
    local modifier = getWeaponModifier(self,weapon)
    local pellet = weaponItem:getPellet()
    local cost = self:shoot_cost(oneWeapon)
    local dps = (face/2 +base)*modifier /cost *pellet
    local hitLevel = getHitLevel(self,oneWeapon)-self.level
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
      dmgstr = string.format("%dx(%s) x%.1f (%.1f,%d)",pellet,dmgstr,modifier,dps,hitLevel)
    else
      dmgstr = string.format("%s x%.1f (%.1f,%d)",dmgstr,modifier,dps,hitLevel)
    end
    return name,dmgstr
  end
end





function Unit:getWeaponRandomHitEffect(weapon)
  if weapon.item then
    return weapon.item:getRandomHitEffect()
  end
  --空手格斗
  --当前单位的空手格斗攻击效果。一般是拳，可能是爪，咬。
  return "unarmed"
end

--获得非主手武器攻击几率
function Unit:getWeaponAttakRate(weapon)
  return weapon.item.type.attackRate or 1
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
  
  local skill1,skill2 ="martial_arts",nil
  local weaponItem = weapon.item--可能为空。
  if weaponItem then skill1,skill2 = weaponItem:getWeaponSkill(weapon.isMelee) end
  
  if skill2 then
    fix=fix/2
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