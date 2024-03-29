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
  shield =      {name = tl("盾牌","Shield"),icon = 27, main_attr = "con",
    description = tl("使用盾牌格挡攻击的技能。也能影响盾牌打击的效果。", "Your skill in using shield to block attacks.  It can also affect the damage of shield strikes."),},
  magic_chant ={name = tl("咏唱","Magic Chant"),icon = 28,main_attr = "mag",
    description = tl("引导魔法的能力。影响魔导器、法术的命中。", "The Skill to use magical  items or spells. This skill increases the  hit rate of these spells."),},
  soft_weapon = {name = tl("软兵器","Soft Weapon"),icon = 29,main_attr = "chr",
    description = tl("使用奇门兵器的技能。奇门兵器通常都有古怪的附带效果，但没多少人愿意使用这些伤害较低的武器。", "Your Skill of using soft weapons. Soft weapons usually have some weird effect, but not many people are willing to use these less harmful weapons."),},
}

function Unit:initSkills(skills,level)
  for skillid,_ in pairs(g.skills) do
    self.skill[skillid] = 1
  end
  for skillid,_ in pairs(skills) do
    if level<20 then
      self.skill[skillid] = 4+0.8*level
    else
      self.skill[skillid] = level
    end
  end
end


function Unit:getSkillLevel(skillid)
  return math.floor(self.skill[skillid])
end
--返回原始等级
function Unit:getSkillLevelAndExp(skillid)
  assert(g.skills[skillid])
  local org = self.skill[skillid]
  local level = math.floor(self.skill[skillid])
  return level,org-level
end


local skill_up_str = tl("%s的%s技能提升了。","%s's %s skill increases.")
--trian技能。
function Unit:train_skill(skill_id,exp,explv)
  exp = math.max(0,exp)
  local skill = self.skill[skill_id]
  local cur_lv = math.floor(skill)
  local growExp = 1000 --技能等级每级提升的经验都一样。
  local skill_data = g.skills[skill_id]
  
  local lv_fix =1
  local lv_c =cur_lv-self.level
  if lv_c>10 then lv_fix = 0 elseif lv_c>0 then lv_fix  = 0.8^lv_c end --超过自身等级10级不得经验
  lv_c = cur_lv - explv --
  if lv_c>10 then lv_fix  = lv_fix* math.max(0,1-(lv_c-10)*0.03) end -- 给出的经验质量等级太低不得经验。
  if lv_c<-20 then lv_fix = 3 end
  if lv_c<-10 then lv_fix = 1+(-lv_c-10)*0.2 end
  
  local realexp = exp*lv_fix
  skill = skill +realexp/growExp
  self.skill[skill_id] = skill
  if cur_lv~=math.floor(skill) then --等级提升
    --self:reloadBasisBonus()--暂时不需要load等级。
    if self:isInPlayerTeam() then --音效
      local selfname = self:getShortName()
      local skillname = skill_data.name
      addmsg(string.format(skill_up_str,selfname,skillname),"good")
      --音效
      g.playSound("ding3") 
    end
  end
  --提升技能等级有益于相应属性等级提升。
  self:train_attr(skill_data.main_attr,realexp/3,cur_lv)
  self:train_attr("ler",realexp/4,cur_lv)
end

