--动作条，可以存放快捷指向物品或技能。
ActionBar = {
  
}
saveMetaType("ActionBar",ActionBar)--注册保存类型

function Unit:initActionBar()
  self.actionBar = setmetatable({},ActionBar)
end

--新学会的技能想要加入动作条。如果有空位的话，自动加入靠前的位置。
function ActionBar:learnAbility(abi)
  for i=1,8 do
    if self[i]==nil then
      self[i] = {etype = "ability",val = abi}
      return 
    end
  end
end

function ActionBar:getAbilityIndexStr(abi)
  for i=1,8 do
    local entry = self[i]
    if entry~=nil then
      if entry.etype == "ability" and entry.val == abi then
        return tostring(i)
      end
    end
  end
  return " "
end

function Unit:useActionBar(index)
  --self:bar_delay(1,"action","actionbar")
  local action = self.actionBar[index]
  if action ==nil then return false end
  if action.etype == "ability" then
    return self:useAbility(action.val,true)
  end
  --addmsg("使用了actionbar"..index)
end

function Unit:assignAbilityToActionBar(skillIndex,actionIndex)
  local actionBar = self.actionBar
  local abi = self.abilities[skillIndex]
  if abi then actionBar[actionIndex] = {etype = "ability",val = abi} end
end

function ActionBar:clearAbility(abi)
  if abi==nil then return end
  for i=1,8 do
    if self[i] and self[i].etype == "ability" and self[i].val == abi then self[i]=nil end
  end
end