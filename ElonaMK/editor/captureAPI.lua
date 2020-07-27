
--抓取自动提示到指定文件夹
local filePath = "F:\\ProgramingTool\\zeroBraneStudio\\api\\lua\\elonaMK.lua"
--local filePath = "D:\\elonaMK.lua"

function editor.captureAPI()
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
      local typestr = "value"
      if type(val) =="function" then
        if kname =="new" then
          typestr ="function"
        else
          typestr ="method"
        end
      end
      
      local memberDes = {
          type = typestr,
          description = name.."."..kname,
      }
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
  local function loadClassVar(cname,varname)
    local class,ntable = saveClass[cname],ClassNil[cname]
    local varDes = {
        type = "class",
        description = varname.." Class:"..cname,
        childs = {},
      }
    tosave[varname] = varDes
    local function loadMember(kname,val)
      if kname =="__index" or kname =="__newindex" or kname =="saveType" or kname =="new" then return end
      local typestr = "value"
      if type(val) =="function" then
        typestr ="method"
      end
      
      local memberDes = {
          type = typestr,
          description = cname..":"..kname,
      }
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
  
  loadClassVar("Unit","unit")
  loadClassVar("Item","item")
  loadClassVar("Map","map")
  loadClassVar("Ability","abi")
  
  local res,err = table.save(tosave, filePath)
  if res then
    debugmsg("capture done. save at:"..filePath)
  else
    debugmsg("error:"..err)
  end
end