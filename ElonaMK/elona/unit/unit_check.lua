 --视野范围。
function Unit:get_seen_range()
  --受到其他trait debuff影响。失明等
  return 7 
end



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



--在小队中对队伍负重的贡献。最小为0.
function Unit:getTeamCarryContribution()
  return math.max(0,self:getMaxCarry() - self.inv:getWeight())
end

