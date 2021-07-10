local bitser = require"file/bitser"

--所有callback都应该声明在这个table里
CB = {}
local func_to_id = {}
local id_to_func ={empty_func = function()end}
--启用重复
setmetatable(CB,{
  __index = id_to_func,
  __newindex = function(o,k,v)
    assert(id_to_func[k] ==nil,"CB: Duplicated callback funciton name found!")
    id_to_func[k] = v
  --debugmsg("insert function")
  end
})

function c.initAllCallBackFunction()
  --放弃重复性检查
  CB = id_to_func
  local num = 0
  for k,v in pairs(CB) do
    assert(type(v)=="function")
    func_to_id[v] = k
    num =num +1
  end
  debugmsg(string.format("Load CallBack Function:%d",num))
end

function checkSaveFunc(func)
  if func_to_id[func]==nil then error("check save func failed!!") end 
end

local saveClass= {}--各种class类型 
local ClassNil = {}
function saveMetaType(name,metaT,nilT)
  saveClass[name] = metaT
  metaT.saveType = name
  metaT.__index = metaT
  if nilT then ClassNil[name] = nilT end
end
function GetSavedClass()
  return saveClass,ClassNil
end



local tableLookup--防止循环引用,查找table
local subtables

--以引用形式输出table，obj为要输出的table。必须是可引用的类型
--可引用的类型有：class类型，metadata元数据。
--class类型需要
local function saveSub(filehandle,obj)
  if obj.saveType =="MetaData" then
    --储存为元数据的引用
    filehandle:write(string.format("{dataFormName = %q, id = %q }",obj.dataFormName,obj.id))
    return
  end
  local index =tableLookup[obj]
  if index==nil then
    index = #subtables+1
    subtables[#subtables+1] = obj
    tableLookup[obj] = index --保存至subtables
  elseif index ==true then
    error("saveSub error:find index==true ")--不可能出现，普通table才保存为true
  end
  filehandle:write("{saveIndex = "..tostring(index).." }")
end

--输出右值，提前声明
local serializeVal

--以完整形式输出table，及其左值  o为要输出的table
local function saveNormal(filehandle,o,blank)
  filehandle:write("{\n")
  filehandle:write(blank)
  for k,v in pairs(o) do
    if type(k) == "number" then
      filehandle:write("\t[");filehandle:write(k);filehandle:write("] = ")
    elseif type(k) == "string" then
      filehandle:write("\t",k," = ")
    elseif type(k) == "table" then --以table做key。
      if k.saveType then 
        filehandle:write("\t[")
        saveSub(filehandle,k)
        filehandle:write("] = ")
      else
        error("cannot serialize table key: table")
      end
    else
      error("cannot serialize table key:"..type(k))
    end
    serializeVal(filehandle,v,blank.."\t",o,k)
    filehandle:write(",\n")
    filehandle:write(blank)
  end
  filehandle:write("}")
end


--输出右值，判断o的类型。
function serializeVal(filehandle,o,blank,parent,valname)
  if(blank == nil) then
    blank = ""
  end
  if type(o) == "number" then
    filehandle:write(o)
  elseif type(o) == "string" then
    filehandle:write(string.format("%q",o))
  elseif type(o) == "boolean" then
    filehandle:write(tostring(o))
  elseif type(o) == "function" then
    local func_id = func_to_id[o]
    if func_id ==nil then error("save function must registered:"..o) end
    filehandle:write(string.format("{saveFuncIndex = %d}",func_id))
  elseif type(o) == "cdata" then
    parent:writeCdata(filehandle,o,valname)
  elseif type(o) == "table" then
    if o.saveType then --引用类型的table
      saveSub(filehandle,o)--存储引用
    elseif o.noSave then--跳过。
      filehandle:write("nil")
    else--普通表
      --防止多重引用。普通table装载数据不能存在于多个实体。如有需要需转化为class类型
      assert(tableLookup[o]==nil,"circle reference")
      tableLookup[o] = true --防止循环引用
      saveNormal(filehandle,o,blank)
    end
  else error("cannot serialize a "..type(o))
  end
end

local function serialize_subtables(filehandle)
  local index =1
  while index<=#subtables do
    subtables[index].saveType = subtables[index].saveType --将metatable的数据取出
    if subtables[index].preSave then subtables[index]:preSave() end
    saveNormal(filehandle,subtables[index],"")
    if subtables[index].postSave then subtables[index]:postSave() end
    
    filehandle:write(",\n")
    index = index+1
  end
end



--// The Save Function
function table.saveAdv(  tbl,filename )
  local file,err
  -- create a pseudo file that writes to a string and return the string
  if not filename then
    file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
    -- write table to tmpfile
  elseif filename == true or filename == 1 then
    file = io.tmpfile()
    -- write table to file
    -- use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
  else
    file,err = io.open( filename, "w" )
    if err then return nil,err end
  end


  tableLookup = {}
  subtables = {}
  file:write("return { main = ")
  serializeVal(file,tbl,"")
  file:write(",\n")
  serialize_subtables(file)
  file:write("}")
  subtables = nil
  tableLookup = nil
  -- Return Values
  -- return stringtable from string
  if not filename then
    -- set marker for stringtable
    return file.str.."--|"
    -- return stringttable from file
  elseif filename == true or filename == 1 then
    file:seek ( "set" )
    -- no need to close file, it gets closed and removed automatically
    -- set marker for stringtable
    return file:read( "*a" ).."--|"
    -- close file and return 1
  else
    file:close()
    return 1
  end
end


--只link一个classTable，包括其所有key和val，和下属子普通table所有key，val
local function linkOneTable(t,tables)

  local tolinkKey  = nil
  for k,v in pairs(t) do
    if type(k) =="table" then
      if k.saveIndex then
        if tolinkKey ==nil then tolinkKey = {} end
        table.insert(tolinkKey,{k,tables[k.saveIndex]}) --装入
      elseif k.dataFormName then --metadata
        if tolinkKey ==nil then tolinkKey = {} end
        local met = assert(data[k.dataFormName][k.id],"MetaData Link error")
        table.insert(tolinkKey,{k,met}) --装入
      else
        error("table as key")--不能执行到这一步,普通table不能用作key
      end
    end
    if type(v) == "table" then
      if v.saveIndex then --class
        t[k] = tables[v.saveIndex]
      elseif v.dataFormName then --metadata
        t[k] = assert(data[v.dataFormName][v.id],"MetaData Link error")
      elseif v.saveFuncIndex then --callback function
        local func = CB[v.saveFuncIndex]
        if func ==nil then 
          debugmsg ("find saveFunc id error:"..v.saveFuncIndex)
          func = CB.empty_func --找不到，可能删除了，用empty function替代
        end
        t[k] = func
      else --normal table
        linkOneTable(v,tables)
      end
    end
  end
  --link key
  if tolinkKey then
    for _,v in ipairs( tolinkKey ) do
      t[v[2]],t[v[1]] =  t[v[1]],nil
    end
  end
  if t.saveType then
    local metat = saveClass[t.saveType]
    setmetatable(t,metat)
    if t.loadfinish then
      t:loadfinish()
    end
  end

end


function table.loadAdv( sfile )
  local tables,err
  -- catch marker for stringtable
  if string.sub( sfile,-3,-1 ) == "--|" then
    tables,err = loadstring( sfile )
  else
    tables,err = loadfile( sfile )
  end
  if err then 
    return nil,err
  end
  tables = tables()
  if tables.main.saveIndex then --如果save的首个table是class
    tables.main = tables[tables.main.saveIndex]
  else
    linkOneTable(tables.main,tables)
  end
  for i=1,#tables do
    linkOneTable(tables[i],tables)
  end
  return tables.main
end



local function deSub(obj)
  if obj.saveType =="MetaData" then
    return {dataFormName = obj.dataFormName, id = obj.id}
  end
  local index =tableLookup[obj]
  if index==nil then
    
    index = #subtables+1
    subtables[#subtables+1] = obj
    tableLookup[obj] = index --保存至subtables
  elseif index ==true then
    error("deSub error:find index==true ")--不可能出现，普通table才保存为true
  end
  return {saveIndex = index}
end

local function decomposeOneTable(o)
  local tolinkKey  = nil
  local keyToDel = nil
  
  for k,v in pairs(o) do
    
    local typek = type(k)
    if typek== "table" then --以table做key。
      if k.saveType then 
        if tolinkKey ==nil then tolinkKey = {} end
        table.insert(tolinkKey,{k,deSub(k)}) --装入
      else
        error("cannot serialize table key: table")
      end
    elseif typek ~="string" and typek~="number" then
      error("cannot serialize table key:"..typek)
    end
    
    local typev = type(v)
    if typev== "function" then --以table做key。
      local func_id = func_to_id[v]
      if func_id ==nil then error("save function must registered:"..v) end
      o[k] = {saveFuncIndex = func_id}
    elseif typev== "table" then 
      if v.saveType then --引用类型的table
        o[k] = deSub(v) --重组
      elseif v.noSave then--跳过。
        if keyToDel ==nil then keyToDel = {} end
        keyToDel[k] = true
        --弃用
      else--普通表
        --防止多重引用。普通table装载数据不能存在于多个实体。如有需要需转化为class类型
        assert(tableLookup[v]==nil,"circle reference")
        tableLookup[v] = true --防止循环引用
        decomposeOneTable(v)--递归分解
      end
    elseif typev~="number" and typev~="string" and typev~="boolean" then
      error("cannot decompose a "..typev)
    end
  end
  --有删除旧key的删除
  if keyToDel then
    for k,v in pairs( keyToDel ) do
      o[k] = nil
    end
  end
  --有交换旧KEY到新key的交换
  if tolinkKey then
    for _,v in ipairs( tolinkKey ) do
      o[v[2]],o[v[1]] =  o[v[1]],nil
    end
  end
  
end

local function decompose_subtables()
  local index =1
  while index<=#subtables do
    subtables[index].saveType = subtables[index].saveType --将metatable的数据取出
    if subtables[index].preSave then subtables[index]:preSave() end
    setmetatable(subtables[index],nil) --清除metatable
    decomposeOneTable(subtables[index])
    index = index+1
  end
end


--将table拆分成可传输的形式，没有cycle，没有特殊类型。拆分逻辑与上面保存一致
--用于线程间table数据传输
function table.decompose(tbl)
  tableLookup = {}
  subtables = {}
  
  --返回值
  local ret = {main = tbl}
  decomposeOneTable(ret)
  decompose_subtables()
  for i=1,#subtables do
    ret[i] = subtables[i]
  end
  
  subtables = nil
  tableLookup = nil
  
  return ret
end

--将table重组为原本的格式。
--用于线程间table数据传输
function table.recompose(tables)
  --与原一致
  if tables.main.saveIndex then --如果save的首个table是class
    tables.main = tables[tables.main.saveIndex]
  else
    linkOneTable(tables.main,tables)
  end
  for i=1,#tables do
    linkOneTable(tables[i],tables)
  end
  return tables.main
end

function c.initBitser()
  for k,v in pairs(CB) do --登记funciton resource
    bitser.register(k,v)
  end
  for k,v in pairs(saveClass) do
    bitser.registerClass(k,v)
  end

end

function table.saveBitser( tbl,filename)
  assert(type(filename)=="string")
  
  local file,err
  file,err = io.open( filename, "wb" )
  if err then return nil,err end

  file:write(bitser.dumps(tbl))
  file:close()
  return 1
end

function table.loadBitser(filename)
  
  assert(type(filename)=="string")
  
  local file,err
  file,err = io.open( filename, "rb" )
  if err then return nil,err end
  local filestr = file:read("*all")
  file:close()
  return bitser.loads(filestr)
end

function c.LoadFile(filename)
  if string.sub(filename,-4,-1)== ".lua" then
    return table.loadAdv(filename)
  else
    return table.loadBitser(filename)
  end
end

function c.SaveFile(tbl,filename)
  if string.sub(filename,-4,-1)== ".lua" then
    return table.saveAdv(tbl,filename)
  else
    return table.saveBitser(tbl,filename)
  end
  
end
