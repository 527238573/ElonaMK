data = {}

local dataMeta = {
  noSave = true
  
}
data.dataMeta = dataMeta
dataMeta.__index = dataMeta
dataMeta.__newindex = function(o,k,v)
  if data.loadComplete  then 
    error("load完毕后不能修改data数据。") 
  else 
    rawset(o,k,v) 
  end
end

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

local function convertToMetaData(targetT)
  if UseMetaDataStrict then
    local newT = {__source = targetT}
    setmetatable(newT,metaData)
    return newT
  else
    return targetT
  end
end











function data.strToBoolean(str,default)
  if str =="" then
    return default
  elseif str =="FALSE" then
    return false
  elseif str =="TRUE" then
    return true
  else
    error("invalid booleanStr")
  end
end

function data.flagsTable(flagstr)
  if flagstr =="" then return {} end
  local t1 = string.split(flagstr,"|")
  local ret = {}
  for i=1,#t1 do
    ret[t1[i]] = true
  end
  return ret
end

function data.addFlags(dataT,valname,flagstr)
  local flagt = dataT[valname]
  if flagt ==nil then
    dataT[valname] = data.flagsTable(flagstr)
  elseif flagstr ~="" then
    local t1 = string.split(flagstr,"|")
    for i=1,#t1 do
      flagt[t1[i]] = true
    end
  end
end
--使用数组来排列flag

function data.flagsIndexTable(flagstr)
  if flagstr =="" then return {} end
  return string.split(flagstr,"|")
end

function data.colorTable(colorstr,r,g,b)
  if colorstr =="" then return {r,g,b} end
  local t1 = string.split(colorstr,",")
  return t1
end



--读取整个表格，预定按格式。读取完成后还需要处理
--tableName是data.xxx的名字，保存路径 如"class",表示表读取完成后存储在data.class   
--filePath是"data/unit/class.csv"这样的
--mode = nil 正常添加整张表，覆盖data[tableName]  mode = "append" 覆盖式增加新条目  "combine"  向已有的项中添加/覆盖数据，只能向已存在的添加，否则报错
--返回：LinkList函数，表载入完毕后执行可能的链接
function data.LoadCVS(tableName,filePath,mode)
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
          data.addFlags(dataT,fieldname,val)
        else
          dataT[fieldname] = data.flagsTable(val)
        end
        if ops["GEN_A"] then
          dataT[fieldname.."_a"] = data.flagsIndexTable(val)
        end
      end
      allField[i] = decodeVal
    elseif fieldtype =="flagsIndex" then
      --FlagsIndex类型
      allDefault[i] = ops["D"] or "ND" --默认不能为空
      local function decodeVal(dataT,val)
        dataT[fieldname] = data.flagsIndexTable(val)
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
      dataT = convertToMetaData(dataT)
      if dataList[dataT.id]~=nil then
        error(string.format("repetitive id !Form:%s,id:%s",tableName,dataT.id))
      end
      dataList[dataT.id] = dataT
    end
    
    indexList[index] = dataT
    line = file:read()
    index = index+1
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
