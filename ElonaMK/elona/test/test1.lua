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
  local gentype = Unit.randomUnitTypeByLevel(10)

  for i=1,1 do
    local utype = gentype()
    local unit = Unit.create(utype.id,nil,"wild")
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


function g.test1()
  Test.genMonster()
  --Test.grow_attr()

  -- ui.ynAskWin:Open(callb,"什么问题什么问题什么问题什么问题什么问题什？")

end