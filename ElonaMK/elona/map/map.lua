Map = {
    --一些默认值
    w = 10,--宽
    h = 10, --高默认值，
    edge = 0,
    id = "null",
    name = tl("未知之地","Unknown place"),
    refreshMiniMap = false, --刷新小地图
    squareInfo_dirty = true,
    seen_dirty = true,
    lastTurn = 0,--最后次更新的游戏内时间。载入新cmap时使用
    gen_id ="",--map生成及刷新相关函数的id。data.mapgen[gen_id] 
    can_exit = false,--能否在边缘退出。
  }
local niltable = {
  seen = true, --cache
  transparent = true,--cache
  movecost = true,--cache
  
  unit = true,--临时table
  field = true,--临时table
  items = true,--临时table
  tmp_pathNodes = true,--临时table
  
}
saveMetaType("Map",Map,niltable)--注册保存类型
Map.__newindex = function(o,k,v)
  if Map[k]==nil and niltable[k]==nil then error("使用了Map的意料之外的值。") else rawset(o,k,v) end
end

function Map:preSave()
  self.tmp_pathNodes = nil --删除临时
  self.seen = nil
  self.transparent = nil
  self.movecost = nil
  self.squareInfo_dirty = true
  self.seen_dirty = true
  self:clearFieldLists()
  self:clearItemLists()
end
function Map:postSave()
  
end

function Map:loadfinish()
  --如果新版增加字段，则需要补充。
  self.squareInfo_dirty = true
  self.seen_dirty = true
  self:decodeTerrainCdata()
  self:rebuildUnitGrid()
  self:rebuildFieldGrid()
  self:rebuildItemsGrid()
  
  self:reloadOldVersionTer()
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
  
  --一部分初始化代码放在这里
  Map.initTerAndBlock(o) --ter block
  
  
  o.activeUnit_num = 0--登记活跃单位的数量。
  o.activeUnits = {} --活跃中的单位列表。以key为值。无先后顺序。
  o.activeFieldLists = {} --所有地图上的fieldlist。以key为值。无先后顺序。
  o.allItemLists = {}--已有的itemList
  --其他npc列表
  
  o.frames = {}--地图上的活动特效。--不会保存
  o.projectiles={} --地图中的弹道投射物等。--不会保存
  
  o.squareInfo_dirty = true
  o.seen_dirty = true
  
  setmetatable(o,Map)
  
  o:rebuildUnitGrid()--重建unitGrid
  o:rebuildFieldGrid()--重建fielGrid --地形效果。烟雾，火，一滩水，立场等等。
  o:rebuildItemsGrid()
  return o
end




function Map:updateRL(dt)
  for unit,_ in pairs(self.activeUnits) do
    unit:updateRL(dt)
  end
  for list,_ in pairs(self.activeFieldLists) do
    list:updateRL(dt)
  end
  
  
  --清理fieldlist。不一定需要频繁清理
  self:clearFieldLists()
  
  
end

function Map:updateAnim(dt)
  for unit,_ in pairs(self.activeUnits) do
    unit:updateAnim(dt)
  end
  self.seen.time = self.seen.time+dt
  self:updateFrames(dt)
  self:updateProjectiles(dt)
  
  
  --清理死去或离开地图的unit。 activeUnits的unit只能由这里清理。
  --在这里清理最保险。updateProjectiles可能会杀死一些unit，updateRL不更新就无法清理。
  --清理完成后进入render环节，这里清理了activeUnits里不该绘制的死unit
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
  
end


