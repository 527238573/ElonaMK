
--当前单位的格斗攻击效果。一般是拳，可能是爪，咬。
function Unit:get_unarmed_hit_effect()
  return "unarmed"
end


function Unit:melee_attack(target)

  --出现不能近战攻击的情况，debuff之类。
  if target ==self then return end

  local attack_cost_time = self:melee_cost()  --攻击耗时
  local fhit = self:attack_animation(target,attack_cost_time)
  
  
  local meleeList= self.weapon_list.melee
  local atk_intv = math.max(0.1,0.3 -#meleeList*0.05)
  for i=1,#meleeList do
    local oneWeapon = meleeList[i]
    self:melee_weapon_attack(target,oneWeapon,fhit+(i-1)*atk_intv)--2武器间隔0.2，4武器间隔0.1
  end
  
end



--攻击耗时，返回实际delay时间单位。
function Unit:melee_cost()
  return 0.7
end

--单个武器的攻击。一次近战攻击中可能多段不同武器攻击（双持）
function Unit:melee_weapon_attack(target,weapon,fdelay)
  --确定 hir_effect
  local hit_effect;
  local weaponItem = weapon.item
  if weapon.unarmed then 
    hit_effect = self:get_unarmed_hit_effect() 
  else
    hit_effect = weaponItem:getRandomHitEffect()
  end
  
  --命中判定
  local hit = rnd(0,3)
  if hit ==0 then
    --未命中
    target:melee_miss_animation(self,fdelay,hit_effect)
  else
    target:melee_hit_animation(self,fdelay,hit_effect)
    
    --------          伤害值   类型0真实1物理2魔法      固定穿透，百分比穿透，子类型
    local  dam_ins = {dam = 10,dtype = 1,resist_pen =0,resist_mul = 0,subtype = nil,} --damage的格式，不使用metatable
    if hit_effect == "bash" or hit_effect == "light_bash" then
      dam_ins.subtype = "bash" --钝击
    elseif hit_effect =="cut" then
      dam_ins.subtype = "cut" --劈砍
    elseif hit_effect =="stab" or hit_effect == "spear" then
      dam_ins.subtype = "stab" --穿刺
    end
    
    target:deal_damage(self,dam_ins,fdelay)
  end
  
end




function Unit:attack_animation(destunit,costtime)
  costtime = math.max(0.2,costtime)--不能小于0.2秒，因为伤害生效时间为0.2秒，时间太短动画也没有意义
  local interval_time = 0.2*((math.min(costtime,0.5)-0.2)/0.3)--间隔停顿，0-0.2秒，取决于costtime
  local anim_time = math.min(0.6,costtime-interval_time)--动画时常不能超过0.6秒，暂定，太长为完全慢动作？
  local time1 = anim_time*0.33 --一阶段时长
  local delay1 = math.min(0,time1-0.1)--小于0.1无delay


  local dx,dy =  destunit.x -self.x ,destunit.y - self.y

  local clip  = AnimClip.new("moveAndBack",anim_time,time1,dx*28,dy*28)
  self:addClip(clip)
  self:add_delay(costtime,"melee_attack")
  return time1
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
  elseif hit_effect =="cut" then
    cuttingEffect(self,dx,dy,hit_dx,hit_dy,frame_delay)
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
  local clip  = AnimClip.new("impact",0.2,tdx,tdy,delay)
  self:addClip(clip)
end

--未击中的动画
function Unit:melee_miss_animation(source_u,delay,hit_effect)
  local sound = "swing_mid"
  if hit_effect == "bash" then sound = "swing_heavy" end
  if hit_effect == "stab" or hit_effect == "spear" then sound = "swing_light" end
  g.playSound_delay(sound,self.x,self.y,delay)
   --当源头是自己时弹出miss字样
  if source_u ==p.mc then
    local frame = FrameClip.createUnitFrame("miss",0,-16,delay)
    frame.drop_to_map = true
    self:addFrameClip(frame)
    frame.updateFunc = function(self,dt) self.dy = self.dy +dt*64 end
  end
end