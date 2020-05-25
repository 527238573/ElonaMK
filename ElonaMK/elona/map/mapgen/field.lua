
--野外地形生成设置
local dirt = {}
local grass = {}
local desert = {}
local snowland = {}
--bank
data.mapgen.dirt = dirt
data.mapgen.grass = grass
data.mapgen.desert = desert
data.mapgen.snowland = snowland


--提前声明
local addDeadTree
local addFlower
local addPlant
local addRoad
local generateMonster



function dirt.generate(newmap,ovmap,x,y)
  newmap.name = tl("野外","Wilderness")
  newmap.can_exit = true
  rawset(newmap,"wmap_cord",{x,y})
  --map 生成设置。
  --通用套用
  local ti = data.terIndex
  local bi = data.blockIndex
  local pick = c.getWeightValue
  
  local tree_lv = 0
  if ovmap:hasFlag("FOREST",x,y) then
    tree_lv =2
  elseif ovmap:hasFlag("TREE",x,y) then
    tree_lv =1
  end
  --群簇地表
  local group_weight,size_weight,group_num
  if tree_lv ==0 then
    group_weight =  c.weightT{[ti["rock"]]=3,}
    size_weight = c.weightT{[1]=3,[2]=4,[3] =5,[4]=3,[5]=1}
    group_num = rnd(10,13)
  elseif tree_lv==1 then
    group_weight =  c.weightT{[ti["rock"]]=1,[ti["grass"]]=3,[ti["ngrass"]]=9}
    size_weight = c.weightT{[3]=5,[4]=6,[5]=3,[6]=2}
    group_num = rnd(10,13)
  else
    group_weight =  c.weightT{[ti["grass"]]=1,[ti["ngrass"]]=4}
    size_weight = c.weightT{[3]=3,[4]=3,[5]=5,[6]=3}
    group_num = rnd(15,19)
  end
  for i=1,group_num do
    local size = pick(size_weight)
    local gtype = pick(group_weight)
    local gx,gy = rnd(0,newmap.realw-1),rnd(0,newmap.realh-1)
    for nx,ny in c.closest_xypoint_first(gx,gy,size) do
      if newmap:inbounds_real(nx,ny) then
        if rnd()<= (size -c.dist_2d(nx,ny,gx,gy))/size then newmap.ter[ny*newmap.realw+nx+1] = gtype end
      end
    end
  end
  --block
  if tree_lv ==0 then
  local block_w =  c.weightT{[bi["gallet1"]]=200,[bi["gallet2"]]=200,[bi["stone"]]=120,[bi["rock_m"]]=50,[bi["bush1"]]=5,[bi["bush2"]]=2,[bi["bush3"]]=2,
                              [bi["grass1"]]=2,[bi["grass2"]]=3,[bi["grass3"]]=3,[bi["grasscluster"]]=3,[bi["weed1"]]=1,[bi["weed2"]]=1,[bi["weed3"]]=1,
                              [bi["blossom1"]]=3,
                              [bi["vegetation1"]]=16,[bi["vegetation2"]]=5,[bi["vegetation3"]]=16,[bi["vegetation4"]]=5,
                              [bi["sapling"]]=4,[bi["tree1"]]=1,[bi["tree2"]]=1,[bi["tree3"]]=3,[bi["withered_tree"]]=15,
                              [bi["stump"]]=12,[bi["cactus"]]=20
                              }
  for i=1,newmap.realw*newmap.realh do if rnd()<0.06 then newmap.block[i] = pick(block_w) end end
  elseif tree_lv==1 then
  local block_w =  c.weightT{[bi["gallet1"]]=200,[bi["gallet2"]]=200,[bi["stone"]]=100,[bi["bush1"]]=150,[bi["bush2"]]=100,[bi["bush3"]]=100,
                              [bi["grass1"]]=20,[bi["grass2"]]=20,[bi["grass3"]]=20,[bi["grasscluster"]]=3,[bi["weed1"]]=5,[bi["weed2"]]=5,[bi["weed3"]]=5,
                              [bi["flower"]]=10,[bi["blossom1"]]=10,[bi["blossom2"]]=5,[bi["blossom3"]]=3,[bi["blossom4"]]=1,
                              [bi["vegetation1"]]=15,[bi["vegetation2"]]=5,[bi["vegetation3"]]=15,[bi["vegetation4"]]=5,[bi["rock_m"]]=30,
                              [bi["sapling"]]=80,[bi["tree1"]]=60,[bi["tree2"]]=60,[bi["tree3"]]=60,[bi["withered_tree"]]=50,
                              [bi["pine"]]=80,[bi["fruiter"]]=80,[bi["stump"]]=60,[bi["cactus"]]=20
                              }
      for i=1,newmap.realw*newmap.realh do if rnd()<0.12 then newmap.block[i] = pick(block_w) end end
  else--tree_lv==2
  local block_w =  c.weightT{[bi["gallet1"]]=90,[bi["gallet2"]]=90,[bi["stone"]]=50,[bi["bush1"]]=200,[bi["bush2"]]=100,[bi["bush3"]]=100,
                              [bi["grass1"]]=20,[bi["grass2"]]=20,[bi["grass3"]]=20,[bi["grasscluster"]]=1,[bi["weed1"]]=2,[bi["weed2"]]=2,[bi["weed3"]]=3,
                              [bi["flower"]]=20,[bi["blossom1"]]=20,[bi["blossom2"]]=10,[bi["blossom3"]]=5,[bi["blossom4"]]=3,
                              [bi["vegetation1"]]=15,[bi["vegetation2"]]=4,[bi["vegetation3"]]=15,[bi["vegetation4"]]=4,[bi["rock_m"]]=20,
                              [bi["sapling"]]=160,[bi["tree1"]]=80,[bi["tree2"]]=80,[bi["tree3"]]=80,[bi["withered_tree"]]=80,
                              [bi["pine"]]=100,[bi["fruiter"]]=80,[bi["stump"]]=60,
                              }
      for i=1,newmap.realw*newmap.realh do if rnd()<0.24 then newmap.block[i] = pick(block_w) end end
  end
  
  if ovmap:hasFlag("STUMP",x,y) then
    local tree_w =  c.weightT{[bi["stump"]]=80,[bi["withered_tree"]]=5,[bi["tree1"]]=1,[bi["tree2"]]=1,[bi["tree3"]]=1}
      for i=1,newmap.realw*newmap.realh do if newmap.block[i] ==1 and rnd()<0.03 then newmap.block[i] = pick(tree_w) end end
  end
  addDeadTree(newmap,ovmap,x,y,false)
  addPlant(newmap,ovmap,x,y,false)
  addFlower(newmap,ovmap,x,y,false)
  addRoad(newmap,ovmap,x,y,true)
  
  generateMonster(newmap,ovmap,x,y)
end

function grass.generate(newmap,ovmap,x,y)
  newmap.name = tl("野外","Wilderness")
  newmap.can_exit = true
  rawset(newmap,"wmap_cord",{x,y})
  --map 生成设置。
  
  --通用套用
  local ti = data.terIndex
  local bi = data.blockIndex
  local pick = c.getWeightValue
  
  local tree_lv = 0
  if ovmap:hasFlag("FOREST",x,y) then
    tree_lv =2
  elseif ovmap:hasFlag("TREE",x,y) then
    tree_lv =1
  end
  
  --生成地表
  local baseground = ti["ngrass"]
  if tree_lv >1 then baseground = ti["dgrass"] end
  for i=1,newmap.realw*newmap.realh do 
    newmap.ter[i] = baseground 
  end
  --群簇地表
  local group_weight,size_weight,group_num
  if tree_lv ==0 then
    group_weight =  c.weightT{[ti["grass"]]=2,[ti["dgrass"]]=3,[ti["dirt"]]=1}
    size_weight = c.weightT{[2]=3,[3]=4,[4]=3,[5]=1}
    group_num = rnd(15,19)
  elseif tree_lv==1 then
    group_weight =  c.weightT{[ti["grass"]]=1,[ti["dgrass"]]=3}
    size_weight = c.weightT{[3]=3,[4]=3,[5]=5,[9]=3}
    group_num = rnd(10,13)
  else
    group_weight =  c.weightT{[ti["grass"]]=1,[ti["ngrass"]]=4}
    size_weight = c.weightT{[3]=3,[4]=3,[5]=5,[6]=3}
    group_num = rnd(10,13)
  end
  for i=1,group_num do
    local size = pick(size_weight)
    local gtype = pick(group_weight)
    local gx,gy = rnd(0,newmap.realw-1),rnd(0,newmap.realh-1)
    for nx,ny in c.closest_xypoint_first(gx,gy,size) do
      if newmap:inbounds_real(nx,ny) then
        if rnd()<= (size -c.dist_2d(nx,ny,gx,gy))/size then newmap.ter[ny*newmap.realw+nx+1] = gtype end
      end
    end
  end
  --block
  if tree_lv ==0 then
  local block_w =  c.weightT{[bi["gallet1"]]=400,[bi["gallet2"]]=400,[bi["stone"]]=50,[bi["bush1"]]=400,[bi["bush2"]]=170,[bi["bush3"]]=170,
                              [bi["grass1"]]=220,[bi["grass2"]]=140,[bi["grass3"]]=140,[bi["grasscluster"]]=10,[bi["weed1"]]=10,[bi["weed2"]]=10,[bi["weed3"]]=20,
                              [bi["flower"]]=30,[bi["blossom1"]]=70,[bi["blossom2"]]=40,[bi["blossom3"]]=20,[bi["blossom4"]]=10,
                              [bi["vegetation1"]]=40,[bi["vegetation2"]]=10,[bi["vegetation3"]]=40,[bi["vegetation4"]]=10,[bi["rock_m"]]=10,
                              [bi["sapling"]]=80,[bi["tree1"]]=30,[bi["tree2"]]=30,[bi["tree3"]]=30,[bi["withered_tree"]]=40,
                              [bi["pine"]]=2,[bi["fruiter"]]=30,[bi["stump"]]=50,
                              }
  for i=1,newmap.realw*newmap.realh do if rnd()<0.1 then newmap.block[i] = pick(block_w) end end
  elseif tree_lv==1 then
  local block_w =  c.weightT{[bi["gallet1"]]=200,[bi["gallet2"]]=200,[bi["stone"]]=30,[bi["bush1"]]=400,[bi["bush2"]]=150,[bi["bush3"]]=150,
                              [bi["grass1"]]=80,[bi["grass2"]]=60,[bi["grass3"]]=60,[bi["grasscluster"]]=5,[bi["weed1"]]=5,[bi["weed2"]]=5,[bi["weed3"]]=5,
                              [bi["flower"]]=20,[bi["blossom1"]]=50,[bi["blossom2"]]=30,[bi["blossom3"]]=10,[bi["blossom4"]]=5,
                              [bi["vegetation1"]]=20,[bi["vegetation2"]]=5,[bi["vegetation3"]]=20,[bi["vegetation4"]]=5,[bi["rock_m"]]=3,
                              [bi["sapling"]]=180,[bi["tree1"]]=60,[bi["tree2"]]=60,[bi["tree3"]]=60,[bi["withered_tree"]]=50,
                              [bi["pine"]]=80,[bi["fruiter"]]=80,[bi["stump"]]=60,
                              }
      for i=1,newmap.realw*newmap.realh do if rnd()<0.15 then newmap.block[i] = pick(block_w) end end
  else--tree_lv==2
  local block_w =  c.weightT{[bi["gallet1"]]=100,[bi["gallet2"]]=100,[bi["stone"]]=10,[bi["bush1"]]=200,[bi["bush2"]]=100,[bi["bush3"]]=100,
                              [bi["grass1"]]=50,[bi["grass2"]]=30,[bi["grass3"]]=30,[bi["grasscluster"]]=1,[bi["weed1"]]=3,[bi["weed2"]]=3,[bi["weed3"]]=5,
                              [bi["flower"]]=30,[bi["blossom1"]]=30,[bi["blossom2"]]=20,[bi["blossom3"]]=7,[bi["blossom4"]]=5,
                              [bi["vegetation1"]]=15,[bi["vegetation2"]]=4,[bi["vegetation3"]]=15,[bi["vegetation4"]]=4,[bi["rock_m"]]=2,
                              [bi["sapling"]]=160,[bi["tree1"]]=80,[bi["tree2"]]=80,[bi["tree3"]]=80,[bi["withered_tree"]]=50,
                              [bi["pine"]]=100,[bi["fruiter"]]=80,[bi["stump"]]=60,
                              }
      for i=1,newmap.realw*newmap.realh do if rnd()<0.27 then newmap.block[i] = pick(block_w) end end
  end
  
  if ovmap:hasFlag("STUMP",x,y) then
    local tree_w =  c.weightT{[bi["stump"]]=80,}
      for i=1,newmap.realw*newmap.realh do if newmap.block[i] ==1 and rnd()<0.04 then newmap.block[i] = pick(tree_w) end end
  end
  addDeadTree(newmap,ovmap,x,y,false)
  addPlant(newmap,ovmap,x,y,false)
  addFlower(newmap,ovmap,x,y,false)
  addRoad(newmap,ovmap,x,y,false)
  
  generateMonster(newmap,ovmap,x,y)
end

function desert.generate(newmap,ovmap,x,y)
  newmap.name = tl("野外","Wilderness")
  newmap.can_exit = true
  rawset(newmap,"wmap_cord",{x,y})
  --map 生成设置。
  --通用套用
  local ti = data.terIndex
  local bi = data.blockIndex
  local pick = c.getWeightValue
  
  local tree_lv = 0
  if ovmap:hasFlag("FOREST",x,y) then
    tree_lv =2
  elseif ovmap:hasFlag("TREE",x,y) then
    tree_lv =1
  end
  
  --生成地表
  local baseground = ti["desert"]
  debugmsg("base:.."..tostring(baseground))
  for i=1,newmap.realw*newmap.realh do 
    newmap.ter[i] = baseground 
  end
  --block
  
  local block_w =  c.weightT{[bi["gallet1"]]=3,[bi["gallet2"]]=3,[bi["stone"]]=80,[bi["rock_m"]]=20,
                              [bi["weed1"]]=15,[bi["weed2"]]=15,[bi["weed3"]]=15,
                              [bi["blossom1"]]=20,[bi["blossom2"]]=5,
                              [bi["vegetation1"]]=20,[bi["vegetation2"]]=10,[bi["vegetation3"]]=40,[bi["vegetation4"]]=20,
                              [bi["withered_tree"]]=15,[bi["stump"]]=15,[bi["cactus"]]=60
                              }
  for i=1,newmap.realw*newmap.realh do if rnd()<0.06 then newmap.block[i] = pick(block_w) end end
  
  
  if ovmap:hasFlag("STUMP",x,y) then
    local tree_w =  c.weightT{[bi["stump"]]=13,[bi["withered_tree"]]=4}
      for i=1,newmap.realw*newmap.realh do if newmap.block[i] ==1 and rnd()<0.03 then newmap.block[i] = pick(tree_w) end end
  end
  addDeadTree(newmap,ovmap,x,y,false)
  addPlant(newmap,ovmap,x,y,false)
  
  generateMonster(newmap,ovmap,x,y)
end

function snowland.generate(newmap,ovmap,x,y)
  newmap.name = tl("野外","Wilderness")
  newmap.can_exit = true
  rawset(newmap,"wmap_cord",{x,y})
  --map 生成设置。
  local ti = data.terIndex
  local bi = data.blockIndex
  
  local tree_lv = 0
  if ovmap:hasFlag("FOREST",x,y) then
    tree_lv =2
  elseif ovmap:hasFlag("TREE",x,y) then
    tree_lv =1
  end
  
  --生成地表
  local baseground = ti["snow"]
  for i=1,newmap.realw*newmap.realh do 
    newmap.ter[i] = baseground 
  end
  --block
  local block_w =  c.weightT{[bi["road_snow1"]]=50,[bi["road_snow2"]]=50,[bi["road_snow3"]]=50,[bi["road_snow4"]]=50,[bi["road_snow5"]]=50,[bi["road_snow6"]]=50,
                              [bi["plant_snow1"]]=80,[bi["plant_snow2"]]=80,[bi["plant_snow3"]]=80,[bi["flower_snow1"]]=20,[bi["flower_snow2"]]=20,[bi["flower_snow3"]]=20,
                              [bi["vegetation_snow1"]]=220,[bi["vegetation_snow2"]]=220,[bi["vegetation_snow3"]]=220,[bi["blossom_snow1"]]=120,[bi["bush_snow"]]=80,
                              [bi["stone_snow"]]=220,[bi["boulder"]]=150,[bi["snow_big_rock"]]=50,[bi["snow_pile"]]=5,[bi["snowball1"]]=180,[bi["snowball2"]]=180,
                              [bi["ice_pool"]]=30,[bi["snow_dead_wood"]]=60,[bi["stump_snow"]]=60,[bi["stump"]]=50,
                              [bi["withered_tree_snow"]]=60,[bi["pine_snow"]]=60,
                              }
  for i=1,newmap.realw*newmap.realh do if rnd()<0.06 then newmap.block[i] = pick(block_w) end end
  --block
  if tree_lv==1 then
    local tree_w =  c.weightT{[bi["snow_dead_wood"]]=10,[bi["stump_snow"]]=60,[bi["stump"]]=30,[bi["withered_tree_snow"]]=80,[bi["pine_snow"]]=260,}
      for i=1,newmap.realw*newmap.realh do if rnd()<0.02 then newmap.block[i] = pick(tree_w) end end
  elseif tree_lv==2 then
    local tree_w =  c.weightT{[bi["snow_dead_wood"]]=10,[bi["stump_snow"]]=30,[bi["stump"]]=10,[bi["withered_tree_snow"]]=60,[bi["pine_snow"]]=220,}
      for i=1,newmap.realw*newmap.realh do if rnd()<0.08 then newmap.block[i] = pick(tree_w) end end
  end
  
  if ovmap:hasFlag("STUMP",x,y) then
    local tree_w =  c.weightT{[bi["snow_dead_wood"]]=1,[bi["stump_snow"]]=13,[bi["stump"]]=7,[bi["withered_tree_snow"]]=2,[bi["pine_snow"]]=2}
      for i=1,newmap.realw*newmap.realh do if newmap.block[i] ==1 and rnd()<0.04 then newmap.block[i] = pick(tree_w) end end
  end
  addDeadTree(newmap,ovmap,x,y,true)
  addPlant(newmap,ovmap,x,y,true)
  addFlower(newmap,ovmap,x,y,true)
  addRoad(newmap,ovmap,x,y,false)
  
  generateMonster(newmap,ovmap,x,y)
end


function addDeadTree(newmap,ovmap,x,y,isSnow)
  local ti = data.terIndex
  local bi = data.blockIndex
  if ovmap:hasFlag("DEAD_TREE",x,y) then
    local wt
    if isSnow then
      wt =  c.weightT{[bi["snow_dead_wood"]]=1,[bi["withered_tree_snow"]]=20,}
    else
      wt =  c.weightT{[bi["stump"]]=1,[bi["withered_tree"]]=15}
    end
    for i=1,newmap.realw*newmap.realh do if newmap.block[i] ==1 and rnd()<0.03 then newmap.block[i] = pick(wt) end end
  end
  
  
  
end
function addFlower(newmap,ovmap,x,y,isSnow)
  local flower_lv = 0
  if ovmap:hasFlag("MORE_FLOWER",x,y) then 
    flower_lv =2
  elseif ovmap:hasFlag("FLOWER",x,y) then 
    flower_lv =1
  else
    return
  end
  
  local ti = data.terIndex
  local bi = data.blockIndex
  local group_weight,size_weight,group_num
  if isSnow then
    local wt1 = c.weightT{[bi["flower_snow1"]]=10,[bi["flower_snow2"]]=10,[bi["flower_snow3"]]=10,}
    local wt2 =c.weightT{[bi["blossom_snow1"]]=40,[bi["flower_snow1"]]=80,[bi["flower_snow2"]]=10,}
    local wt3 =c.weightT{[bi["blossom_snow1"]]=40,[bi["flower_snow2"]]=80,[bi["flower_snow3"]]=10,}
    local wt4 =c.weightT{[bi["blossom_snow1"]]=80,[bi["flower_snow3"]]=80,[bi["flower_snow1"]]=10,}
    group_weight =  c.weightT{[wt1] =20,[wt2] =7,[wt3] =5,[wt4]=5}
    size_weight = c.weightT{[3]=5,[4]=3,[5]=1,}
    group_num = rnd(5,8)
    if flower_lv ==2 then group_num = group_num+4 end
  else
    local wt1 = c.weightT{[bi["flower"]]=2,[bi["blossom1"]]=3,[bi["blossom2"]]=1,}
    local wt2 =c.weightT{[bi["blossom1"]]=10,[bi["blossom2"]]=5,[bi["blossom3"]]=10,[bi["grass1"]]=1,[bi["grass2"]]=1,[bi["grass3"]]=1,}
    local wt3 =c.weightT{[bi["blossom1"]]=5,[bi["blossom2"]]=2,[bi["blossom4"]]=1,}
    local wt4 =c.weightT{[bi["blossom3"]]=5,[bi["blossom4"]]=3,[bi["blossom5"]]=1,[bi["grass1"]]=4,[bi["grass2"]]=4,[bi["grass3"]]=3,}
    group_weight =  c.weightT{[wt1] =10,[wt2] =10,[wt3] =7,[wt4] =7,}
    size_weight = c.weightT{[3]=5,[4]=5,[5]=2,[6]=2,}
    group_num = rnd(4,6)
    if flower_lv ==2 then group_num = group_num+6 end
  end
  for i=1,group_num do
    local size = pick(size_weight)
    local gwt = pick(group_weight)
    local gx,gy = rnd(0,newmap.realw-1),rnd(0,newmap.realh-1)
    for nx,ny in c.closest_xypoint_first(gx,gy,size) do
      if newmap:inbounds_real(nx,ny) then
        local ipos = ny*newmap.realw+nx+1
        if newmap.block[ipos]==1 and rnd()<= (size -c.dist_2d(nx,ny,gx,gy))/size then newmap.block[ipos] = pick(gwt) end
      end
    end
  end
  
  
end

function addPlant(newmap,ovmap,x,y,isSnow)
  if not ovmap:hasFlag("PLANT",x,y) then return end
  local ti = data.terIndex
  local bi = data.blockIndex
  local group_weight,size_weight,group_num
  if isSnow then
    local wt1 = c.weightT{[bi["vegetation_snow1"]]=10,[bi["vegetation_snow2"]]=10,[bi["vegetation_snow3"]]=10,}
    local wt2 =c.weightT{[bi["plant_snow1"]]=40,[bi["plant_snow2"]]=80,[bi["plant_snow3"]]=10,}
    local wt3 =c.weightT{[bi["plant_snow3"]]=80,[bi["bush_snow"]]=20,[bi["vegetation_snow2"]]=10,}
    group_weight =  c.weightT{[wt1] =20,[wt2] =7,[wt3] =5,}
    size_weight = c.weightT{[3]=5,[4]=3,[5]=1,}
    group_num = rnd(5,8)
  else
    local wt1 = c.weightT{[bi["grass1"]]=2,[bi["grass2"]]=3,[bi["grass3"]]=3,}
    local wt2 =c.weightT{[bi["weed1"]]=5,[bi["weed2"]]=5,[bi["weed3"]]=8,}
    local wt3 =c.weightT{[bi["vegetation1"]]=15,[bi["vegetation2"]]=7,[bi["grasscluster"]]=1,}
    local wt4 =c.weightT{[bi["vegetation3"]]=15,[bi["vegetation4"]]=7,[bi["grasscluster"]]=1,}
    group_weight =  c.weightT{[wt1] =10,[wt2] =10,[wt3] =7,[wt4] =7,}
    --size_weight = c.weightT{[3]=5,[4]=3,[5]=1,}
    --group_num = rnd(5,8)
    size_weight = c.weightT{[3]=5,[4]=5,[5]=2,[6]=1,}
    group_num = rnd(7,10)
    --size_weight = c.weightT{[7]=5,[10]=5,[13]=2,}
    --group_num = rnd(3,5)
  end
  for i=1,group_num do
    local size = pick(size_weight)
    local gwt = pick(group_weight)
    local gx,gy = rnd(0,newmap.realw-1),rnd(0,newmap.realh-1)
    for nx,ny in c.closest_xypoint_first(gx,gy,size) do
      if newmap:inbounds_real(nx,ny) then
        local ipos = ny*newmap.realw+nx+1
        if newmap.block[ipos]==1 and rnd()<= (size -c.dist_2d(nx,ny,gx,gy))/size then newmap.block[ipos] = pick(gwt) end
      end
    end
  end
end



--铺路，重新放置物品。路上会低几率出现丢弃的物品。
function addRoad(newmap,ovmap,x,y,isDirt)
  if not ovmap:hasFlag("ROAD",x,y) then return end
  local north = ovmap:hasFlag("ROAD",x,y+1)
  local south = ovmap:hasFlag("ROAD",x,y-1)
  local west = ovmap:hasFlag("ROAD",x-1,y)
  local east = ovmap:hasFlag("ROAD",x+1,y)
  if not(north or south or west or east) then return end
  local ti = data.terIndex
  local bi = data.blockIndex
  
  local baseter = ti["dirt"]
  if isDirt then baseter = ti["dirt_road"] end
  
  
  --选取中心点
  local cx,cy = math.floor(newmap.realw/2),math.floor(newmap.realh/2)
  cx = cx+rnd(-5,5)
  cy = cy+rnd(-3,3)
  newmap.block[cy*newmap.realw+cx+1]=1
  newmap.ter[cy*newmap.realw+cx+1] = baseter
  local chance = {[0] = 1, [1] = 0.98,[2]=0.7,[3] = 0.5,[4] =0.2 }
  
  
  --写入地格
  local function road_square(posx,posy)
    local ipos = posy*newmap.realw+posx+1
    newmap.block[ipos]=1
    newmap.ter[ipos] = baseter 
  end
  
  
  
  local function make_road(mdx,mdy,sdx,sdy)
    local curx,cury = cx,cy
    local step =0
    while(true) do
      step = step+1
      curx,cury= curx +mdx,cury+mdy
      if step %4==0 then
        local rv = rnd(-1,1)
        curx,cury= curx +sdx*rv,cury+sdy*rv
      end
      for i= -4,4 do
        local posx,posy = curx +sdx*i,cury+sdy*i
        local rate = chance[math.abs(i)]
        if rnd()<rate then
          if not newmap:inbounds_real(posx,posy) then return end
          --写入地格
          road_square(posx,posy)
        end
      end
    end
  end
  
  if north then make_road(0,1,1,0) end
  if south then make_road(0,-1,1,0) end
  if west then make_road(-1,0,0,1) end
  if east then make_road(1,0,0,1) end
  if north and south then
    for i= -4,4 do
        local posx,posy = cx +i,cy
        local rate = chance[math.abs(i)]
        if rnd()<rate and  newmap:inbounds_real(posx,posy) then
          road_square(posx,posy)
        end
      end
  end
  if west and east then
    for i= -4,4 do
        local posx,posy = cx ,cy+i
        local rate = chance[math.abs(i)]
        if rnd()<rate and  newmap:inbounds_real(posx,posy) then
          road_square(posx,posy)
        end
      end
  end
  
end

function generateMonster(newmap,ovmap,x,y)
  local mon_num = rnd(4,6)
  local maxlevel = 5
  local monlist = {}
  rawset(newmap,"monlist",monlist) --保存列表
  local gentype = Unit.randomUnitTypeByLevel(maxlevel)
  
  for i=1,mon_num do
    local utype = gentype()
    local unit = Unit.create(utype.id,nil,"wild")
    table.insert(monlist,unit)
    newmap:monsterSpawn(unit,rnd(0,newmap.w-1),rnd(0,newmap.h-1),false)
  end
end


