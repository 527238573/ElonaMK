


saveClass= {}--各种class类型  


local tableLookup--防止循环引用,查找table
local subtables

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
  elseif type(o) == "table" then
    local function savenormal()
      filehandle:write("{\n")
      filehandle:write(blank)
      for k,v in pairs(o) do
        if type(k) == "number" then
          filehandle:write("\t[");filehandle:write(k);filehandle:write("] = ")
        elseif type(k) == "string" then
          filehandle:write("\t",k," = ")
        else
          error("cannot serialize table key:"..type(k))
        end
        serialize(v,blank.."\t",filehandle)
        filehandle:write(",\n")
        filehandle:write(blank)
      end
      filehandle:write("}")
    end
    local function saveSub()
      local index =tableLookup[o]
      if index==nil then
        index = #subtables+1
        subtables[#subtables+1] = o
        tableLookup[o] = index --保存至subtables
      end
      filehandle:write("{saveIndex = "..tostring(index).." }")
    end
    
    if o.saveType then --能够circle的类型。
      if savesub == tableLookup[o] and savesub~=nil then --savesub正在存储此table
        savenormal()
      else
        --存储引用
        saveSub()
      end
    else --普通表
      if tableLookup[o]~=nil then --有引用
          error("circle reference") 
      end
      tableLookup[o] = true --防止循环引用
      savenormal()
    end
  else error("cannot serialize a "..type(o))
  end
end

local function serialize_subtables(filehandle)
  local index =1
  while index<=#subtables do
    subtables[index].saveType = subtables[index].saveType 
    serialize(subtables[index],"",filehandle,index)
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
  for k,v in pairs(t) do
    if type(v) == "table" then
      if v.saveIndex then
        t[k] = tables[v.saveIndex]
      else
        linkOneTable(v,tables)
      end
    end
  end
  
  if t.saveType then
    local metat = saveClass[t.saveType]
    setmetatable(t,metat)
    if t.loadfinish then
      t:loadfinsh()
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
