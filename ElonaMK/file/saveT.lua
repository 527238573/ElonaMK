
local tableLookup--防止循环引用,查找table

local function serialize(o,blank,filehandle)
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
    if tableLookup[o]~=nil then error("circle reference") end
    tableLookup[o] = true --防止循环引用
    
		filehandle:write("{\n")
		filehandle:write(blank)
		for k,v in pairs(o) do
			if type(k) == "number" then
				filehandle:write("\t[");filehandle:write(k);filehandle:write("] = ")
			else
				filehandle:write("\t",k," = ")
			end
			serialize(v,blank.."\t",filehandle)
			filehandle:write(",\n")
			filehandle:write(blank)
		end
		filehandle:write("}")
	else error("cannot serialize a "..type(o))
	end
end

--// The Save Function
function table.save(  tbl,filename )
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
  file:write("return ")
	serialize(tbl,"",file)
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

function table.load( sfile )
  local tables,err
	-- catch marker for stringtable
	if string.sub( sfile,-3,-1 ) == "--|" then
		tables,err = loadstring( sfile )
	else
		tables,err = loadfile( sfile )
	end
	if err then return nil,err
	end
	return tables()
end
