

data.item ={}

data.itemImgs = {}
data.itemImgs["item1"] = love.graphics.newImage("data/item/item1.png")


local strToBoolean =data.strToBoolean
local colorTable =data.colorTable
local flagsTable =data.flagsTable
local flagsIndexTable = data.flagsIndexTable
data.enchantment ={}
data.material ={}
data.material_seq ={}

local function loadEnchantment()
  local file = assert(io.open(c.source_dir.."data/item/enchantment.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="type" then
        if val =="" then val = "attr" end
        dataT[key] = val
      elseif  key=="percent" then
        dataT[key] = strToBoolean(val,false)
      elseif  key=="color" then
        dataT[key] = colorTable(val,1,1,1)
      elseif  key=="level" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="rare" then
        dataT[key] = tonumber(val) or 100
      else
        error("error item key:"..key)
      end
    end


    if data.enchantment[dataT.id]~=nil then
      error("repetitive enchantment id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.enchantment[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load enchantment Nubmer:"..(index-1))
  file:close()
end


local function loadMaterial()
  local file = assert(io.open(c.source_dir.."data/item/materials.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="aka" then
        dataT.aka = val
      elseif  key=="level" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="AR" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="MR" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="weight" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="rare" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="color" then
        dataT[key] = colorTable(val,1,1,1)
      elseif  key=="enchantment1" then
        if val~= "" then  
          dataT[key] = assert(data.enchantment[val]) --找到对应 的附魔
        end
      elseif  key=="enchantment2" then
        if val~= "" then  
          dataT[key] = assert(data.enchantment[val]) --找到对应 的附魔
        end
      else
        error("error item key:"..key)
      end
    end


    if data.material[dataT.id]~=nil then
      error("repetitive material id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.material[dataT.id] = dataT
    data.material_seq[index] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load material Nubmer:"..(index-1))
  file:close()
end






local function loadItemType()

  local file = assert(io.open(c.source_dir.."data/item/item_generic.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 

      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="type" then
        if val =="" then val = "generic" end
        dataT[key] = val
      elseif  key=="img" then
        local img = data.itemImgs[val]
        if img ==nil then error("wrong itemImg id:"..val)  end
        dataT.img = img
      elseif  key=="quadX" then
        dataT.quadX = assert(tonumber(val))
      elseif  key=="quadY" then
        dataT.quadY = assert(tonumber(val))
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="hanging" then
        dataT.hanging = strToBoolean(val,false)
      elseif  key=="frameNum" then
        dataT.frameNum = tonumber(val) or 1
        dataT.useAnim = dataT.frameNum>1 
      elseif  key=="frameInterval" then
        dataT.frameInterval = tonumber(val) or 0.2
      elseif  key=="weight" then
        dataT[key] = tonumber(val) or 0.1
      elseif  key=="price" then
        dataT[key] = tonumber(val) or 100
      elseif key =="description" then
        dataT[key] = val
      elseif key =="canStack" then
        dataT[key] = strToBoolean(val,true)
      elseif key =="initNum" then
        dataT[key] = tonumber(val) or 1
        if not dataT.canStack then dataT[key]=1 end 
      else
        error("error item key:"..key)
      end
    end
    --quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
    end
    if dataT.useAnim then
      for i=1,dataT.frameNum do
        loadQuad(dataT.quadX+(i-1)*dataT.w/64,dataT.quadY,dataT.w,dataT.h,dataT)
      end
    else
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end


    if data.item[dataT.id]~=nil then
      error("repetitive item id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.item[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load item Nubmer:"..(index-1))
  file:close()
  
  --loadname
  file = assert(io.open(c.source_dir.."data/item/item_generic_name.csv","r"))
  line = file:read()
  attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = nil
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT = data.item[val]
      elseif  key=="name" then
        dataT[key] = val
      elseif key =="description" then
        dataT[key] = val
      end
    end
    line = file:read()
  end    
  file:close()
end



local function loadWeapon()

  local file = assert(io.open(c.source_dir.."data/item/item_weapon.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 

      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="type" then
        if val =="" then val = "generic" end
        dataT[key] = val
      elseif  key=="img" then
        local img = data.itemImgs[val]
        if img ==nil then error("wrong itemImg id:"..val.." index:"..index)  end
        dataT.img = img
      elseif  key=="quadX" then
        dataT.quadX = assert(tonumber(val))
      elseif  key=="quadY" then
        dataT.quadY = assert(tonumber(val))
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="frameNum" then
        dataT.frameNum = tonumber(val) or 1
        dataT.useAnim = dataT.frameNum>1 
      elseif  key=="frameInterval" then
        dataT.frameInterval = tonumber(val) or 0.2
      elseif  key=="weight" then
        dataT[key] = tonumber(val) or 0.1
      elseif  key=="price" then
        dataT[key] = tonumber(val) or 100
      elseif key =="description" then
        dataT[key] = val
      elseif key == "flags" then
        dataT[key] = flagsTable(val)
      elseif key =="equipType" then
        dataT[key] = assert(val)
      elseif  key=="AR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="AR_grow" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MR_grow" then
        dataT[key] = tonumber(val) or 0
      elseif key == "weapon_skill" then
        dataT[key] = flagsTable(val)
      elseif key == "hit_effect" then
        dataT[key] = flagsIndexTable(val)
      elseif  key=="atkCost" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceNum" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceFace" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="baseAtk" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="face_grow" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="base_grow" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="to_hit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="m_dps" then
        --无效
      elseif  key=="is_melee" then
        dataT[key] = strToBoolean(val,false)
      else
        error("error weapon key:"..key)
      end
    end
    --此类型默认的值。
    dataT.weapon = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end

    --quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
    end
    if dataT.useAnim then
      for i=1,dataT.frameNum do
        loadQuad(dataT.quadX+(i-1)*dataT.w/64,dataT.quadY,dataT.w,dataT.h,dataT)
      end
    else
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end


    if data.item[dataT.id]~=nil then
      error("repetitive weapon id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.item[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load weapon Nubmer:"..(index-1))
  file:close()
  
  --loadname
  file = assert(io.open(c.source_dir.."data/item/item_weapon_name.csv","r"))
  line = file:read()
  attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = nil
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT = data.item[val]
      elseif  key=="name" then
        dataT[key] = val
      elseif key =="description" then
        dataT[key] = val
      end
    end
    line = file:read()
  end    
  file:close()
  
end

local function loadRangeWeapon()
  
  local file = assert(io.open(c.source_dir.."data/item/item_rangeWeapon.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local id = strDH[1]
    local name = strDH[2]
    local dataT = data.item[id]
    if dataT==nil then
      error("error range weapon id :"..id.." name:"..name)
    end
    if not dataT.weapon then
      error("error (not a weapon) range weapon id :"..id.." name:"..name)
    end
    setmetatable(dataT,nil)--先取消
    dataT.rangeWeapon = true --只要在这张表里的都是rangeweapon
    for i=3,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="fixShotCost" then
        dataT[key] = strToBoolean(val,true)
      elseif  key=="shotCost" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceNum_range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceFace_range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="baseAtk_range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="face_grow_range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="base_grow_range" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="to_hit_range" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="maxRange" then
        dataT[key] = tonumber(val) or 7.9
      elseif  key=="dispersion" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="pellet" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="r_dps" then
        --无效
      elseif  key=="maxAmmo" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="ammo_type" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif  key=="R_key" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif  key=="reloadCost" then
        dataT[key] = tonumber(val) or 0.4
      elseif key=="bullet" then
        if val =="" then val = "bullet1" end
        dataT[key] = val
      elseif key=="shootSound" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif key=="reloadSound" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif key=="bulletSound" then
        if val =="" then val = nil end
        dataT[key] = val
      else
        error("error rangeweapon key:"..key.." i:"..i)
      end
    end
    
    setmetatable(dataT,data.dataMeta) --重设
    line = file:read()
    index = index+1
  end
  debugmsg("load rangeweapon Nubmer:"..(index-1))
  file:close()
end



local function loadEquipment()
  
  local file = assert(io.open(c.source_dir.."data/item/item_equipment.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {}
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 

      if key=="id" then
        dataT.id = val
      elseif  key=="name" then
        dataT.name = val
      elseif  key=="type" then
        if val =="" then val = "generic" end
        dataT[key] = val
      elseif  key=="img" then
        local img = data.itemImgs[val]
        if img ==nil then error("wrong itemImg id:"..val.." index:"..index)  end
        dataT.img = img
      elseif  key=="quadX" then
        dataT.quadX = assert(tonumber(val))
      elseif  key=="quadY" then
        dataT.quadY = assert(tonumber(val))
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 64
      elseif  key=="frameNum" then
        dataT.frameNum = tonumber(val) or 1
        dataT.useAnim = dataT.frameNum>1 
      elseif  key=="frameInterval" then
        dataT.frameInterval = tonumber(val) or 0.2
      elseif  key=="weight" then
        dataT[key] = tonumber(val) or 0.1
      elseif  key=="price" then
        dataT[key] = tonumber(val) or 100
      elseif key =="description" then
        dataT[key] = val
      elseif key == "flags" then
        dataT[key] = flagsTable(val)
      elseif key =="equipType" then
        dataT[key] = assert(val)
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="AR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="AR_grow" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MR_grow" then
        dataT[key] = tonumber(val) or 0
      else
        error("error equipment item key:"..key)
      end
    end
    --此类型默认的值。
    dataT.weapon = false
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end

    --quad
    local function loadQuad(x,y,w,h,tt)
      table.insert(tt,love.graphics.newQuad(x*64,y*64,w,h,tt.img:getWidth(),tt.img:getHeight()))
    end
    if dataT.useAnim then
      for i=1,dataT.frameNum do
        loadQuad(dataT.quadX+(i-1)*dataT.w/64,dataT.quadY,dataT.w,dataT.h,dataT)
      end
    else
      loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
    end


    if data.item[dataT.id]~=nil then
      error("repetitive equipment id :"..dataT.id)
    end
    setmetatable(dataT,data.dataMeta)
    data.item[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load equipment Nubmer:"..(index-1))
  file:close()
  
  --loadname
  file = assert(io.open(c.source_dir.."data/item/item_equipment_name.csv","r"))
  line = file:read()
  attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = nil
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key=="id" then
        dataT = data.item[val]
      elseif  key=="name" then
        dataT[key] = val
      elseif key =="description" then
        dataT[key] = val
      end
    end
    line = file:read()
  end    
  file:close()
  
end



return function ()
  loadEnchantment()
  loadMaterial()
  loadItemType()
  loadWeapon()
  loadRangeWeapon()
  loadEquipment()
end