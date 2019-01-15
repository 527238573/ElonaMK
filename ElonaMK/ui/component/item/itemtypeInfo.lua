


--使用itemtype创建一个临时物品，然后使用标准的iteminfo来查看信息。就是itemtype的信息。
local curType
local curTmpItem

local function createSnapshoot(curItemtype)
  if curItemtype== curType then return end
  curType = curItemtype
  curTmpItem = g.itemFactory.createItem(curItemtype.id)
end

function ui.itemtypeInfo(curItemtype,x,y,w,h,reserved_h)
  createSnapshoot(curItemtype)
  ui.iteminfo(curTmpItem,x,y,w,h,reserved_h)
end

function ui.itemtypeInfo_reset()--强行重置
  curType= nil
  curTmpItem = nil
end