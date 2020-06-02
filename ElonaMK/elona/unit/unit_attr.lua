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
g.attr = {
  life = 100,
  mana = 100,
  speed = 70,

  str = 1,
  con = 1,
  dex = 1,
  per = 1,
  ler = 1,
  wil = 1,
  mag = 1,
  chr = 1,
  str_p = 1,
  con_p = 1,
  dex_p = 1,
  per_p = 1,
  ler_p = 1,
  wil_p = 1,
  mag_p = 1,
  chr_p = 1,
  
  --各种抗性
  res_bash =0,
  res_cut =0,
  res_stab =0,
  res_fire = 0,
  res_ice =0,
  res_nature =0,
  res_earth =0,
  res_dark =0,
  res_light =0,
}
g.skills = {
  --专业技能
  blacksmithing = {name = tl("铁匠","Blacksmithing"),icon = 33, main_attr = "str",description = tl("锻造武器和护甲的技能。 这项技能在制造金属类装备会用到，也影响你使用素材强化装备的成功率。", "Your skill to craft weapon and armor.This skill covers the craft of metal equipment and also affects the success rate of using material to reinforce equipment."),},
  mechanics = {name = tl("机械学","mechanics"),icon = 34, main_attr = "ler",description = tl("操作、维护和修理枪械和其他机械系统的技能。 这项技能在制造复杂装置的时候会被用到，也影响你安装生化插件。", "Your skill in engineering, maintaining and repairing guns and other mechanical systems.  This skill covers the craft of items with complex parts, and plays a role in the installation of bionic equipment."),},
  fabrication = {name = tl("制造","Fabrication"),icon = 35, main_attr = "con",description = tl("把原材料加工和塑造成有用东西的技能。 这项技能在各项制作中起着重要的作用。", "Your skill in working with raw materials and shaping them into useful objects.  This skill plays an important role in the crafting of many objects."),},
  alchemy ={name = tl("炼金","Alchemy"),icon = 36, main_attr = "ler",description = tl("制作各种药水、爆炸物的技能。 需要在炼金台上制作，或使用炼金工具组。", "Your skill in making various potions and explosives. Need to be made on the alchemy platform or using the alchemy kit."),},
  tailoring  ={name = tl("裁缝","Tailoring"),icon = 37, main_attr = "dex",description = tl("制作维修服装、 箱包、 毛毯和其他纺织品的技能。 帮助你编织、 缝纫以及其他任何与针线有关的事儿。", "Your skill in the craft and repair of clothing, bags, blankets and other textiles.  Affects knitting, sewing, stitching, weaving, and nearly anything else involving a needle and thread."),},
  jeweler ={name = tl("宝石加工","Jeweler"),icon = 38, main_attr = "mag",description = tl("加工矿物原石并生产宝石制品的技能。 很多魔道具都是通过这一技能制造。", "Your skill to process mineral rough and produce gemstone products. Many magic items are made through this skill."),},
  cooking ={name = tl("烹饪","Cooking"),icon = 39, main_attr = "ler",description = tl("把食材加工、组合，让它们变得更美味的技能。随着等级的提高，你利用食材的效率会更高，有机会一次产出多份菜肴。", "Your skill in combining food ingredients to make other, tastier food items.  As the level increases, you will be more efficient and have the opportunity to produce multiple dishes at once."),},
  gardening ={name = tl("栽培","Gardening"),icon = 40, main_attr = "wil",description = tl("种植各种作物的技能。技能等级影响作物在田地里的成活率，和新苗的再生几率。宝石，武器，魔道具，水果和蔬菜等等都可以通过种田获得。", "Your skill that affects the survival rate of crops at your farm, and the chance of plant re-growth after harvesting. Gems, weapons, magic rods, fruits, and vegetables can be obtained as harvests."),},
  fishing ={name = tl("钓鱼","Fishing"),icon = 31, main_attr = "per",description = tl("采集技能，使用钓竿可以在水池或岸边获得各种水产、鱼类。没有高等级的钓鱼技能支持，想要获得优质的食材原料就会很困难。", "Your skill that allows you gather water-related materials from pools as well as catch fish from water with a fishing pole. Gathering materials from a pool is very difficult without this skill."),},
  performer ={name = tl("演奏","Performer"),icon = 32, main_attr = "chr",description = tl("演奏乐器，并从观众获得奖赏的技能。乐器包括钢琴，口琴，竖琴，号角，琵琶，排萧等等。越高等级的观众越难以讨好，注意他们向你丢来的石块！", "Your skill in playing instruments in order to get gold or items from NPCs. Instruments include the grand piano, harmonica, harp, horn, lute, pan flute, etc. The higher the level of the audience, the more difficult it is to please, pay attention to the stones they have thrown at you! "),},
  --武器技能
  cutting =  {name = tl("劈砍","Cutting"),icon = 17, main_attr = "str",
    description =tl("用砍，劈类型的武器战斗的技能。 较低级别时，等级仅仅决定命中和伤害，而更高级别的技能将有助于穿透重甲。",
    "Your skill in fighting with weaponry designed to cut, hack and slash an opponent.  Lower levels of skill increase accuracy and damage, while higher levels will help to bypass heavy armor."),},
  bashing =     {name = tl("钝击","Bashing"),icon = 18,main_attr = "str",
    description = tl("用钝器战斗的技能。 等级越高伤害越高，等级较高时也会提高命中。","Your skill in fighting with blunt weaponry.  Skill increases damage, and higher levels will improve the accuracy of an attack."),},
  stabbing =    {name = tl("穿刺","Stabbing"),icon = 19,main_attr = "dex",
    description = tl("用匕首，袖剑等刺击武器战斗的技能。技能增加攻击精度以及背刺打击的伤害。","Your skill in fighting with knives, sleeve swords and other such stabbing implements.  Skill increases the accuracy of the attack and the damage of the backstab."),},
  polearm =     {name = tl("长柄","Polearm"),icon = 20,main_attr = "con",
    description = tl("用长矛，龙枪等长柄武器战斗的技能。影响武器的命中率和刺穿多个敌人时的效果。","Your skill of fighting with long-handed weapons such as spears, dragonlance, etc. Affects the weapon's hit rate and the effect of piercing multiple enemies."),},
  martial_arts ={name = tl("格斗","Martial Arts"),icon = 21,main_attr = "str",
    description = tl("肉搏战技能。 对于门外汉来说，这是自残的好办法。但有些高手可以用他们特殊的技法来打击和干翻敌人。等级越高伤害骰面越大。","Your skill in hand-to-hand fighting.  For the unskilled, it's a good way to get hurt, but those with enough practice can perform special blows and techniques to quickly dispatch enemies. Skill increases number of damage dice faces."),},
  bow =         {name = tl("弓弩","Bow"),icon = 22,main_attr = "dex",
    description = tl("使用弓的技能。从自弓到十字弩，都需要弹药才能造成更高伤害。记住，对距离远一点儿的敌人来说，你是在给他们挠痒痒。","Your skill in using bow weapons, from the bow to the cross, all need ammunition to cause more damage, and are not terribly accurate over a long distance."),},
  firearm=      {name = tl("火器","Firearm"),icon = 23, main_attr = "per",
    description = tl("使用火器的整体技能。等级提高会提升使用任何枪支的准确性。","Your overall skill in using firearms.  With higher levels, this general experience increases accuracy with any guns or firearms."),},
  energy_gun =  {name = tl("能量武器","Energy Gun"),icon = 24,main_attr = "per",
    description = tl("使用能量武器的技能。任何远程科幻武器都可以归到此类。通常无需弹药，不论距离都能造成等额的伤害。","Your skill in using energy weapons, any ranged si-fi weapon can be classified into this type.Usually no ammunition is needed, and the distance does not affect the damage."),},
  big_gun=      {name = tl("重型武器","Big Gun"),icon = 25,main_attr = "wil",
    description = tl("使用像火箭、 榴弹或导弹发射器之类的重型武器的技能。 这些武器用途多样，威力巨大，但他们也很笨重和难用。","Your skill in using heavy weapons like rocket, grenade or missile launchers.  These weapons have a variety of applications and may carry immense destructive power, but they are cumbersome and hard to manage."),},
  throw =       {name = tl("投掷","Throwing"),icon = 26, main_attr = "per",
    description = tl("远距离投掷物体的技能。 等级越高，投掷距离和精度越高。", "Your skill in throwing objects over a distance.  Skill increases accuracy, and at higher levels, the range of a throw."),},
  sheild =      {name = tl("盾牌","Sheild"),icon = 27, main_attr = "con",
    description = tl("使用盾牌格挡攻击的技能。也能影响盾牌打击的效果。", "Your skill in using sheild to block attacks.  It can also affect the damage of shield strikes."),},
  magic_device ={name = tl("魔道具","Magic Device"),icon = 28,main_attr = "mag",
    description = tl("使用魔法道具武器的能力。将魔杖，魔导器激活后直接放出法术，技能增加这些法术的伤害。", "The Skill to use magical  items. When the wand and the magic artifact are activated, the spells are directly cast, and this skill increases the damage of these spells."),},
  soft_weapon = {name = tl("软兵器","Soft Weapon"),icon = 29,main_attr = "chr",
    description = tl("使用奇门兵器的技能。奇门兵器通常都有古怪的附带效果，但没多少人愿意使用这些伤害较低的武器。", "Your Skill of using soft weapons. Soft weapons usually have some weird effect, but not many people are willing to use these less harmful weapons."),},
}




function Unit.unitInitAttrAndBouns(unit)
  local attr = {
    --基础
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
    
    total_point = 1,--总属性加值。  race class 提供的总属性合计。
    --抗性
    res_bash =0,
    res_cut =0,
    res_stab =0,
    res_fire = 0,
    res_cold =0,
    res_nature =0,
    res_earth =0,
    res_dark =0,
    res_light =0,
  }


  for k,v in pairs(g.skills) do --所有技能
    attr[k] =1
  end
  local bonus = {}
  for k,v in pairs(attr) do --所有在attr里的都在bonus里有
    bonus[k] =0
  end
  unit.attr = attr
  unit.bonus = bonus
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
  self.attr.total_point = totalp
end

function Unit:initSkills(skills,level)
  for skillid,_ in pairs(skills) do
    if level<20 then
      self.attr[skillid] = 4+0.8*level
    else
      self.attr[skillid] = level
    end
  end
end

--提升1点属性获得1点xp.，属性基数越大，升级需要经验越多。
function Unit:getLevelUpExp()
  return self.attr.total_point*0.1*level_afactor
end

--取得等级增长平均属性。 level可以不为整数。
local aver =7.5--假设平均7.5点点数.  已经接近主角平均值
c.averageAttrGrow = (aver+2)*0.1 *level_afactor--1.235



function Unit:getSpeed()
  return self.attr.speed
end

function Unit:cur_str() return math.floor(self.attr.str)+math.floor(self.bonus.str) end
function Unit:cur_con() return math.floor(self.attr.con)+math.floor(self.bonus.con) end
function Unit:cur_dex() return math.floor(self.attr.dex)+math.floor(self.bonus.dex) end
function Unit:cur_per() return math.floor(self.attr.per)+math.floor(self.bonus.per) end
function Unit:cur_ler() return math.floor(self.attr.ler)+math.floor(self.bonus.ler) end
function Unit:cur_wil() return math.floor(self.attr.wil)+math.floor(self.bonus.wil) end
function Unit:cur_mag() return math.floor(self.attr.mag)+math.floor(self.bonus.mag) end
function Unit:cur_chr() return math.floor(self.attr.chr)+math.floor(self.bonus.chr) end

function Unit:base_str() return math.floor(self.attr.str) end
function Unit:base_con() return math.floor(self.attr.con) end
function Unit:base_dex() return math.floor(self.attr.dex) end
function Unit:base_per() return math.floor(self.attr.per) end
function Unit:base_ler() return math.floor(self.attr.ler) end
function Unit:base_wil() return math.floor(self.attr.wil) end
function Unit:base_mag() return math.floor(self.attr.mag) end
function Unit:base_chr() return math.floor(self.attr.chr) end

--潜力
function Unit:potential_str() return self.attr.str_p+self.bonus.str_p end
function Unit:potential_con() return self.attr.con_p+self.bonus.con_p end
function Unit:potential_dex() return self.attr.dex_p+self.bonus.dex_p end
function Unit:potential_per() return self.attr.per_p+self.bonus.per_p end
function Unit:potential_ler() return self.attr.ler_p+self.bonus.ler_p end
function Unit:potential_wil() return self.attr.wil_p+self.bonus.wil_p end
function Unit:potential_mag() return self.attr.mag_p+self.bonus.mag_p end
function Unit:potential_chr() return self.attr.chr_p+self.bonus.chr_p end

--
function Unit:cur_life() return math.floor(self.attr.life)+math.floor(self.bonus.life)end
function Unit:cur_mana() return math.floor(self.attr.mana)+math.floor(self.bonus.mana)end
function Unit:cur_speed() return math.floor(self.attr.speed)+math.floor(self.bonus.speed)end
function Unit:base_life() return math.floor(self.attr.life)end
function Unit:base_mana() return math.floor(self.attr.mana)end
function Unit:base_speed() return math.floor(self.attr.speed)end
function Unit:getSpeed() return math.floor(self.attr.speed)+math.floor(self.bonus.speed) end


function Unit:cur_attr(aname)
  assert(g.attr[aname])
  return self.attr[aname]+self.bonus[aname]
end

function Unit:base_attr(aname)
  assert(g.attr[aname])
  return self.attr[aname]
end


function Unit:getMaxHP()
  local con = self:cur_con()
  local str = self:cur_str()
  local wil = self:cur_wil()
  local life = self:cur_life()
  local level = self.level
  return math.min(math.max(math.floor(1+life/100*((level/25+0.2)*( 2 * con + 1.3*str + wil*0.7)+con/2)),5),4000000)
  
end
function Unit:getMaxMP()
  local mag = self:cur_mag()
  local ler = self:cur_ler()
  local wil = self:cur_wil()
  local mana = self:cur_mana()
  local level = self.level
  return math.min(math.max(math.floor(1+mana/100*((level/25+0.2)*( 1.5 * mag + 1.25*ler + 1.25*wil)+mag/2)),5),4000000)
end
--最大搬运量
function Unit:getMaxCarry()
  local con = self:cur_con()
  local str = self:cur_str()
  local level = self.level
  return 35+ str*1.5+con*0.5+level*0.5
end

--返回原始等级
function Unit:getSkillLevelAndExp(skillid)
  assert(g.skills[skillid])
  local org = self.attr[skillid]
  local level = math.floor( self.attr[skillid])
  return level,org-level
end

--护甲值 即时
function Unit:getAR()
  return  math.max(0,self.weapon_list.AR)
end

function Unit:getMR()
  return  math.max(0,self.weapon_list.MR)
end

--单一属性的抗性，-8到8之间。
function Unit:getResistance(atktype)
  local res_str = "res_bash"
  if atktype=="bash" then res_str="res_bash" 
  elseif atktype=="cut" then res_str="res_cut" 
  elseif atktype=="stab" then res_str="res_stab" 
  elseif atktype=="fire" then res_str="res_fire" 
  elseif atktype=="ice" then res_str="res_ice" 
  elseif atktype=="nature" then res_str="res_nature" 
  elseif atktype=="earth" then res_str="res_earth" 
  elseif atktype=="dark" then res_str="res_dark" 
  elseif atktype=="light" then res_str="res_light" 
  else return 0 end
  local rnum = math.floor(self.attr[res_str]+self.bonus[res_str])
  return c.clamp(rnum,-8,8)
end
