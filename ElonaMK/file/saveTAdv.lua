

local func_to_id = {}
local id_to_func = {}
function saveFunction(func) --保存回调函数，使回调函数可以保存在文件中。
  assert(type(func)=="function")
  if func_to_id[func]~=nil then debugmsg("save func repetition!");return end --已经存过。
  table.insert(id_to_func,func)
  func_to_id[func] = #id_to_func
end
local empty_func = function()end
saveFunction(empty_func) --第一个函数始终为空。跨版本读取文件，所有回调都会变成空函数。
function checkSaveFunc(func)
  if func_to_id[func]==nil then error("check save func failed!!") end --已经存过。
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


local function saveSub(filehandle,obj)
  local index =tableLookup[obj]
  if index==nil then
    index = #subtables+1
    subtables[#subtables+1] = obj
    tableLookup[obj] = index --保存至subtables
  elseif index ==true then
    error("saveSub error:find index==true ")
  end
  filehandle:write("{saveIndex = "..tostring(index).." }")
end


--simp
local function serialize(o,blank,filehandle,savesub)
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
  elseif type(o) == "table" then
    
    local function savenormal()
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
        serialize(v,blank.."\t",filehandle)
        filehandle:write(",\n")
        filehandle:write(blank)
      end
      filehandle:write("}")
    end
    
    if o.saveType then --能够circle的类型。
      if savesub == tableLookup[o] and savesub~=nil then --savesub正在存储此table
        savenormal()
      else
        --存储引用
        saveSub(filehandle,o)
      end
    else --普通表
      if o.noSave then
        --跳过。通常是固定类型数据等。
        filehandle:write("nil")
      else
        if tableLookup[o]~=nil then --有引用
          error("circle reference") 
        end
        tableLookup[o] = true --防止循环引用
        savenormal()
      end
    end
  else error("cannot serialize a "..type(o))
  end
end

local function serialize_subtables(filehandle)
  local index =1
  while index<=#subtables do
    subtables[index].saveType = subtables[index].saveType --将metatable的数据取出
    if subtables[index].preSave then subtables[index]:preSave() end
    serialize(subtables[index],"",filehandle,index)
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
  serialize(tbl,"",file)
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



local function linkOneTable(t,tables)
  
  local tolinkKey  = nil
  for k,v in pairs(t) do
    if type(k) =="table" then
      if k.saveIndex then
        if tolinkKey ==nil then tolinkKey = {} end
        table.insert(tolinkKey,{k,tables[k.saveIndex]}) --装入
      else
        --for k1,v1 in pairs(k) do
        --  debugmsg(tostring(k1).." = "..tostring(v1))
        --end
        error("table as key")--不能执行到这一步,普通table不能用作key
      end
    end
    if type(v) == "table" then
      if v.saveIndex then
        t[k] = tables[v.saveIndex]
      elseif v.saveFuncIndex then --解析为
        local func = id_to_func[v.saveFuncIndex]
        if func ==nil then error ("find saveFunc id error:"..v.saveFuncIndex) end
        t[k] = func
      else
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
  if tables.main.saveIndex then
    tables.main = tables[tables.main.saveIndex]
  else
    linkOneTable(tables.main,tables)
  end
  for i=1,#tables do
    linkOneTable(tables[i],tables)
  end
  return tables.main
end
