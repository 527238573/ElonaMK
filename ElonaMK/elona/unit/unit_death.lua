




function Unit:die(killer)
  if self.dead then return end --只能死一次
  self.dead = true
  rawset(self,"killer",killer)--设置killer
  
  self:drop_frames_to_map()--掉落特效到地图上
  
  --解除在地图上的位置，activeUnit列表里靠自己清理。
  if self.map then
    self.map:unitLeave(self)
  end
  --安排死亡动画。
  --
  local frame = FrameClip.createUnitFrame("red_dead")
  cmap:addSquareFrame(frame,self.x,self.y,0,30)
  g.playSound("kill",self.x,self.y) 
  
  --drop物品
  
end