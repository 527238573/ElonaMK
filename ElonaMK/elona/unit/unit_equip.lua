

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
  if toEquip:hasFlag("TWOHAND")  and slot ==1 then --双手
    --主手穿戴双手物品，副手退下
    self:dropEquipmentToInventory(2)--褪下副手物品
  end
  if slot ==2 then --装备副手物品，但主手是双手武器
    if self.equipment[1] and self.equipment[1]:hasFlag("TWOHAND") then
      self:dropEquipmentToInventory(1)--褪下主手物品
    end
  end
  
  self:on_equip_change()
end

function Unit:takeoffEquipment(slot,interactive)
  if self.equipment[slot] then
    if self:canUnwearItem(slot,interactive) then
      self:dropEquipmentToInventory(slot)
      self:on_equip_change()
    end
  end
end

--更换装备之后。直接调用此函数。
function Unit:on_equip_change()
  self:buildWeaponList()
  --重读固有加成属性。（装备和基本属性和特性）
  self:reloadBasisBonus()
end



function Unit:buildWeaponList()
  local weapon_list = {melee={},range = {}}
  --统计ar，mr，重量 武器
  local ar =0
  local mr = 0
  local totalWeight = 0
  
  for i=1,5 do
    local eq = self.equipment[i]
    if eq  then--有装备
      totalWeight = totalWeight+eq:getWeight()
      ar = ar+eq:getAR()
      mr = mr+eq:getMR()
      if eq:isWeapon() then
        if eq:isMeleeWeapon() then
          local weapon = {item = eq,isMelee = true}
          table.insert(weapon_list.melee,weapon)
        end
        if eq:isRangeWeapon() then
          local weapon = {item = eq,isMelee = false}
          table.insert(weapon_list.range,weapon)
        end
      end
    end
  end
  if #(weapon_list.melee) ==0 then --当没有可用的近战武器，以徒手攻击为武器。
    local weapon = {unarmed = true,isMelee = true} --代表。徒手格斗。具体数据实时计算
    table.insert(weapon_list.melee,weapon)
  end
  
  weapon_list.AR =ar
  weapon_list.MR = mr
  weapon_list.totalWeight=totalWeight
  self.weapon_list = weapon_list
end

--刷新一下weapon的相关数据，用于显示。实际战斗不会用这些，而是取实时值。
--[[
function Unit:loadWeaponListData()
  local meleeList = self.weapon_list.melee
  for i=1,#meleeList do
    local oneWeapon = meleeList[i]
    if oneWeapon.unarmed then
      local dice_num,dice_face,base_atk = self:getUnarmedAtkData()
      oneWeapon.dice = dice_num
      oneWeapon.face = dice_face
      oneWeapon.base = base_atk +self:getWeaponBaseBonus(oneWeapon)
      oneWeapon.modifier = self:getWeaponModifier(oneWeapon)
    else
      local weaponItem = oneWeapon.item
      oneWeapon.dice = weaponItem.diceNum
      oneWeapon.face = weaponItem.diceFace
      oneWeapon.base = weaponItem.baseAtk +self:getWeaponBaseBonus(oneWeapon)
      oneWeapon.modifier = self:getWeaponModifier(oneWeapon)
    end
  end
  
  local rangeList = self.weapon_list.range
  for i=1,#rangeList do
    local oneWeapon = rangeList[i]
    local weaponItem = oneWeapon.item
    oneWeapon.dice = weaponItem.diceNum_range
    oneWeapon.face = weaponItem.diceFace_range
    oneWeapon.base = weaponItem.baseAtk_range +self:getWeaponBaseBonus(oneWeapon)
    oneWeapon.modifier = self:getWeaponModifier(oneWeapon)
    oneWeapon.pellet = weaponItem:getPellet()
  end
  
end
--]]


