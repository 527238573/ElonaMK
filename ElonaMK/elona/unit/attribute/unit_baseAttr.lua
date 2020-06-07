g.main_attr = {
  str = {name = tl("力量","Strength"),icon = 1,},
  con = {name = tl("体质","Constitution"),icon = 2,},
  dex = {name = tl("灵巧","Dexterity"),icon = 3,},
  per = {name = tl("感知","Perception"),icon = 4,},
  ler = {name = tl("学习","Learning"),icon = 5,},
  wil = {name = tl("意志","Will"),icon = 6,},
  mag = {name = tl("魔力","Magic"),icon = 7,},
  chr = {name = tl("魅力","Charisma"),icon = 8,},
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
    self.attr[aname] = baseVal
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



--提升1点属性获得1点xp.，属性基数越大，升级需要经验越多。
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