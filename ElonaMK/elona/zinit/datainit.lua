data = {}



local UseMetaDataStrict = true--使用metaData限制元数据的访问
local metaData = {}
metaData.__index = function(t,n) return t.__source[n] end
metaData.__newindex = function(t,n,v) 
  if data.loadComplete  then 
    error("load完毕后不能修改data数据。") 
  else 
    t.__source[n] = v 
  end
end

local function convertToMetaData(targetT,dataFormName)
  targetT.saveType = "MetaData"--标记为元数据
  targetT.dataFormName = dataFormName
  if UseMetaDataStrict then
    local newT = {__source = targetT}
    setmetatable(newT,metaData)
    return newT
  else
    return targetT
  end
end

--插入quad。
function data.insertQuad(dataT,x,y,w,h,sw,sh)
--  if SubThread then return end
  local quad = love.graphics.newQuad(x,y,w,h,sw,sh)
  
  if UseMetaDataStrict then
    table.insert(dataT.__source,quad)
  else
    table.insert(dataT,quad)
  end
end

local emptyImg = {
    getWidth = function() return 64 end,
    getHeight =  function() return 64 end,
    getDimensions = function() return 64,64 end,
  }

function data.newImage(...)
--  if SubThread then return emptyImg end
  return love.graphics.newImage(...)
end






local function flagsTable(flagstr)
  if flagstr =="" then return {} end
  local t1 = string.split(flagstr,"|")
  local ret = {}
  for i=1,#t1 do
    ret[t1[i]] = true
  end
  return ret
end

local function addFlags(dataT,valname,flagstr)
  local flagt = dataT[valname]
  if flagt ==nil then
    dataT[valname] = flagsTable(flagstr)
  elseif flagstr ~="" then
    local t1 = string.split(flagstr,"|")
    for i=1,#t1 do
      flagt[t1[i]] = true
    end
  end
end
--使用数组来排列flag

local function flagsIndexTable(flagstr)
  if flagstr =="" then return {} end
  return string.split(flagstr,"|")
end

local function colorTable(colorstr)
  local t1 = string.split(colorstr,"|")
  if #t1 ~= 3 then error ("colorTable num Error") end
  t1[1] = assert(tonumber(t1[1]))
  t1[2] = assert(tonumber(t1[2]))
  t1[3] = assert(tonumber(t1[3]))
  if t1[1]>1 then t1[1]= t1[1]/255 end
  if t1[2]>1 then t1[2]= t1[2]/255 end
  if t1[3]>1 then t1[3]= t1[3]/255 end
  return t1
end

local function multiValTable(valstr)
  if valstr =="" then return {} end
  local t1 = string.split(valstr,"|")
  local ret = {}
  for i=1,#t1 do
    local findeq = string.find(t1[i],"=",1,true)
    if not findeq then
      error("val Table not find = ")
    else
      local bef= string.sub(t1[i], 1, findeq - 1)
      local aft= string.sub(t1[i], findeq+1)
      ret[bef] = assert(tonumber(aft))
    end
  end
  return ret
end

local function checkSkillType(skills)
  for k,v in pairs(skills) do
    if g.skills[k]==nil then error("wrong skillname:"..k) end
  end
end


--读取整个表格，预定按格式。读取完成后还需要处理
--tableName是data.xxx的名字，保存路径 如"class",表示表读取完成后存储在data.class   
--filePath是"data/unit/class.csv"这样的
--mode = nil 正常添加整张表，覆盖data[tableName]  mode = "append" 覆盖式增加新条目  "combine"  向已有的项中添加/覆盖数据，只能向已存在的添加，否则报错
--返回：LinkList函数，表载入完毕后执行可能的链接
local function LoadCVS(tableName,filePath,mode)
  local file = assert(io.open(c.source_dir..filePath,"r"))

  --第一行 字段名字
  local line = file:read()
  local attrName = string.split(line,",")
  line = file:read() -- 第二行 字段类型
  local attrTypes = string.split(line,",")
  line = file:read() -- 第三行 字段操作
  local attrOps = string.split(line,",")

  --attrName[1] = "id" --utf8头，可能需要修正
  --字段[

  local allDefault = {} --保存每个字段的默认值。执行相同的默认逻辑
  local allField = {} --为每个字段生成一个decodeVal(dataT,val,index) 闭包函数 val已经被赋予了默认值
  local links = {} -- 为link类型 生成一个LinkVal(dataT) 闭包函数

  for i=1,#attrName do
    local fieldname = attrName[i]
    local fieldtype = attrTypes[i]
    --分解ops
    local ops = {}
    if attrOps[i] ~="" then--有值
      local t1 = string.split(attrOps[i],"|")
      for i=1,#t1 do
        local findeq = string.find(t1[i],"=",1,true)
        if not findeq then
          ops[t1[i]] = true
        else
          local bef= string.sub(t1[i], 1, findeq - 1)
          local aft= string.sub(t1[i], findeq+1)
          ops[bef] = aft
        end
      end
    end

    --处理类型
    if fieldtype == "str" then
      --字符类型
      allDefault[i] = ops["D"] or ""--字符串默认的默认值为空字符串
      local isUTF8 = ops["UTF8"]
      local function decodeVal(dataT,val)
        if isUTF8 then
          val = c.gbk2utf8(val)
        end
        dataT[fieldname] = val
        if ops["SKILL"] then
          if g.skills[val]==nil then error("wrong skillname:"..val) end
        end
        if ops["ATTR"] then
          if g.main_attr[val]==nil then error("wrong attribute name:"..val) end
        end
      end
      allField[i] = decodeVal
    elseif fieldtype =="number" then 
      --数字类型
      allDefault[i] = ops["D"] or "0" --缺省默认值为0
      local max,min = ops["Max"],ops["Min"]
      if max then max = assert(tonumber(max)) end
      if min then min = assert(tonumber(min)) end

      local function decodeVal(dataT,val)
        val = assert(tonumber(val))
        if max then assert(val<=max) end
        if min then assert(val>=min) end
        dataT[fieldname] = val
      end
      allField[i] = decodeVal
    elseif fieldtype =="bool" then 
      --布尔类型
      allDefault[i] = ops["D"] or "ND" --需要填值不然就报错
      local function decodeVal(dataT,val)
        if val == "TRUE" then
          val= true
        elseif val == "FALSE" then
          val = false
        else
          error("invalid booleanStr")
        end
        dataT[fieldname] = val
      end
      allField[i] = decodeVal
    elseif fieldtype =="flagstable" then
      --Flags类型
      allDefault[i] = ops["D"] or "" --默认不变，就是空字符-》空table
      local function decodeVal(dataT,val)
        if ops["ADD"] then--标为增加flag，不是覆盖
          addFlags(dataT,fieldname,val)
        else
          dataT[fieldname] = flagsTable(val)
        end
        if ops["GEN_A"] then
          dataT[fieldname.."_a"] = flagsIndexTable(val)
        end
        if ops["SKILL"] then
          checkSkillType(dataT[fieldname])
        end
      end
      allField[i] = decodeVal
    elseif fieldtype =="flagsIndex" then
      --FlagsIndex类型
      allDefault[i] = ops["D"] or "ND" --默认不能为空
      local function decodeVal(dataT,val)
        dataT[fieldname] = flagsIndexTable(val)
      end
      allField[i] = decodeVal
    elseif fieldtype =="link" then 
      --链接类型
      allDefault[i] = ops["D"] or "ND" --默认没有链接要报错
      local LinkT = ops["L"] -- 字符串
      if LinkT ==nil then  
        error(string.format("Error: Link  opcode L must not empty!Form:%s,key:%s",tableName,fieldname))
      end
      local function decodeVal(dataT,val)
        dataT[fieldname] =val --这里存的是字符串类型。因为id全都是字符串
      end
      allField[i] = decodeVal

      local function LinkVal(dataT)--link执行
        local val  =dataT[fieldname]
        if val ==nil then
          return --无连接
        end
        local linkt = data[LinkT]
        if linkt == nil then 
          error(string.format("Invalid Link Table:%s!Form:%s,key:%s",LinkT,tableName,fieldname))
        end
        local target = linkt[val]
        if target == nil then
          error(string.format("Invalid Link Index:%s!Form:%s,key:%s,linkT:%s",val,tableName,fieldname,LinkT))
        end
        dataT[fieldname] = target  --链接成功
      end
      table.insert(links,LinkVal)
    elseif fieldtype =="valTable" then 
      --valTable类型
      allDefault[i] = ops["D"] or "nil" --默认为nil
      local function decodeVal(dataT,val)
        dataT[fieldname] = multiValTable(val)
      end
      allField[i] = decodeVal
    elseif fieldtype =="color3" then 
      --color3类型
      allDefault[i] = ops["D"] or "0.5|0.5|0.5" --默认灰色
      local function decodeVal(dataT,val)
        dataT[fieldname] = colorTable(val)
      end
      allField[i] = decodeVal
    elseif fieldtype =="notLoad" then 
      allDefault[i] = ""
      local function decodeVal(dataT,val)
      end
      allField[i] = decodeVal
    else
      --未知类型
      error(string.format("Error field type:%s!Form:%s,key:%s",fieldtype,tableName,fieldname))
    end
  end

  --开始取得数据
  local dataList--id to dataT
  if mode == "combine" then
    dataList = data[tableName]
    if dataList ==nil then
      error("Not Find Combine TableName "..tableName)
    end
  else
    dataList = {} --id to dataT
  end

  local indexList = {} --index to dataT
  local index = 1
  line = file:read()
  while(line) do
    local strDH = string.split(line,",") 
    if strDH[1] ~="" then --首位空行就忽略
      local dataT--单行data
      if mode == "combine" then
        dataT = dataList[strDH[1]]--从已有的取，第一位是id
        if dataT ==nil then
          error("Not Found DataT,id:"..strDH[1].." tableName:"..tableName)
        end
      else
        dataT = {}
      end


      for i=1,#strDH do
        local key = attrName[i] 
        local val = strDH[i] --表中的值
        local default = allDefault[i] --默认值
        if val =="" then
          if default == "nil" then--D=nil
            val = nil
          elseif default == "ND" then--D=ND
            error(string.format("Value Cannot be empty!Form:%s,key:%s,index:%d",tableName,key,index))
          else
            val = default
          end
        end
        if val ==nil then
          dataT[key] = nil
        else
          allField[i](dataT,val)
        end
      end
      --单个dataT生成完毕

      --不是合并的需要保存到datalist
      if mode ~= "combine" then
        dataT.noSave = true
        dataT = convertToMetaData(dataT,tableName)
        if dataList[dataT.id]~=nil then
          error(string.format("repetitive id !Form:%s,id:%s",tableName,dataT.id))
        end
        dataList[dataT.id] = dataT
      end

      indexList[index] = dataT
      index = index+1
    end
    line = file:read()
  end
  file:close()

  local displayName = tableName
  if mode == "combine" then
    local t= string.split(filePath,"/") 
    displayName = t[#t]


  end

  debugmsg(string.format("Load %s Number:%d",displayName,index-1))

  if mode == nil then
    data[tableName] = dataList
  elseif mode == "append" then
    local orgDataList = data[tableName]
    for i=1,#indexList do
      local dataT = indexList[i]
      orgDataList[dataT.id] = dataT
    end
  end

  --LINK执行
  local function LinkList()
    if #links<1 then return end
    for i=1,#indexList do
      local dataT = indexList[i]
      for j=1,#links do
        links[j](dataT)
      end
    end
  end
  return LinkList,indexList
end



local list_to_load = {}

function data.addLoadingCvs(tableName,filePath,mode)
  local at = {tableName,filePath,mode}
  table.insert(list_to_load,at)
end


local allIndexList= {}
function data.LoadAllCvs()
  local linkList = {}
  for i=1,#list_to_load do
    local at = list_to_load[i]
    local linkf,indexList=LoadCVS(at[1],at[2],at[3])
    table.insert(linkList,linkf)
    allIndexList[at[2]] = indexList
  end
  for i=1,#linkList do
    linkList[i]()
  end
  list_to_load = nil
end

function data.GetCVSIndexList(filePath)
  return allIndexList[filePath]
end

function data.FinishLoad()
  allIndexList = nil
  data.loadComplete = true
  --载入所有callback
  c.initAllCallBackFunction()
  c.initBitser()
end


