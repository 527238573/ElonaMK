Target = {
}
saveMetaType("Target",Target)--注册保存类型
--target可能被重复引用，所以注册成类型
function Target:new(unit,x,y)
  assert(unit~=nil or x~=nil)
  return setmetatable({unit=unit,x=x,y=y},Target)
end
--获得目标的等级，用于训练，
function Target:getTargetLv()
  if self.unit then 
    return self.unit.level
  end
  return 0
end


--检查target是否合法，不合法就清楚target返回false，合法返回true。  只允许可见目标。
function Unit:checkTarget()
  if self.target==nil then return false end
  if self.target.unit then
    local tu = self.target.unit
    if self:seesUnit(tu) then
      return true
    end
  elseif self.target.x then
    if self:seesXY(self.target.x,self.target.y) then
      return true
    end
  end
  self.target = nil
  return false
end
--寻找最近的敌人。只能寻找视野内的。如果指定范围则以更小的范围搜索
function Unit:findNearestEnemy(findrange)
  local maxrange = self:get_seen_range()
  if findrange then
    maxrange = math.min(maxrange,findrange)
  end

  local closestUnit,range = nil,maxrange+0.001--范围内目标
  local map = self.map
  if map.activeUnit_num<=100 then --数量不多，搜索单位表。
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

--特定取得目标：
--取得最近的敌人，或手选地格。不能取得单位所在地格。
--showmsg 是否显示信息。aitarget，通过ai条件触发的target（优先考虑）。clearTarget：如果单位手选目标(unit.target)不合法，是否清除。
function Unit:findSeeRangeEnemyOrSquare(showmsg,aiTarget,clearTarget)
  --第一优先级，ai触发的
  if aiTarget then --aiTarget默认为视野内可见的
    if aiTarget.unit then
      if self:isHostile(aiTarget.unit) then
        return aiTarget
      end
    elseif aiTarget.x  then --射击地面
      if not(self.x==aiTarget.x and self.y == aiTarget.y) then
        return aiTarget --射击地面
      end
    end
  end
  --第二优先级，所手选的目标。
  if self:checkTarget() then 
    if self.target.unit then -- 单位目标
      if self:isHostile(self.target.unit) then--符合射击条件
        return self.target
      end
    elseif self.target.x and not (self.x==self.target.x and self.y == self.target.y) then --地面目标,不能以自身位置为目标
      return self.target
    end
    --未能成功选择手动目标
    if clearTarget then
      self.target = nil
    end
  end
  --第三优先级，搜索附近,视野内
  local near_enemy  = self:findNearestEnemy()
  if near_enemy then
    return Target:new(near_enemy)
  end
  --找不到目标：
  if showmsg then addmsg(tl("找不到目标!","You cant find a target.")) end
  return nil
end

--根据条件获取目标或地格conditionCheck(targetunit,x,y)    只允许可见的目标。 敌友检查等在conditionCheck里面进行。
--square型 只能由aiTarget 和self.target获取
--maxrange可选参数，默认视野最大值
function Unit:findConditionRangeUnitOrSquare(showmsg,aiTarget,clearTarget,conditionCheck,maxrange)
  --第一优先级，ai触发的
  if aiTarget then --aiTarget默认为视野内可见的,不检查。
    if conditionCheck(aiTarget.unit,aiTarget.x,aiTarget.y) then
      return aiTarget
    end
  end
  --第二优先级，所手选的目标。
  if self:checkTarget() then 
    
    if conditionCheck(self.target.unit,self.target.x,self.target.y) then
      return self.target
    end
    --未能成功选择手动目标
    if clearTarget then self.target = nil end
  end
  --第三优先级，搜索附近,视野内，由近到远。不会选择自己
  maxrange = maxrange or self:get_seen_range()
  local map = self.map
  --单位数量很多，按地格搜索
  local radius = math.floor(maxrange)
  for nx,ny in c.closest_xypoint_rnd(self.x,self.y,radius) do
    --搜索每个地格,按方形顺序。大体上是由近到远，但不是严格按圆形远近
    local unit =map:unit_at(nx,ny)
    if unit and unit ~= self then
      local currange= c.dist_2d(self.x,self.y,unit.x,unit.y)
      if currange<=maxrange and self:seesUnit(unit) then 
        if conditionCheck(unit,nx,ny) then
          return Target:new(unit)
        end
      end
    end
  end
  --找不到目标： 一般根据情况提示条件，并不在这里提示
  if showmsg then addmsg(tl("找不到目标!","You cant find a target.")) end
  return nil
end




--获得近战1格内目标
function Unit:findCloseRangeEnemy(showmsg,aiTarget,clearTarget)
  --第一优先级，ai触发的
  if aiTarget then --aiTarget默认为视野内可见的
    local tunit = aiTarget.unit
    if tunit then
      if self:isHostile(tunit) and  c.dist_2d(tunit.x,tunit.y,self.x,self.y)<1.7 then--在近身范围内
        return aiTarget
      end
    end
  end
  --第二优先级，所手选的目标。
  if self:checkTarget() then 
    local tunit = self.target.unit
    if tunit then -- 单位目标
      if self:isHostile(tunit) and  c.dist_2d(tunit.x,tunit.y,self.x,self.y)<1.7 then--在近身范围内
        return self.target
      end
    end
    --未能成功选择手动目标
    if clearTarget then
      self.target = nil
    end
  end
  --第三优先级，搜索附近, 按优先级搜索
  local map = self.map
  local sx,sy = self:getFace_dxdy()
  local cdis = 10
  local c_unit
  for dx = -1,1 do
    for dy = -1,1 do
      local dis = math.abs(dx -sx) +math.abs(dy-sy)
      local unit =map:unit_at(self.x+dx,self.y+dy)
      if unit and self:isHostile(unit) and self:seesUnit(unit) then
        if dis<cdis then --更近的单位才够好
          cdis = dis
          c_unit = unit
        end
      end
    end
  end
  if c_unit then
    return Target:new(c_unit)
  end
  --找不到目标：
  if showmsg then addmsg(tl("找不到目标!","You cant find a target.")) end
  return nil
end