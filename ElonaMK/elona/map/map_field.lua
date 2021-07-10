

function Map:rebuildFieldGrid()
  local empty = c.empty
  local fieldGrid = {noSave = true}
  self.field = fieldGrid
  for i=1,self.w*self.h do
    fieldGrid[i] = empty
  end
  --重建unitGrid
  --if self.activeFieldLists ==nil then return end
  for list,_ in pairs(self.activeFieldLists) do
    fieldGrid[list.y*self.w+list.x+1] = list
  end
end



function Map:clearFieldLists()
  
  local leaveFieldLists = {}
  for list,_ in pairs(self.activeFieldLists) do
    if #list==0 then 
      table.insert(leaveFieldLists,list)
    end
  end
  for _,list in ipairs(leaveFieldLists) do
    self.activeFieldLists[list]=nil
    self.field[list.y*self.w+list.x+1] = c.empty
  end
  
end


--默认force为false，若为true则强行创建。否则返回nil
function Map:getFieldList(x,y,force)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self.field[y*self.w+x+1]
  if list== c.empty then list =nil end
  
  if list==nil and force then 
    list = FieldList.new(self,x,y)
    self.field[y*self.w+x+1] = list
    self.activeFieldLists[list] = true--加入活动列表中
  end
  return list
end

--不检查直接添加。
function Map:spawnField(field,x,y)
  local list = self:getFieldList(x,y,true)
  list:add(field)
end
--强行清楚一个地格上的所有field。
function Map:clearSquareField(x,y)
  assert(x>=0 and x<=self.w-1 and y>=0 and y<=self.h-1)
  local list = self:getFieldList(x,y,false)
  if list==nil then return end
  self.activeFieldLists[list] = nil
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


function Map:fetchFieldsFrom(omap,offsetX,offsetY)
  debugmsg("copy X"..tostring(offsetX).." Y".. tostring(offsetY))
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  for x = 0,self.w-1 do
    for y = 0,self.h-1 do
      local destX = x+offsetX
      local destY = y+offsetY
      if omap:inbounds(destX,destY) then
        local index = destY*omap.w+destX+1
        local list = omap.field[index]
        if list ~= c.empty then 
          list.x = x
          list.y = y
          self.activeFieldLists[list] = true
        end
      end
    end
  end
  self:rebuildFieldGrid()
end