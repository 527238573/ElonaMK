

function g.test1()
  if cmap then
    --[[
    local gentype = Unit.randomUnitTypeByLevel(10)
  
    for i=1,1 do
      local utype = gentype()
      local unit = Unit.create(utype.id,nil,"wild")
      cmap:monsterSpawn(unit,p.mc.x,p.mc.y+3,false)
    end
    --]]
    
    local frame = FrameClip.createUnitFrame("red_dead")
    cmap:addSquareFrame(frame,p.mc.x,p.mc.y+1,0,30)
    g.playSound("kill",p.mc.x,p.mc.y+1)
    
    
    
    local proj = Projectile.new("bullet1")
    
    local sc = p.team[2]
    proj:attack(p.mc,nil,nil,sc,sc.x,sc.y)
    
  end
  
  -- ui.ynAskWin:Open(callb,"什么问题什么问题什么问题什么问题什么问题什？")
  
end