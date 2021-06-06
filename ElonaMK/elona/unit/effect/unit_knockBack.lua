
local halfTime = 0.07
--返回true,可以向下一格飞去，false，不能。
local function KnockBackCheckSquare(dx,dy,power,map,cx,cy,attacker,dam)
  local cost = (dx~=0 and dy~=0 ) and 1.4 or 1
  map:bash_square(cx,cy,power)
  if not map:can_pass(cx,cy) then
    --停止在此
    return false
  end
  
  local k_unit = map:unit_at(cx,cy)
  if k_unit~= nil then
    --碰撞效果
    local frame = FrameClip.createUnitFrame("impact3",-dx*15,-dy*15,0)
    frame.drop_to_map = true
    frame.rotation = math.pi/4 + math.atan2(-dy,dx)
    k_unit:addFrameClip(frame)
    g.playSound("bash1",cx,cy,0.7)
    
    --施加伤害(立即)
    if attacker and dam then
      if attacker:isHostile(k_unit) then
        local new_dam = dam:clone()
        new_dam.dam = new_dam.dam *power --每power的伤害
        k_unit:deal_damage(attacker,new_dam,0)
      end
    end
    
    if k_unit:is_alive() then
      --推kunit
      k_unit:KnockBack(dx,dy,power-cost-0.5,nil)
    end
    
    if map:unit_at(cx,cy) then
      --kunit活着 或仍有单位在此
      --停止在此
      return false
    end
  end
  return true
end

local function knockBackDelayFunc(unit,dx,dy,power,nx,ny,attacker,dam)
  local map = unit.map
  local cost = (dx~=0 and dy~=0 ) and 1.4 or 1
  
  if KnockBackCheckSquare(dx,dy,power,map,nx,ny,attacker,dam) then
    --前往下一格
    map:unitMove(unit,nx,ny)
    --动画
    if power< cost then--停在nx,ny处
      local clip = Animation.FreeMove(0.3,-dx*32,-dy*32,0,0)
      unit:addClip(clip)
      unit:clips_update(0)
      unit:short_delay(0.3,"knockBack")
    else
      --飞向下一格
      local clip = Animation.FreeMove(halfTime*2,-dx*32,-dy*32,dx*32,dy*32)
      unit:addClip(clip)
      unit:clips_update(0)
      unit:short_delay(halfTime*2+0.1,"knockBack")
      unit:insertAnimDelayFunc(halfTime*2,knockBackDelayFunc,unit,dx,dy,power-cost,nx+dx,ny+dy,attacker,dam)
      
      --添加击退状态（续接时间）
      local effect = Effect.new("knock_back")
      effect.remain =halfTime*2+0.1 --
      unit:addEffect(effect)
    end
  else--弹回原位
    local clip = Animation.FreeMove(0.3,dx*32,dy*32,0,0)
    unit:addClip(clip)
    unit:clips_update(0)
    unit:short_delay(0.3,"knockBack")
  end
  
end
saveFunction(knockBackDelayFunc)--使这个函数可以保存  。

--被击退 dam指的是每power的damage
function Unit:KnockBack(dx,dy,power,attacker,dam)
  
  if not self:canPush()  or  power <0.5 then 
    --仅impact，并尝试震击背后的单位、地格
    local impact_clip  = Animation.Impact(halfTime*4,0.25,dx*32,dy*32,0)
    self:addClip(impact_clip)
    return
  end
  
  local clip = Animation.FreeMove(halfTime,0,0,dx*32,dy*32)
  self:addClip(clip)
  self:short_delay(halfTime+0.1,"knockBack")
  --添加击退状态（击退状态中不能被位移）
  local effect = Effect.new("knock_back")
  effect.remain =halfTime+0.1 --
  self:addEffect(effect)
  
  
  local nx,ny = self.x +dx,self.y+dy
  self:insertAnimDelayFunc(halfTime,knockBackDelayFunc,self,dx,dy,power,nx,ny,attacker,dam)
end