

--在slot1-5上检查能否装备物品,或其他特殊天赋都在这里检查。只检查能否使用。
function Unit:canWearItem(toEquip,slot,interactive)
  if not toEquip:isEquipment() then 
    --必须是一个装备
    return false
  end
  local equiptype = toEquip:getEquipType()
  if slot ==1 then
    return equiptype == "mainhand" or equiptype == "hand"
  elseif slot ==2 then
    return equiptype == "offhand" or equiptype == "hand"
  elseif slot ==3 then
    return equiptype == "body"
  elseif slot ==4 or slot ==5 then
    return equiptype == "accessory"
  end
  return false 
end
--可能诅咒等脱不下来
function Unit:canUnwearItem(slot,interactive)
  return true
end


--并不调用change。
function Unit:dropEquipmentToInventory(slot)
  local equipment = self.equipment[slot]
  if equipment then
    self.equipment[slot] = nil
    if p:isUnitInTeam(self) then
      --进入玩家背包
      p.inv:addItem(equipment)
    else--进入单位自身背包
      self.inv:addItem(equipment)
    end
  end
end


function Unit:wearEquipment(toEquip,slot,interactive)
  if not self:canWearItem(toEquip,slot,interactive) then return end
  if self.equipment[slot] then
    if self:canUnwearItem(slot,interactive) then
      self:dropEquipmentToInventory(slot)
    else
      return
    end
  end
  self.inv:addItem(toEquip)
  self.equipment[slot] = toEquip
  self:on_equip_change()
end

function Unit:takeoffEquipment(slot,interactive)
  if self.equipment[slot] then
    if self:canUnwearItem(slot,interactive) then
      self:dropEquipmentToInventory(slot)
    end
  end
  self:on_equip_change()
end

--更换装备之后。直接调用此函数。
function Unit:on_equip_change()
  self:buildWeaponList()
  
  
  
end



function Unit:buildWeaponList()
  local weapon_list = {}
  --统计pv，dv，重量 武器
  local pv =0
  local dv = 0
  local totalWeight = 0
  
  for i=1,5 do
    local eq = self.equipment[i]
    if eq  then--有装备
      totalWeight = totalWeight+eq:getWeight()
      pv = pv+eq:getPV()
      dv = dv+eq:getDV()
      if eq:isWeapon() then
        local weapon = {item = eq,type = "melee",}
        weapon_list[#weapon_list+1] = weapon
      end
    end
  end
  weapon_list.pv =pv
  weapon_list.dv = dv
  weapon_list.totalWeight=totalWeight
  self.weapon_list = weapon_list
end

function Unit:getWeaponBaseAtk(weapon)
  return weapon.baseAtk
  
end
function Unit:getWeaponMeleeModifier(weapon)
  return 1
end

function Unit:getUnarmedDice()
  return 2,6,2
end

function Unit:getUnarmedModifier()
  return 1
end