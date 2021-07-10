
function Unit:can_shoot(show_msg)
  local rangeList= self.weapon_list.range
  if #rangeList<1 then 
    if show_msg then addmsg(tl("你没有远程武器。","You need a weapon to shoot."),"info") end
    return false 
  end
  local canshoot = true
  return canshoot
end

function Unit:canReload(show_msg)
  local rangeList= self.weapon_list.range
  if #rangeList<1 then 
    if show_msg then addmsg(tl("你没有远程武器。","You don't have a ranged weapon to reload."),"info") end
    return false 
  end
  for i=1,#rangeList do
    local oneWeaponItem = rangeList[i].item
    if oneWeaponItem.useReload then
      if oneWeaponItem.ammoNum<oneWeaponItem:getMaxAmmo() then
        return true
      end
    end
  end
  if show_msg then addmsg(tl("你无需装填弹药。","You don't need to reload."),"info") end
  return false
end


local function hasAmmoToShoot(oneWeapon)
  local oneWitem = oneWeapon.item
  if oneWitem.useReload  then
    if oneWeapon.item.ammoNum<1 then
      return false
    end
  end
  return true
end

--需要装填
function Unit:needReload()
  local rangeList= self.weapon_list.range
  if #rangeList<1 then return false end --没有远程武器
  for i=1,#rangeList do
    if hasAmmoToShoot(rangeList[i]) then return false end
  end
  return true
end


function Unit:reloadAction(show_msg)
  if not self:canReload(show_msg) then return end
  
  local rangeList= self.weapon_list.range
  local costTime = 0.2--最小时间 
  local intv = 0.1
  local reload_index =1--第几个射击的武器。
  
  for i=1,#rangeList do
    local oneWeapon = rangeList[i]
    local oitem = oneWeapon.item
    if oitem.useReload and oitem.ammoNum<oitem:getMaxAmmo() then --有弹药
      oitem.ammoNum = oitem:getMaxAmmo()
      local curCosttime = self:reload_cost(oneWeapon)
      costTime = math.max(costTime,curCosttime+(reload_index-1)*intv)
      local reload_sound = oitem:getReloadSound()
      if reload_sound then
        g.playSound_delay(reload_sound,self.x,self.y,(reload_index-1)*intv)
      end
      reload_index = reload_index+1
    end
  end
  self:bar_delay(costTime,"reload","reload")
end




function Unit:fastShootAction(show_msg)
  if not self:can_shoot(show_msg) then return end
  --出现不能攻击的情况，debuff之类。可能delay
  
  --使用通用寻找目标的函数选择目标。注意当枪械有效距离短时，这个函数可能会选择超过有效距离的单位。
  local target_t = self:findSeeRangeEnemyOrSquare(false,nil,true)
  if target_t==nil and show_msg then 
    addmsg(tl("你找不到可以射击的目标！","You cant find a target to shoot."),"info") 
    return 
  end
  self:face_target(target_t)
  
  local costTime = 0.15--最小时间， 没子弹扣扳机也会消耗这么时间
  local showbar = false --消耗时间时是否显示动作条。狙击枪等开枪后会显示，因为delay较长。
  --出现不能近战攻击的情况，debuff之类。
  local rangeList= self.weapon_list.range
  local atk_intv = math.max(0.1,0.3 -#rangeList*0.05)
  local shoot_index =1--第几个射击的武器。
  
  local tlevel =0
  if target_t.unit then
    tlevel = target_t.unit:getDodgeLevel()
  end
  local exp_fix = 1/#rangeList --武器经验。 获取经验的速度，与攻速无关。
  
  for i=1,#rangeList do
    local oneWeapon = rangeList[i]
    if hasAmmoToShoot(oneWeapon) then --有弹药
      if shoot_index==1 then
        self:range_weapon_attack(target_t,oneWeapon) --第一个武器直接发射，
      else
        self:insertAnimDelayFunc((shoot_index-1)*atk_intv,self.range_weapon_attack,self,target_t,oneWeapon)--2武器间隔0.2，4武器间隔0.1
      end
      local curCosttime = (shoot_index-1)*atk_intv +self:shoot_cost(oneWeapon)
      costTime = math.max(costTime,curCosttime)
      if oneWeapon.item:getMaxAmmo() ==1 then
        showbar = true--当打一枪上一堂需要showbar
        local reload_sound = oneWeapon.item:getReloadSound()--播放装弹
        if reload_sound then
          g.playSound_delay(reload_sound,self.x,self.y,(shoot_index)*atk_intv)
        end
      end
      shoot_index = shoot_index +1
      self:train_weapon_skill(oneWeapon,exp_fix*curCosttime,tlevel)--获取经验的速度，与攻速无关。
    end
  end
  if shoot_index<=1 then --没能射击
    addmsg(tl("需要装填弹药!","You need to reload to shoot!"),"info")
    g.playSound("shoot_fail",self.x,self.y) 
  else
    if target_t.unit then self:train_range_attack(costTime,target_t.unit.level) end
  end
  if showbar then
    self:short_delay(costTime,"shoot")
    self:bar_delay(costTime-0.2,"","shoot")
  else
    self:short_delay(costTime,"shoot")
  end
end

--改为延迟调用
function Unit:range_weapon_attack(target,weapon)
  local weaponItem = weapon.item
  local snum = weaponItem:getPellet()
  for i =1,snum do --绝大部分枪一次只发一发，散弹一次多发
    local proj = Projectile.new(weaponItem:getBulletFrames())
    proj.shot_dispersion = weaponItem:getDispersion()
    proj.max_range = weaponItem:getMaxRange()
    
    if weaponItem:hasFlag("SNIPER") then
      proj.pierce_through = true
      proj.pierce =3
      proj.speed = 1500
      proj.impact =8
    end
    if snum>1 then proj.multi_shot = true end
    proj.dam_ins = self:getWeaponDamageInstance(weapon)
    proj.dam_ins.subtype =  weaponItem:getRangeWeaponDmgType()
    
    proj:attack(self,nil,nil,target,self.map) 
    if weaponItem:hasFlag("SNIPER") then
      self:recoilImpact(proj.rotation,8)
    end
  end
  
  
  weaponItem.ammoNum = math.max(0,weaponItem.ammoNum-1)
  local fire_sound = weaponItem:getShootSound()
  if fire_sound then
    g.playSound(fire_sound,self.x,self.y) 
  end
end
--虽然是成员函数，仍然要保存到延迟调用CB里
CB.range_weapon_attack = Unit.range_weapon_attack




