
MapFactory = {}
data.mapgen = {}
require"elona/map/mapgen/Vernis"
require"elona/map/mapgen/field"


local path =c.source_dir.."data/map/"

--从地图文件模板创建地图。
function MapFactory.createFromTemplateId(id)
  local file  =  path..id..".bsr"
  local template,err = c.LoadFile(file)
  print("load map Template:",template,err)
  io.flush()
  if template==nil then error("load map template failed:"..id)end
  --基础复制。
  local newmap = Map.new(template.w,template.h,template.edge)
  newmap:copyFrom(template)
  newmap.id = id
  newmap.lastTurn = p.calendar:getTurnpast()--记录创建时间为最后更新时间
  --创建物品。
  for x =0,newmap.w-1 do
    for y= 0,newmap.h-1 do
      local list = template:getItemList(x,y,false)
      if list then
        for i=1,#list.list do
          newmap:spawnItemById(list.list[i].type.id,x,y) --创建物品。
        end
      end
    end
  end
  --field不创建。
  newmap:buildSquareInfoCache()--刷新cache
  
  newmap.gen_id = id --必须与模板的id一致。
  local gen_t = data.mapgen[newmap.gen_id]
  if gen_t then
    if gen_t.generate then
      gen_t.generate(newmap,template)
    end
  else
    debugmsg("warning:no gen_t map："..id)
  end
  newmap.squareInfo_dirty = true
  newmap:buildSquareInfoCache()--刷新cache
  return newmap
end

local overmapPath =c.source_dir.."data/overmap/"
function  MapFactory.createOverMapFromTemplateId(id)
  local file  =  overmapPath..id..".bsr"
  local template,err = c.LoadFile(file)
  print("load overmap Template:",template,err)
  io.flush()
  if template==nil then error("load overmap template failed:"..id)end
  return template
end


--创建野外地图。
function MapFactory.createWmapField(x,y,id)
  assert(x>=0 and x<=wmap.w-1 and y>=0 and y<=wmap.h-1)
  local newmap = Map.new(42,28,3) --野外固定大小。
  newmap:buildSquareInfoCache()--刷新cache
  newmap.id = id
  newmap.lastTurn = p.calendar:getTurnpast()--记录创建时间为最后更新时间
  local gtype = wmap:getGroundFlag(x,y)
  if gtype =="DIRT" then
    newmap.gen_id = "dirt"
  elseif gtype =="GRASS" then
    newmap.gen_id = "grass"
    --newmap.gen_id = "grass"
  elseif gtype =="DESERT" then
    newmap.gen_id = "desert"
  elseif gtype =="SNOW" then
    newmap.gen_id = "snowland"
  else
    newmap.gen_id = "dirt"
  end
  
  local gen_t = data.mapgen[newmap.gen_id]
  if gen_t.generate then
    gen_t.generate(newmap,wmap,x,y)
  end
  newmap.squareInfo_dirty = true
  newmap:buildSquareInfoCache()--刷新cache
  return newmap
end