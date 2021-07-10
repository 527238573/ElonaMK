Effect = {
  id = "null", --type的id
  type = nil,
  level = 1,--等级(可能有部分)
  life = 0, --持续存在的时间。
  remain = 0, --剩余寿命时间。 
  loopSound = nil, --循环的声音id。设置后自动循环该声音。
  isAnim = nil,--是否根据Anim时间流失。
  
}

saveMetaType("Effect",Effect)--注册保存类型



function Effect.new(typeid)
  local etype = assert(data.effect[typeid])
  local o= {type = etype,id = typeid}
  o.isAnim = etype.isAnim --默认使用type类型。可被覆盖
  setmetatable(o,Effect)
  
  return o
end

--分级
function Effect:getName()
  return self.type.name
end
local default_front_c ={0,0,0} 
function Effect:getFrontColor()--名字颜色
  return self.type.front_c or default_front_c
end
local default_back_c ={0.8,0.8,0.8} 
function Effect:getBackColor() --名字框颜色。
  return self.type.back_c or default_back_c
end
--分级
function Effect:getDescription()
  if self.description ~= nil then
    return self.description
  end
  return self.type.description
end

----返回true，如果强化变动。（注意可能在角色已经死亡的情况下调用。）
function Effect:updateRL(dt,unit)
  if not self.isAnim then
    self.life = self.life+dt
    self.remain = self.remain-dt
  end
  return false
end

--刷新所掌管的frames的持续时间。
function Effect:updateAnim(dt,unit)
  if self.isAnim then
    self.life = self.life+dt
    self.remain = self.remain-dt
  end
  
  local frames = self.frames
  if frames then
    for i=1,#frames do
      frames[i].remaining_life = self.remain
    end
  end
  if self.loopSound then
    g.loopSound(self,self.loopSound,unit.x,unit.y)
  end
end

function Effect:addFrame(frame)
  self.frames = self.frames or {}
  table.insert(self.frames,frame)
end
function Effect:addClip(clip)
  self.clips = self.clips or {}
  table.insert(self.clips,clip)
end


--一种effect不能重复获得。两个相同id的effect合并。
--自动更新bonus数值。
function Effect:merege(a_effect)
  if self.type.merege then
    self.type.merege(self,a_effect)
    return
  end
  -- 默认merege方法，选取持续时间长的
  self.remain = math.max(self.remain,a_effect.remain)
  
  a_effect:onRemove(self)--将特效清除。
end




function Effect:onAddEffect(unit)
  --
end
--包括正常结束和不正常结束（被移出）。
function Effect:onRemove(unit)
  local frames = self.frames
  if frames then
    for i=1,#frames do
      frames[i].finished = true --结束。
    end
  end
  local clips = self.clips
  if clips then
    for i=1,#clips do
      clips[i].finished = true --结束。
    end
  end
end


--从队列里移出之后被调用。正常时间到的调用，意外移除不调用。
--有可能在角色已经死亡的情况下调用
function Effect:onLifeEnd(unit)
  self:onRemove(unit)
  if unit.dead then--角色已死亡的，不执行后续，视作半途中断。
    return 
  end
  --播放消息
  if unit:isInPlayerTeam() then 
    local msg = self.type.end_message or self.end_message
    if msg then addmsg(string.format(msg,unit:getShortName()),self.type.rating or "info") end
  end
  if self.end_call  and not self.isAnim then --不能在anim类型触发逻辑代码。时序逻辑应使用delayFunc
    self.end_call.f(unpack(self.end_call.args))
  end
end


function Effect:calculate_bonus(bonus)
  local mod_t = self.mod_t or self.type.mod_t
  if mod_t ==nil then return end
  for k,v in pairs(mod_t) do
    bonus[k] = bonus[k] + v
  end
end

--可以在endcall里添加逻辑，包括delaycall或衔接新Effect，但不能保证时序同步
--不能在Anim类型的EFFECT里使用。
function Effect:setEndCall(func,...)
  checkSaveFunc(func)
  self.end_call = {args = {...},f= func}
end