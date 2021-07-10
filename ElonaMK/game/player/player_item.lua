

--showmsg为true 输出信息，不能捡起的原因。（超重或者不能捡起隐藏物品。或者不能捡起他人物品）
--npc捡东西需要其他验证函数。
function Player:canPickupItem(item,showmsg)
  if item:isHidden() then return false end
  return true
end


--能否丢弃物品。
function Player:canDropItem(item,showmsg)
  if item:isHidden() then return false end
  return true
end

