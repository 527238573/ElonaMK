--单位的势力所属。判断敌对/友善关系。

local factionList = 
{                           --1.player  2.ally 3.neutral 4.neifia 5.wild 6.neutral_enemy  
  [1] = {id = "player",           1,      1,       0,        -1,     -1,       -1,        },
  [2] = {id = "ally",             1,      1,       0,        -1,     -1,        0,        },
  [3] = {id = "neutral",          0,      0,       1,        -1,     -1,        0,        },
  [4] = {id = "nefia",            -1,     -1,      -1,        1,     -1,       -1,       },
  [5] = {id = "wild",             -1,     -1,      -1,       -1,      0,       -1,       },
  [6] = {id = "neutral_enemy",    -1,     0,       1,        -1,     -1,        1,       },
}

local idToIndex = {}



function Unit.initUnitFactions()
  for i=1,#factionList do
    idToIndex[factionList[i].id]=i
  end
end


function Unit:setFaction(id)
  local faction_index = idToIndex[id]
  assert(faction_index)
  self.faction = faction_index
end

function Unit:getFaction()
  return factionList[self.faction].id
end


--是否盟友。中立的不算盟友，只是不攻击
function Unit:isFriendly(unit)
  if unit ==self then return true end --自己是友
  local selftype = factionList[self.faction]
  return selftype[unit.faction]>0
end
--是否是敌人。
function Unit:isHostile(unit)
   if unit ==self then return false end --自己判断
  local selftype = factionList[self.faction]
  return selftype[unit.faction]<0
end

function Unit:factionRel(unit)
  local selftype = factionList[self.faction]
  return selftype[unit.faction]
end

function Unit:isInEnemyFaction()
  return self.faction>3
end

function Unit:isInPlayerFaction()
  return self.faction==1
end

--再队伍中，播放信息的角色
function Unit:isInPlayerTeam()
  for i=1,#p.team do
    if self==p.team[i] then return true end
  end
  return false
  --return self==p.team[1] or self==p.team[2] or self==p.team[3] or self==p.team[4]
end
