

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
  deal_dam = math.max(0,deal_dam) --最小为0，不能为负值。
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


--获取躲闪等级。是为
function Unit:getDodgeLevel()
  local dex = self:cur_dex()
  local per = self:cur_per()
  local val = dex*0.85+per*0.15
  local dodgeLevel = math.max(1, val/c.averageAttrGrow-5)--低于一定属性就为1.属性起码8以上，才能开始闪避。
  --还有其他装备buff附加的等级，todo
  return dodgeLevel
end


--根据命中等级和闪避等级，取得命中概率。
local function hitRate(hitLevel,dodgeLevel)
  --命中率最小20%，最大当然是100%.
  --命中等级1.5倍时100%
  --命中等级 = 闪避等级时，命中率90%
  --同等级单位最大的闪避：60%命中。也就是。闪避等级两倍于命中等级时候，60命中。
  --4倍约37%左右命中
  --最小值20%命中
  --单一公式：-(x-6)^2/8+5
  local x = hitLevel/(dodgeLevel*0.25)
  if x>=6 then return 1 end
  return math.max(0.2,(-(x-6)^2/8+5)*0.2)
  --[[
  --(x-1)^2/2+1,-(x-5)^2/2+5,-(x-6)^2/8+5  公式曲线
  if x<1 then
    return 0.2
  elseif x<3 then
    return ((x-1)^2/2+1)*0.2
  elseif x<4 then
    return (-(x-5)^2/2+5)*0.2
  elseif x<6 then
    return (-(x-6)^2/8+5)*0.2
  end
  return 1  
  ]]
end

--近战命中判定，返回0，miss。返回1，命中，返回。。。其他格挡等等。
function Unit:check_melee_hit(dam_ins,fdelay)
  local selfDodgeLevel = self:getDodgeLevel()
  local hit_probability = hitRate(dam_ins.hitLevel,selfDodgeLevel)
  local hit = 0
  if rnd()<hit_probability then
    self:deal_damage(self,dam_ins,fdelay)
    hit =1
  end
  debugmsg(string.format("meleeDam:%.1f, hitlevel:%.1f,dodgeLevel:%.1f,dex:%d, rate:%.2f",dam_ins.dam,dam_ins.hitLevel,selfDodgeLevel,self:cur_dex(),hit_probability))
  return hit
end


--检测远程命中。已经有子弹projectile飞来，检测能否躲过去。被命中就返回true，然后计算接受伤害。躲过就返回false子弹继续飞
function Unit:check_range_hit(projectile)
  local hitrate = 0.35--被乱弹打中的机率
  if projectile.dest_unit ==self then
    hitrate = hitrate+1 --必定命中
  end
  if projectile.dest_unit==nil then
    hitrate = hitrate+0.2 --被无目标射击打中的概率。
    if  self.x == projectile.dest_x and self.y== projectile.dest_y then
      hitrate = hitrate+0.25 --被无目标射击打中的概率。
    end
  end
  --散弹和强力穿弹都会提升乱弹概率。
  if projectile.pierce_through then
    hitrate = hitrate+0.4
  end
  if projectile.multi_shot then
    hitrate = hitrate+0.5
  end
  
  if rnd()>hitrate then return false end
  
  local dam_ins = projectile.dam_ins
  
  local selfDodgeLevel = self:getDodgeLevel()
  local hit_probability = hitRate(dam_ins.hitLevel,selfDodgeLevel)
  local hit = rnd()<hit_probability--经过数值运算的结果。
  if hit then
    self:deal_damage(self,dam_ins,0)
  end
  debugmsg(string.format("hitlevel:%.1f,dodgeLevel:%.1f,dex:%d, rate:%.2f",dam_ins.hitLevel,selfDodgeLevel,self:cur_dex(),hit_probability))
  
  return hit 
end