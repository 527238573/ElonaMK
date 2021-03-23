

function Unit:updateAbilities(dt)
  local list = self.abilities
  for i=1,#list do list[i]:updateRL(dt) end
end


--学会指定的技能。不会重复。
function Unit:learnAbility(abi_id,showmsg)
  local list = self.abilities
  for i=1,#list do
    if  list[i].id == abi_id then return list[i] end
  end
  local abi = Ability.new(abi_id)
  local old_level = self.abilities_level[abi_id]
  if old_level then abi.level = old_level end --曾经学过的技能，会保留等级。
  table.insert(list,abi)

  self.actionBar:learnAbility(abi)

  if showmsg and self:isInPlayerTeam() then
    addmsg(string.format(tl("%s掌握了技能:%s。","%s learned a new ability:%s."),self:getShortName(),abi:getName()),"good")
    g.playSound_delay("ding3",self.x,self.y,0.5)--推迟一点
  end
  return abi
end


--验证是否有法力值来释放技能。
function Unit:hasManaToCast(abi)
  local cost = abi:getCostMana()
  return self.mp>=cost

end
--实际扣除施放技能所需要法力值。
function Unit:costManaToCast(abi)
  local cost = abi:getCostMana()
  self.mp = math.max(0,self.mp - cost)
end




--尝试使用技能。返回true，如果使用成功。，showmsg为true会显示不能释放时的信息。
function Unit:useAbility(abi,showmsg)
  --使用前要检查状态，可能死亡或不能动
  if self.dead then return false end --

  --某些状态会阻止技能释放。（沉默，麻痹等）

  if abi:getCoolRate()>0 then--技能没有冷却完成。
    if showmsg then addmsg(tl("技能没有冷却完成!","Ability cooldown not complete!"),"info") end
    return false
  end

  if not self:hasManaToCast(abi) then
    if showmsg then addmsg(tl("没有足够法力值!","Not enough mana!"),"info") end
    return false
  end

  local suc,trainTime,trainLv = abi:use(self,showmsg)
  if suc then
    --释放成功
    abi:startCooling(abi:getCooldown())
    self:costManaToCast(abi)
    self:train_ability(abi,trainTime,trainLv)
  end

  return suc
end

--请求进行chanting动作，满足则返回true。
--成功返回eff，失败返回nil
function Unit:requestChanting(style,time)
  if self.dead then return nil end --
  local res = false
  if self.delay<=0 then  
    return self:addEffect_chanting(style,time)--成功释放（普通）
  end
  --delay>0,需要额外特性，双重chanting等。
  --if 判断双重changting成功，添加的是另种eff，并立即返回该eff。

  return nil
end

--请求进行short_delay动作，满足则返回true。
function Unit:requestDelay(time,delay_id)
  if self.dead then return false end
  if self.delay<=0 then  
    self:short_delay(time,delay_id)
    return true
  end
  --delay>0,绝大部分情况当然是在执行其他动作时不能做新动作。
  --某些特殊的特性，可以根据delay_id来判断动作，同时进行2个特定动作。
  return false
end
--请求进行bar_delay动作，满足则返回true。
function Unit:requestBarDelay(time,delay_name,delay_id)
  if self.dead then return false end
  if self.delay<=0 then  
    self:bar_delay(time,delay_name,delay_id)
    return true
  end
  --delay>0,绝大部分情况当然是在执行其他动作时不能做新动作。
  --某些特殊的特性，可以根据delay_id来判断动作，同时进行2个特定动作。
  return false
end

--瞬发技能不用请求以上这些，可以在做其他动作时同时发出技能。



function Unit:getAbilityAtkLevel(abi)
  local atkLevel = abi:getCombinedLevel()
  atkLevel = self:getBaseRoundLevel(atkLevel) --不会超过一定范围
  if abi:isMagic() then
    atkLevel = atkLevel+self:getBonus("mgc_lv")
  else
    atkLevel = atkLevel+self:getBonus("atk_lv")
  end
  return atkLevel
end
--获得技能的命中等级。
function Unit:getAbilityHitLevel(abi)
  local skill = abi.type.hit_skill
  local hitLevel=self:getSkillLevel(skill)
  
  hitLevel = hitLevel+ self:getBonus("hit_lv")--命中与物理共用，使得命中属性实用性增强
  return hitLevel
end

function Unit:getAbilityCritLevel(abi)
  local critLevel = abi:getCombinedLevel()
  critLevel = critLevel+ self:getBonus("crit_lv")
  
  
  local ulevel = self.level
  local attrlv = ulevel
  if abi:isMagic() then
    attrlv = (self:cur_per()*0.7+self:cur_ler()*0.3)/c.averageAttrGrow --计算出属性的平均等级
  else
    attrlv = (self:cur_dex()*0.5+self:cur_ler()*0.5)/c.averageAttrGrow --计算出属性的平均等级
  end
  local val = (attrlv-ulevel)/(ulevel+3) -- -1到2以上  常见-0.5 到1  
  
  critLevel = critLevel + val*10 -- (属性一般 -5到+10， 最大-10到+20以上)val*10的时候
  return critLevel
end

--伤害倍乘系数。非伤害技能可能有自己的属性加成算法。
function Unit:getAbilityModifier(abi)
  local attr1 = self:cur_mag()
  local attr2 = self:cur_main_attr(abi.type.main_attr)
  local m_attr = attr1*0.4 +attr2*0.6 
  if m_attr<20 then
    return 0.95+m_attr*(m_attr+1)/2*0.005
  else
    return m_attr*0.1
  end
end

--返回伤害dam_ins
function Unit:getAbilityDamageInstance(abi,dice,face,base)
  if dice ==nil then
    local atype = abi.type
    dice,face,base = atype.diceNum,atype.diceFace,atype.baseAtk --如果没有填，三项都是0
  end
  local mod = self:getAbilityModifier(abi)
  local dam_ins = setmetatable({},Damage)
  dam_ins.hit_lv = self:getAbilityHitLevel(abi)
  dam_ins.atk_lv = self:getAbilityAtkLevel(abi)
  dam_ins.crit_lv = self:getAbilityCritLevel(abi)
     --计算伤害
  local roll = 0
  if dice>0 then
    for i=1,dice do
      roll = roll+rnd()
    end
    roll = roll/dice
  end
  dam_ins.dam = (base + roll*face) *mod
  return dam_ins
end


--同时还训练相关属性。
function Unit:train_ability(abi,trainTime,trainlv)
  trainlv = trainlv or abi:getCombinedLevel() --没有等级，就按技能等级来算。
  trainTime = trainTime or 1 --默认按训练1秒。或许会修改。
  if abi:isMagic() then
    self:train_attr("mag",rnd(8,12)*trainTime,trainlv) -- 施法主属性
  else
    self:train_attr("mag",rnd(3,5)*trainTime,trainlv) -- 施法主属性
    self:train_attr("con",rnd(5,7)*trainTime,trainlv) -- 施法主属性
  end
  self:train_attr(abi:getMainAttr(),rnd(8,12)*trainTime,trainlv)--次要属性
  abi:train(rnd(8,12)*trainTime,trainlv,self)
end

