local lovefs = require("file/lovefs")

local fileTable

--搜索/data/frames下的文件和次一级目录。
local function searchFiles()
  fileTable = {}

  local baseDir = love.filesystem.getSource().."/data/frames"
  local fs = lovefs(baseDir)
  for _, v in ipairs(fs.files) do --
    if string.match(v,".%.png",-5) then
      local fname = string.sub(v,1,-5)
      if fileTable[fname] then
        error("Repeat Frames Name:"..fname)
      end
      fileTable[fname]= "data/frames/"..v
    end
  end
  for _,d in ipairs(fs.dirs) do
    local cdir = baseDir.."/"..d
    fs:cd(cdir)
    for _, v in ipairs(fs.files) do --
      if string.match(v,".%.png",-5) then
        local fname = string.sub(v,1,-5)
        if fileTable[fname] then
          error("Repeat Frames Name:"..fname)
        end
        fileTable[fname]= "data/frames/"..d.."/"..v
      end
    end
  end
end


data.addLoadingCvs("frames","data/frames/frames.csv",nil)
return function ()
  --if SubThread then return end--子线程不执行
  searchFiles()
  local indexList = data.GetCVSIndexList("data/frames/frames.csv")
  for i=1,#indexList do
    local dataT = indexList[i]
    local w,h = dataT.w,dataT.h
    --ox,oy
    if dataT.ox==-1 then dataT.ox = w/2 end
    if dataT.oy==-1 then dataT.oy = h/2 end
    
    --默认用id在filetable中搜索
    local path = dataT.file
    if path =="" then path = fileTable[dataT.id] end 
    if path ==nil then
      error("FrameName: "..dataT.id.." not found")
    end
    --自动切割
    local img = love.graphics.newImage(path)
    local imgw,imgh = img:getDimensions()
    local fw,fh = math.floor(imgw/w),math.floor(imgh/h)
    if fw<1 or fh<1 then error("Frames wh error"..dataT.id) end
    local frameNum = 0
    for j=1,fh do
      for i=1,fw do
        frameNum= frameNum+1
        data.insertQuad(dataT,(i-1)*w,(j-1)*h,w,h,imgw,imgh)
      end
    end
    dataT.img = img
    dataT.frameNum = frameNum
  end
  
  fileTable = nil
  
end