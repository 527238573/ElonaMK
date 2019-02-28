



data.mapgen = {}
require"elona/map/mapgen/Vernis"



local path =love.filesystem.getSourceBaseDirectory().."/ElonaMK/data/map/"

--从地图文件模板创建地图。
function Map.createFromTemplateId(id)
  local file  =  path..id..".lua"
  local template,err = table.loadAdv(file)
  print("load map Template:",template,err)
  io.flush()
  if template==nil then error("load map template failed:"..id)end
  
  --基础复制。
  local newmap = Map.new(template.w,template.h,template.edge)
  newmap:copyFrom(template)
  newmap.id = id
  
  --创建物品。
  for x =0,newmap.w-1 do
    for y= 0,newmap.h-1 do
      local list = template:getItemList(x,y,false)
      if list then
        for i=1,#list.list do
          newmap:spawnItemById(list.list[i].type.id) --创建物品。
        end
      end
    end
  end
  --field不创建。
  if data.mapgen[id] then
    data.mapgen[id](newmap,template)
  end
  return newmap
end