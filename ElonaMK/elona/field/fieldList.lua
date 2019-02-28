--用来存放field的list，一个地格可以有多个field，所以一个地格对应一个list。
FieldList = { 
  --一些默认值
  saveType = "FieldList",--注册保存类型
  x=0,
  y=0,
}
saveClass["FieldList"] = FieldList --注册保存类型
FieldList.__index = FieldList



function FieldList.new(map,x,y)
  local o= {}
  o.map = map
  o.x =x
  o.y = y
  setmetatable(o,FieldList)
  return o
end


function FieldList:add(field)
  field.parent = self
  field.map = self.map
  field.x = self.x
  field.y = self.y
  for i=1,#self do
    if field.type.priority <= self[i].type.priority then
      table.insert(self,i,field)
      return
    end
  end
  table.insert(self,field)
end

function FieldList:remove(field)
  for i=1,#self do
    if self[i] ==field then
      table.remove(self,i)
      field.map =nil
      field.parent = nil
      return 
    end
  end
  debumsg("Warning:FieldList cant find removing field")
end


function FieldList:removeAll()
  for i=#self,1,-1 do
    local field = self[i]
    table.remove(self,i)
    field.map =nil
    field.parent = nil
  end
end
