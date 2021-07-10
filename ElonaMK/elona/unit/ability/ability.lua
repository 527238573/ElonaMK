Ability = {
  id = "null", --type的id
  type = nil,
  level = 1,--技能等级
  cooling = 0,--正在冷却的剩余时间。
  coolTime = 0,--当前冷却过程的总时间。
}
local niltable = { --默认值为nil的成员变量
  }
saveMetaType("Ability",Ability,niltable)--注册保存类型
Ability.__newindex = function(o,k,v)
  if Ability[k]==nil and niltable[k]==nil then error("使用了Ability的意料之外的值。") else rawset(o,k,v) end
end



function Ability.new(typeid)
  local etype = assert(data.ability[typeid])
  local o= {type = etype,id = typeid}
  setmetatable(o,Ability)
  return o
end

function Ability:getName()
  return self.type.name
end

function Ability:getAbilityIcon()
  return self.type.icon
end

--用单位描述
function Ability:getDescription(unit)
  local des = self.type.description
  if type(des) =="function" then
    des = des(self,unit)
  end
  if des=="" then 
    des = "测试描述。技能大段问字技能大段问字技能大段问字技能大段问字，伤害212-323，很多的伤害很多的伤害很多的伤害很多的伤害。"
  end
  if type(des) =="string" then
    return {{0.9,0.9,0.9},des}--必须要返回table类型
  end
  return des --table类型
end

function Ability:isMagic() return self.type.isMagic end
function Ability:getMainAttr() return self.type.main_attr end
function Ability:getLevel() return math.floor(self.level) end
function Ability:getExp() return self.level - math.floor(self.level) end

function Ability:getCostMana()
  return self.type.costMana
end

function Ability:getCooldown()
  return self.type.cooldown
end

function Ability:getCoolRate()
  if self.coolTime<=0 then return 0 end
  return self.cooling/self.coolTime
end

--开始冷却,通过自定的冷却时间
function Ability:startCooling(time)
  self.cooling = time
  self.coolTime = time --总冷却时间保留
end

function Ability:updateRL(dt)
  if self.cooling>0 then
    self.cooling = math.max(0,self.cooling-dt)
  end
end


function Ability:use(source_unit,showmsg,...)
  if self.type.func then
    return self.type.func(self,source_unit,showmsg,...)
  end
  addmsg(tl("技能调用未实装！","Ability invocation is not installed!"))
  return false
end

-- baseLevel代表技能的难度等级，baselevel 为30的技能 1级就相当于31级难度
function Ability:getCombinedLevel()
  return math.floor(self.level) +self.type.baseLevel
end



local ability_up_str = tl("%s的%s升级了。","%s's %s levels up.")
function Ability:train(exp,explv,unit)
  exp = math.max(0,exp)
  local level = self.level
  local cur_lv =self:getCombinedLevel()
  local growExp = 1000*self.type.difficulty --技能等级每级提升的经验默认1000，但随difficulty有修正
  
  local lv_fix =1
  local lv_c =cur_lv-unit.level
  if lv_c>10 then lv_fix = 0 elseif lv_c>0 then lv_fix  = 0.8^lv_c end --超过自身等级10级不得经验
  lv_c = cur_lv - explv --
  if lv_c>10 then lv_fix  = lv_fix* math.max(0,1-(lv_c-10)*0.03) end -- 给出的经验质量等级太低不得经验。
  local realexp = exp*lv_fix
  self.level = level +realexp/growExp
  if math.floor(self.level)~=math.floor(level) then --等级提升
    --self:reloadBasisBonus()--暂时不需要load等级。
    if unit:isInPlayerTeam() then --音效
      local selfname = unit:getShortName()
      local abname = self:getName()
      addmsg(string.format(ability_up_str,selfname,abname),"good")
      --音效
      g.playSound("ding3") 
    end
  end
  
  unit:train_attr("ler",realexp/4,cur_lv)
end


