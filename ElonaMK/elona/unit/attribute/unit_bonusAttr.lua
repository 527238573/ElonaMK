Bonus = { 
  --一些默认值
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
  exp_point = 0,
  
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
  
  dodge_mod = 0,--三大平衡修正，范围-0.5 到0.5。（正值增益）
  melee_mod = 0,
  range_mod = 0,--仅非机械武器伤害。
  
  --flag形式的加成也登记在此。大于0就会生效。
}

saveMetaType("Bonus",Bonus)--注册保存类型
Bonus.__newindex = function(o,k,v)
  if Bonus[k]==nil then error("使用了Bonus的意料之外的值:"..k) else rawset(o,k,v) end
end

function Unit:createBonusAttr()
  self.basis = setmetatable({},Bonus)
  self.bonus = setmetatable({},Bonus)  
end


function Unit:reloadBasisBonus()
  local bas_t = setmetatable({},Bonus) --直接重建
  self.basis = bas_t
  for key,_ in pairs(g.attr) do
    if g.main_attr [key] then
      bas_t[key] = math.floor( self.attr[key]) 
    else
      bas_t[key] = self.attr[key] 
    end
  end
  for _,tra in ipairs(self.traits) do
    tra:calculate_bonus(bas_t)
  end
  
  self.basis["AR"] = math.max(0,self.weapon_list.AR)
  self.basis["MR"] = math.max(0,self.weapon_list.MR)
  self:resetMaxHPMP() --有任何变动都会刷新最大hpmp
  --debugmsg("reloadBasisBonus")
end

function Unit:reloadRealTimeBouns()
  local bon_t = setmetatable({},Bonus)  
  self.bonus = bon_t
  for _,eff in ipairs(self.effects) do
    eff:calculate_bonus(bon_t)
  end
  self:resetMaxHPMP()--有任何变动都会刷新最大hpmp
  --debugmsg("reloadRealTimeBouns")
end



function Unit:getBonus(bonusName)
  return self.basis[bonusName] + self.bonus[bonusName]
end

--护甲值 即时
function Unit:getAR()
  return  self.basis["AR"] +self.bonus["AR"] --后续可能会有百分比的加成
end

function Unit:getMR()
  return  self.basis["MR"] +self.bonus["MR"] --后续可能会有百分比的加成
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
  local rnum = math.floor(self.basis[res_str]+self.bonus[res_str])
  return c.clamp(rnum,-8,8)
end

function Unit:getResistanceByResId(res_id)
   local rnum = math.floor(self.basis[res_id]+self.bonus[res_id])
  return c.clamp(rnum,-8,8)
end