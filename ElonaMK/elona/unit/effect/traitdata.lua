data.trait ={}

local function addTrait(ttable)
  assert(data.trait[ttable.id]==nil)
  setmetatable(ttable,data.dataMeta)
  data.trait[ttable.id] = ttable
end



return function()
  --三大平衡修正数值转化的trait
  addTrait{id = "dodge_mod",name = tl("闪避修正","Dodge_mod"), description = tl("修正闪避值。","Fixed dodge value."),
    levels = {
      [1] ={name = tl("轻盈","light"), good = true,description = function(tra) 
          return string.format(tl("轻快的身躯容易闪避，被命中的机率下降%d%%。","Light body is easy to dodge and the chance of being hit is reduced %d%%."),tra.mod_t.dodge_mod*100) end},
      [2] ={name = tl("笨重","Heavy"), good = false,description = function(tra) 
          return string.format(tl("沉重的身躯难以闪避，被命中的机率增加%d%%。","Heavy body hard to dodge, chance of being hit is increased %d%%."),tra.mod_t.dodge_mod*-100) end},
    },
  }
  
  addTrait{id = "melee_mod",name = tl("近战修正","melee_mod"), description = tl("修正近战伤害。","Fixed melee damage."),
    levels = {
      [1] ={name = tl("强击","Heavy strike"),good = true, description = function(tra) 
          return string.format(tl("近战伤害上升%d%%。","Melee damage increased by %d%%."),tra.mod_t.melee_mod*100) end},
      [2] ={name = tl("轻击","Light strike"), good = false,description = function(tra) 
          return string.format(tl("近战伤害下降%d%%。","Melee damage reduced by %d%%."),tra.mod_t.melee_mod*-100) end},
    },
  }
  
  addTrait{id = "range_mod",name = tl("远程修正","range_mod"), description = tl("修正闪避值。","Fixed melee damage."),
    levels = {
      [1] ={name = tl("猛射","Heavy shot"),good = true, description = function(tra) 
          return string.format(tl("远程非机械(弓，投掷等)伤害上升%d%%。","Ranged non-mechanical (bow, throw, etc.) damage increased %d%%."),tra.mod_t.range_mod*100) end},
      [2] ={name = tl("轻射","Light shot"), good = false,description = function(tra) 
          return string.format(tl("远程非机械(弓，投掷等)伤害下降%d%%。","Ranged non-mechanical (bow, throw, etc.) damage reduced %d%%."),tra.mod_t.range_mod*-100) end},
    },
  }
  
  
  addTrait{ id = "magicRes",name = tl("先天魔抗","Innate Magic Res"), description = tl("能少量减少受到的魔法伤害。","Slightly reduces the amount of magic damage taken."),
    --mod_t = {speed =10,res_cut =-1},
  }
  

end