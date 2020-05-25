Projectile = {
  noSave = true,--不能保存。
  id ="null",-- frameclip的类型id，表示动画外观类型。projectile没有类型，每次创建属性需要自设
  type = 0,-- AnimClip的类型。等同于frameclip 的type
  
  x=0, --model坐标
  y=0,
  rotation = 0, --旋转。
  speed = 1000,
  flying = false,--飞行中，还是爆炸中。
  
}

Projectile.__index = Projectile



function Projectile.new(id)
  local o= {}
  o.id = id
  o.type = assert(data.frames[id])
  
  o.time = 0--播放位置  为负数表示delay。
  o.life = 0--存活总时间。
  setmetatable(o,Projectile)
  return o
end

function Projectile:getImgQuad()
  local frameT = self.type
  if self.flying then
    return frameT.img,frameT[1] --返回固定第一帧
  end
  --播放爆炸动画，根据时间time
  local frameIndex = math.floor(self.time/frameT.secPerFrame)+2 --从第二帧开始。
  if frameIndex>frameT.frameNum then --
    frameIndex = frameT.frameNum
  end
  return frameT.img,frameT[frameIndex]
end


function Projectile:attack(source_unit,sx,sy,dest_unit,dx,dy,map)
  sx = sx or source_unit.x+source_unit.status.dx/64
  sy = sy or source_unit.y+source_unit.status.dy/64
  map =map or cmap
  self.source_unit = source_unit;self.dest_unit = dest_unit
  self.source_x = sx;self.source_y = sy;
  self.dest_x = dx;self.dest_y = dy;
  
  --补充
  self.shot_dispersion = self.shot_dispersion or 255--散布
  self.max_range =self.max_range or 7
  
  local range = c.dist_2d(sx,sy,dx,dy)
  local missed_by = self.shot_dispersion * 0.01 * range/7;
  --missed_by-- 小于1，理应命中，等于2，命中率1/2，等于3，命中率1/3（不考虑被阻挡和闪避）
  
  local tx,ty = dx,dy --最终射击地点
  
  if missed_by>0 then
    local offset_x = (rnd()-0.5)*missed_by
    local offset_y =  0
    local ra =1 --反转
    if (dx-sx)*(dy-sy)<0 then ra=-1 end --2，4象限反转
    if offset_x>0 then
      offset_y =  ra*(missed_by*0.5 - offset_x)--根据x求出Y
    else
      offset_y = ra*(-missed_by*0.5 - offset_x)
    end
    tx = tx+offset_x
    ty = ty+offset_y
  end
  
  --self.tx = tx;self.ty = ty
  local movex = tx-sx
  local movey = ty-sy
  local realspeed = self.speed/64
  
  local useX = math.abs(movex)>math.abs(movey)
  local moveRange = math.sqrt(movex*movex+movey*movey)
  
  self.speedX = realspeed/moveRange*movex
  self.speedY = realspeed/moveRange*movey
  self.lastAxis = useX and sx or sy
  self.sourceAxis = useX and sx or sy
  self.useX = useX
  
  self.timeFlying = self.max_range/realspeed
  if movex==0 and movey ==0 then self.timeFlying = 0 end --特殊的为0 的情况
  
  --local arct = math.atan2 (self.move_y, self.move_x)
  --debugmsg(" arct:"..arct.." y:"..self.move_y.." x:"..self.move_x)
  self.rotation =   -math.atan2 (movey, movex)
  self:updatePos(self.source_x,self.source_y)
  self.flying =true
  --加入地图
  
  map:addProjectile(self)
end


function Projectile:updatePos(nx,ny)
  self.x = nx*64+32
  self.y = ny*64+64
end

function Projectile:updateAnim(dt,map)
  self.life = self.life+dt
  if not self.flying then self.time = self.time+dt;return end --不在飞行状态只更新动画时间
  
  local speedAxis = self.useX and self.speedX or self.speedY
  local lastA = self.lastAxis
  local nowA = self.lastAxis + speedAxis*dt
  self.lastAxis = nowA
  
  local function nextA(last)
    if speedAxis >0 then 
      return math.floor(last)+1
    else
      return math.ceil(last)-1
    end
  end
  local checkf = speedAxis>0 and  math.floor or math.ceil
  
  while(checkf(nowA)~= checkf(lastA)) do
    local nextaa = nextA(lastA)
    local nexttime = (nextaa-self.sourceAxis)/speedAxis
    local nx,ny,ndx,ndy
    if self.useX then
      nx = nextaa
      ny = self.source_y + nexttime*self.speedY
      ndx = nx
      ndy = math.floor(ny+0.5)
    else
      nx = self.source_x + nexttime*self.speedX
      ny = nextaa
      ndx = math.floor(nx+0.5)
      ndy = ny
    end
    --检测碰撞
    --debugmsg("ndxndy:"..ndx.." "..ndy.."selfxselfy:"..self.x.." "..self.y)
    if self:checkHit(ndx,ndy,map)then
      self:updatePos(nx,ny)--成功碰撞，停在碰撞点
      self.flying = false
      return 
    end
    lastA = nextaa
  end
  local nx,ny
  local nexttime = (nowA-self.sourceAxis)/speedAxis
  if self.useX then
      nx = nowA
      ny = self.source_y + self.life*self.speedY
      
  else
      nx = self.source_x + nexttime*self.speedX
      ny = nowA
  end
  self:updatePos(nx,ny)
  if self.life>self.timeFlying then 
    self.flying = false 
    --debugmsg("selfxselfy:"..self.x.." "..self.y)
  end --飞行超过最大限度，停止飞行
end




function Projectile:isFinish()
  if not self.flying then
    local frameT = self.type
    return self.time>frameT.secPerFrame*(frameT.frameNum-1)
  end
  return false
end


--检查格子，是否击中东西。击中就返回true，停止继续飞行，未击中返回false
function Projectile:checkHit(ndx,ndy,map)
  if not map:inbounds(ndx,ndy) then return false end --飞出边界
  
  local unit =map:unit_at(ndx,ndy)
  if unit then
    if self.source_unit:isHostile(unit) or unit == self.dest_unit then
      --考虑射中
      if unit:check_range_hit(self) then
        return true
      end
    end
  else --为空
    if ndx ==self.dest_x and ndy ==self.dest_y then --射击到原位置
      if math.abs(self.dest_unit.x -ndx)<=1 and math.abs(self.dest_unit.y -ndy)<=1 then
        if rnd()<0.5 then --只要目标单位没有走出1格距离，还是有一半鸡率射中
          if unit:check_range_hit(self) then
            return true
          end
        end
      end
    end
  end
  --地形阻挡。
  local movecost = map:move_cost(ndx,ndy)
  if movecost<0 then--无法通过的地格
    if map:isTranspant(ndx,ndy) then
      if rnd()<0.85 then
        return true  --不可通过，但是可以视野穿过。85%机率挡住
      end
    else
      return true--完全被挡
    end
  end
  if movecost >=120 and math.abs(self.dest_x -ndx)<=1 and math.abs(self.dest_y -ndy)<=1 then --在目标点周围1格范围内，有掩体作用。
    local mv = movecost-100
    local jl = 0 --机率
    if mv<= 80 then 
      jl = mv/80*40  --0-80 最大40机率掩盖射击
    else 
      jl = math.min(40+(mv-80)/3,70)  --上限掩体70几率
    end
    if rnd()<jl/100 then
      return true
    end
  end
  
  return false
  
end