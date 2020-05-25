

function Map:inbounds(x,y)
  return x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1
end

function Map:inbounds_edge(x,y)
  return x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1
end

function Map:inbounds_real(x,y)
  return x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1
end



function Map:copyFrom(omap)
  if getmetatable(omap) ~= Map then
    error("copy map error")
  end
  self.transparent_dirty = true
  
  self.id =omap.id
  for x = -self.edge,self.w+self.edge-1 do
    for y = -self.edge,self.h+self.edge-1 do
      if omap:inbounds_edge(x,y) then
        self:setTer(omap:getTer(x,y),x,y)
        self:setBlock(omap:getBlock(x,y),x,y)
      end
    end
  end
  --[[
  for x = 0,self.w-1 do
    for y = 0,self.h-1 do
      if omap:inbounds(x,y) then
        
      end
    end
  end
  --]]
  
end


--坐标，0，0为左下角。向上是Y正，向右是X正
function Map:getTer(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.ter[y*self.realw+x+1]
end

function Map:setTer(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.ter[y*self.realw+x+1] = index
end

function Map:setTer_real(index,x,y)
  assert(x>=0 and x<=self.realw-1 and y>=0 and y<=self.realh-1)
  self.ter[y*self.realw+x+1] = index
end


function Map:getBlock(x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  return self.block[y*self.realw+x+1]
end

function Map:setBlock(index,x,y)
  assert(x>=-self.edge and x<=self.w+self.edge-1 and y>=-self.edge and y<=self.h+self.edge-1)
  x = x+self.edge
  y= y+self.edge
  self.block[y*self.realw+x+1] = index
  self.transparent_dirty = true
end

function Map:getAltitude(x,y)
  local bid = self:getBlock(x,y)
  return data.block[bid].altitude
end




function Map:can_pass(x,y)
  if not self:inbounds(x,y) then return false end
  x = x+self.edge
  y= y+self.edge
  local tid = self.ter[y*self.realw+x+1]
  local bid = self.block[y*self.realw+x+1]
  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  return binfo.pass
end


function Map:move_cost(x,y)
  if not self:inbounds(x,y) then return -1 end
  x = x+self.edge
  y= y+self.edge
  local tid = self.ter[y*self.realw+x+1]
  local bid = self.block[y*self.realw+x+1]
  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  --if bid==nil then error("x,y:"..x.." "..y) end
  
  if not binfo.pass then return -1 end
  local cost = tinfo.move_cost + binfo.move_cost
  return cost
end

--CONTAINER
--LOCKED --
function Map:hasFlag(flag,x,y)
  
  
end
