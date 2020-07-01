

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

--尝试使用技能。返回true，如果使用成功。，showmsg为true会显示不能释放时的信息。
function Unit:useAbility(abi,showmsg)
  --使用前要检查状态，可能死亡或不能动
  if self.delay>0 then
    addmsg("二次使用了ability"..abi:getName())
    return false
  else
    abi.cooling = abi:getCooldown()
    addmsg("使用了ability"..abi:getName())
     p.mc:bar_delay(1,"useA","useA")
  end
  
  return true
end