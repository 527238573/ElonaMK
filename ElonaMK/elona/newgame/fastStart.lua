

function g.fastStart()
  
  --g.runScene(g.mainGame_scene)
  g.runScene(g.overMap_scene)
  
  p = Player.new()
  p.calendar:setDate(1,1,1,5) --517年1月1日8点
  
  --cmap = Map.createFromTemplateId("Vernis")
  wmap = Map.createOverMapFromTemplateId("tyris1")
  cmap = Map.getOrCreateIdmap("Vernis")
  --大地图位置
  p:setPosition(26,31)
  
  local mc = Unit.createMC("Nilo","wizard")
  p.mc = mc
  p.team[1] = mc
  cmap:unitSpawn(mc,38,20,true)
  
  p.team[2] = Unit.createMC("teenage_girl","warrior")
  cmap:unitSpawn(p.team[2],35,20,true)
  
  local item = Item.create("saving_pot")
  p.inv:addItem(item)
  item = Item.create("pistol")
  p.inv:addItem(item)
  item = Item.create("pistol")
  p.inv:addItem(item)
  item = Item.create("machine_gun")
  p.inv:addItem(item)
  item = Item.create("repeating_bow")
  p.inv:addItem(item)
  item = Item.create("revolver")
  p.inv:addItem(item)
  item = Item.create("laser_gun")
  p.inv:addItem(item)
  item = Item.create("shotgun")
  p.inv:addItem(item)
  item = Item.create("heavy_mg")
  p.inv:addItem(item)
  item = Item.create("sniper_rifle")
  p.inv:addItem(item)
  
  item = Item.create("spear")
  p.inv:addItem(item)
  item = Item.create("noble_coat")
  p.inv:addItem(item)
  item = Item.create("protection_coat")
  p.inv:addItem(item)
  item = Item.create("shield_arm")
  p.inv:addItem(item)
  item = Item.create("bejeweled_necklace")
  p.inv:addItem(item)
  item = Item.create("magic_gloves")
  p.inv:addItem(item)
  item = Item.create("long_sword")
  p.inv:addItem(item)
  item = Item.create("beer_shelf")
  p.inv:addItem(item)
  item = Item.create("scarecrow1")
  p.inv:addItem(item)
  item = Item.create("kotatsu")
  p.inv:addItem(item)
  item = Item.create("bear_fur")
  p.inv:addItem(item)
  item = Item.create("toy_bear")
  p.inv:addItem(item)
  item = Item.create("goods1")
  item:set_num(10)
  p.inv:addItem(item)
  
  item = Item.create("goods2")
  p.inv:addItem(item)
  item = Item.create("empty_tub")
  p.inv:addItem(item)
  item = Item.create("potting1")
  p.inv:addItem(item)
  item = Item.create("short_bow")
  p.inv:addItem(item)
  item = Item.create("potting3")
  p.inv:addItem(item)
  item = Item.create("potting4")
  p.inv:addItem(item)
  item = Item.create("potting5")
  p.inv:addItem(item)
  item = Item.create("potting6")
  p.inv:addItem(item)
  item = Item.create("potting7")
  p.inv:addItem(item)
  item = Item.create("potting8")
  p.inv:addItem(item)
  item = Item.create("potting9")
  p.inv:addItem(item)
  item = Item.create("potting10")
  p.inv:addItem(item)
  item = Item.create("potting11")
  p.inv:addItem(item)
  item = Item.create("potting12")
  p.inv:addItem(item)
  item = Item.create("potting13")
  p.inv:addItem(item)
  item = Item.create("potting14")
  p.inv:addItem(item)
  item = Item.create("pickax")
  p.inv:addItem(item)
  item = Item.create("alchemy_tools")
  p.inv:addItem(item)
  item = Item.create("saucepot")
  p.inv:addItem(item)
  
  
  
  g.initCamera()
  g.camera:updateRect(cmap)
  g.camera:setCenter(38*64,20*64)
  g.wcamera:updateRect(wmap)
  g.wcamera:setCenter(38*64,20*64)
end