--mapgen数据
local Vernis = {}
data.mapgen.Vernis = Vernis



function Vernis.generate(newmap,template)
  newmap.name = tl("韦尔尼斯","Vernis")
  newmap.can_exit = true
  rawset(newmap,"wmap_cord",{26,31})
  rawset(newmap,"north_entrance",{32,49})
  rawset(newmap,"south_entrance",{51,0})
  rawset(newmap,"east_entrance",{69,20})
  rawset(newmap,"west_entrance",{0,25})
  --map 生成设置。
end

function Vernis.enter(map)
  
  
end

--一般没用
function Vernis.leave(map)
  
  
end