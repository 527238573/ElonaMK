

--在背包等地方显示的名字
function Item:getDisplayName()
  if self.displayName~="" then return self.displayName end
  
  local str = self.type.name 
  if self.num>1 then
    str = string.format("%d %s",self.num , str)
  end 
  return str
end
--显示名称的颜色。
function Item:getDisplayNameColor()
  return 0,0,0 --暂用黑色。
end


--隐藏的物品。比如装在容器里，不能看见。
function Item:isHidden()
  return false
end

--标注的类型。
function Item:getSubType()
  return self.type.type
end

--绘制固定形态所用。
function Item:getImgAndQuad()
  local itype = self.type
  return itype.img,itype[1],itype.w,itype.h
end

function Item:getDrawColor()
  return 1,1,1,1
end

function Item:hasFlag(flag)
  return self.type.flags[flag]
end