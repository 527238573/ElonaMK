g={
  
}

cmap = nil --当前地图
wmap = nil --大世界地图。
p = nil --当前player数据




local CameraClass = require"game/camera/camera"
function g.initCamera()
  
  --editor.topbar_H = 30
  g.rightPanel_W = 300--只有右侧主面板
  g.camera = CameraClass.new(0,0,c.win_W-g.rightPanel_W,c.win_H)--工作区域在屏幕上的起始坐标
  g.wcamera = CameraClass.new(0,0,c.win_W-g.rightPanel_W,c.win_H)--大地图下的camera
end

g.curFrame = 1
g.dt_rl = 0--标记RL的dt。
function g.update(dt)
  if p.mc.delay<=0 then
    --检查操作。
    ui.mainGameKeyCheck(dt)
  end
  g.curFrame = g.curFrame+1
  if p.mc.delay>0 then
    g.updateRL(dt)
    g.dt_rl = dt
  else
    g.dt_rl = 0
  end
  g.updateAnim(dt)
  
end


function g.updateRL(dt)
  p.calendar:updateRL(dt) --日期更新
  cmap:updateRL(dt)
end

function g.updateAnim(dt)
  cmap:updateAnim(dt)
  --g.updateSound(dt) --转移到scene最后
end

--overmap模式更新入口
function g.updateOvermap(dt)
  if p.delay<=0 then
    --检查操作。
    ui.overmapKeyCheck(dt)
  end
  if p.delay>0 then
    p:updateOM(dt)
  end

end

