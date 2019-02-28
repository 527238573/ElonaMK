local Camera 

Camera = {
    --一些默认值
  }
  
  
Camera.__index = Camera
--Camera.__newindex = function(o,k,v)
--  if Map[k]==nil then error("使用了Camera的意料之外的值。") else rawset(o,k,v) end
--end

--屏幕中的方形位置
function Camera.new(x,y,w,h)
  assert(x>=0 and x<=c.win_W and y>=0 and y<=c.win_H)
  assert(w>=300 and w<=c.win_W  and h>=300 and h<=c.win_H)
  local o={}
  o.work_W = w
  o.work_H = h
  o.workx = x
  o.worky = y--工作区域在屏幕上的起始坐标
  o.workZoom = 1; -- 可见部分缩放比例
  
  --可见区域在模型坐标的半长
  o.half_seen_W = o.work_W/o.workZoom/2
  o.half_seen_H = o.work_H/o.workZoom/2
  --可视中心点坐标及其移动范围，坐标系采用标准上Y右X，与屏幕坐标系不同
  o.center_minX = 0
  o.center_maxX = 20 *c.SQUARE_L
  o.center_minY = 0
  o.center_maxY = 20 *c.SQUARE_L
  
  setmetatable(o,Camera)
  
  o:setCenter(o.center_maxX/2,o.center_maxY/2)--初始化
  return o
end

function Camera:updateRect(map)
  self.center_minX = 0
  self.center_maxX = map.w *c.SQUARE_L
  self.center_minY = 0
  self.center_maxY = map.h *c.SQUARE_L
  
end

function Camera:setWorkZoom(z)
  self.workZoom = c.clamp(z,0.5,1)
  self.half_seen_W = self.work_W/self.workZoom/2
  self.half_seen_H = self.work_H/self.workZoom/2
  --
  if self.workZoom ==0.5 then 
    --self.centerX = self.centerX -self.centerX%2
    --self.centerY = self.centerY -self.centerY%2
  elseif self.workZoom ==0.75 then 
    --self.centerX = self.centerX -self.centerX%(4/3)
    --self.centerY = self.centerY -self.centerY%(4/3)
  end
  
  self:updateSeenRect()
end

function Camera:setCenter(x,y)
  self.centerX = c.clamp(x,self.center_minX,self.center_maxX)
  self.centerY = c.clamp(y,self.center_minY,self.center_maxY)
  
  self:updateSeenRect()
end

function Camera:updateSeenRect()
  self.seen_minX = self.centerX -self.half_seen_W
  self.seen_maxX = self.centerX +self.half_seen_W
  self.seen_minY = self.centerY -self.half_seen_H
  self.seen_maxY = self.centerY +self.half_seen_H
end


function Camera:modelToScreen(x,y)
  return (x-self.seen_minX)*self.workZoom+self.workx,(self.seen_maxY-y)*self.workZoom+self.worky--注意maxY，模型坐标轴与屏幕坐标Y轴相反
end

function Camera:screenToModel(x,y)
  return (x-self.workx)/self.workZoom+self.seen_minX,self.seen_maxY-(y-self.worky)/self.workZoom
end

function Camera:clampXY()
  local x,y = self.centerX,self.centerY
  if self.workZoom ==1 then
    x = math.floor(x+0.5)
    y = math.floor(y+0.5)
  elseif self.workZoom ==0.5 then 
    x = x +1
    y = y +1
    
    x = x -x%2
    y = y -y%2
  elseif self.workZoom ==0.75 then 
    x = x +2/3
    y = y +2/3
    x = x -x%(4/3)
    y = y -y%(4/3)
  end
  self:setCenter(x,y)
end


return Camera
