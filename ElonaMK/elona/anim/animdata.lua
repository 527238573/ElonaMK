



data.unitAnim = {} --使用字符串id作为key

local strToBoolean =data.strToBoolean

local function loadUnitAnim()
  
  local picbase = "data/unit/anim/"
  
  local file = assert(io.open("data/unit/anim_unit1.csv","r"))
  local index = 1
  local line = file:read()
  local attrName = string.split(line,",") 
  attrName[1] = "id" --utf8头，需要修正
  
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    local dataT = {} --不许保存的类型
    for i=1,#strDH do
      local val = strDH[i]
      local key = attrName[i] 
      
      if key=="id" then
        dataT.id = val
      elseif  key=="file" then
        if val =="" then val = dataT.id..".png" end
        local picfile = picbase..val
        dataT.img = love.graphics.newImage(picbase..val) --读取img
      elseif  key=="type" then
        if val =="" then val = "twoside" end
        dataT[key] = val 
      elseif  key=="stillframe" then
        dataT[key] = tonumber(val) or 1
      elseif  key=="autoWH" then
        dataT.autoWH = strToBoolean(val,true)
      elseif  key=="w" then
        dataT[key] = tonumber(val) or 32
      elseif  key=="h" then
        dataT[key] = tonumber(val) or 32
      elseif  key=="anchorX" then
        if dataT.autoWH then
          dataT[key] = tonumber(val) --如未空后面再计算
        else
          dataT[key] = tonumber(val) or dataT.w/2
        end
      elseif  key=="anchorY" then
        if dataT.autoWH then
          dataT[key] = tonumber(val) --如未空后面再计算
        else
          dataT[key] = tonumber(val) or dataT.h/2
        end
      elseif key == "num" then
        dataT[key] = tonumber(val) or 4
      elseif key == "scalefactor" then
        dataT[key] = tonumber(val) or 2
      elseif key == "pingpong" then
        dataT.pingpong = strToBoolean(val,true)
      elseif key == "playSpeed" then
        dataT[key] = tonumber(val) or 0.5
      elseif key == "shadowSize" then
        dataT[key] = tonumber(val) or 1
      else
        error("error unitAnim key:"..key)
      end
    end
    
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
      dataT.anchorX = dataT.anchorX  or dataT.w/2
      dataT.anchorY = dataT.anchorY  or dataT.h/2
    end
    --图片quad。
    for i= 1,w do
      for j=1,h do
        table.insert(dataT,love.graphics.newQuad(dataT.w*(i-1),dataT.h*(j-1),dataT.w,dataT.h,imgw,imgh))
      end
    end
    
    
    setmetatable(dataT,data.dataMeta)
    if data.unitAnim[dataT.id]~=nil then
      error("repetitive unitAnim id :"..dataT.id)
    end
    data.unitAnim[dataT.id] = dataT
    line = file:read()
    index = index+1
  end
  debugmsg("load unitAnim Nubmer:"..(index-1))
  file:close()
end


return function ()
  loadUnitAnim()
end