Field = {
    --一些默认值
    
    type = nil,--类型数据。
    id = "null", --type的id
    name = "noname", --名字，可能同种不同子类会使用不同名字
    parent = nil, -- 父list
    color = {1,1,1,1},--自身颜色。
    life = 0,--从创建起自身存在时间。
    remain = 1,--剩余时间寿命。
    density =1, --密度。不是对所有类型都有用。
    startRnd = 0,
    x=-999,
    y=-999,
    map = nil,
    try_to_stack_with = function() return false end,
    
 }
 saveMetaType("Field",Field)--注册保存类型
Field.__newindex = function(o,k,v)
  if Field[k]==nil and k~="parent" and k~= "map" then error("使用了Field的意料之外的值。") else rawset(o,k,v) end
end



function Field.new(typeid)
  local o= {}
  local itype = assert(data.field[typeid])
  
  o.id = typeid
  o.type = itype
  o.name = itype.name
  o.life = 0
  o.remain = 1
  o.startRnd = rnd() --初始随机偏移。
  setmetatable(o,Field)
  return o
end






function Field:drawType()
  return self.type.drawType
end

function Field:is_end()
  return self.remain<= 0 
  
end


function Field:updateRL(dt)
  self.life = self.life +dt
  self.remain = self.remain-dt
  
  
end
