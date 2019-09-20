

function Item:isEquipment()
  return self.type.type =="equipment"
end
function Item:isWeapon()
  return self.type.weapon
end

function Item:getEquipType()
  return self.type.equipType
end
function Item:getPV()
  return self.pv
end

function Item:getDV()
  return self.dv
end



function Item:randomMaterial(level)
  local dlevel = level - self.type.sLevel
  local material = Item.getRandomMaterial(dlevel)
  self.material_id = material.id
  rawset(self,"material",assert(material))
end

--根据物品等级。初始化装备的基础属性。
function Item:initEquipment(level)
  local itype = self.type
  local dlevel = level - self.type.sLevel
  self.dv = math.floor(itype.DV+dlevel*itype.DV_grow)
  self.pv = math.floor(itype.PV+dlevel*itype.PV_grow)
  if not itype.weapon then return end--必须是武器
  self.diceNum =itype.diceNum
  self.to_hit =itype.to_hit
  self.diceFace =math.floor(itype.diceFace +dlevel*itype.face_grow*itype.atkCost/100*2)
  self.baseAtk =math.floor(itype.baseAtk+dlevel*itype.base_grow*itype.atkCost/100)
  if not itype.rangeWeapon then return end --远程武器
  self.diceNum_range =itype.diceNum_range
  self.to_hit_range =itype.to_hit_range
  self.diceFace_range =math.floor(itype.diceFace_range +dlevel*itype.face_grow_range*itype.shotCost/100*2)
  self.baseAtk_range =math.floor(itype.baseAtk_range+dlevel*itype.base_grow_range*itype.shotCost/100)
end


--初始化
function Item:randomEnchantment(level,quality)
  self.quality = quality
end

local cword = tl("的"," ")
local prefix = {"","◇","☆","★",} 
function Item:resetEquipmentName()
  local materialname 
  if self.quality>= 3 then 
    materialname = self.material.aka
  else
    materialname = self.material.name..cword
  end
  local name = prefix[self.quality]..materialname..self.type.name
  if self.type.rangeWeapon then
    local dmgstr
    if self.baseAtk_range ==0 then 
      dmgstr = string.format(" (%dr%d)",self.diceNum_range,self.diceFace_range)
    elseif self.baseAtk>0 then
      dmgstr = string.format(" (%dr%d+%d)",self.diceNum_range,self.diceFace_range,self.baseAtk_range)
    elseif self.baseAtk<0 then
      dmgstr = string.format(" (%dr%d%d)",self.diceNum_range,self.diceFace_range,self.baseAtk_range)
    end
    name = name..dmgstr
    if self.to_hit_range~=0 then name = name..string.format("(%d)",self.to_hit_range) end
  elseif self.type.weapon then
    local dmgstr
    if self.baseAtk ==0 then 
      dmgstr = string.format(" (%dr%d)",self.diceNum,self.diceFace)
    elseif self.baseAtk>0 then
      dmgstr = string.format(" (%dr%d+%d)",self.diceNum,self.diceFace,self.baseAtk)
    elseif self.baseAtk<0 then
      dmgstr = string.format(" (%dr%d%d)",self.diceNum,self.diceFace,self.baseAtk)
    end
    name = name..dmgstr
    if self.to_hit~=0 then name = name..string.format("(%d)",self.to_hit) end
  end
  if self.pv>0 or self.dv>0 then
    name = name..string.format(" [%d,%d]",self.dv,self.pv)
  end
  self.displayName = name
end