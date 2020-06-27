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