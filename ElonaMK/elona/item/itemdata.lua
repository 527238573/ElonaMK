

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
  local file = assert(io.open("data/item/enchantment1.csv","r"))
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
  local file = assert(io.open("data/item/materials1.csv","r"))
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
      elseif  key=="DV" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="PV" then
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

  local file = assert(io.open("data/item/item_generic1.csv","r"))
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
end



local function loadWeapon()

  local file = assert(io.open("data/item/item_weapon1.csv","r"))
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
      elseif  key=="DV" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="PV" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="DV_grow" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="PV_grow" then
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
      elseif  key=="F_key" then
        if val =="" then val = nil end
        dataT[key] = val
        if val =="shot" then dataT.rangeWeapon = true end --标记远程。
      elseif  key=="fixShotCost" then
        if dataT.rangeWeapon then  dataT[key] = strToBoolean(val,true) end
      elseif  key=="shotCost" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="diceNum_range" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="diceFace_range" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="baseAtk_range" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="face_grow_range" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="base_grow_range" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="to_hit_range" then
        if dataT.rangeWeapon then dataT[key] = tonumber(val) or 0 end
      elseif  key=="r_dps" then
        --无效
      elseif  key=="maxAmmo" then
        if dataT.rangeWeapon then dataT[key] = assert(tonumber(val)) end
      elseif  key=="ammo_type" then
        if dataT.rangeWeapon then 
          if val =="" then val = nil end
          dataT[key] = val
        end
      elseif  key=="R_key" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif  key=="reloadCost" then
        dataT[key] = tonumber(val) or 100
      else
        error("error item key:"..key)
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
end


local function loadEquipment()
  
  local file = assert(io.open("data/item/item_equipment1.csv","r"))
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
      elseif  key=="DV" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="PV" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="DV_grow" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="PV_grow" then
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
  
end



return function ()
  loadEnchantment()
  loadMaterial()
  loadItemType()
  loadWeapon()
  loadEquipment()
end