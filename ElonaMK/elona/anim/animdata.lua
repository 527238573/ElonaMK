


data.addLoadingCvs("unitAnim","data/unit/anim_unit.csv",nil)


return function ()
  if SubThread then return end--子线程不执行
  
  local indexList = data.GetCVSIndexList("data/unit/anim_unit.csv")
  
  
  local picbase = "data/unit/anim/"
  for i=1,#indexList do
    local dataT = indexList[i]
    local file = dataT.file
    if file =="" then file = dataT.id..".png" end
    local picfile = picbase..file
    dataT.img = data.newImage(picbase..file) --读取img
    
    
    --整理图片
    local w,h= 1,1
    if dataT.type =="twoside" then
      w = dataT.num*2
    elseif dataT.type =="oneside" then
      w= dataT.num
    else
      error("error unitAnim type:"..dataT.type)
    end
    local imgw,imgh = dataT.img:getDimensions()
    --自动宽高
    if dataT.autoWH then
      dataT.w = imgw/w
      dataT.h = imgh/h
      if not ((dataT.w==32 or dataT.w==48 ) and (dataT.h==32 or dataT.h==48 or dataT.h==64)) then
         error("error unitAnim wh:"..dataT.id)
      end
    end
    
    dataT.anchorX = dataT.anchorX>=0 and dataT.anchorX  or dataT.w/2
    dataT.anchorY = dataT.anchorY>=0 and dataT.anchorY  or dataT.h-16
    
    --图片quad。
    for i= 1,w do
      for j=1,h do
        data.insertQuad(dataT,dataT.w*(i-1),dataT.h*(j-1),dataT.w,dataT.h,imgw,imgh)
      end
    end
  end
  
end