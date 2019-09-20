

local wmapCache ={}--储存wmap坐标到map的映射。
local mapBuffer ={}--mapid到map的映射。


function Map.initMapBuffer()
  
  
end





--现阶段不可用，所有都返回nil
local function unserialize_map(id)
  return nil
end


local function get_existing_idmap(id)
  local map = mapBuffer[id]
  if map==nil then
    map = unserialize_map(id)
  end
  return map
end



local function get_existing_wmap(x,y)
  if x<0 or x>wmap.w-1 or y<0 or y>wmap.h-1 then return nil end --超出边界不要
  local map = wmapCache[y*wmap.w+x+1] --登记的快捷入口。
  if map~=nil then return map end --从快捷入口里找。
  --找不到，获得这个格子的id，从id里找
  local id = wmap:getTargetMap(x,y)--取得特定id
  if id==nil then 
    id = string.format("wmap%dx%d",x,y)--没有则是普通野外地形，自建id。
  end
  map =get_existing_idmap(id) --使用id找或读取。
  if map~=nil then
    wmapCache[y*wmap.w+x+1] = map --如果找到，加入快捷入口。
  end
  return map,id --返回，没找到的话，根据id创建新地图。
end




function Map.getrOrCreateWmapSquare(x,y)
  local map,id = get_existing_wmap(x,y)
  if map~=nil then return map end
  local isField = wmap:getTargetMap(x,y)==nil
  if isField then
    map = Map.createWmapField(x,y,id)
  else
    map = Map.createFromTemplateId(id)
  end
  wmapCache[y*wmap.w+x+1] = map
  mapBuffer[id] = map
  return map
end

function Map.getOrCreateIdmap(id)
  local map = get_existing_idmap(id)
  if map~=nil then return map end
  map = Map.createFromTemplateId(id)
  mapBuffer[id] = map
  return map
end


