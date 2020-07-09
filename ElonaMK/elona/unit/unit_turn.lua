--固定回合的检定等。

function Unit:regenerateHPMP(dt)
  local real_gen_hp = math.max(0,math.min(dt*self.hp_regen,self.max_hp-self.hp))
  local real_gen_mp = math.max(0,math.min(dt*self.mp_regen,self.max_mp-self.mp))
  self.hp_rcount = self.hp_rcount+real_gen_hp
  self.mp_rcount = self.mp_rcount+real_gen_mp
  self.hp = self.hp+real_gen_hp
  self.mp = self.mp+real_gen_mp
end


--每隔一段时间运行一次的检查，但不保证时间间隔固定。快进时间可能会使检查间隔变长。
local turn_base = 0.5--最低每0.5秒检查一次
function Unit:turnCheck(dt)
  self.turn_past = self.turn_past  +dt
  if self.turn_past<turn_base then return end --
  local turn_past = self.turn_past
  self.turn_past = 0 --清除。
  if self.hp_rcount>self.max_hp*0.1 then
    local trian_base = self.hp_rcount/self.max_hp*500
    self:train_attr("wil",trian_base,self.level)
    self:train_attr("con",trian_base*0.6,self.level)
    self.hp_rcount =0
  end
  
  if self.mp_rcount>self.max_mp*0.1 then
    local trian_base = self.mp_rcount/self.max_mp*300
    self:train_attr("wil",trian_base,self.level)
    self:train_attr("mag",trian_base*0.6,self.level)
    self.mp_rcount =0
  end
  
end