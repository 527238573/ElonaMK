--[[
Copyright (c) 2020, Jasmijn Wellner

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

local VERSION = '1.1+'

local floor = math.floor
local pairs = pairs
local type = type
local insert = table.insert
local getmetatable = getmetatable
local setmetatable = setmetatable

local ffi = require("ffi")
local buf_pos = 0
local buf_size = -1
local buf = nil
local writable_buf = nil
local writable_buf_size = nil
local SEEN_LEN = {}

local function Buffer_prereserve(min_size)
  if buf_size < min_size then
    buf_size = min_size
    buf = ffi.new("uint8_t[?]", buf_size)
  end
end

local function Buffer_clear()
  buf_size = -1
  buf = nil
  writable_buf = nil
  writable_buf_size = nil
end

local function Buffer_makeBuffer(size)
  if writable_buf then
    buf = writable_buf
    buf_size = writable_buf_size
    writable_buf = nil
    writable_buf_size = nil
  end
  buf_pos = 0
  Buffer_prereserve(size)
end

local function Buffer_newReader(str)
  Buffer_makeBuffer(#str)
  ffi.copy(buf, str, #str)
end

local function Buffer_newDataReader(data, size)
  writable_buf = buf
  writable_buf_size = buf_size
  buf_pos = 0
  buf_size = size
  buf = ffi.cast("uint8_t*", data)
end

local function Buffer_reserve(additional_size)
  while buf_pos + additional_size > buf_size do
    buf_size = buf_size * 2
    local oldbuf = buf
    buf = ffi.new("uint8_t[?]", buf_size)
    ffi.copy(buf, oldbuf, buf_pos)
  end
end

local function Buffer_write_byte(x)
  Buffer_reserve(1)
  buf[buf_pos] = x
  buf_pos = buf_pos + 1
end

local function Buffer_write_raw(data, len)
  Buffer_reserve(len)
  ffi.copy(buf + buf_pos, data, len)
  buf_pos = buf_pos + len
end

local function Buffer_write_string(s)
  Buffer_write_raw(s, #s)
end

local function Buffer_write_data(ct, len, ...)
  Buffer_write_raw(ffi.new(ct, ...), len)
end

local function Buffer_ensure(numbytes)
  if buf_pos + numbytes > buf_size then
    error("malformed serialized data")
  end
end

local function Buffer_read_byte()
  Buffer_ensure(1)
  local x = buf[buf_pos]
  buf_pos = buf_pos + 1
  return x
end

local function Buffer_read_string(len)
  Buffer_ensure(len)
  local x = ffi.string(buf + buf_pos, len)
  buf_pos = buf_pos + len
  return x
end

local function Buffer_read_raw(data, len)
  ffi.copy(data, buf + buf_pos, len)
  buf_pos = buf_pos + len
  return data
end

local function Buffer_read_data(ct, len)
  return Buffer_read_raw(ffi.new(ct), len)
end

local resource_registry = {}
local resource_name_registry = {}
local class_registry = {}
local class_name_registry = {}

local serialize_value

local function write_number(value, _)
  if floor(value) == value and value >= -2147483648 and value <= 2147483647 then
    if value >= -27 and value <= 100 then
      --small int
      Buffer_write_byte(value + 27)
    elseif value >= -32768 and value <= 32767 then
      --short int
      Buffer_write_byte(250)
      Buffer_write_data("int16_t[1]", 2, value)
    else
      --long int
      Buffer_write_byte(245)
      Buffer_write_data("int32_t[1]", 4, value)
    end
  else
    --double
    Buffer_write_byte(246)
    Buffer_write_data("double[1]", 8, value)
  end
end

local function write_string(value, _)
  --debugmsg("writestring:"..value)
  if #value < 32 then
    --short string
    Buffer_write_byte(192 + #value)
  else
    --long string
    Buffer_write_byte(244)
    write_number(#value)
  end
  Buffer_write_string(value)
end

local function write_nil(_, _)
  Buffer_write_byte(247)
end

local function write_boolean(value, _)
  Buffer_write_byte(value and 249 or 248)
end

local function write_metadata(value,seen)--元数据
  Buffer_write_byte(253)
  local dataFormName = value.dataFormName
  local id = value.id
  serialize_value(dataFormName, seen)
  serialize_value(id, seen)
  --debugmsg("write metadata, name:"..dataFormName.." id:"..id.." idtype:"..type(id))
end

local function write_table(value, seen)
  if value.saveType == "MetaData" then
    write_metadata(value,seen)
    return
  end
  
  if value.noSave then --万一用作key，读取的时候就会报错
    write_nil() 
    return
  end
  
  
  local classname = class_name_registry[getmetatable(value)] -- hump.class
  if classname then
    Buffer_write_byte(242)
    serialize_value(classname, seen)
    if value.preSave then value:preSave() end
  else
    Buffer_write_byte(240)
  end
  local len = #value
  write_number(len, seen)
  for i = 1, len do
    serialize_value(value[i], seen)
  end
  local klen = 0
  for k in pairs(value) do
    if (type(k) ~= 'number' or floor(k) ~= k or k > len or k < 1) then
      klen = klen + 1
    end
  end
  write_number(klen, seen)
  for k, v in pairs(value) do
    if (type(k) ~= 'number' or floor(k) ~= k or k > len or k < 1) then
      
      --if(type(k)=="string") then debugmsg(k) end
      serialize_value(k, seen)
      serialize_value(v, seen)
    end
  end
end

local function write_cdata(value, seen)
  local ty = ffi.typeof(value)
  if ty == value then
    -- ctype
    Buffer_write_byte(251)
    serialize_value(tostring(ty):sub(7, -2), seen)
    return
  end
  -- cdata
  Buffer_write_byte(252)
  serialize_value(ty, seen)
  local len = ffi.sizeof(value)
  write_number(len)
  --
  local tyVar = tostring(ty)
  if tyVar.find(tyVar,"[?]",1,true) then
    local tylen = ffi.sizeof(ty,1)
    local nelem = len/tylen
    debugmsg(tyVar.."vla find"..nelem)
    Buffer_write_raw(value, len)
  else
    --非vla单一结构--伪造成数组
    Buffer_write_raw(ffi.typeof('$[1]', ty)(value), len)
  end
  
  --debugmsg(tostring(ty).." len:"..len)
  
  --Buffer_write_raw(ffi.typeof('$[1]', ty)(value), len)
end

local types = {number = write_number, string = write_string, table = write_table, boolean = write_boolean, ["nil"] = write_nil, cdata = write_cdata}

serialize_value = function(value, seen)
  if seen[value] then
    local ref = seen[value]
    if ref < 64 then
      --small reference
      Buffer_write_byte(128 + ref)
    else
      --long reference
      Buffer_write_byte(243)
      write_number(ref, seen)
    end
    return
  end
  local t = type(value)
  if t ~= 'number' and t ~= 'boolean' and t ~= 'nil' and t ~= 'cdata' then
    if t =='table' and value.saveType ~= "MetaData"  and value.noSave then
      --不能增加seen
    else
      seen[value] = seen[SEEN_LEN]
      seen[SEEN_LEN] = seen[SEEN_LEN] + 1
      --debugmsg("seen+1:"..seen[SEEN_LEN]..(t=="string" and value or " "))
    end
  end
  if resource_name_registry[value] then
    local name = resource_name_registry[value]
    if #name < 16 then
      --small resource
      Buffer_write_byte(224 + #name)
      Buffer_write_string(name)
    else
      --long resource
      Buffer_write_byte(241)
      write_string(name, seen)
    end
    return
  end
  (types[t] or
    error("cannot serialize type " .. t)
    )(value, seen)
end

local function serialize(value)
  Buffer_makeBuffer(4096)
  local seen = {[SEEN_LEN] = 0}
  serialize_value(value, seen)
end

local function add_to_seen(value, seen)
  insert(seen, value)
  --debugmsg("seen+1:"..#seen.. ((type(value)=="string") and value or " "))
  return value
end

local function reserve_seen(seen)
  insert(seen, 42)
  return #seen
end


local function deserialize_humpclass(instance, class)
  --debugmsg("deserialize_humpclass")
  local retc = setmetatable(instance, class)
  if retc.loadfinish then retc:loadfinish() end
  return retc
end

local function deserialize_value(seen)
  local t = Buffer_read_byte()
  --debugmsg(t)
  if t < 128 then
    --small int
    return t - 27
  elseif t < 192 then
    --small reference
    --debugmsg("rederence:"..t-127)
    return seen[t - 127]
  elseif t < 224 then
    --small string
    return add_to_seen(Buffer_read_string(t - 192), seen)
  elseif t < 240 then
    --small resource
    return add_to_seen(resource_registry[Buffer_read_string(t - 224)], seen)
  elseif t == 240 then
    --table
    local v = add_to_seen({}, seen)
    local len = deserialize_value(seen)
    for i = 1, len do
      v[i] = deserialize_value(seen)
    end
    len = deserialize_value(seen)
    for _ = 1, len do
      local key = deserialize_value(seen)
      v[key] = deserialize_value(seen)
    end
    return v
  elseif t == 241 then
    --long resource
    local idx = reserve_seen(seen)
    local value = resource_registry[deserialize_value(seen)]
    seen[idx] = value
    return value
  elseif t == 242 then
    --instance
    local instance = add_to_seen({}, seen)
    local classname = deserialize_value(seen)
    local class = class_registry[classname]
    local len = deserialize_value(seen)
    for i = 1, len do
      instance[i] = deserialize_value(seen)
    end
    len = deserialize_value(seen)
    for _ = 1, len do
      local key = deserialize_value(seen)
      instance[key] = deserialize_value(seen)
    end
    
    return deserialize_humpclass(instance, class)
  elseif t == 243 then
    --reference
    return seen[deserialize_value(seen) + 1]
  elseif t == 244 then
    --long string
    return add_to_seen(Buffer_read_string(deserialize_value(seen)), seen)
  elseif t == 245 then
    --long int
    return Buffer_read_data("int32_t[1]", 4)[0]
  elseif t == 246 then
    --double
    return Buffer_read_data("double[1]", 8)[0]
  elseif t == 247 then
    --nil
    return nil
  elseif t == 248 then
    --false
    return false
  elseif t == 249 then
    --true
    return true
  elseif t == 250 then
    --short int
    return Buffer_read_data("int16_t[1]", 2)[0]
  elseif t == 251 then
    --ctype
    return ffi.typeof(deserialize_value(seen))
  elseif t == 252 then
    local ctype = deserialize_value(seen)
    local len = deserialize_value(seen)
    local tyVar = tostring(ctype)
    if tyVar.find(tyVar,"[?]",1,true) then
      local tylen = ffi.sizeof(ctype,1)
      local nelem = len/tylen
      debugmsg(tyVar.."vla find"..nelem)
      local read_into = ctype(nelem)
      Buffer_read_raw(read_into, len)
      --debugmsg("vla read complete"..nelem)
      return read_into
    else
      local read_into = ffi.typeof('$[1]', ctype)()
      Buffer_read_raw(read_into, len)
      return ctype(read_into[0])
    end
  elseif t == 253 then
    --metadata 元数据
    add_to_seen({},seen)
    local index  = #seen--记录然后修改
    
    local dataFormName = deserialize_value(seen)
    local id = deserialize_value(seen)
    --debugmsg("read metadata, name:"..dataFormName.." id:"..id)
    
    local metad = assert(data[dataFormName][id],"MetaData Link error")
    seen[index] = metad
    return metad
  else
    error("unsupported serialized type " .. t)
  end
end




return {
  dumps = function(value)
    serialize(value)
    return ffi.string(buf, buf_pos)
  end, 
  dumpLoveFile = function(fname, value)
    serialize(value)
    assert(love.filesystem.write(fname, ffi.string(buf, buf_pos)))
  end, 
  loadLoveFile = function(fname)
    local serializedData, error = love.filesystem.newFileData(fname)
    assert(serializedData, error)
    Buffer_newDataReader(serializedData:getPointer(), serializedData:getSize())
    local value = deserialize_value({})
    -- serializedData needs to not be collected early in a tail-call
    -- so make sure deserialize_value returns before loadLoveFile does
    return value
  end, 
  loadData = function(data, size)
    if size == 0 then
      error('cannot load value from empty data')
    end
    Buffer_newDataReader(data, size)
    return deserialize_value({})
  end,
  loads = function(str)
    if #str == 0 then
      error('cannot load value from empty string')
    end
    Buffer_newReader(str)
    return deserialize_value({})
  end, 
  register = function(name, resource)
    assert(not resource_registry[name], name .. " already registered")
    resource_registry[name] = resource
    resource_name_registry[resource] = name
    return resource
  end, 
  unregister = function(name)
    resource_name_registry[resource_registry[name]] = nil
    resource_registry[name] = nil
  end, 
  registerClass = function(name, class)
    --debugmsg("regclass:"..name)
    class_registry[name] = class
    class_name_registry[class] = name
    return class
  end, 
  unregisterClass = function(name)
    class_name_registry[class_registry[name]] = nil
    class_registry[name] = nil
  end, 
  reserveBuffer = Buffer_prereserve, 
  clearBuffer = Buffer_clear, 
  version = VERSION
}
