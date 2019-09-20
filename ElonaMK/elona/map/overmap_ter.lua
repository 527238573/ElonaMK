


function Overmap:can_pass(x,y)
  if not self:inbounds(x,y) then return false end
  local l1id = self.layer1[y*self.w+x+1]
  local l2id = self.layer2[y*self.w+x+1]
  local l1info = data.oter[l1id]
  local l2info = data.oter[l2id]
  return (l1info.pass and l2info.pass) or l2info.flags["BRIDGE"]
end

function Overmap:can_enter(x,y,showmsg)
  return self:can_pass(x,y)
end


function Overmap:getTargetMap(x,y)
  if not self:inbounds(x,y) then error ("targetMap out of bounds")end
  local l2id = self.layer2[y*self.w+x+1]
  local l2info = data.oter[l2id]
  return l2info.targetMap
end

function Overmap:getGroundFlag(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local l1id = self.layer1[y*self.w+x+1]
  local l1info = data.oter[l1id]
  local flags = l1info.flags
  if flags["DIRT"] then return "DIRT" end
  if flags["GRASS"] then return "GRASS" end
  if flags["DESERT"] then return "DESERT" end
  if flags["SNOW"] then return "SNOW" end
  return nil
end

function Overmap:hasFlag(flag,x,y)
  if not self:inbounds(x,y) then return false end
  local l1id = self.layer1[y*self.w+x+1]
  local l2id = self.layer2[y*self.w+x+1]
  local l1info = data.oter[l1id]
  local l2info = data.oter[l2id]
  return l1info.flags[flag] or l2info.flags[flag]
end