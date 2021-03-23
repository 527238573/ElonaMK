--[[
map.unit表保存所有地格单位 坐标 index =y*self.w+x+1
对同一格子的单位，使用链表链接

--]]
--新加入map。并插入活跃列表
function Map:unitEnter(unit,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  assert(unit.map ==nil,"Unit must leave map before enter map") --进入之前必须处于退出状态
  assert(unit.next_unit ==nil) --进入之前必须处于退出状态
  if unit:is_dead() then
    debugmsg("Warning:dead unit cant enter map")
    return 
  end
  local index = y*self.w+x+1
  local tarU = self.unit[index] --取得地格单位
  if tarU == c.empty then --为空
    self.unit[index] = unit 
  else
    --有链表  因为硬插入的情况多为位移技能途中，所以插入末尾，使之不优先占用格子
    while(tarU.next_unit) do tarU = tarU.next_unit end --移动到尾部
    tarU.next_unit = unit--插入链表尾部
  end
  
  unit.x = x
  unit.y = y
  unit.map = self
  if self.activeUnits[unit]==nil then self.activeUnit_num = self.activeUnit_num+1 end --增加数目
  self.activeUnits[unit] = true
  unit.target  =nil--清除单位引用，防止代入下个地图
end

function Map:unitLeave(unit)
  assert(unit.map ==self,"Incorrect leave map call") --严格检查，必须从正确的地图退出。
  unit.map = nil
  local x = unit.x
  local y = unit.y
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1,"Error:Leaving unit out of map")
  
  
  local index = y*self.w+x+1
  local tarU = self.unit[index]
  if tarU== unit then -- 找到
    if tarU.next_unit ==nil then
      self.unit[index] = c.empty --还原为空
    else
      self.unit[index] = tarU.next_unit --续接链表
    end
  else
    --向后找
    local find_u = false
    while(tarU.next_unit) do
      if tarU.next_unit == unit then
        tarU.next_unit = unit.next_unit --续接链表
        find_u = true
        break
      end
      tarU = tarU.next_unit
    end
    assert(find_u,"Error:Leaving unit not found in map.unit")
  end
  unit.next_unit = nil --不能忘记清除，无论是否有值
  unit.target  =nil --清除单位引用，防止代入下个地图
end

function Map:unitMove(unit,x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) --不检查位置不能调用此函数
  assert(unit.map ==self) --必须已在地图上。
  local sx = unit.x
  local sy = unit.y
  assert(sx>=0 and sx<=self.w-1 and sy>=0 and sy<=self.h-1) --原位置也要检测
  
  --离开原位置 
  local index = sy*self.w+sx+1
  local tarU = self.unit[index]
  if tarU== unit then -- 找到
    if tarU.next_unit ==nil then
      self.unit[index] = c.empty --还原为空
    else
      self.unit[index] = tarU.next_unit --续接链表
    end
  else
    --向后找
    local find_u = false
    while(tarU.next_unit) do
      if tarU.next_unit == unit then
        tarU.next_unit = unit.next_unit --续接链表
        find_u = true
        break
      end
      tarU = tarU.next_unit
    end
    assert(find_u,"Error:Moving unit not found in map.unit")
  end
  unit.next_unit = nil --不能忘记清除，无论是否有值
  
  --进入新位置
  unit.x = x
  unit.y = y
  
  index = y*self.w+x+1
  tarU = self.unit[index]
  if tarU == c.empty then
    self.unit[index] = unit
  else
    --有链表  因为硬插入的情况多为位移技能途中，所以插入末尾，使之不优先占用格子
    while(tarU.next_unit) do tarU = tarU.next_unit end --移动到尾部
    tarU.next_unit = unit
  end
end



--取得定点上的unit
function Map:unit_at(x,y)
  if not (x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) then return nil end
  local unit = self.unit[y*self.w+x+1]
  if unit== c.empty then unit =nil end
  return unit
end


--将新unit放置在x，y位置。
function Map:unitSpawn(unit,x,y,force)
  force = force or true --默认强制生成。
  if not self:inbounds(x,y) then --若超出范围
    x =c.clamp(x,0,self.w-1)
    y =c.clamp(y,0,self.h-1)
  end
  --优先找空位，其次找可通行。再次就是XY原地不可通行。

  local function spawn(nx,ny)
    self:unitEnter(unit,nx,ny)
  end

  local findsec = false --是否找到第二可行
  local sx,sy
  for nx,ny in c.closest_xypoint_rnd(x,y,4) do--9*9的方框内。够大了
    if self:can_pass(nx,ny) then
      if self:unit_at(nx,ny) ==nil then
        --找到合理的放置点
        spawn(nx,ny)
        return true
      else
        if findsec==false then
          findsec = true --找到第二合理点（能行走但有其他单位占据）
          sx,sy = nx,ny
        end
      end
    end
  end
  if force then
    if findsec then
      spawn(sx,sy)
    else
      spawn(x,y)--可能生成至墙内
    end
  end
  return false
end

--从地图上移除。
--注意这个方法不能在单位自循环内使用，self.activeUnits 被改变了。
function Map:unitDespawn(unit)
  self:unitLeave(unit)
  if self.activeUnits[unit]==true then self.activeUnit_num = self.activeUnit_num-1 end --增加数目
  self.activeUnits[unit] = nil
end

function Map:monsterSpawn(unit,x,y,force)
  if unit:hasFlag("NEUTRAL") then
    unit:setFaction("neutral")
  end
  self:unitSpawn(unit,x,y,force)
end
