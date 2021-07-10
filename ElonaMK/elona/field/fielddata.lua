

data.addLoadingCvs("field","data/field/field.csv",nil)
return function ()
  if SubThread then return end--子线程不执行
  local indexList =data.GetCVSIndexList("data/field/field.csv")
  
  local picbase = "data/field/anim/"
  for i=1,#indexList do
    local dataT = indexList[i]
    --img
    local val = dataT.img
    if val =="" then val = dataT.id..".png" end
    local picfile = picbase..val
    dataT.img = love.graphics.newImage(picbase..val) --读取img
    
    local imgw,imgh = dataT.img:getDimensions()
    --自动宽高
    if dataT.autoWH  and  (dataT.type == "anim" or dataT.type == "density")then
      dataT.w = imgw/dataT.frameNum
      dataT.h = imgh
    end
    if  dataT.anchorX  == -1 then dataT.anchorX =  math.floor(dataT.w/2) end--重设默认值。
    
    --图片quad。
    if dataT.type == "anim" or dataT.type == "density" then
      for i= 1,dataT.frameNum do
        data.insertQuad(dataT,dataT.w*(i-1),0,dataT.w,dataT.h,imgw,imgh)
      end
    elseif dataT.type == "edge" then
      data.insertQuad(dataT,5*16,0,32,32,imgw,imgh)
      local function loadQuad(x,y)
        data.insertQuad(dataT,x*16,y*16,16,16,imgw,imgh)
      end
      loadQuad(0,0);loadQuad(1,0);loadQuad(2,0);
      loadQuad(0,1);loadQuad(1,1);loadQuad(2,1);
      loadQuad(0,2);loadQuad(1,2);loadQuad(2,2);
      loadQuad(3,0);loadQuad(4,0);
      loadQuad(3,1);loadQuad(4,1);
    else
      error("unknow field type:"..dataT.type)
    end
  end
  
  --loadFieldType()
end
