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
    return self.map:seeLine(self.fx,self.fy,x,y)
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

--展示显示的名字。
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

-- zanding
function Unit:is_dead()
  return self.hp<=0 
end

function Unit:is_alive()
  return self.hp>0 
end
--是否能被F1-F4切换操控到
function Unit:canOperate()
  return self.hp>0  
end


function Unit:getHPRate()
  return math.min(1,math.max(0,self.hp/self.max_hp))
end
function Unit:getMPRate()
  return math.min(1,math.max(0,self.mp/self.max_mp))
end

--在小队中对队伍负重的贡献。最小为0.
function Unit:getTeamCarryContribution()
  return math.max(0,self:getMaxCarry() - self.inv:getWeight())
end

function Unit:hasFlag(flag)
  return self.type.flags[flag]
end

--检查target是否合法，不合法就清楚target返回false，合法返回true。 可能更新允许版。
function Unit:checkTarget(banHostile,banFriend,banGound)
  if self.target==nil then return false end
  if self.target.unit then
    local tu = self.target.unit
    if self:seesUnit(tu) then
      if banHostile and self:isHostile(tu) then
        self.target = nil
        return false
      end
      if banFriend and self:isFriendly(tu) then
        self.target = nil
        return false
      end
      --hostile等
      return true
    end
  elseif self.target.x then
    if (not banGound )and self:seesXY(self.target.x,self.target.y) then
      return true
    end
  end
  self.target = nil
  return false
end