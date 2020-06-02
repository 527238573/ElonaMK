
function Unit:can_shoot(show_msg)
  local rangeList= self.weapon_list.range
  if #rangeList<1 then 
    if show_msg then addmsg(tl("你没有可以射击的武器。","You need a weapon to shoot."),"info") end
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


function Unit:fastShootAction(show_msg)
  if not self:can_shoot(show_msg) then return end
  --出现不能攻击的情况，debuff之类。可能delay
  local target
  if self:checkTarget() then --优先检定玩家指定的目标
    if self.target.unit then -- 单位目标
      if self:isHostile(self.target.unit) then--符合射击条件
        target= self.target.unit --合法目标
      else
        self.target = nil --清除目标
      end
    elseif self.target.x and not (self.x==self.target.x and self.y == self.target.y) then --地面目标,不能以自身位置为目标
      target = {not_unit= true,x= self.target.x,y = self.target.y}-- 地面目标，
    else
      self.target = nil --清除目标
    end
  end
  --自动寻找目标
  if target ==nil then
    target = self:findNearestEnemy()
  end
  if target ==nil then
    if show_msg then addmsg(tl("你找不到可以射击的目标！","You cant find a target to shoot."),"info") end
    return
  end
  self:face_position(target.x,target.y)
  
  local costTime = 0.15--最小时间， 没子弹扣扳机也会消耗这么时间
  local showbar = false --消耗时间时是否显示动作条。狙击枪等开枪后会显示，因为delay较长。
  --出现不能近战攻击的情况，debuff之类。
  local rangeList= self.weapon_list.range
  local atk_intv = math.max(0.1,0.3 -#rangeList*0.05)
  local shoot_index =1--第几个射击的武器。
  
  for i=1,#rangeList do
    local oneWeapon = rangeList[i]
    if hasAmmoToShoot(oneWeapon) then --有弹药
      if shoot_index==1 then
        self:range_weapon_attack(target,oneWeapon) --第一个武器直接发射，
      else
        self:insertAnimDelayFunc((shoot_index-1)*atk_intv,self.range_weapon_attack,self,target,oneWeapon)--2武器间隔0.2，4武器间隔0.1
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
    end
  end
  if shoot_index<=1 then --没能射击
    addmsg(tl("需要装填弹药!","You need to reload to shoot!"),"info")
    g.playSound("shoot_fail",self.x,self.y) 
  end
  if showbar then
    self:short_delay(costTime,"shoot")
    self:bar_delay(costTime-0.2,"","shoot")
  else
    self:short_delay(costTime,"shoot")
  end
end


function Unit:range_weapon_attack(target,weapon)
  local weaponItem = weapon.item
  local snum = weaponItem:getPellet()
  for i =1,snum do --绝大部分枪一次只发一发，散弹一次多发
    local proj = Projectile.new(weaponItem:getBulletFrames())
    proj.shot_dispersion = weaponItem:getDispersion()
    proj.max_range = weaponItem:getMaxRange()
    proj.hitLevel = self:getHitLevel(weapon)--命中等级
    if weaponItem:hasFlag("SNIPER") then
      proj.pierce_through = true
      proj.pierce =3
      proj.speed = 1500
    end
    if snum>1 then proj.multi_shot = true end
    
    if target.not_unit  then
      proj:attack(p.mc,nil,nil,nil,target.x,target.y) --射击地面 
    else
      proj:attack(p.mc,nil,nil,target,target.x,target.y) 
    end
  end
  
  
  weaponItem.ammoNum = math.max(0,weaponItem.ammoNum-1)
  local fire_sound = weaponItem:getShootSound()
  if fire_sound then
    g.playSound(fire_sound,self.x,self.y) 
  end
end






--暂时放在这里。这个属于AI，有很多用途。
--寻找最近的敌人。只能寻找视野内的。如果指定范围则以更小的范围搜索
function Unit:findNearestEnemy(findrange)
  local maxrange = self:get_seen_range()
  if findrange then
    maxrange = math.min(maxrange,findrange)
  end
  
  local closestUnit,range = nil,maxrange+0.001--范围内目标
  local map = self.map
  if map.activeUnit_num<=170 then --数量不多，搜索单位表。
    local unitList = self.map.activeUnits
    for unit,_ in pairs(unitList) do
      if self:isHostile(unit) then
        local currange= c.dist_2d(self.x,self.y,unit.x,unit.y)
        if currange<range and self:seesUnit(unit) then --see最复杂，所以作为最后的条件
          closestUnit = unit
          range= currange
        end
      end
    end
  else
    --单位数量很多，按地格搜索
    local radius = math.floor(maxrange)
    local absdxdy = 0
    for nx,ny in c.closest_xypoint_rnd(self.x,self.y,radius) do
      if closestUnit then
        local cur_absdxdy = math.max(math.abs(nx-self.x),math.abs(ny-self.y))
        if cur_absdxdy>absdxdy then break end --超出距离。
      end
      --搜索每个地格
      local unit =map:unit_at(nx,ny)
      if unit and self:isHostile(unit) then
        local currange= c.dist_2d(self.x,self.y,unit.x,unit.y)
        if currange<range and self:seesUnit(unit) then --see最复杂，所以作为最后的条件
          closestUnit = unit
          range= currange
          absdxdy = math.max(math.abs(nx-self.x),math.abs(ny-self.y)) --当前行圈。继续在当前行圈内寻找更近的。
        end
      end
    end
  end
  
  return closestUnit --可能为空
end