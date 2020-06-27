Effect = {
  id = "null", --type的id
  type = nil,
  level = 1,--等级(可能有部分)
  life = 0, --持续存在的时间。
  remain = 0, --剩余寿命时间。 
}

saveMetaType("Effect",Effect)--注册保存类型

function Effect:loadfinish()
  rawset(self,"type",assert(data.effect[self.id])) --
end


function Effect.new(typeid)
  local etype = assert(data.effect[typeid])
  local o= {type = etype,id = typeid}
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
  return self.type.description
end

----返回true，如果强化变动。
function Effect:updateRL(dt,unit)
  self.life = self.life+dt
  self.remain = self.remain-dt
  return false
end

--刷新所掌管的frames的持续时间。
function Effect:updateAnim(dt)
  local frames = self.frames
  if frames then
    for i=1,#frames do
      frames[i].remaining_life = self.remain
    end
  end
end

function Effect:addFrame(frame)
  self.frames = self.frames or {}
  table.insert(self.frames,frame)
  --rame.remaining_life = self.remain
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
end


--从队列里移出之后被调用。正常时间到的调用，意外移除不调用。
function Effect:onLifeEnd(unit)
  self:onRemove(unit)
  --播放消息
  if unit:isInPlayerTeam() then 
    local msg = self.type.end_message or self.end_message
    if msg then addmsg(string.format(msg,unit:getShortName()),self.type.rating or "info") end
  end
  if self.end_call then
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

function Effect:setEndCall(func,...)
  checkSaveFunc(func)
  self.end_call = {args = {...},f= func}
end