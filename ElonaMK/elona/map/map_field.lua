


--默认force为false，若为true则强行创建。否则返回nil
function Map:getFieldList(x,y,force)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self.field[y*self.w+x+1]
  if list== c.empty then list =nil end
  
  if list==nil and force then 
    list = FieldList.new(self,x,y)
    self.field[y*self.w+x+1] = list
  end
  return list
end

--不检查直接添加。
function Map:spawnField(field,x,y)
  local list = self:getFieldList(x,y,true)
  list:add(field)
  table.insert(self.activeFields,field)--加入活动列表中
  
end
--强行清楚一个地格上的所有field。
function Map:clearSquareField(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self:getFieldList(x,y,false)
  if list==nil then return end
  list:removeAll()
  self.field[y*self.w+x+1] = c.empty
end




function Map:hasField(id,x,y)
  if not (x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1) then return false end
  local list = self:getFieldList(x,y,false)
  if list ==nil then return false end
  for i=1,#list do
    if list[i].id ==id then return true end
  end
  return false 
end
