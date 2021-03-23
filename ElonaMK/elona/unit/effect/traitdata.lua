data.trait ={}

local function addTrait(ttable)
  assert(data.trait[ttable.id]==nil)
  setmetatable(ttable,data.dataMeta)
  data.trait[ttable.id] = ttable
end



return function()
  --三大平衡修正数值转化的trait
  addTrait{id = "native_trait",name = tl("种族天赋","Ethnic talent"), description = tl("属性修正。","Fixed bonus value."),
    
  }
  
  
  
  addTrait{ id = "magicRes",name = tl("先天魔抗","Innate Magic Res"), description = tl("能少量减少受到的魔法伤害。","Slightly reduces the amount of magic damage taken."),
    mod_t = {MGR =10},
  }
  

end