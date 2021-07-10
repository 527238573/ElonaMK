

function Unit:attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)--间隔停顿，0-0.2秒，取决于costtime
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local midRate = 0.33 --冲锋时间占比33%

  local dx,dy =  destunit.x -self.x ,destunit.y - self.y
  local clip  = Animation.MoveAndBack(anim_time,midRate,dx*28,dy*28)
  self:addClip(clip)
  self:short_delay(costtime,"melee_attack")
  return anim_time*midRate --返回冲锋时间
end



local function lightbashEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("bash1",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("light_bash_hit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.4,-math.pi*0.2)
      else
        frame.rotation = rnd_float(0,-math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.6 then frame.flipY = true  end
      frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.1)
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.3)
      end
    end

  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.6)
      else
        frame.rotation = rnd_float(math.pi*0.2,math.pi*0.6)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true 
        if rnd()>0.5 then 
          frame.flipX = true  
          frame.rotation = rnd_float(math.pi*0.5,math.pi*0.7)
        else
          frame.rotation = rnd_float(-math.pi*0.5,-math.pi*0.7)
        end
      else
        if rnd()>0.5 then frame.flipX = true  end
      end
    end

  else
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.4,math.pi*0.2)
      else
        frame.rotation = rnd_float(0,math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.6 then frame.flipY = true  end
      frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.1)
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.3)
      else
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.3)
      end
    end
  end
  unit:addFrameClip(frame)
end

local function bashingEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("bash_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("bash_hit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.4,-math.pi*0.2)
      else
        frame.rotation = rnd_float(0,-math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.6 then frame.flipY = true  end
      frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.1)
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.3)
      end
    end

  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.6)
      else
        frame.rotation = rnd_float(math.pi*0.2,math.pi*0.6)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true 
        if rnd()>0.5 then 
          frame.flipX = true  
          frame.rotation = rnd_float(math.pi*0.5,math.pi*0.7)
        else
          frame.rotation = rnd_float(-math.pi*0.5,-math.pi*0.7)
        end
      else
        if rnd()>0.5 then frame.flipX = true  end
      end
    end

  else
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.4,math.pi*0.2)
      else
        frame.rotation = rnd_float(0,math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.6 then frame.flipY = true  end
      frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.1)
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.3)
      else
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.3)
      end
    end
  end
  unit:addFrameClip(frame)
end

local function heavyBashingEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("bash_heavy",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("bash_heavy",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    --frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.4,-math.pi*0.2)
      else
        frame.rotation = rnd_float(0,-math.pi*0.3)
      end
    elseif dy==0 then
      if rnd()>0.6 then 
        frame.flipY= true  
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.15)
      else
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.3)
      end
    else
      if rnd()>0.6 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.4)
      end
    end

  elseif dx==0 then
    if dy<0 then
      
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(math.pi*0.3,math.pi*0.6)
      else
        frame.rotation = rnd_float(-math.pi*0.36,-math.pi*0.6)
      end
    else
        frame.flipY = true 
        if rnd()>0.5 then 
          frame.rotation = rnd_float(math.pi*0.37,math.pi*0.6)
        else
          frame.flipX = true 
          frame.rotation = rnd_float(-math.pi*0.3,-math.pi*0.6)
        end
    end

  else
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.4,math.pi*0.2)
      else
        frame.rotation = rnd_float(0,math.pi*0.3)
      end
    elseif dy==0 then
      if rnd()>0.6 then 
        frame.flipY= true  
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.15)
      else
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.3)
      end
    else
      if rnd()>0.6 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*-0.5,-math.pi*0.15)
      end
    end
  end
  unit:addFrameClip(frame)
end


local function cuttingEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("cut2_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("cut_hit3",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.8,-math.pi*0.5)
      else
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.2)
      end
    elseif dy==0 then
      if 
        rnd()>0.6 then frame.flipY = true  
        frame.rotation = rnd_float(-math.pi*0.6,-math.pi*0.1)
      else
        frame.rotation = rnd_float(0,math.pi*0.5)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.25)
      else
        frame.rotation = rnd_float(math.pi*0.2,math.pi*0.7)
      end
    end
  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.3)
      end
    else
      if rnd()>0.3 then 
        if rnd()>0.5 then 
          frame.flipX = true  
          frame.rotation = rnd_float(-math.pi*0.3,-math.pi*0.7)
        else
          frame.rotation = rnd_float(math.pi*0.3,math.pi*0.7)
        end
      else
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.1)
        if rnd()>0.5 then frame.flipX = true  end
      end
    end
  else
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.8,math.pi*0.5)
      else
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.2)
      end
    elseif dy==0 then
      if 
        rnd()>0.6 then frame.flipY = true  
        frame.rotation = rnd_float(math.pi*0.6,math.pi*0.1)
      else
        frame.rotation = rnd_float(0,-math.pi*0.5)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.25)
      else
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.7)
      end
    end
  end
  unit:addFrameClip(frame)
end


local function heavyCuttingEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("cut2_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("cut_heavy2",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.9,-math.pi*0.5)
      else
        frame.rotation = rnd_float(math.pi*0.0,math.pi*0.3)
      end
    elseif dy==0 then
      if 
        rnd()>0.5 then frame.flipY = true  
        frame.rotation = rnd_float(-math.pi*0.6,-math.pi*0.3)
      else
        frame.rotation = rnd_float(math.pi*0.2,math.pi*0.6)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.25)
      else
        frame.rotation = rnd_float(math.pi*0.5,math.pi*0.8)
      end
    end
  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.2)
      else
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.2)
      end
    else
      
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.25,math.pi*0.25)
        if rnd()>0.5 then 
          frame.flipX = true  
        end
    end
  else
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.9,math.pi*0.5)
      else
        frame.rotation = rnd_float(math.pi*0.0,-math.pi*0.3)
      end
    elseif dy==0 then
      if 
        rnd()>0.5 then frame.flipY = true  
        frame.rotation = rnd_float(math.pi*0.6,math.pi*0.3)
      else
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.6)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.05,math.pi*0.25)
      else
        frame.rotation = rnd_float(-math.pi*0.5,-math.pi*0.8)
      end
    end
  end
  unit:addFrameClip(frame)
end


local function stabbingEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("stab_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("stab_hit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.5)
      else
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.3)
      end
    elseif dy==0 then
      if 
        rnd()>0.6 then frame.flipY = true  
        frame.rotation = rnd_float(0,-math.pi*0.5)
      else
        frame.rotation = rnd_float(0,math.pi*0.5)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.15,-math.pi*0.1)
      else
        frame.rotation = rnd_float(math.pi*0.2,math.pi*0.7)
      end
    end
  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(-math.pi*0.3,math.pi*0.1)
      else
        frame.rotation = rnd_float(math.pi*0.3,-math.pi*0.1)
      end
    else
      frame.flipY = true 
      if rnd()>0.5 then 
        frame.flipX = true  
        frame.rotation = rnd_float(math.pi*0.3,-math.pi*0.1)
      else
        frame.rotation = rnd_float(-math.pi*0.3,math.pi*0.1)
      end
    end
  else
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.1,math.pi*0.5)
      else
        frame.rotation = rnd_float(-math.pi*0.1,math.pi*0.3)
      end
    elseif dy==0 then
      if 
        rnd()>0.6 then frame.flipY = true  
        frame.rotation = rnd_float(0,math.pi*0.5)
      else
        frame.rotation = rnd_float(0,-math.pi*0.5)
      end
    else
      if rnd()>0.5 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.15,math.pi*0.1)
      else
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.7)
      end
    end
  end
  
  unit:addFrameClip(frame)
end

local function spearhitEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("spear_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("spear_hit",hit_dx/2,hit_dy/2,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.6 then 
        frame.rotation = rnd_float(-math.pi*0.15,-math.pi*0.35)
      else
        frame.rotation = rnd_float(-math.pi*0.45,-math.pi*0.05)
      end
    elseif dy==0 then
      if rnd()>0.6 then 
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.1)
      else
        frame.rotation = rnd_float(math.pi*0.2,-math.pi*0.2)
      end
    else
      if rnd()>0.6 then 
        frame.rotation = rnd_float(math.pi*0.15,math.pi*0.35)
      else
        frame.rotation = rnd_float(math.pi*0.45,math.pi*0.05)
      end
    end
  elseif dx==0 then
    frame.dx = hit_dx
    if dy<0 then
      if rnd()>0.6 then 
        frame.rotation = rnd_float(math.pi*0.4,math.pi*0.6)
      else
        frame.rotation = rnd_float(math.pi*0.3,math.pi*0.7)
      end
    else
      if rnd()>0.6 then 
        frame.rotation = rnd_float(-math.pi*0.4,-math.pi*0.6)
      else
        frame.rotation = rnd_float(-math.pi*0.3,-math.pi*0.7)
      end
    end
  else
    if dy<0 then
      if rnd()>0.6 then 
        frame.rotation = rnd_float(math.pi*0.15,math.pi*0.35)
      else
        frame.rotation = rnd_float(math.pi*0.45,math.pi*0.05)
      end
    elseif dy==0 then
      if rnd()>0.6 then 
        frame.rotation = rnd_float(math.pi*0.1,-math.pi*0.1)
      else
        frame.rotation = rnd_float(math.pi*0.2,-math.pi*0.2)
      end
    else
      if rnd()>0.6 then 
        frame.rotation = rnd_float(-math.pi*0.15,-math.pi*0.35)
      else
        frame.rotation = rnd_float(-math.pi*0.45,-math.pi*0.05)
      end
    end
  end
  
  unit:addFrameClip(frame)
end

local function unarmedEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("bash1",unit.x,unit.y,frame_delay) --拳击音效，暂定
  local frame = FrameClip.createUnitFrame("quanhit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  unit:addFrameClip(frame)
end

local function bitehitEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("bite_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("bitehit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  unit:addFrameClip(frame)
end

local function clawhitEffect(unit,dx,dy,hit_dx,hit_dy,frame_delay)
  g.playSound_delay("claw_hit",unit.x,unit.y,frame_delay) 
  local frame = FrameClip.createUnitFrame("clawhit",hit_dx,hit_dy,frame_delay)
  frame.drop_to_map = true
  if dx<0 then 
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.05,-math.pi*0.4)
      else
        frame.rotation = rnd_float(-math.pi*0.5,-math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.6 then frame.flipY = true  
        frame.rotation = rnd_float(math.pi*0.2,-math.pi*0.2)
      else
        frame.rotation = rnd_float(math.pi*0.2,-math.pi*0.2)
      end
    else
      if rnd()>0.6 then 
        frame.flipY = true
        frame.rotation = rnd_float(math.pi*0.5,math.pi*0.2)
      else
        frame.rotation = rnd_float(-math.pi*1.5,-math.pi*2.0)
      end
    end
  elseif dx==0 then
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipX = true 
        frame.rotation = rnd_float(math.pi*0.4,math.pi*0.7)
      else
        frame.rotation = rnd_float(-math.pi*0.3,-math.pi*0.7)
      end
    else
      if rnd()>0.5 then 
        frame.rotation = rnd_float(math.pi*0.6,math.pi*0.3)
      else
        frame.flipY = true 
        frame.rotation = rnd_float(math.pi*0.7,math.pi*0.4)
      end
    end
  else
    frame.flipX = true 
    if dy<0 then
      if rnd()>0.5 then 
        frame.flipY = true 
        frame.rotation = rnd_float(-math.pi*0.05,math.pi*0.4)
      else
        frame.rotation = rnd_float(math.pi*0.5,math.pi*0.2)
      end
    elseif dy==0 then
      if rnd()>0.4 then 
        frame.flipY = true  
        frame.rotation = rnd_float(-math.pi*0.1,-math.pi*0.5)
      else
        frame.rotation = rnd_float(math.pi*0.2,-math.pi*0.2)
      end
    else
      if rnd()>0.4 then 
        frame.flipY = true
        frame.rotation = rnd_float(-math.pi*0.2,-math.pi*0.6)
      else
        frame.rotation = rnd_float(0,-math.pi*0.3)
      end
    end
  end
  unit:addFrameClip(frame)
end


--被击中得动画
function Unit:melee_hit_animation(source_u,delay,hit_effect)
  hit_effect = hit_effect or "light_bash"
  local dx,dy =  self.x -source_u.x ,self.y - source_u.y
  local frame_delay =  math.max(0,delay-0.1)--小于0.1无delay
  local hit_dx,hit_dy = (rnd()-0.5)*(8+12*math.abs(dy))-12*dx,(rnd()-0.5)*(8+12*math.abs(dx))-12*dy
  
  
  if hit_effect =="unarmed" then
    unarmedEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="light_bash" then
    lightbashEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="bash" then
    bashingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="heavy_bash" then
    heavyBashingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="cut" then
    cuttingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="heavy_cut" then
    heavyCuttingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="stab" then
    stabbingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="spear" then
    spearhitEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="bite" then
    bitehitEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  elseif hit_effect =="claw" then
    clawhitEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
  else
    debugmsg("error: hit_effect id:"..hit_effect)
    g.playSound("bash1",self.x,self.y) 
    self:addFrameClip(FrameClip.createUnitFrame("quanhit",hit_dx,hit_dy,frame_delay))
  end


  local impact_xishu = 1
  if dx~=0 and dy~=0 then impact_xishu = 0.8 end
  local impact_rnd = (rnd()-0.5)*4 *impact_xishu    
  local tdx,tdy = 8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx
  local clip  = Animation.Impact(0.2,0.25,tdx,tdy,delay)
  self:addClip(clip)
end



function CB.missFrameMoveUp(self,dt)self.dy = self.dy +dt*64 end

function Unit:fly_miss_word(delay)
  local frame = FrameClip.createUnitFrame("miss",0,-16,delay)
  frame.drop_to_map = true
  self:addFrameClip(frame)
  frame:setFrameUpdateFunc(CB.missFrameMoveUp)
end

--未击中的动画
function Unit:melee_miss_animation(source_u,delay,hit_effect)
  local sound = "swing_mid"
  if hit_effect == "bash" then sound = "swing_heavy" end
  if hit_effect == "stab" or hit_effect == "spear" then sound = "swing_light" end
  g.playSound_delay(sound,self.x,self.y,delay)
   --当源头是自己时弹出miss字样
  if source_u ==p.mc then
    self:fly_miss_word(delay)
  end
end