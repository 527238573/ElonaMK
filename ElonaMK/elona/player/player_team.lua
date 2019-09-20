

--team 固定为4个人。这是周密考虑的结果。不会再改了。超过4个人会使操作复杂性提高。超过四个人可用随行npc。
function Player:changeMC(index)
  assert(0<index and index<=4)
  
  local unit = self.team[index]
  if unit  and unit:canOperate() then
    local dist = c.dist_2d(unit.x,unit.y,self.mc.x,self.mc.y)
    self.mc = unit
    --其他改变。
    if dist<8.1 then
      ui.cameraInterpolationMove(dist*0.04+0.2)
    end
  end
end

--这个值是四人合起来的上限
function Player:getCarryLimit()
  local limit = 0
  for i=1,4 do
    if self.team[i] then limit = limit+ self.team[i]:getTeamCarryContribution() end
  end
  return limit
end


--当前team包里物品的总重量
function Player:getCarryWeight()
  return self.inv:getWeight()
end

function Player:isUnitInTeam(unit)
  if unit ==nil then return false end
  for i=1,4 do
    if self.team[i]==unit then return true end
  end
  return false
end