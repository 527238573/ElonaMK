local Map = {
    --一些默认值
    w = 10,--宽
    h = 10, --高默认值，
    edge = 0,
    id = "null",
    name = tl("未知之地","Unknown place"),
    saveType = "Map",--注册保存类型
    refreshMiniMap = false, --刷新小地图
    seen ={w=10,sx=1,sy=1,allseen = true,time = 0},
    transparent = {},
    transparent_dirty = true,
    seen_dirty = true,
    lastTurn = 0,--最后次更新的游戏内时间。载入新cmap时使用
    gen_id ="",--map生成及刷新相关函数的id。data.mapgen[gen_id] 
    can_exit = false,--能否在边缘退出。
  }
saveClass["Map"] = Map --注册保存类型
  
Map.__index = Map
Map.__newindex = function(o,k,v)
  if Map[k]==nil then error("使用了Map的意料之外的值。") else rawset(o,k,v) end
end

function Map:preSave()
  self.seen = nil
  self.transparent = nil
  self.transparent_dirty = true
  self.seen_dirty = true
end
function Map:postSave()
  
end

function Map:loadfinish()
  --如果新版增加字段，则需要补充。
  self.transparent_dirty = true
  self.seen_dirty = true
end

local empty = 0--{saveType = 0}
function Map.new(x,y,edge)
  edge = edge or 0 --默认0
  assert(type(x)=="number" and type(y)=="number" and x>3 and y>3)
  assert(edge>=0)
  x = math.floor(x)--保证整数
  y = math.floor(y)
  edge = math.floor(edge) --edge表示多出的无效区域的宽度。
  
  local o = {}
  o.w = x;o.h = y
  o.edge = edge
  o.realw = x+2*edge;o.realh = y+2*edge
  
  
  
  o.ter = {} --地型
  o.block = {} --地面上的物体 树，块等等。 trap合并入这一层。
  o.field = {} --地形效果。烟雾，火，一滩水，立场等等。
  
  o.unit = {} --单位，所站地格之上的。
  o.items = {} -- itemlist.一个list，包含多个物品。
  
  o.transparent={}
  
  o.activeUnit_num = 0--登记活跃单位的数量。
  o.activeUnits = {} --活跃中的单位列表。以key为值。无先后顺序。
  o.activeFields = {} --所有地图上的field。以key为值。无先后顺序。
  --其他npc列表
  
  o.frames = {}--地图上的活动特效。--不会保存
  o.projectiles={} --地图中的弹道投射物等。--不会保存
  
  for i=1,o.realw*o.realh do --无效区域内只有ter 和block，做装饰用。
    o.ter[i] = 1 --默认为index为1 的类型 ，是泥土实地，最基本的ter类型
    o.block[i] = 1 --block为1代表空气，无东西，但block类型里存在这一类型。也就是说block也必须有值
  end
  for i=1,x*y do
    o.field[i] = empty --field是一个list，列出了地形上的所有field。按绘制优先级顺序。empty为空占位
    o.unit[i] = empty --unit指具体的unit。 empty空占位
    o.items[i] = empty --items是物品的列表。
    
    o.transparent[i] = true --
  end
  o.transparent_dirty = false
  o.seen_dirty = true
  setmetatable(o,Map)
  return o
end




function Map:updateRL(dt)
  for unit,_ in pairs(self.activeUnits) do
    unit:updateRL(dt)
  end
  for field,_ in pairs(self.activeFields) do
    field:updateRL(dt)
  end
  
  
  --清理死去或离开地图的unit。 activeUnits的unit只能由这里清理。
  local leaveUnits = {}
  for unit,_ in pairs(self.activeUnits) do
    if unit:is_dead() or not self:inbounds(unit.x,unit.y) or unit.map~=self  then 
      table.insert(leaveUnits,unit)
    end
  end
  for _,unit in ipairs(leaveUnits) do
    self.activeUnits[unit]=nil
    self.activeUnit_num = self.activeUnit_num-1
  end
  
  local leaveFields = {}
  for field,_ in pairs(self.activeFields) do
    if field:is_end() or field.map~=self  then 
      table.insert(leaveFields,field)
    end
  end
  for _,field in ipairs(leaveFields) do
    self.activeFields[field]=nil
  end
  
  
end

function Map:updateAnim(dt)
  for unit,_ in pairs(self.activeUnits) do
    unit:updateAnim(dt)
  end
  self.seen.time = self.seen.time+dt
  self:updateFrames(dt)
  self:updateProjectiles(dt)
end



return Map