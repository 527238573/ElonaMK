Unit = {
    --一些默认值
    
    type = nil,--unit的类型。
    id = "null", --type的id
    name = "noname",
    x=0, --位置。
    y=0,
    saveType = "Unit",--注册保存类型
    level = 1,--等级
    exp = 0,--经验。
    hp = 0,--生命
    mp = 0,--魔法
    max_hp =1,--因为计算复杂，所以不是实时更新的。
    max_mp = 1,--因为计算复杂，所以不是实时更新。
    karma = 0,--善恶值
    fame = 0,--名声
    status = 0, ---动画状态 类似 {rate =0,dx = 0,dy =0,dz=0,face = 1,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,flying =0,}  
    anim_id = "null",
    sex_male = true, --male为true， female为false
    delay = 0,--动作延迟的状态。
    delay_id ="null",
    delay_bar = 0, --可视化的delay时间
    delay_barmax = 0.1,--可视化delay的总时间。
    delay_barname = "noname",--可视化delay的可见名称。
    class_id = "null", --classid。因为可能更换职业，所以
    protrait = 0,
    weapon_list= {},--临时数据结构
    faction = 5,--所属势力，默认wild，（敌对的）
    dead = false,--死亡状态，
    
    
    
    
  }
saveClass["Unit"] = Unit --注册保存类型

local niltable = { --默认值为nil的成员变量
  attr = true,--存储的属性。
  bnous = true,--加成。
  map=true,--父地图的状态。
  target = true,--目标。mc的目标用蓝色的框标注
}
Unit.__index = Unit
Unit.__newindex = function(o,k,v)
  if Unit[k]==nil and niltable[k]==nil then error("使用了Unit的意料之外的值。") else rawset(o,k,v) end
end

function Unit:preSave()
  self.target= nil --清除引用，
end

--读取完成后自动调用。不再使用index。id是字符串，永不变化。
function Unit:loadfinish()
  rawset(self,"type",assert(data.unit[self.id]))
  --如果新版增加字段，则需要补充。
  rawset(self,"anim",assert(data.unitAnim[self.anim_id]))
  rawset(self,"class",assert(data.class[self.class_id]))
  
  rawset(self,"animdelay_list",{noSave = true}) --重建新的。
end

function Unit.new(typeid,level)
  local utype = assert(data.unit[typeid])
  local o= {}
  o.id = typeid
  o.type = utype
  o.level = level or 1
  o.class = utype.class
  o.class_id = o.class.id
  o.status={rate=0,dx = 0,dy =0,dz = 0,face = 8,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,} --动画状态
  Unit.unitInitAttrAndBouns(o)
  
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
  o.animdelay_list = {noSave = true} --延迟动画调用。里面是function，所以不能保存。里面有东西会在保存时直接丢失掉，但不重要
  
  setmetatable(o,Unit)
  return o
end

-- zanding
function Unit:is_dead()
  return self.dead
end

--只有被标记为死亡才真正死亡，HP降为0暂不代表死亡。
function Unit:is_alive()
  return not self.dead
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


function Unit:add_delay(time,delay_id)
  self.delay = self.delay+time
  self.delay_id = delay_id
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
  self:update_damage(dt)
  
  if self.delay_bar>0 then self.delay_bar = self.delay_bar -dt end --跟新delaybar。
  self.delay = self.delay -dt
  
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




function Unit:updateAnim(dt)
  self:clips_update(dt)
  self:updateFrameClips(dt)
  self:updateAnimDelayFunc(dt)
end

function Unit:planAndMove()
  
  
end

