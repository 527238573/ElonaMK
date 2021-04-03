--储存player信息。
Player = {
  
  calendar = 0,--日期。
  teamNum = 4,--常数
}
local niltable = { --默认值为nil的成员变量
    mc = true, --当前角色，是小队其中一个。
    team = true,--小队角色最多4个
    clip = true,--占位
  }

saveMetaType("Player",Player,niltable)--注册保存类型

Player.__newindex = function(o,k,v)
  if Player[k]==nil and niltable[k]==nil then error("使用了Player的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
end


function Player:loadfinish()
  
end

function Player.new()
  local o= {}
  o.gold = 0
  o.team = {}
  o.calendar = Calendar.new()
  o.inv = Inventory.new(false,o)
  o.delay = 0--大地图移动操作延迟
  o.x =1 --大地图上的坐标
  o.y =1
  o.status={rate=0,dx = 0,dy =0,dz = 0,face = 8,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,} --动画状态
  setmetatable(o,Player)
  return o
end
