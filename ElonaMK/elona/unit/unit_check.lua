 --视野范围。
function Unit:get_seen_range()
  --受到其他trait debuff影响。失明等
  return 7.9
end

function Unit:seesXY(x,y)
  local range = self:get_seen_range()
  local wanted_range= c.dist_2d(self.x,self.y,x,y)
  if wanted_range>range then return false end
  if self ==p.mc then
    return self.map:isMCSeen(x,y)
  else
    return self.map:seeLine(self.x,self.y,x,y)
  end
end

function Unit:seesUnit(unit)
  if self ==unit then return true end
  if unit.map == self.map then
    return self:seesXY(unit.x,unit.y)
  else
    return false
  end
end



--用于 展示的短名。如 少女
function Unit:getShortName()
  return self.type.name
end
--展示显示的名字。全名，少女 索菲娅 typename +自名字。
function Unit:getName()
  return self.type.name
end

function Unit:getAkaName()
  return "自由微风"
  
end

function Unit:getRaceName()
  return self.type.race.name
  
end

function Unit:getClassName()
  return self.class.name
end

function Unit:getSexName()
  if self.sex_male then
    return tl("男","Male")
  else
    return tl("女","Female")
  end
end

function Unit:getAge()
  return 17
end

function Unit:getHeight()
  return self.type.race.height
end

function Unit:getWeight()
  return self.type.race.weight
end
--获得肖像
function Unit:getPortrait()
  if self.protrait==0 then return data.face.default end
  return self.protrait
end

--状态

--是否能被F1-F4切换操控到
function Unit:canOperate()
  return not self.dead
end

--能否被推动。 --冲刺 击退 击飞 霸体 扎根固定等状态下均不可
function Unit:canPush()
  if self:hasEffect("sprinting") then
    return false
  end
  
  if self:hasEffect("knock_back") then
    return false
  end
  return true
end


--在小队中对队伍负重的贡献。最小为0.
function Unit:getTeamCarryContribution()
  return math.max(0,self:getMaxCarry() - self.inv:getWeight())
end

function Unit:hasFlag(flag)
  return self.type.flags[flag]
end
