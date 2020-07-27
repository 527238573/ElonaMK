local Test = {}
g.TestList = Test


function Test.testKillEffect()
  local frame = FrameClip.createUnitFrame("red_dead")
  cmap:addSquareFrame(frame,p.mc.x,p.mc.y+1,0,30)
  g.playSound("kill",p.mc.x,p.mc.y+1)

end

function Test.attackMember2()
  local proj = Projectile.new("bullet1")
  proj.hitLevel = 10
  local sc = p.team[2]
  proj:attack(p.mc,nil,nil,sc,sc.x,sc.y)
  p.mc.target = {unit = p.mc}

end

function Test.genMonster()
  local gentype = UnitFactory.randomUnitTypeByLevel(10)

  for i=1,1 do
    local utype = gentype()
    local unit = UnitFactory.create(utype.id,nil,"wild")
    cmap:monsterSpawn(unit,p.mc.x,p.mc.y+3,false)
    unit:setFaction("wild")
  end
end

function Test.test_message()
  addmsg("aaaaaaaaaaaaaaaaaaaaaaaaa")
  addmsg("bbbbbbbbbbbbbbbbbbbb","bad")
end

function Test.grow_attr()
  --p.mc:train_attr("str",100,9999)
  p.mc:train_skill("cutting",100,999)
end

function Test.magic_circle()
  local mc = p.mc
  local frame = FrameClip.createUnitFrame("single_circle")
  frame:setLoopPeriod(4)
  frame.scaleX = 0.5
  frame.scaleY = 0.25
  frame.dy = -32
  frame.underUnit = true
  frame.rot_uv_speed = 1
  
  mc:addFrameClip(frame)
  mc:short_delay(4,"chanting")
    mc:bar_delay(4,"chant","chanting")
  --g.playSound("kill",p.mc.x,p.mc.y+1)
  local frame2 = FrameClip.createUnitFrame("small_magic")
  --frame2.scaleY = 0.5
  frame2:setLoopPeriod(4)
  frame2.rotation_speed = -0.5
   mc:addFrameClip(frame2)
   
   frame2 = FrameClip.createUnitFrame("magic_circle")
   frame2:setLoopPeriod(4)
  frame2.rotation_speed = -1
   p.team[2]:addFrameClip(frame2)
end

function Test.test_effect()
  p.mc:addEffect_chanting(3,2)
    
  local effect = Effect.new("test1")
  effect.remain = 4
  p.mc:addEffect(effect)
  
  effect = Effect.new("test2")
  effect.remain = 6
  p.mc:addEffect(effect)
end

function Test.refuel_mana()
  p.mc.mp =p.mc.max_mp
end


function g.test1()
  Test.genMonster()
  --Test.test_effect()
  --Test.magic_circle()
  --Test.grow_attr()

  -- ui.ynAskWin:Open(callb,"什么问题什么问题什么问题什么问题什么问题什？")

end