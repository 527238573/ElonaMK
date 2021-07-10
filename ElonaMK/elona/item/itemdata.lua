



data.itemImgs = {}
data.itemImgs["item1"] = data.newImage("data/item/item1.png")
local itemScale = 1 --使用64*64格子的图 不能缩小到32*32，因为在1.5缩放效果看上去不佳。
--data.itemImgs["item1"]:setFilter("linear","linear")
data.addLoadingCvs("enchantment","data/item/enchantment.csv",nil)
data.addLoadingCvs("item","data/item/item.csv",nil)
data.addLoadingCvs("item","data/item/item_melee.csv","combine")
data.addLoadingCvs("item","data/item/item_range.csv","combine")
data.addLoadingCvs("item","data/item/item_body.csv","combine")
data.addLoadingCvs("item","data/item/item_accessory.csv","combine")




local function dataTLoadQuad(dataT)
  dataT.scaleFactor = itemScale
  local function loadQuad(x,y,w,h)
    data.insertQuad(dataT,x*64/itemScale,y*64/itemScale,w,h,dataT.img:getWidth(),dataT.img:getHeight())
  end
  if dataT.useAnim then
    for i=1,dataT.frameNum do
      loadQuad(dataT.quadX+(i-1)*dataT.w/(64/itemScale),dataT.quadY,dataT.w,dataT.h,dataT)
    end
  else
    loadQuad(dataT.quadX,dataT.quadY,dataT.w,dataT.h,dataT)
  end
end


return function ()
  local item_indexList =data.GetCVSIndexList("data/item/item.csv")
  local melee_indexList =data.GetCVSIndexList("data/item/item_melee.csv")
  local range_indexList =data.GetCVSIndexList("data/item/item_range.csv")
  local body_indexList =data.GetCVSIndexList("data/item/item_body.csv")
  local acc_indexList =data.GetCVSIndexList("data/item/item_accessory.csv")
  
  for i=1,#item_indexList do
    local dataT = item_indexList[i]
    --img
    local val = dataT.img 
    local img = data.itemImgs[val]
    if img ==nil then error("wrong itemImg id:"..val)  end
    dataT.img = img
    --wh
    dataT.w = dataT.w*2/itemScale
    dataT.h = dataT.h*2/itemScale
    dataT.useAnim = dataT.frameNum>1 
    if not dataT.canStack then dataT.initNum=1 end 
    --quad
      dataTLoadQuad(dataT)
  end
  
  for i=1,#melee_indexList do
    local dataT = melee_indexList[i]
    --此类型默认的值。
    dataT.weapon = true
    dataT.meleeWeapon = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end
  end
  
  for i=1,#range_indexList do
    local dataT = range_indexList[i]
    --此类型默认的值。
    dataT.weapon = true
    dataT.rangeWeapon = true--只要在这张表里的都是rangeweapon
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
    if dataT.equipType=="twohand" then
      dataT.equipType = "mainhand" --双手武器就是主手武器带双手flag
      dataT.flags["TWOHAND"] = true --
    end
  end
  
  for i=1,#body_indexList do
    local dataT = body_indexList[i]
    --此类型默认的值。
    dataT.equipType = "body"
    dataT.bodyArmor = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
  end
  
  for i=1,#acc_indexList do
    local dataT = acc_indexList[i]
    --此类型默认的值。
    dataT.equipType = "accessory"
    dataT.accessory = true
    dataT.hanging = false
    dataT.canStack = false
    dataT.initNum = 1
  end
  
  --todo需要验证skill
end