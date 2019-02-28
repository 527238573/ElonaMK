

function g.fastStart()
  p = Player.new()
  p.calendar:setDate(1,1,1) --517年1月1日8点
  
  cmap = Map.createFromTemplateId("Vernis")
  local mc = Unit.createMC("cat","warrior")
  p.mc = mc
  p.team[1] = mc
  cmap:unitEnter(mc,38,20,true)
  
  
  
  
  
  g.initCamera()
  g.camera:updateRect(cmap)
  g.camera:setCenter(38*64,20*64)
end