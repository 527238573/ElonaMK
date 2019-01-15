ui.overmap = {}
local ov = ui.overmap


function ui.overmap.init()
  ov.right_w = 250
  --state
  ui.show_overmap = false
  
  ov.cur_Z = 1-- 当前观察Z层数
  
  ov.view_W = c.win_W - ov.right_w
  ov.view_H = c.win_H
  ov.viewX=0
  ov.viewY=0
  
  ov.half_seen_W = ov.view_W/2
  ov.half_seen_H = ov.view_H/2
  
  ov.center_minX = 0
  ov.center_maxX = 32*256 --测试数据
  ov.center_minY = 0
  ov.center_maxY = 32*256
  
  ov.setCenter(0,0)
end


function ov.setCenter(x,y)
  ov.centerX = c.clamp(x,ov.center_minX,ov.center_maxX)
  ov.centerY = c.clamp(y,ov.center_minY,ov.center_maxY)
  ov.updateSeenRect()
end

function ov.updateSeenRect()
  ov.seen_minX = ov.centerX -ov.half_seen_W
  ov.seen_maxX = ov.centerX +ov.half_seen_W
  ov.seen_minY = ov.centerY -ov.half_seen_H
  ov.seen_maxY = ov.centerY +ov.half_seen_H
end

function ov.modelToScreen(x,y)
  return (x-ov.seen_minX)+ov.viewX,(ov.seen_maxY-y)+ov.viewY--注意maxY，模型坐标轴与屏幕坐标Y轴相反
end

function ov.screenToModel(x,y)
  return (x-ov.viewX)+ov.seen_minX,ov.seen_maxY-(y-ov.viewY)
end

