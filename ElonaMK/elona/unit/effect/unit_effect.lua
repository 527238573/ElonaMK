

function Unit:hasEffect(effect_id)
  local list = self.effects
  for _,o_eff in ipairs(list) do
    if o_eff.id == effect_id then
      return o_eff
    end
  end
  return nil
end


function Unit:addEffect(effect)
  --检查是否有重复id的effect
  local list = self.effects
  local mereged = false
  for _,o_eff in ipairs(list) do
    if o_eff.id == effect.id then
      o_eff:merege(effect)
      mereged = true
      break
    end
  end
  if not mereged then
    table.insert(list,effect)
    effect:onAddEffect(self)
  end
  
  self:reloadRealTimeBouns()
end



function Unit:updateEffectsRL(dt)
  local changed = false
  local list = self.effects
  local i=1
  while i<=#list do
    local effect = list[i]
    changed = changed or effect:updateRL(dt,self)
    if effect.remain<=0 then
      table.remove(list,i)
      --debugmsg("end frame:"..frame.id)
      changed = true
      effect:onLifeEnd(self)
    else
      i = i+1
    end
  end
  if changed then
    self:reloadRealTimeBouns()--只要有可能变动，就重算加成。
  end
end


function Unit:updateEffectsAnim(dt)
  local changed = false
  local list = self.effects
  local i=1
  while i<=#list do
    local effect = list[i]
    effect:updateAnim(dt,self)
    if effect.remain<=0 then
      table.remove(list,i)
      --debugmsg("end frame:"..frame.id)
      changed = true
      effect:onLifeEnd(self)
    else
      i = i+1
    end
  end
  if changed then
    self:reloadRealTimeBouns()--只要有可能变动，就重算加成。
  end
end

--根据id移除
function Unit:removeEffect(effect_id)
  local list = self.effects
  for i=1,#list do
    if list[i].id == effect_id then
      list[i]:onRemove(self)
      table.remove(list,i)
      break
    end
  end
end

function Unit:clearEffectWhenLeaveMap()
  local list = self.effects
  for i=#list,1,-1 do
    if list[i].type.leaveClear then
      list[i]:onRemove(self)
      table.remove(list,i)
    end
  end
end