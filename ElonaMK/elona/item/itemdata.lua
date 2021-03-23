

data.item ={}

data.itemImgs = {}
data.itemImgs["item1"] = love.graphics.newImage("data/item/item1.png")
local itemScale = 1 --使用64*64格子的图 不能缩小到32*32，因为在1.5缩放效果看上去不佳。
--data.itemImgs["item1"]:setFilter("linear","linear")

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


local function dataTLoadQuad(dataT)
  dataT.scaleFactor = itemScale
  local function loadQuad(x,y,w,h,tt)
    table.insert(tt,love.graphics.newQuad(x*64/itemScale,y*64/itemScale,w,h,tt.img:getWidth(),tt.img:getHeight()))
  end
  if dataT.useAnim then
    for i=1,dataT.frameNum do
      loadQuad(dataT.quadX+(i-1)*dataT.w/(64/itemScale),dataT.quadY,dataT.w,dataT.h,dataT)
    end
  else
    loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
  end
end



local function loadItemType()

  local file = assert(io.open(c.source_dir.."data/item/item.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",")
    if strDH[1] ~="" then --有空行忽略掉
      local dataT = {}
      for i=1,#strDH do
        local val = strDH[i]
        local key = attrName[i] 

        if key=="id" then
          dataT.id = val
        elseif  key=="name" then
          dataT.name = c.gbk2utf8(val)
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
          dataT[key] = (tonumber(val) or 32)*2/itemScale
        elseif  key=="h" then
          dataT[key] = (tonumber(val) or 32)*2/itemScale
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
          dataT[key] = c.gbk2utf8(val)
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
      dataTLoadQuad(dataT)


      if data.item[dataT.id]~=nil then
        error("repetitive item id :"..dataT.id)
      end
      setmetatable(dataT,data.dataMeta)
      data.item[dataT.id] = dataT
      index = index+1

    end
    line = file:read()
  end
  debugmsg("load item Nubmer:"..(index-1))
  file:close()

end



local function loadMeleeWeapon()

  local file = assert(io.open(c.source_dir.."data/item/item_melee.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正

  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = data.item[strDH[1]]
    if dataT ==nil then
      error("not found meleeWeapon Id: "..strDH[1])
    end
    setmetatable(dataT,nil)--先取消
    
    for i=3,#strDH do --3号开始
      local val = strDH[i]
      local key = attrName[i] 

      if key == "flags" then
        data.addFlags(dataT,key,val)
      elseif key =="equipType" then
        assert(val~="")
        dataT[key] = val
      elseif key == "melee_skill" then
        dataT[key] = flagsTable(val)
        dataT.melee_skill_a = flagsIndexTable(val)--数组排列。
      elseif key == "hit_effect" then
        dataT[key] = flagsIndexTable(val)
      elseif  key=="atkCost" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceNum_m" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceFace_m" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="baseAtk_m" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="m_dps" then
        --无效
      elseif  key=="hit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="crit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="DEF" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MGR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="evade" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="block" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="attackRate" then
        dataT[key] = tonumber(val) or 1
      else
        error("error weapon key:"..key)
      end
    end
    --此类型默认的值。
    dataT.weapon = true
    dataT.meleeWeapon = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end
    setmetatable(dataT,data.dataMeta) --重设
    line = file:read()
    index = index+1
  end
  debugmsg("load meleeWeapon Nubmer:"..(index-1))
  file:close()

end

local function loadRangeWeapon()

  local file = assert(io.open(c.source_dir.."data/item/item_range.csv","r"))
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
    
    setmetatable(dataT,nil)--先取消
    for i=3,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key == "flags" then
        data.addFlags(dataT,key,val)
      elseif key =="equipType" then
        assert(val~="")
        dataT[key] = val
      elseif key == "range_skill" then
        dataT[key] = flagsTable(val)
        dataT.range_skill_a = flagsIndexTable(val)--数组排列。
      elseif  key=="ammo_type" then
        if val =="" then val = nil end
        dataT[key] = val
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
      elseif  key=="R_key" then
        if val =="" then val = nil end
        dataT[key] = val
      elseif  key=="reloadCost" then
        dataT[key] = tonumber(val) or 0.4
      elseif  key=="maxAmmo" then
        dataT[key] = assert(tonumber(val))
      elseif key=="fixShotCost" then
        dataT[key] = strToBoolean(val,true)
      elseif  key=="shotCost" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceNum_r" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="diceFace_r" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="baseAtk_r" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="maxRange" then
        dataT[key] = tonumber(val) or 7.9
      elseif  key=="dispersion" then
        dataT[key] = tonumber(val) or 100
      elseif  key=="pellet" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="m_dps" then
        --无效
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="hit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="crit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="DEF" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MGR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="evade" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="block" then
        dataT[key] = tonumber(val) or 0
      else
        error("error rangeweapon key:"..key.." i:"..i)
      end
    end
    
    dataT.weapon = true
    dataT.rangeWeapon = true--只要在这张表里的都是rangeweapon
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end
    setmetatable(dataT,data.dataMeta) --重设
    line = file:read()
    index = index+1
  end
  debugmsg("load rangeweapon Nubmer:"..(index-1))
  file:close()
end


local function loadBodyEquipment()

  local file = assert(io.open(c.source_dir.."data/item/item_body.csv","r"))
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
      error("error body armor id :"..id.." name:"..name)
    end
    
    setmetatable(dataT,nil)--先取消
    for i=3,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key == "flags" then
        data.addFlags(dataT,key,val)
      elseif key =="equipType" then
        assert(val=="body")
        dataT[key] = val
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="DEF" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MGR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="evade" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="block" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="life" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="mana" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_bash" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_cut" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_stab" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_fire" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_ice" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_nature" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_earth" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_dark" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="res_light" then
        dataT[key] = tonumber(val) or 0
      else
        error("error body armor key:"..key.." i:"..i)
      end
    end
    
    dataT.bodyArmor = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    setmetatable(dataT,data.dataMeta) --重设
    line = file:read()
    index = index+1
  end
  debugmsg("load bodyArmor Nubmer:"..(index-1))
  file:close()
end



local function loadAccessory()

  local file = assert(io.open(c.source_dir.."data/item/item_accessory.csv","r"))
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
      error("error accessory id :"..id.." name:"..name)
    end
    
    setmetatable(dataT,nil)--先取消
    for i=3,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      if key == "flags" then
        data.addFlags(dataT,key,val)
      elseif key =="equipType" then
        assert(val=="accessory")
        dataT[key] = val
      elseif  key=="sLevel" then
        dataT[key] = assert(tonumber(val))
      elseif  key=="DEF" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="MGR" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="hit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="crit" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="evade" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="block" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="life" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="mana" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="speed" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="atk_lv" then
        dataT[key] = tonumber(val) or 0
      elseif  key=="mgc_lv" then
        dataT[key] = tonumber(val) or 0
      else
        error("error accessory key:"..key.." i:"..i)
      end
    end
    
    dataT.accessory = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    setmetatable(dataT,data.dataMeta) --重设
    line = file:read()
    index = index+1
  end
  debugmsg("load accessory Nubmer:"..(index-1))
  file:close()
end


return function ()
  loadEnchantment()
  --loadMaterial()
  loadItemType()
  loadMeleeWeapon()
  loadRangeWeapon()
  loadBodyEquipment()
  loadAccessory()
end