local lovefs = require("file/lovefs")

data.addLoadingCvs("ability","data/ability/ability.csv",nil)
data.addLoadingCvs("effect","data/ability/effect.csv",nil)
data.addLoadingCvs("trait","data/ability/trait.csv",nil)

local function loadAbilityIcons()
  data.ability_icon = {}
  local fs = lovefs(c.source_dir.."data/ability/icon")
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.png") then
      local fname = string.sub(v,1,-5)
      --debugmsg("load face:"..fname)
      data.ability_icon[fname]= data.newImage("/data/ability/icon/"..v) 
    end
  end
end


--读取代码机制文件
local function loadAbilityCode()
  local baseDir = c.source_dir.."elona/unit/ability_call"
  local fs = lovefs(baseDir)
  local fileNum = 0
  local function loadOneFile(fileName,base)
    local aloadfunc = assert(loadfile(base.."/"..fileName))
    aloadfunc()
    fileNum = fileNum +1
  end
  
  local function ScanAbiDir(dirName,base)
    local link = base.."/"..dirName;
    fs:cd(link)
    for _, v in ipairs(fs.files) do
      --debugmsg(link.."/"..v)
      loadOneFile(v,link)
    end
    for _, v in ipairs(fs.dirs) do
      ScanAbiDir(v,link)
    end
  end
  
  for _, v in ipairs(fs.files) do
    --debugmsg(link.."/"..v)
    loadOneFile(v,baseDir)
  end
  for _, v in ipairs(fs.dirs) do
    ScanAbiDir(v,baseDir)
  end
  
  debugmsg("load ability code files:"..fileNum)
end



return function ()
  loadAbilityIcons()
  
  local indexList =data.GetCVSIndexList("data/ability/ability.csv")
  for i=1,#indexList do
    local dataT = indexList[i]
    --icon
    local val = dataT.icon
    local img = data.ability_icon[val]
    if img ==nil then error("ability_icon error:"..val) end
    dataT.icon = img
    if g.main_attr[dataT.main_attr]==nil then error("error mainattr:"..dataT.main_attr) end
  end
  
  --loadAbilities()
  loadAbilityCode()
end