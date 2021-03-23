

function Unit:deal_damage(source,dam_ins,delay)
  delay = delay or 0 
  local deal_dam = math.max(0,dam_ins.dam)
  local resist = 0
  if dam_ins.dtype ==1 then --物理伤害
    resist = self:getDEF()
  elseif dam_ins.dtype ==2 then --魔法伤害
    resist = self:getMGR()
  end
  --计算伤害加减成
  local dam_Lv_mod =1 --等级影响的倍乘
  local cha = dam_ins.atk_lv - resist
  if cha>=0 then
    dam_Lv_mod = (20+cha)/20 --相差20级伤害翻倍
  else
    dam_Lv_mod = 20/(20-cha) --相差-20级 伤害减半 
  end
  deal_dam = deal_dam *dam_Lv_mod

  --检定是否暴击
  --暴击几率最小5%，最大50%
  --计算等级差cha
  --CHA<=-40, 6%以下
  --cha == 0   10%
  local critRate = 0.05 --
  local critMul = 2
  do
    local uncritLv = self:getDodgeLevel()
    local crit_cha = dam_ins.crit_lv  -uncritLv
    if crit_cha<0 then
      critRate = 0.05 +0.5/(10-crit_cha)
    else
      critRate = math.min(0.1 + crit_cha*0.01,0.50)
      critMul = math.min(2+0.01*crit_cha,3)
    end
  end
  --检定是否格挡

  local blockRate = 0.2  --  
  local blockMul = 0.8  --最小20%免伤
  do
    local blockLv = self:getBlockLevel()
    local block_cha = dam_ins.hit_lv  -blockLv
    if block_cha<0 then
      blockRate = 0.02 +1.8/(10-block_cha)
    else
      blockRate = math.min(0.2 + blockRate*0.01,0.5)
      local x =math.min(0.11+0.01*block_cha,0.99)
      blockMul = 1-2*x/(1+x)
    end
  end

  local roll_crit_block = rnd()

  local deal_crit = roll_crit_block<critRate
  if deal_crit then 
    deal_dam = deal_dam*critMul --暴击后伤害翻倍
  end
  local block_hit = (1-roll_crit_block)<blockRate
  if block_hit then 
    deal_dam = deal_dam*blockMul --暴击后伤害翻倍
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

  debugmsg(string.format("takeDam:%.2f,atklv:%.1f, resist:%.1f,dam_Lv_mod:%.2f,critrate%.2f,critLv%d,blockrate%.2f",
      deal_dam,dam_ins.atk_lv,resist,dam_Lv_mod,critRate,dam_ins.crit_lv,blockRate))

  --apply damage
  if deal_dam<=0 then 
    local train_base = 10
    self:train_attr("con",train_base,dam_ins.atk_lv)
    return 
  else
    local train_base = deal_dam/self.max_hp*50+10
    self:train_attr("con",train_base,dam_ins.atk_lv)
  end
  
  if block_hit then
    self:train_attr("wil",30,dam_ins.hit_lv)
    if self:isUsingShield() then
      self:train_skill("shield",rnd(30,50),dam_ins.hit_lv)
    end
  end
  --train block，train shield
  --挨揍的
  local displayType = nil
  if source and source:isInPlayerTeam() then
    displayType = "hit"
  elseif self:isInPlayerTeam() then
    displayType = "enemy_hit"
  end

  if displayType then
    if deal_crit then
      addmsg(string.format("(%d!)",deal_dam),displayType)
    elseif block_hit then
      addmsg(string.format("(%d-)",deal_dam),displayType)
    else
      addmsg(string.format("(%d)",deal_dam),displayType)
    end
  end

  if delay<=0 then 
    self:take_damage(source,dam_ins)
  else
    table.insert(self.damage_queue,{source = source,dam_ins=dam_ins,delay = delay})--延迟伤害
  end
  --on_hurt
end



function Unit:update_damage(dt)
  local i=1
  while i<=#self.damage_queue do
    local dam_t = self.damage_queue[i]
    dam_t.delay = dam_t.delay  - dt
    if dam_t.delay<=0 then
      self:take_damage(dam_t.source,dam_t.dam_ins)
      table.remove(self.damage_queue,i)
    else
      i= i+1
    end
  end
end

--仅能使用此函数扣除hp。
function Unit:take_damage(source,dam_ins)
  if self:is_dead() then return end
  self.hp = self.hp-dam_ins.dam
  if self.hp<=0 then 
    self:die(source,dam_ins)
  end
end


--获取躲闪等级。是为
function Unit:getDodgeLevel(showmsg)
  local dodgeLevel = self.level
  local dex = self:cur_dex()
  local per = self:cur_per()
  local attrlv = (dex*0.85+per*0.15)/c.averageAttrGrow --计算出属性的平均等级
  local val = (attrlv-dodgeLevel)/(dodgeLevel+3) -- -1到2以上  常见-0.5 到1  


  dodgeLevel = dodgeLevel + val*10 -- 属性一般 -5到+10， 最大-10到+20以上
  --还有其他装备buff附加的等级，种族天赋等

  dodgeLevel = dodgeLevel+self:getBonus("dodge_lv")

  if (showmsg) then debugmsg(string.format("dodgeLevel:%.1f,attrBouns:%.1f, effectBonus:%.1f,attrlv:%.1f,selfLv:%d",dodgeLevel,val*10,self:getBonus("dodge_lv"),attrlv,self.level))end
  return dodgeLevel
end

--格挡等级
function Unit:getBlockLevel()
  local blockLevel = self.level
  local attrlv = (self:cur_con()*0.4+self:cur_wil()*0.6)/c.averageAttrGrow --计算出属性的平均等级
  local val = (attrlv-blockLevel)/(blockLevel+3) -- -1到2以上  常见-0.5 到1  


  blockLevel = blockLevel + val*10 -- 属性一般 -5到+10， 最大-10到+20以上
  --还有其他装备buff附加的等级，种族天赋等
  blockLevel = blockLevel+self:getBonus("block_lv")

  return blockLevel
end


--根据命中等级和闪避等级，取得命中概率。
local function hitRate(hitLevel,dodgeLevel)
  --命中率最小20%，最大当然是100%.
  --计算等级差 CHA
  --CHA>=20， 100%
  --cha==0   (range =60 为89%)  
  --cha == 20-0.7*range  50%
  --cha ==-20-range 0%(不可能，因为在此之前达到最小值20%)20-0.89range 20%
  local range = 60
  local cha = hitLevel - dodgeLevel
  if cha>=20 then return 1 end
  return math.max(0.2,1-((cha-20)/range)^2)
end






--近战命中判定，返回0，miss。返回1，命中，返回。。。其他格挡等等。
function Unit:check_melee_hit(source,dam_ins,fdelay)
  local selfDodgeLevel = self:getDodgeLevel(true)
  local hit_probability = hitRate(dam_ins.hit_lv,selfDodgeLevel)
  local hit = 0
  self:train_attr("dex",rnd(6,8),dam_ins.hit_lv)--训练敏捷，无论是否击中。
  if rnd()<hit_probability then
    hit =1
    self:deal_damage(source,dam_ins,fdelay)
  else
    self:train_attr("dex",rnd(4,8),dam_ins.hit_lv)--训练敏捷， 躲闪成功。
  end
  debugmsg(string.format("meleeDam:%.1f, hitlevel:%.1f,dodgeLevel:%.1f,dex:%d, rate:%.2f",dam_ins.dam,dam_ins.hit_lv,selfDodgeLevel,self:cur_dex(),hit_probability))
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

  local selfDodgeLevel = self:getDodgeLevel(true)
  local hit_probability = hitRate(dam_ins.hit_lv,selfDodgeLevel)
  local hit = rnd()<hit_probability--经过数值运算的结果。


  local source = projectile.source_unit
  if hit or projectile.dest_unit == self then --只有命中或想要命中的子弹才显示，无意并擦过的子弹不显示。
    local con1 = self:isInPlayerTeam() 
    local con2 = source and source:isInPlayerTeam() 
    if con1 or con2 then
      local selfname = self:getShortName()

      if hit then
        if source then
          local sourcename = source:getShortName()
          if projectile.name then
            addmsg(string.format(tl("%s的%s命中了%s。","%s's %s hit %s."),sourcename,projectile.name,selfname),"info")
          else
            addmsg(string.format(tl("%s射中了%s。","%s's shot hit %s."),sourcename,selfname),"info")
          end
        else
          addmsg(string.format(tl("%s被射中了.","%s have been shot."),selfname),"info")
        end
      else
        if source then
          local sourcename = source:getShortName()
          if projectile.name then
            addmsg(string.format(tl("%s躲开了%s的%s。","%s dodged %s's %s."),selfname,sourcename,projectile.name),"info")
          else
            addmsg(string.format(tl("%s躲开了%s的射击。","%s dodged %s's shot."),selfname,sourcename),"info")
          end
        else
          addmsg(string.format(tl("%s躲开了射击。","%s dodged the shot."),selfname),"info")
        end
      end
    end
  end


  self:train_attr("dex",rnd(4,6),dam_ins.hit_lv)--训练敏捷，无论是否击中。
  if hit then
    self:deal_damage(source,dam_ins,0)
    if projectile.impact then
      self:hitImpact(projectile.rotation,projectile.impact)
    end
  else
    self:train_attr("dex",rnd(5,7),dam_ins.hit_lv)--训练敏捷，躲闪成功。
  end
  debugmsg(string.format("hitlevel:%.1f,dodgeLevel:%.1f,dex:%d, rate:%.2f",dam_ins.hit_lv,selfDodgeLevel,self:cur_dex(),hit_probability))

  return hit 
end