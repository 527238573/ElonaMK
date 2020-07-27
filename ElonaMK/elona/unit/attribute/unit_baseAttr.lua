g.main_attr = {
  str = {name = tl("力量","Strength"),icon = 1,color ={1,1,1}},
  con = {name = tl("体质","Constitution"),icon = 2,color ={1,1,1}},
  dex = {name = tl("灵巧","Dexterity"),icon = 3,color ={1,1,1}},
  per = {name = tl("感知","Perception"),icon = 4,color ={1,1,1}},
  ler = {name = tl("学习","Learning"),icon = 5,color ={1,1,1}},
  wil = {name = tl("意志","Will"),icon = 6,color ={1,1,1}},
  mag = {name = tl("魔力","Magic"),icon = 7,color ={1,1,1}},
  chr = {name = tl("魅力","Charisma"),icon = 8,color ={1,1,1}},
}
g.attr = { --attr 已有的成员：
  life = 100,
  mana = 100,
  speed = 70,
  --属性
  str = 1,
  con = 1,
  dex = 1,
  per = 1,
  ler = 1,
  wil = 1,
  mag = 1,
  chr = 1,
  --属性潜力
  str_p = 1,
  con_p = 1,
  dex_p = 1,
  per_p = 1,
  ler_p = 1,
  wil_p = 1,
  mag_p = 1,
  chr_p = 1,
  
  exp_point = 1,--总属性加值。  race class 提供的总属性合计。 会影响每级需要经验 
  --抗性已经不属于基本属性 在bouns里查看抗性。
}


--unit创建时进行基本成员的生成
function Unit:createBaseAttr()
  local attr = {}
  for k,v in pairs(g.attr) do --复制上面那张table
    attr[k] =v
  end
  self.attr = attr --仅站住位置。后面需要初始化具体的数值。
end



local level_afactor = 1.3 --固定参数，越大每级升级需要提升的属性越多
--根据种族 职业 等级，初始化属性。
function Unit:initAttr(race,class,level,attrFactor)
  self:resetPotential(race,class)
  for aname,_ in pairs(g.main_attr) do
    local baseVal = (race[aname] +class[aname])*1.2--等级1基础值
    local potential = self.attr[aname.."_p"] 
    baseVal = baseVal +(level-1)*(potential-0.2)*level_afactor --等级成长值。
    baseVal = attrFactor*baseVal --属性初始值调整。
    self.attr[aname] = math.max(1,baseVal)--最下为1，不能为0
  end
  self.attr.life = race.life
  self.attr.mana = race.mana
  self.attr.speed = race.speed
end

--传输的是具体类型。
function Unit:resetPotential(race,class)
  local totalp = 0
  for aname,_ in pairs(g.main_attr) do
    
    local basePotential = 0.4 
    basePotential = basePotential + race[aname]*0.1 +class[aname]*0.1
    self.attr[aname.."_p"] = basePotential
    totalp = totalp+race[aname]+class[aname]
  end
  totalp = totalp+16--略加一点基础值。
  self.attr.exp_point = totalp
end



--提升1点属性获得1点exp.，属性基数越大，升级需要经验越多。
function Unit:getLevelUpExp()
  return self.attr.exp_point*0.1*level_afactor
end

--取得等级增长平均属性。 level可以不为整数。
local aver =7.5--假设平均7.5点点数.  已经接近主角平均值
c.averageAttrGrow = (aver+2)*0.1 *level_afactor--1.235




--因为attr
function Unit:cur_str() return math.floor(self.basis.str+self.bonus.str) end
function Unit:cur_con() return math.floor(self.basis.con+self.bonus.con) end
function Unit:cur_dex() return math.floor(self.basis.dex+self.bonus.dex) end
function Unit:cur_per() return math.floor(self.basis.per+self.bonus.per) end
function Unit:cur_ler() return math.floor(self.basis.ler+self.bonus.ler) end
function Unit:cur_wil() return math.floor(self.basis.wil+self.bonus.wil) end
function Unit:cur_mag() return math.floor(self.basis.mag+self.bonus.mag) end
function Unit:cur_chr() return math.floor(self.basis.chr+self.bonus.chr) end

function Unit:base_str() return math.floor(self.attr.str) end
function Unit:base_con() return math.floor(self.attr.con) end
function Unit:base_dex() return math.floor(self.attr.dex) end
function Unit:base_per() return math.floor(self.attr.per) end
function Unit:base_ler() return math.floor(self.attr.ler) end
function Unit:base_wil() return math.floor(self.attr.wil) end
function Unit:base_mag() return math.floor(self.attr.mag) end
function Unit:base_chr() return math.floor(self.attr.chr) end

--潜力
function Unit:potential_str() return self.basis.str_p+self.bonus.str_p end
function Unit:potential_con() return self.basis.con_p+self.bonus.con_p end
function Unit:potential_dex() return self.basis.dex_p+self.bonus.dex_p end
function Unit:potential_per() return self.basis.per_p+self.bonus.per_p end
function Unit:potential_ler() return self.basis.ler_p+self.bonus.ler_p end
function Unit:potential_wil() return self.basis.wil_p+self.bonus.wil_p end
function Unit:potential_mag() return self.basis.mag_p+self.bonus.mag_p end
function Unit:potential_chr() return self.basis.chr_p+self.bonus.chr_p end



--
function Unit:cur_life() return math.floor(self.basis.life)+math.floor(self.bonus.life)end
function Unit:cur_mana() return math.floor(self.basis.mana)+math.floor(self.bonus.mana)end
function Unit:cur_speed() return math.floor(self.basis.speed)+math.floor(self.bonus.speed)end
function Unit:base_life() return math.floor(self.attr.life)end
function Unit:base_mana() return math.floor(self.attr.mana)end
function Unit:base_speed() return math.floor(self.attr.speed)end
function Unit:getSpeed() return math.floor(self.basis.speed)+math.floor(self.bonus.speed) end

--获得
function Unit:cur_main_attr(attr_id)
  assert(g.main_attr[attr_id])
  local funcName = "cur_"..attr_id
  return self[funcName](self)
end

--增长主属性经验。 explv代表经验的等级。经验的等级影响较为微弱，只有相差非常大时，才有明显限制。
function Unit:train_attr(attr_id,exp,explv)
  exp = math.max(0,exp)
  local attr = self.attr[attr_id]
  local cur_a = math.floor(attr)
  local cur_lv =cur_a/c.averageAttrGrow --大约是当前经验等级
  local lv_fix = 1 --等级的修正。
  local potential_id = attr_id.."_p"
  local potentail = self.basis[potential_id]+self.bonus[potential_id]
  
  --先确定当前升级需要经验。
  local growExp = 1000+cur_a
  if cur_a<100 then -- 100属性以下需要经验偏少，前期升级加快。
    growExp = 1120-(cur_a-120)^2/20
  end
  local lv_c = cur_a-explv
  if lv_c>20 then --获得经验等级差距过大，经验消减，100-200级之间快速衰减 当差距250级时达到最低20%，
    lv_fix = 0.8/(1+math.exp((lv_c-150)/20))+0.2
  end
  local real_grow = exp/growExp * lv_fix * potentail
  self:grow_attr(attr_id,real_grow)
end


local grow_str = {
  str = tl("%s感到肌肉变强壮了。","%s's muscles feel stronger."),
  con = tl("%s变的能承受更多打击。","%s begins to feel good when being hit hard."),
  dex = tl("%s更加敏捷了。","%s becomes dexterous."),
  per = tl("%s感到世界更加清晰了。","%sfeels more in touch with the world."),
  ler = tl("%s的好奇心上升了。","%s feels studious."),
  wil = tl("%s的意志更加坚定。","%s's will hardens."),
  mag = tl("%s与魔力的共鸣加强了。","%s's resonance with magic improves."),
  chr = tl("%s感到世界对自己更友好了。","%s enjoys showing off self."),
  level = tl("%s等级提升了！","%s level up!!")
}

function Unit:grow_attr(attr_id,grow)
  local attr = self.attr[attr_id]
  local cur_a = math.floor(attr)
  attr = attr +grow
  self.attr[attr_id] = attr
  if cur_a~=math.floor(attr) then --属性变动
    self:reloadBasisBonus()--需要重新load已经变化
    if self:isInPlayerTeam() then --音效
      local selfname = self:getShortName()
      addmsg(string.format(grow_str[attr_id],selfname),"good")
      --音效
      g.playSound("ding3") 
    end
  end
  
  self.exp = self.exp +grow
  local next_exp = self:getLevelUpExp()
  if self.exp>=next_exp then
    self.exp = self.exp - next_exp
    self.level = self.level+1
    self:reloadBasisBonus()--需要重新load已经变化
    self:reloadRealTimeBouns() --重载所有加成，可能有被等级影响的部分。
    if self:isInPlayerTeam() then --音效
      local selfname = self:getShortName()
      addmsg(string.format(grow_str.level,selfname),"good")
      --音效
      g.playSound("ding1",self.x,self.y) 
    end
    
  end
end

