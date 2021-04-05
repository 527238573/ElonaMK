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














--搜索一条推挤单位的路径。push_dis推挤距离
local function searchPushRoute(map,x,y,push_dis)
  push_dis = math.max(1,push_dis or 4) --默认4格距离,最小为1
  local max_dis = math.ceil(push_dis)--非整数时，计算影响最远格子距离（比如3.5，那么最远推按4格）
  
  local searched = {} --储存搜索路径信息
  --搜索落脚空间 
  for i=-max_dis,max_dis do
    searched[i] = {} --二维数组
  end
  --remain_dis：剩余可延伸的距离
  --lastdir 上次推挤的方向(1-8)。
  --原点 --连续推挤最多3个单位（4个地格距离）
  searched[0][0] = {remain_dis = push_dis, lastdir = 0}
  
  --增加一个预搜索的地格info路径信息
  --Px py：路径的前一个坐标
  local function addRoadInfo(px,py,remain_dis,lastdir)
    --输入的dir可能不在1~8范围内，在这里规范到1~8内
    lastdir = (lastdir-1)%8 +1
    
    if lastdir %2 ==1 then --斜向移动消耗1.5
      remain_dis = remain_dis-1.5
    else
      remain_dis = remain_dis-1
    end
    
    local fx,fy = c.face_dir(lastdir)
    local tx,ty = fx+px,fy+py --需要添加路径信息的坐标
    local roadinfo = searched[tx][ty] --可能被添加过了
    if roadinfo ==nil or roadinfo.remain_dis<remain_dis then--没有添加过，或当前路径更短
      searched[tx][ty] = {px =px, py = py, lastdir = lastdir,remain_dis =remain_dis} --增加路径信息
    end
  end
  
  
  --搜索节点，顺带添加与此节点链接的路径信息
  local function search_space(dx,dy)
    local sx,sy = dx+x,dy+y --当前地点真实坐标
    local roadinfo = searched[dx][dy] --当前路径信息
    
    
    if roadinfo ==nil then --没有通向此处的路径，可能在墙后面。
      
      return false --直接返回。此格无效
    end
    
    if not (dx==0 and dy ==0) then
      --当前不是起始点
      ----判断这个地格是否是终点
      if not map:can_pass(sx,sy) then
        return false --如果不可通行，直接返回。
      end
      local sunit = map:unit_at(sx,sy)
      if sunit ==nil then
        --可通行，--又没有单位占用的地格，
        --debugmsg("search end:"..sx.." "..sy)
        return true --有路径信息，这就是终点。
      elseif not sunit:canPush() then--所在单位不能被推挤，可能是炮台，或处于霸体等，
        return false --当作墙壁类似处理
      end
    end
    
    
    --现在是可通行，有路径，但是有单位占用。需要准备搜索其他格
    if roadinfo.remain_dis<=0 then 
      return false --搜索距离用完了。不用往下执行
    end
    
    --安排路径点
    if dx==0 and dy ==0 then
      for dir= 1,8 do 
        addRoadInfo(dx,dy,roadinfo.remain_dis,dir)
      end
    else
      --本次的方向只能+0，+1 或-1 或+2-2
      addRoadInfo(dx,dy,roadinfo.remain_dis,roadinfo.lastdir)
      addRoadInfo(dx,dy,roadinfo.remain_dis,roadinfo.lastdir+1)
      addRoadInfo(dx,dy,roadinfo.remain_dis,roadinfo.lastdir-1)
      addRoadInfo(dx,dy,roadinfo.remain_dis,roadinfo.lastdir+2)
      addRoadInfo(dx,dy,roadinfo.remain_dis,roadinfo.lastdir-2)
    end
    return false--当前不是终点，返回。
  end
  
  --开始搜索，从原点开始扫描周围
  for nx,ny in c.closest_xypoint_rnd(0,0,max_dis) do--push_dis=4时是9*9的方框内。够大了
    --debugmsg("search point:"..nx.." "..ny)
    if search_space(nx,ny) then
      --搜索成功，建立路径
      local route = {}
      local sx,sy = nx,ny
      while (not(sx==0 and sy ==0)) do
        local roadinfo = searched[sx][sy]
        table.insert(route,{x = x+sx,y=y+sy})
        sx,sy = roadinfo.px,roadinfo.py
      end
      return route
    end
  end
  
  --没有搜索到,地图挤满了
  return nil
end












--将单位置于X,Y位置，推挤原有xy上的单位。
--strength最远推挤距离。 最小为1，默认为4
--返回false表示仍然有单位重叠
function Map:unitPushPlace(unit,x,y,strength)
  if not self:inbounds(x,y) then --若超出范围
    x =c.clamp(x,0,self.w-1)
    y =c.clamp(y,0,self.h-1)
  end
  strength = strength or 4
  
  if (unit.map == self) then --移动到所在点，排外最末尾。
    self:unitMove(unit,x,y)
  else
    self:unitEnter(unit,x,y)
  end
  
  --如果有单位
  local unit_topush = self:unit_at(x,y)
  while(unit_topush~= unit) do
    
    local route = searchPushRoute(self,x,y,strength)
    if route then
      --路径是从后到前的
      --[[
      local str =""
      for i=1,#route do
        str = str.. string.format("(%d,%d),",route[i].x,route[i].y)
      end
      debugmsg(str)]]
      local delay = 0.2*(#route-1)
      local pushtime =0.4
      
      for i=2,#route do
        local uc = route[i]
        local dc = route[i-1]
        local cu = self:unit_at(uc.x,uc.y)
        
        cu:push_to(dc.x,dc.y,delay,pushtime)
        delay = delay -0.2
        --pushtime =pushtime-0.05
      end
      local last = route[#route]
      unit_topush:push_to(last.x,last.y,delay,pushtime)
    else
      --没有路径
      debugmsg("no room to push unit!")
      return false
    end
    
    unit_topush = self:unit_at(x,y)
  end
  return true
end



