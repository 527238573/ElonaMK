Unit = {
    --一些默认值
    
    type = nil,--unit的类型。
    id = "null", --type的id
    name = "noname",
    x=0, --位置。--只能在map_unit 修改，其他情况只读
    y=0, --位置。--只能在map_unit 修改，其他情况只读
    level = 1,--等级
    exp = 0,--经验。
    hp = 0,--生命
    mp = 0,--魔法
    max_hp =1,--因为计算复杂，所以不是实时更新的。
    max_mp = 1,--因为计算复杂，所以不是实时更新。
    hp_regen = 0,--当前生命恢复，--生命每帧都在恢复，回复速度 计算和maxhp等同步
    mp_regen = 0,--当前法力恢复
    hp_rcount =0,--累计自动回复的生命值，达到一定数值后清空并转化为经验
    mp_rcount =0,--累计自动回复的法力值
    karma = 0,--善恶值
    fame = 0,--名声
    sex_male = true, --male为true， female为false
    delay = 0,--动作延迟的状态。
    delay_id ="null",
    delay_bar = 0, --可视化的delay时间
    delay_barmax = 0.1,--可视化delay的总时间。
    delay_barname = "noname",--可视化delay的可见名称。
    protrait = 0,--头像id？
    weapon_list= {DEF=0,MGR =0,totalWeight = 0,melee ={{unarmed = true}},range={}},--临时数据结构
    faction = 5,--所属势力，默认wild，（敌对的）
    dead = false,--死亡状态，
    turn_past =0,--turn检查时间计数。（RL时间）
    
  }
local niltable = { --默认值为nil的成员变量
  class = true,--职业类型
  class_id = true, --职业id --classid。因为可能更换职业，所以需要登记
  anim = true,--动画数据
  anim_id = true,--动画数据的id
  status = true,---动画状态 类似 {rate =0,dx = 0,dy =0,dz=0,face = 1,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,flying =0,}  
  attr = true,--存储的属性。
  basis = true,--较为固定的属性。基础属性+装备和特性所带来的加成，基本不会变动。
  bonus = true,--加成。快速实时变动，各种buff，状态。
  skill = true,--存储的技能。
  clips = true,----animClip列表
  frames = true,--frameClip列表
  inv = true,--背包实体
  equipment = true, --装备列表--内涵1-5位置
  damage_queue = true,-- --延迟伤害队列
  
  delayAnim_list = true,--延迟动画调用。里面是function 。 
  delayRL_list = true,--延迟RL调用
  map=true,--父地图的状态。--只能在map_unit 修改，其他情况只读
  next_unit = true, -- 同一格的单位串联链表 --只能在map_unit 修改，其他情况只读
  target = true,--目标。mc的目标用蓝色的框标注。 切换目标时必须创建新的table，而不是给旧的赋值。
  
  abilities_level = true, --技能等级列表。删除后的技能，会保留技能等级。技能次数用完或装备移除等，都会保留技能等级。
  abilities = true,--技能列表，数组。
  actionBar = true, --动作条，1-8的位置放技能或物品引用。
  effects = true,--effect列表，数组。
  traits = true,--traits列表，数组。
  
  brain = true, --brain状态机table，ai相关
}
saveMetaType("Unit",Unit,niltable) --注册保存类型
Unit.__index = Unit

Unit.__newindex = function(o,k,v)
  if k =="x" or k=="y" then error("不能直接写入unit.x,unit.y") end --写入控制。后期可以删除这行
  if Unit[k]==nil and niltable[k]==nil then error("使用了Unit的意料之外的值。") else rawset(o,k,v) end
end

function Unit:preSave()
  self.target= nil --清除引用，
  
end



function Unit.new(typeid,level)
  local utype = assert(data.unit[typeid])
  local o= {}
  o.id = typeid
  o.type = utype
  setmetatable(o,Unit)
  
  o.level = level 
  o.class = utype.class
  o.class_id = o.class.id
  o.status={rate=0,dx = 0,dy =0,dz = 0,face = 8,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,} --动画状态
  o.skill = {}
  o:createBaseAttr()
  o:createBonusAttr()
  
  if utype.sex =="male" then
    o.sex_male = true
  elseif utype.sex =="female" then
    o.sex_male = false
  else --random
    o.sex_male = (rnd()*100)< utype.race.male_ratio
  end
  o.anim = o.sex_male and utype.animMale or utype.animFemale 
  o.anim_id = o.anim.id
  --clip
  o.clips ={} --animClip列表
  o.frames = {}--frameClip列表
  --inventory
  o.inv =  Inventory.new(false,o)
  o.equipment = {} --内涵1-5位置
  
  o.damage_queue={} --延迟伤害队列
  o.delayAnim_list = {} --延迟动画调用。里面是function，可以保存。
  o.delayRL_list = {} --延迟RL调用
  o.abilities_level = {}
  o.abilities = {}
  o.effects = {}
  o.traits = {}
  o:initActionBar()
  o:initBrain()
  return o
end



function Unit:set_face(dx,dy)
  self.status.face = c.face(dx,dy)
end


function Unit:face_position(x,y)
  local dx,dy = x-self.x,y-self.y
  if dx >0 then dx =1 elseif dx<0 then dx=-1 end
  if dy >0 then dy =1 elseif dy<0 then dy=-1 end
  self:set_face(dx,dy)
end

--必须是有效的target
function Unit:face_target(target)
  local tXY = target.unit or target
  self:face_position(tXY.x,tXY.y)
end

function Unit:getFace_dxdy()
  return c.face_dir(self.status.face)
end
function Unit:getFace_Rotation()
  local dx,dy = c.face_dir(self.status.face)
  return math.atan2(dy,dx)
end


--短暂固定长度的延迟。，不暂用其他事件的时间。
function Unit:short_delay(time,delay_id)
  if self.delay<time then
    self.delay = time
    self.delay_id = delay_id
  end
end

--可见的delay.会形成进度条。
function Unit:bar_delay(time,delay_name,delay_id)
  if self.delay_bar<time and time>0 then --更长的时间才能生效
    self.delay_bar = time
    self.delay_barmax = time
    self.delay_barname = delay_name
    self:short_delay(time,delay_id)
  end
end



function Unit:updateRL(dt)
  self:updateEffectsRL(dt)
  self:updateRLDelayFunc(dt)
  if self.dead then return end
  self:regenerateHPMP(dt)
  self:turnCheck(dt)
  self:updateAbilities(dt)
  
  --计算delay
  if self.delay_bar>0 then self.delay_bar = self.delay_bar -dt end --跟新delaybar。
  self.delay = self.delay -dt
  --可行动部分。
  if self.delay<=0 then 
    self.delay =0
    self.delay_id = "null"
    --行动。
    self:checkTarget()--检查目标合法性。--不合法自动取消。
    
    if p.mc ==self then
      ui.mainGameKeyCheck(dt)
    else
      self:planAndMove()
    end
  end
end



--为保证同步，每个计时判定都是 remaining<=0 或time>= remaining,保证同一帧delayFunc AnimClip同步。
--注意在AnimClip结束时，当前帧的位移不会起效，如果有同步触发delayFunc衔接新的位移动画，
--在添加新clip后要调用clips_update（0）刷新一下新产生的位移，参见charge技能。（冲锋动画完毕后衔接恢复位置动画）
function Unit:updateAnim(dt) 
  self:update_damage(dt)--延迟伤害触发。可能导致死亡并执行死亡逻辑。
  self:updateEffectsAnim(dt) --更新Effect 。Anim类型不能触发endCall，无法执行逻辑代码。Anim类别时序控制代码应使用delayFunc
  self:clips_update(dt)--更新AnimClip。不执行任何逻辑代码
  self:updateFrameClips(dt)--更新Unit身上的Frames。不执行任何逻辑代码
  self:updateAnimDelayFunc(dt) --delayfunc可能会插入新的 frames，animClips，delayFunc等，但会从下一帧计时。同一单位同步
end



-- update延迟调用。。。。如果在update时插入新的delayFunc，会排在队列尾。计时从下一帧开始
function Unit:updateAnimDelayFunc(dt)
  local list = self.delayAnim_list
  for i= #list,1,-1 do
    local onet = list[i]
    onet.delay = onet.delay-dt
    if onet.delay <=0 then
      onet.f(unpack(onet.args))
      table.remove(list,i)
    end
  end
end

-- 新 延迟调用。。。。
--参数存在nil的话，后面的参数不起作用，需要注意
--可以在delayFunc触发时添加delayFunc，形成连续延迟触发逻辑，用于编辑连续复杂过程
function Unit:insertAnimDelayFunc(delay,func,...)
  checkSaveFunc(func) --检查function 必须是可保存的。
  local onet = {delay = delay, args = {...},f= func}
  local list = self.delayAnim_list
  list[#list+1] = onet
end

--如果在update时插入新的delayFunc，会排在队列尾。计时从下一帧开始
function Unit:updateRLDelayFunc(dt)
  local list = self.delayRL_list
  for i= #list,1,-1 do
    local onet = list[i]
    onet.delay = onet.delay-dt
    if onet.delay <=0 then
      onet.f(unpack(onet.args))
      table.remove(list,i)
    end
  end
end
--参数存在nil的话，后面的参数不起作用，需要注意
function Unit:insertRLDelayFunc(delay,func,...)
  checkSaveFunc(func) --检查function 必须是可保存的。
  local onet = {delay = delay, args = {...},f= func}
  local list = self.delayRL_list
  list[#list+1] = onet
end

--清理 延迟调用。。。。这个需要注意。里面携带引用。需要适时清理
function Unit:clearDelayFunc()
  self.delayAnim_list = {}
  self.delayRL_list = {}
end
