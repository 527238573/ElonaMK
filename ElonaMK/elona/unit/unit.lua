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
    karma = 0,--善恶值
    fame = 0,--名声
    attr = nil,--存储的属性。
    bnous = nil,--加成。
    status = 0, ---动画状态 类似 {rate =0,dx = 0,dy =0,dz=0,face = 1,rot = 0,scaleX = 1,scaleY =1,camera_dx = 0,camera_dy = 0,flying =0,}  
    anim_id = "null",
    sex_male = true, --male为true， female为false
    delay = 0,--动作延迟的状态。
    delay_id ="null",
    map =nil, --父地图的状态。
    class_id = "null", --classid。因为可能更换职业，所以
    protrait = 0,
  }
saveClass["Unit"] = Unit --注册保存类型

Unit.__index = Unit
Unit.__newindex = function(o,k,v)
  if Unit[k]==nil and k~="map" then error("使用了Unit的意料之外的值。") else rawset(o,k,v) end
end

--读取完成后自动调用。不再使用index。id是字符串，永不变化。
function Unit:loadfinish()
  rawset(self,"type",assert(data.unit[self.id]))
  --如果新版增加字段，则需要补充。
  rawset(self,"anim",assert(data.unitAnim[self.anim_id]))
  rawset(self,"class",assert(data.class[self.class_id]))
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
  o.clips ={} 
  --inventory
  o.inv =  Inventory.new(false,o)
  setmetatable(o,Unit)
  return o
end

-- zanding
function Unit:is_dead()
  return false
end

function Unit:is_alive()
  return true
end

--是否踩在block的高度上。
function Unit:step_on_block()
  return true
end


function Unit:set_face(dx,dy)
  self.status.face = c.face(dx,dy)
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


function Unit:updateRL(dt)
  self.delay = self.delay -dt
  if self.delay<=0 then 
    self.delay =0
    self.delay_id = "null"
    --行动。
    if p.mc ==self then
      ui.mainGameKeyCheck(dt)
    else
      self:planAndMove()
    end
  end
end




function Unit:updateAnim(dt)
  self:clips_update(dt)
end

function Unit:planAndMove()
  
  
end

