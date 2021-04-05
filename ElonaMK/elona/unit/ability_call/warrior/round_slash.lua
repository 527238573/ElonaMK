local abi_type


--[[*****************
--旋风斩 round_slash
--**************--]]
--提前声明的local function
local round_slash_frameUpdate
local apply_dam_round_slash


abi_type = data.ability["round_slash"]
abi_type.cooldown = 2
abi_type.costMana = 3
function abi_type.description(abi,unit)
  local t = {}
  --复制下面的，下面的伤害要改这里也要改
  local dice =2
  local base =5
  local face =10
  local mod = unit:getAbilityModifier(abi)
  c.addDesLine(t,tl("环形挥斩武器，造成","Slash weapon around a circle, dealing "),c.DES_WHITE)
  c.addDesLine(t,string.format("(%dr%d%+d)x%.1f",dice,face,base,mod),c.DES_SKI)
  c.addDesLine(t,tl("物理劈砍伤害。正面的目标会受到两次伤害。"," physical cut damage.The target directly in front will take damage twice."),c.DES_WHITE)
  return t
end


function abi_type.func(abi,source_unit,showmsg,target)

  local req_d = source_unit:requestDelay(1,"round_slash") 
  if not req_d then return false end --动作失败。
  
  
  
  g.playSound("swing_round_slash",source_unit.x,source_unit.y,1)
  local cface =  source_unit.status.face
  local facerot = source_unit:getFace_Rotation()
  local clip  = Animation.RoundSlash(0.2,0.6,0.2,20,facerot,cface)
  source_unit:addClip(clip)

  local frame = FrameClip.createUnitFrame("round_slash",0,0,0)
  frame:setLoopPeriod(1)
  source_unit:addFrameClip(frame)
  --source_unit.map:addSquareFrame(frame,source_unit.x,source_unit.y,0,32) --向地图添加
  frame.rotation_speed = -10.4
  frame.rotation = 0+math.pi/2-facerot+10.4*0.2
  --debugmsg("facerot:"..facerot)
  --frame.rotation_speed = -10.4
  frame:setFrameUpdateFunc(round_slash_frameUpdate)

  --计算伤害
  local dam_ins = source_unit:getAbilityDamageInstance(abi,2,10,5)
  dam_ins.dtype =1 --物理攻击
  dam_ins.subtype = "cut" --类型切砍
  --实施伤害（预）
  for i=-1,9,1 do 
    local atk_face = cface-i
    atk_face = (atk_face-1)%8+1 
    local dx,dy = c.face_dir(atk_face)
    source_unit:insertAnimDelayFunc(0.2+i*(0.6/8),apply_dam_round_slash,source_unit.map,source_unit.x+dx,source_unit.y+dy,dam_ins,source_unit)
  end

  return true,1.8,source_unit.level
end


--延迟调用
function round_slash_frameUpdate(frame,dt)
  local remaining = frame.remaining_life
  if remaining>0.8 then
    local rate = (1-remaining)/0.2
    frame.alpha = 0.3 +0.7*rate
  elseif remaining<0.2 then
    local rate = remaining/0.2
    frame.alpha = 0.3 +0.7*rate
  else
    frame.alpha = 1
  end

end
saveFunction(round_slash_frameUpdate)

function apply_dam_round_slash(map,x,y,dam_ins,source_unit)
  local unit = map:unit_at(x,y);
  if unit and source_unit:isHostile(unit) then
    local hit = unit:check_melee_hit(source_unit,dam_ins,0.1)

    local dx,dy =  unit.x -source_unit.x ,unit.y - source_unit.y
    if hit>0 then
      g.playSound("cut2_hit",x,y)
      local impact_xishu = 1.5
      if dx~=0 and dy~=0 then impact_xishu = 1.2 end
      local impact_rnd = (rnd()-0.5)*4 *impact_xishu    
      local tdx,tdy = 8*dx*impact_xishu+impact_rnd*dy,8*dy*impact_xishu+4*impact_rnd*dx
      local impact_clip  = Animation.Impact(0.2,0.25,tdx,tdy,0)
      unit:addClip(impact_clip)
      local fdx,fdy=0,0
      if dx~=0 and dy~=0 then
        fdx,fdy = -dx*10,-dy*10
      end
      
      local frame = FrameClip.createUnitFrame("cut_hit3",fdx,fdy,0)
      frame.drop_to_map = true
      frame.rotation = math.pi/4 + math.atan2(dy,-dx)
      unit:addFrameClip(frame)
    else
      unit:hitImpact(math.atan2(-dy,dx),25) 
      g.playSound("swing_heavy",x,y,1)
      unit:fly_miss_word(0)
    end
  end
end
saveFunction(apply_dam_round_slash)