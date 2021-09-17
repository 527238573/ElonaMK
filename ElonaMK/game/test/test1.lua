local Test = {}
g.TestList = Test


function Test.testKillEffect()
  local frame = FrameClip.createUnitFrame("red_dead")
  cmap:addSquareFrame(frame,p.mc.x,p.mc.y+1,0,30)
  g.playSound("kill",p.mc.x,p.mc.y+1)

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

function Test.play_sound1()
  g.playSound("charge",p.mc.x,p.mc.y)
end

function Test.saveMcTest()
  local testSavePath = love.filesystem.getSourceBaseDirectory().."/Save/testMc.lua"
  
  local tmpMap = p.mc.map
  p.mc.map = nil
  --local result,err  = table.saveAdv(  p.mc,testSavePath )
  local imc = p.mc
  p.mc = nil
  
  local comt = table.decompose(imc)
  local outmc = table.recompose(comt)
  
  p.mc = outmc
  
  p.mc.map = tmpMap
  
  debugmsg("recompose mc success")
  --print("save",result,err)
  --io.flush()
end

local thread
local ffi = require("ffi")
--local channel = love.thread.getChannel ( "a" );
function Test.testSubThread()
--  if thread ==nil then
--  thread = love.thread.newThread( "elona/gameSub.lua" )
--  thread:start()
--  end
--  channel:push("asd")
--  local tables,err = loadfile( love.filesystem.getSourceBaseDirectory().."/Save/testMc.lua" )
--  local rt =tables()
--  channel:push(rt)
  local v = ffi.new("uint16_t[?]",10,{1})--地型
  debugmsg(string.format("test ffi :%d ,%d",v[8],v[9]))
  debugmsg(type(v))
  debugmsg(string.format("%04X",1))
end
function Test.testFindpath()
  cmap:pathFind(2,2,8,8,20,3)
  
end

function g.test2()
  --g.playSound("charge2",p.mc.x,p.mc.y)
  --debugOn()
  local gentype = UnitFactory.randomUnitTypeByLevel(10)

  for i=1,1 do
    local utype = gentype()
    local unit = UnitFactory.create(utype.id,nil,"wild")
    
    
    --cmap:monsterSpawn(unit,p.mc.x,p.mc.y+3,false)
    cmap:unitPushPlace(unit,p.mc.x,p.mc.y+3)
    
    unit:setFaction("wild")
  end
  Test.refuel_mana()
  --debugOff()
end



function g.test1()
  Test.genMonster()
  --Test.test_effect()
  --Test.magic_circle()
  --Test.grow_attr()

  -- ui.ynAskWin:Open(callb,"什么问题什么问题什么问题什么问题什么问题什？")

end