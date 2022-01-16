
--抓取自动提示到指定文件夹
local filePath = "F:\\ProgramingTool\\zeroBraneStudio\\api\\lua\\elonaMK.lua"
--local filePath = "D:\\elonaMK.lua"
local lovefs = require("file/lovefs")

--扫描文件后收集的信息收集
local funcTable
local totalLine = 0

local function findFunction(baseName,fName,memberDes)
  local base = funcTable[baseName]
  if base ==nil then
    debugmsg("cant find base:"..baseName.."."..fName)
    return
  end
  local func  = base[fName]
  if func ==nil then
    debugmsg("cant find func:"..baseName.."."..fName)
    return
  end
  memberDes.args = func.args
  if func.description then
    memberDes.description = func.description
  end
  if func.isFunc then --根据文本是否是:.来区分
    memberDes.type = "function"
  else
    memberDes.type = "method"
  end
end


local function addFunction(funcName,getargs,description)
  
  if string.find(funcName,"%s+")==1 then
    funcName = string.sub(funcName,string.find(funcName,"%a"),-1)
  end
  
  local isFunc = true
  local namet = string.split(funcName,".")
  if #namet ==1 then
    namet = string.split(funcName,":")
    isFunc = false --method
  end
  if #namet ==1 then return end --local function， or Global function
  
  if #namet>2 then
    debugmsg("3 Split Name function:"..funcName.." args: "..getargs)
    return
  end
  
  local base = funcTable[namet[1]] --get or create BaseTable(lib)
  if base ==nil then
    base = {}
    funcTable[namet[1]] = base
  end
  if base[namet[2]] then
    if namet[1]~= "abi_type" then 
      debugmsg("repeat function:"..funcName.." args: "..getargs)
    end
  else
    base[namet[2]] = {args = getargs,description = description,isFunc = isFunc}
    --debugmsg("new function:"..funcName.." args: "..getargs)
  end
  
end


local function ScanFile(filename,base)
  if not string.match(filename,".%.lua") then
    return
  end
  local file = assert(io.open(base.."/"..filename,"r"))
  
  local line_num = 5 --最大收集的注释行数
  local lines_t={}
  for i=1,line_num do lines_t[i] ="" end
  
  local line_c = file:read()
  
  while(line_c) do
    totalLine = totalLine+1
    local gets = string.match(line_c,"function [%s%a%d%.:_]+%(.*%)")
    if gets then
      local islocal = string.match(line_c,"local +function")~=nil
      
      if not islocal then
        local getargs = string.match(line_c,"%([%s%a%d_,%.]*%)")
        local funcName  = string.match(line_c,"function [%s%a%d%.:_]+%(")
        funcName = string.sub(funcName,9,-2)
        
        local description
        
        for i=1,line_num do
          local s = string.find(lines_t[i],"%s*%-%-")
          if s==1 then
            if description ==nil then
              description = string.sub(lines_t[i],s+2,-1)
            else
              description =string.sub(lines_t[i],s+2,-1).."\n"..description
            end
          else
            break --没有注释了
          end
        end
        addFunction(funcName,getargs,description)
        --debugmsg(line_c.." islocal: "..funcName)
      end
      --debugmsg(line_c.." islocal: "..(islocal and "true" or "false"))
    end
    
    --插入第一位移除最后一位
    table.insert(lines_t,1,line_c)
    table.remove(lines_t)
    line_c = file:read()
  end
  
end

local function ScanDir(fs,dirName,base)
  local link = base.."/"..dirName;
  fs:cd(link)
  for _, v in ipairs(fs.files) do
    --debugmsg(link.."/"..v)
    ScanFile(v,link)
  end
  for _, v in ipairs(fs.dirs) do
     ScanDir(fs,v,link)
  end
end

local function ScanSourceCode()
  totalLine = 0
  local fs = lovefs(c.source_dir)
  for _, v in ipairs(fs.dirs) do
    if v~="assets" and v~= "data" then
      ScanDir(fs,v,c.source_dir)
    end
  end
  debugmsg("Scan Line Num:"..totalLine)
end


function editor.ScanAPI()
  funcTable = {}
  ScanSourceCode()
  for v,t in pairs(funcTable) do debugmsg("tableName:"..v) end
end


function editor.captureAPI()
  funcTable = {}
  ScanSourceCode()
  
  
  
  local tosave = {}
  
  
  --saveClass
  local saveClass,ClassNil  = GetSavedClass()
  for name,class in pairs(saveClass) do
    local ntable =ClassNil[name] 
    
    local classDes = {
        type = "class",
        description = "Class:"..name,
        childs = {},
      }
    tosave[name] = classDes
    
    local function loadMember(kname,val)
      if kname =="__index" or kname =="__newindex" or kname =="saveType" then return end
      
      local memberDes = {
          type = "value",
          description = name.."."..kname,
      }
      if type(val) =="function" then findFunction(name,kname,memberDes) end
      if(memberDes.type ~="function") then return end
      
      classDes.childs[kname] = memberDes
    end
    
    
    for kname,val in pairs(class) do
      loadMember(kname,val)
    end
    
    if ntable then
      for kname,val in pairs(ntable) do
        loadMember(kname,val)
      end
    end
  end
  
  --将一些常用变量添加提示
  local function loadClassVar(cname,varname,ispostfix)
    local class,ntable = saveClass[cname],ClassNil[cname]
    local varDes = {
        type = "class",
        description = varname.." Class:"..cname,
        childs = {},
        postfix = ispostfix,
      }
    tosave[varname] = varDes
    local function loadMember(kname,val)
      if kname =="__index" or kname =="__newindex" or kname =="saveType" or kname =="new" then return end
      local typestr = "value"
      
      local memberDes = {
          type = typestr,
          description = cname..":"..kname,
      }
      if type(val) =="function" then findFunction(cname,kname,memberDes) end
      if(memberDes.type == "function") then return end-- ClassVar 只包含成员函数，不包含静态函数
      
      varDes.childs[kname] = memberDes
    end
    
    
    for kname,val in pairs(class) do
      loadMember(kname,val)
    end
    
    if ntable then
      for kname,val in pairs(ntable) do
        loadMember(kname,val)
      end
    end
  end
  
  
  local function loadLib(libname,lib)
    local libDes = {
        type = "lib",
        description = "Lib:"..libname,
        childs = {},
      }
    tosave[libname] = libDes
    local function loadMember(kname,val)
      
      local typestr = "value"
      if type(val) =="function" then
        typestr ="function"
      end
      
      local memberDes = {
          type = typestr,
          description = libname.."."..kname,
      }
      if type(val) =="function" then findFunction(libname,kname,memberDes) end
      libDes.childs[kname] = memberDes
    end
    for kname,val in pairs(lib) do
      loadMember(kname,val)
    end
    
  end
  
  loadLib("g",g)
  loadLib("ui",ui)
  loadLib("render",render)
  loadLib("data",data)
  loadLib("c",c)
  loadLib("UnitFactory",UnitFactory)
  loadLib("MapFactory",MapFactory)
  loadLib("ItemFactory",ItemFactory)
  loadLib("Animation",Animation)
  
  for name,class in pairs(saveClass) do
    loadClassVar(name,string.lower(name))
  end
  
  
  --loadClassVar("Unit","unit")
  --loadClassVar("Unit","source_unit")
  loadClassVar("Unit","_unit",true)--postfix, 例如t_unit,target_unit这种局域变量都可以自动提示
  --loadClassVar("Item","item")
  --loadClassVar("Map","map")
  loadClassVar("Ability","abi")
  
  local res,err = table.save(tosave, filePath)
  if res then
    debugmsg("capture done. save at:"..filePath)
  else
    debugmsg("error:"..err)
  end
  
end