
function Unit:melee_attack(target)
  --出现不能近战攻击的情况，debuff之类。
  if target ==self then return end

  local attack_cost_time = 0.1--最小时间
  local meleeList= self.weapon_list.melee
  local atk_intv = math.max(0.1,0.3 -#meleeList*0.05)
  for i=1,#meleeList do
    local melee_costTime = self:melee_cost(meleeList[i])+(i-1)*atk_intv
    attack_cost_time = math.max(attack_cost_time,melee_costTime)
  end
  local fhit=self:attack_animation(target,attack_cost_time)
  debugmsg("melee costtime:"..attack_cost_time)
  
  for i=1,#meleeList do
    local oneWeapon = meleeList[i]
    self:melee_weapon_attack(target,oneWeapon,fhit+(i-1)*atk_intv)--2武器间隔0.2，4武器间隔0.1
  end
  
end


--单个武器的攻击。一次近战攻击中可能多段不同武器攻击（双持）
function Unit:melee_weapon_attack(target,weapon,fdelay)
  --确定 hir_effect
  local weaponItem = weapon.item
  local hit_effect = self:getWeaponRandomHitEffect(weapon)
  local weaponRollDam = self:getWeaponRandomDamage(weapon)
  --创建damage实体。
  local dam_ins = setmetatable({},Damage)
  dam_ins.hitLevel = self:getHitLevel(weapon)
  
  --计算伤害
  dam_ins.dam =(weaponRollDam+self:getWeaponBaseBonus(weapon))*self:getWeaponModifier(weapon)
  --todo
  --伤害子类型。
  if hit_effect == "bash" or hit_effect == "light_bash" then
    dam_ins.subtype = "bash" --钝击
  elseif hit_effect =="cut" then
    dam_ins.subtype = "cut" --劈砍
  elseif hit_effect =="stab" or hit_effect == "spear" then
    dam_ins.subtype = "stab" --穿刺
  end
  --命中判定
  local hit = target:check_melee_hit(dam_ins,fdelay)
  if hit ==0 then
    --未命中
    target:melee_miss_animation(self,fdelay,hit_effect)
  else
    target:melee_hit_animation(self,fdelay,hit_effect)
  end
end

