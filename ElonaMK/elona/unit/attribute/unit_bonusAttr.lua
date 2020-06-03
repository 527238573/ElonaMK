Bonus = { 
  --一些默认值
  saveType = "Bonus",--注册保存类型
  --合法的加成属性值名称。除此以外都不合法。
  --基本属性
  life = 0,
  mana = 0,
  speed = 0,
  str = 0,
  con = 0,
  dex = 0,
  per = 0,
  ler = 0,
  wil = 0,
  mag = 0,
  chr = 0,
  str_p = 0,--基本属性潜力
  con_p = 0,
  dex_p = 0,
  per_p = 0,
  ler_p = 0,
  wil_p = 0,
  mag_p = 0,
  chr_p = 0,
  
  --各种抗性。
  res_bash =0,
  res_cut =0,
  res_stab =0,
  res_fire = 0,
  res_ice =0,
  res_nature =0,
  res_earth =0,
  res_dark =0,
  res_light =0,
  
  AR=0,--护甲
  MR=0,--魔抗
  --flag形式的加成也登记在此。大于0就会生效。
}

saveClass["Bonus"] = Bonus --注册保存类型

Bonus.__index = Bonus
Bonus.__newindex = function(o,k,v)
  if Bonus[k]==nil then error("使用了Bonus的意料之外的值:"..k) else rawset(o,k,v) end
end

function Unit:createBonusAttr()
  self.ebonus = setmetatable({},Bonus)
  self.bonus = setmetatable({},Bonus)  
end


function Unit:reloadEquipBouns()
  self.ebonus = setmetatable({},Bonus) --直接重建
  self.ebonus["AR"] = math.max(0,self.weapon_list.AR)
  self.ebonus["MR"] = math.max(0,self.weapon_list.AR)
end

function Unit:reloadRealTimeBouns()
  self.bonus = setmetatable({},Bonus)  
end



function Unit:getBonus(bonusName)
  return self.ebonus[bonusName] + self.bonus[bonusName]
end

--护甲值 即时
function Unit:getAR()
  return  self.ebonus["AR"] +self.bonus["AR"] --后续可能会有百分比的加成
end

function Unit:getMR()
  return  self.ebonus["MR"] +self.bonus["MR"] --后续可能会有百分比的加成
end

--单一属性的抗性，-8到8之间。
function Unit:getResistance(atktype)
  local res_str = "res_bash"
  if atktype=="bash" then res_str="res_bash" 
  elseif atktype=="cut" then res_str="res_cut" 
  elseif atktype=="stab" then res_str="res_stab" 
  elseif atktype=="fire" then res_str="res_fire" 
  elseif atktype=="ice" then res_str="res_ice" 
  elseif atktype=="nature" then res_str="res_nature" 
  elseif atktype=="earth" then res_str="res_earth" 
  elseif atktype=="dark" then res_str="res_dark" 
  elseif atktype=="light" then res_str="res_light" 
  else error("unknow attack type:"..atktype) end
  local rnum = math.floor(self.ebonus[res_str]+self.bonus[res_str])
  return c.clamp(rnum,-8,8)
end