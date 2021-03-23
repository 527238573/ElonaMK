data = {}

local dataMeta = {
    noSave = true
}
data.dataMeta = dataMeta

dataMeta.__index = dataMeta
dataMeta.__newindex = function(o,k,v)
  if data.loadComplete and dataMeta[k]==nil then error("修改data的意料之外的值。") else rawset(o,k,v) end
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


