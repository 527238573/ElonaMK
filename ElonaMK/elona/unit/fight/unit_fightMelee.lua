
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
  --debugmsg("melee costtime:"..attack_cost_time)
  --
  local hit_effect = self:getWeaponRandomHitEffect(meleeList[1]) --取第一个武器的效果做message描述
  self:melee_attack_message(target,hit_effect)

  local tlevel = target:getDodgeLevel()
  local single_exp = attack_cost_time/#meleeList --受训时间。武器经验修正。 获取经验的速度，与攻速无关。
  
  for i=1,#meleeList do
    local oneWeapon = meleeList[i]
    self:melee_weapon_attack(target,oneWeapon,fhit+(i-1)*atk_intv)--2武器间隔0.2，4武器间隔0.1
    
    self:train_weapon_skill(oneWeapon,single_exp,tlevel)
  end
  
  --获得技能的训练。
  self:train_melee_attack(attack_cost_time,target.level)
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
  local hit = target:check_melee_hit(self,dam_ins,fdelay)
  if hit ==0 then
    --未命中
    target:melee_miss_animation(self,fdelay,hit_effect)
    self:melee_miss_message(target) --播放信息
  else
    target:melee_hit_animation(self,fdelay,hit_effect)
  end
  
  
end



local melee_msg = {
  unarmed = {tl("%s拳击%s。","%s punched %s."),tl("%s对%s使出拳击。","%s hits %s with a punch.")},
  light_bash = {tl("%s敲打%s。","%s whacks %s."),tl("%s击向%s。","%s hits %s.")},
  bash = {tl("%s猛击%s。","%s smashes %s."),tl("%s重击%s。","%s batters %s.")},
  cut = {tl("%s斩劈%s。","%s slashes %s."),tl("%s砍向%s。","%s chops %s.")},
  stab = {tl("%s刺击%s。","%s stabs %s."),tl("%s凿击%s。","%s nicks %s.")},
  spear = {tl("%s穿刺%s。","%s impales %s."),tl("%s捅刺%s。","%s punctures %s.")},
  bite = {tl("%s狠咬%s。","%s bites %s."),tl("%s撕咬%s。","%s gnaws %s.")},
  claw = {tl("%s爪击%s。","%s claws %s."),tl("%s撕剜%s。","%s gouges %s.")},
  default = {tl("%s袭向%s。","%s strikes %s."),tl("%s攻击%s。","%s hits %s.")},
}


function Unit:melee_attack_message(target,hit_effect)
  if not(self:isInPlayerTeam() or target:isInPlayerTeam() ) then return end --无关信息不显示
  
  local selfname = self:getShortName()
  local targetname = target:getShortName()
  local rndindex = rnd(1,2)--(love.timer.getTime()%6>3 ) and 1 or 2
  local effect_t = melee_msg[hit_effect]
  if effect_t ==nil then effect_t = melee_msg["default"] end
  addmsg(string.format(effect_t[rndindex],selfname,targetname),"info")
end

function Unit:melee_miss_message(target)
  if self:isInPlayerTeam() then
    addmsg("(miss)","hit")
  elseif target:isInPlayerTeam() then
    addmsg("(miss)","enemy_hit")
  end
end
