

data.face ={}

data.addLoadingCvs("class","data/unit/class.csv",nil)
data.addLoadingCvs("race","data/unit/race.csv",nil)
data.addLoadingCvs("unit","data/unit/unit.csv",nil)



local function loadUnitFace()
--  if SubThread then return end--子线程不执行
  local lovefs = require("file/lovefs")
  --debugmsg("source:"..love.filesystem.getSource())
  local fs = lovefs(love.filesystem.getSource().."/data/pic/face")
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.png") then
      local fname = string.sub(v,1,-5)
      --debugmsg("load face:"..fname)
      data.face[fname]= love.graphics.newImage("/data/pic/face/"..v) 
    end
  end
end

return function ()
  
  local indexList = data.GetCVSIndexList("data/unit/unit.csv")
  
  for i=1,#indexList do
    local dataT = indexList[i]
    --animMale 取得
    local val = dataT.animMale
    if val =="" then val = dataT.id end --与单位id一致
    dataT.animMale = data.unitAnim[val]
    if dataT.animMale ==nil then debugmsg("emptyUnitAnim id:"..val)  end
    --animFemale 取得
    val = dataT.animFemale
    if val =="" then 
      dataT.animFemale = dataT.animMale 
    else
      dataT.animFemale = data.unitAnim[val]
    end 
    if dataT.animFemale ==nil then debugmsg("emptyUnitAnim id:"..dataT.id)  end
    --skill合并
    local skill={}
    for k,v in pairs( dataT.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.profession_skills) do skill[k]=v  end
    for k,v in pairs( dataT.race.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.race.profession_skills) do skill[k]=v  end
    for k,v in pairs( dataT.class.weapon_skills) do skill[k]=v  end
    for k,v in pairs( dataT.class.profession_skills) do skill[k]=v  end
    dataT.skill = skill
    --checktrait,待以后
  end
  
  loadUnitFace()
  
  data.race["roran"].dodge_lv =5
  data.race["roran"].atk_lv =-1
end