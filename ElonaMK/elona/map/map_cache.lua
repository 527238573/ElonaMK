

function Map:buildTransparentCache()
  if not self.transparent_dirty then return end
  if self.transparent==nil then self.transparent = {} end
  local transparent = self.transparent
  local w = self.w
  local h=  self.h
  for y=0,h-1 do
    for x=0,w-1 do
      local binfo = data.block[self:getBlock(x,y)]
      transparent[y*w+x+1] = binfo.transparent
      --添加field的效果
      --if not binfo.transparent then   debugmsg("id:"..tostring(binfo.id).."trans:"..tostring(binfo.transparent)) end
    end
  end
  self.transparent_dirty = false
  self.seen_dirty = true
end

function Map:isTranspant(x,y)
  if not self:inbounds(x,y) then return false end
  return self.transparent[y*self.w+x+1]
end

function Map:buildSeenCache()
  self:buildTransparentCache()
  local range = p.mc.get_seen_range()
  local ox = p.mc.x
  local oy = p.mc.y
  local changeTime = 100/p.mc:getSpeed()/c.timeSpeed 
  if (not self.seen_dirty) and self.seen.range ==range and self.seen.ox ==ox and self.seen.oy ==oy then return end
  local newSeen = {}
  newSeen.range = range
  newSeen.ox = ox
  newSeen.oy = oy
  newSeen.sx = ox-range
  newSeen.sy = oy-range
  newSeen.changeTime = changeTime
  local seenw = range*2+1
  newSeen.w = seenw
  for i=1,seenw*seenw do
    newSeen[i] = false --全设为不可见先。
  end
  local orginx = range
  local orginy = range
  
  local function seethrough(x,y) 
    local dx = x -orginx
    local dy = y -orginy
    local cansee = self:isTranspant(ox+dx,oy+dy)
    --if not cansee then 
    --  print("not see :x:",x,"y:",y,"dx",dx,"dy",dy,"ox",ox,"oy",oy)
    --  io.flush()
    --end
    return cansee
  end
  
  local limit = (range+1.1)*(range+1.1)
  local function see(x,y)
    local dx = x -orginx
    local dy = y -orginy
    if dx*dx +dy*dy <=limit then
      newSeen[y*seenw +x+1]  =true
    end
  end
  see(orginx,orginy) --使原点可见。
  
  local function castLight(xdx,xdy,ydx,ydy,row,startangle,endangle)
    startangle = startangle or 0
    endangle = endangle or 1
    if startangle>=endangle then return end
    row = row or 1
    for dx = row,range,1 do
      local row_unstart = true
      local current_transparency = false
      for dy = 0,dx,1 do
        local realx = orginx+dx*xdx +dy*ydx
        local realy = orginy+dx*xdy +dy*ydy
        local trailing_angle = (dy-0.5)/(dx)
        local self_angle = (dy)/(dx)
        if trailing_angle>=endangle then break end
        if self_angle<=endangle and self_angle>=startangle then --计算可见性。
          see(realx,realy)
        end
        local new_transparency = seethrough(realx,realy)
        if row_unstart then   --确定本列第一个状态。
          row_unstart = false
          current_transparency = new_transparency
        end
        if new_transparency ~= current_transparency then
          if current_transparency ==true then
            castLight(xdx,xdy,ydx,ydy,dx+1,startangle,trailing_angle)
          end
          if trailing_angle>startangle then startangle = trailing_angle  end --起始角度上抬。
          current_transparency = new_transparency --转换到新的
        end
      end --dy结束
      if current_transparency ==false then return end --结束时候不可见。不循环下一层。
    end--dx结束
  end
  if range >=1 then --如果range 为0，不用投射。
    castLight(1,0,0,1)
    castLight(1,0,0,-1)
    castLight(0,1,1,0)
    castLight(0,1,-1,0)
    castLight(-1,0,0,1)
    castLight(-1,0,0,-1)
    castLight(0,-1,1,0)
    castLight(0,-1,-1,0)
  end
  
  newSeen.time = 0
  self.seen = newSeen
  self.seen_dirty = false
end

function Map:isMCSeen(x,y,lastseen)
  if not self:inbounds(x,y) then return false end
  local seen = lastseen or self.seen
  if seen.allseen then return true end
  x= x-seen.sx
  y= y-seen.sy
  if x>=0 and x<=seen.w-1 and y>=0 and y<=seen.w-1 then --必须在矩阵的范围内
    return seen[y*seen.w+x+1]
  else
    return false
  end
end


