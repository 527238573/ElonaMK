
--获得目标的等级，用于训练，
function c.getTargetLv(target)
  if target and target.unit then 
    return target.unit.level
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
    return {unit = near_enemy}
  end
  --找不到目标：
  if showmsg then addmsg(tl("找不到目标!","You cant find a target.")) end
  return nil
end