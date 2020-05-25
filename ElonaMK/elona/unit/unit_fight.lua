

function Unit:deal_damage(source,dam_ins,delay)
  delay = delay or 0 
  local deal_dam = math.max(0,dam_ins.dam)
  local resist = 0
  if dam_ins.dtype ==1 then --物理伤害
    resist = self:getAR()
  elseif dam_ins.dtype ==2 then --魔法伤害
    resist = self:getMR()
  end
  resist = math.max(0,resist*(1-dam_ins.resist_mul)-dam_ins.resist_pen) --护甲穿透计算
  if resist<=0.5*deal_dam then
    deal_dam = deal_dam -resist --加减法
  else
    resist = resist - 0.5*deal_dam
    deal_dam = 0.5*deal_dam--
    deal_dam = deal_dam*deal_dam/(deal_dam+resist)
  end
  if dam_ins.subtype then --子类攻击类型。
    local subresist = self:getResistance(dam_ins.subtype)
    if subresist>=0 then
      deal_dam = deal_dam*(2/(2+subresist))
    else
      deal_dam = deal_dam*((2-subresist)/2)
    end
  end
  dam_ins.deal_dam = deal_dam --回传一个数值，实际攻击
  --apply damage
  if deal_dam<=0 then return end
  if delay<=0 then 
    self:take_damage(source,deal_dam)
  else
    table.insert(self.damage_queue,{source = source,dam=deal_dam,delay = delay})--延迟伤害
  end
  --on_hurt
end



function Unit:update_damage(dt)
  local i=1
  while i<=#self.damage_queue do
    local dam_t = self.damage_queue[i]
    dam_t.delay = dam_t.delay  - dt
    if dam_t.delay<=0 then
      self:take_damage(dam_t.source,dam_t.dam)
      table.remove(self.damage_queue,i)
    else
      i= i+1
    end
  end
end

function Unit:take_damage(source,dam)
  debugmsg("takedam:"..dam)
  if self:is_dead() then return end
  self.hp = self.hp-dam
  if self.hp<=0 then 
    self:die(source)
  end
end

--检测远程命中。已经有子弹projectile飞来，检测能否躲过去。被命中就返回true，然后计算接受伤害。躲过就返回false子弹继续飞
function Unit:check_range_hit(projectile)
  local istarget = projectile.dest_unit ==self --是否是目标单位。如果不是，就属于意外中弹，被命中率较低。
  if istarget then
    return rnd()<0.9 --9成中弹
  else
    return rnd()<0.3 --3成中弹
  end
end