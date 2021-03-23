

function Item:isEquipment()
  return self.type.type =="equipment"
end
function Item:isWeapon()
  return self.type.weapon
end
function Item:isMeleeWeapon()
  return self.type.meleeWeapon
end
function Item:isRangeWeapon()
  return self.type.rangeWeapon
end



function Item:getEquipType()
  return self.type.equipType
end

--防御等。可能后续被物品本身锻造加成。
function Item:getDEF()
  return self.type.DEF
end

function Item:getMGR()
  return self.type.MGR
end

--根据物品等级。初始化装备的基础属性。
function Item:initEquipment(level)
  self.level = level
  local itype = self.type
  --增加一些可变数值？锻造提升防御，攻击等。
  
  
  if itype.R_key =="reload" then --对需要装弹的武器
    self.useReload = true
    self.ammoNum = itype.maxAmmo --当前子弹数设为最大。 
  end
end


--初始化
function Item:randomEnchantment(level,quality)
  self.quality = quality
end

local cword = tl("的"," ")
local prefix = {"","◇","☆","★",} 
function Item:resetEquipmentName()
  
  local name = string.format("%s%s Lv%d",prefix[self.quality],self.type.name,self.level)
  
  --锻造、祝福等的属性才会被额外显示。
  
  self.displayName = name
end

function Item:getRandomHitEffect()
  local hetable = self.type.hit_effect
  return hetable[rnd(#hetable)]
end