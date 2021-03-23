

--在slot1-5上检查能否装备物品,或其他特殊天赋都在这里检查。只检查能否使用。
function Unit:canWearItem(toEquip,slot,interactive)
  if not toEquip:isEquipment() then 
    --必须是一个装备
    return false
  end
  local equiptype = toEquip:getEquipType()
  if slot ==1 then
    return equiptype == "mainhand" or equiptype == "hand" or equiptype == "shield"
  elseif slot ==2 then
    return equiptype == "offhand" or equiptype == "hand" or equiptype == "shield"
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


--做成local function
local function buildWeaponList(unit)
  local weapon_list = {melee={},range = {}}
  --统计def,mgr，重量 武器
  local DEF =0
  local MGR =0
  local totalWeight = 0
  
  for i=1,5 do
    local eq = unit.equipment[i]
    if eq  then--有装备
      totalWeight = totalWeight+eq:getWeight()
      DEF = DEF + eq:getDEF()
      MGR = MGR + eq:getMGR()
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
  
  local meleeList = weapon_list.melee
  
  --标示出有没有装备shield
  weapon_list.use_shield =false
  for i=1,#meleeList do
    if meleeList[i].item:hasFlag("SHIELD") then
      weapon_list.use_shield = true
      break
    end
  end
  
  if #(meleeList) ==0 then --当没有可用的近战武器，以徒手攻击为武器。
    local weapon = {unarmed = true,isMelee = true} --代表。徒手格斗。具体数据实时计算
    table.insert(meleeList,weapon)
  elseif meleeList[1].item:hasFlag("SHIELD") then--首位是shield
    --shield不会优先作为首位武器，除非没有其他武器选择
    for i=2,#meleeList do
      local curW = meleeList[i]
      if not curW.item:hasFlag("SHIELD") then --后续找到一个不是shield的武器
        table.remove(meleeList,i)
        table.insert(meleeList,1,curW)--插入首位
        --debugmsg("change melee weapon pos")
        break
      end
    end
  end
  
  
  --计算防御等级
  local body_def = 0
  local eq = unit.equipment[3] --body
  if eq  then
    body_def =  eq.level
  end
  body_def = unit:getBaseRoundLevel(body_def)
  weapon_list.DEF = body_def+DEF
  weapon_list.MGR = body_def+MGR
  weapon_list.totalWeight=totalWeight
  unit.weapon_list = weapon_list
end


--更换装备之后。直接调用此函数。
function Unit:on_equip_change()
  buildWeaponList(self)
  --重读固有加成属性。（装备和基本属性和特性）
  self:reloadBasisBonus()
end

--是否装备了shield
function Unit:isUsingShield()
  return self.weapon_list.use_shield
end


function Unit:getBaseRoundLevel(eq_level)
  local cha = math.abs(eq_level-self.level)
  
  if cha<=20 then
    return eq_level
  end
  
  local newcha = math.floor(math.sqrt(cha-20))+20
  
  debugmsg("eq outrange!"..cha.."new"..newcha)
  return eq_level>self.level and self.level+newcha or self.level- newcha
end




