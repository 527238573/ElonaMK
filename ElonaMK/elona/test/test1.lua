
--local iconv = require"elona/test/iconv"
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
    p.mc.target = {unit = p.mc}

  end



  --local file = assert(io.open(c.source_dir.."data/item/test.txt","r"))
  --local index = 1
  --local line = file:read()

  --debugmsg((line))
  -- ui.ynAskWin:Open(callb,"什么问题什么问题什么问题什么问题什么问题什？")
  
  --local Iconv = require("iconv")
  --local iconv = require"elona/test/iconv"
  --[[
  local togbk = Iconv:openHandle("gbk", "utf-8");
  if not togbk then 
    print("create handle failed!");
    return; 
  end;
  local succ=nil;
  local value = "我爱汉字~我用UTF-8..."
  print("before iconv:"..value)
  succ,value = togbk:iconv(value);
--togbk:closeHandle();
  togbk = nil;--当没有引用时自动释放，避免了内存泄漏，当然也可以手动调用togbk:closeHandle()
  if not succ then
    value = nil;
  end
  print("after iconv:"..tostring(value));
  out:flush()]]
end