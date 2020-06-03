






function Unit:getMaxHP()
  local con = self:cur_con()
  local str = self:cur_str()
  local wil = self:cur_wil()
  local life = self:cur_life()
  local level = self.level
  return math.min(math.max(math.floor(1+life/100*((level/25+0.2)*( 2 * con + 1.3*str + wil*0.7)+con/2)),5),4000000)
  
end
function Unit:getMaxMP()
  local mag = self:cur_mag()
  local ler = self:cur_ler()
  local wil = self:cur_wil()
  local mana = self:cur_mana()
  local level = self.level
  return math.min(math.max(math.floor(1+mana/100*((level/25+0.2)*( 1.5 * mag + 1.25*ler + 1.25*wil)+mag/2)),5),4000000)
end
--最大搬运量
function Unit:getMaxCarry()
  local con = self:cur_con()
  local str = self:cur_str()
  local level = self.level
  return 35+ str*1.5+con*0.5+level*0.5
end



