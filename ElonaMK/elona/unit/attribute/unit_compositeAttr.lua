--合成属性。由多个基础属性合成。


--只在需要的时候更新。
function Unit:resetMaxHPMP() --最大hpmp 很常用。采用刷新制。任何属性或等级变动直接刷新。
  local con = self:cur_con()
  local str = self:cur_str()
  local wil = self:cur_wil()
  local life = self:cur_life()
  local level = self.level
  self.max_hp = math.min(math.max(math.floor(1+life/100*((level/25+0.2)*( 2 * con + 1.3*str + wil*0.7)+con/2)),5),4000000)
  local mag  = self:cur_mag()
  local ler  = self:cur_ler()
  local mana = self:cur_mana()
  self.max_mp = math.min(math.max(math.floor(1+mana/100*((level/25+0.2)*( 1.5 * mag + 1.25*ler + 1.25*wil)+mag/2)),5),4000000)
end


function Unit:getHPRate()
  return math.min(1,math.max(0,self.hp/self.max_hp))
end
function Unit:getMPRate()
  return math.min(1,math.max(0,self.mp/self.max_mp))
end
--去其他二级属性，只在要取值的时候现场计算。

--最大搬运量
function Unit:getMaxCarry()
  local con = self:base_con()--使用基础属性，不接受buff的增减
  local str = self:base_str()
  local level = self.level
  return 35+ str*1.5+con*0.5+level*0.5
end

