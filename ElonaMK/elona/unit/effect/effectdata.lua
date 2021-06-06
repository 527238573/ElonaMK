data.effect ={}
local function addEffect(etable)
  assert(data.effect[etable.id]==nil)
  setmetatable(etable,data.dataMeta)
  data.effect[etable.id] = etable
end


return function()
  addEffect{ id = "chanting",name = tl("吟唱","Chanting"), description = tl("正在吟唱法术技能。","Casting a spell."),front_c = {250/255,250/255,221/255},back_c = {28/255,107/255,221/255}
      
    }
  addEffect{ id = "ancient_wisdom",name = tl("远古智慧","Ancient wisdom"), description = tl("魔力得到加强。","magic increased."),front_c = {20/255,68/255,180/255},back_c = {200/255,250/255,200/255}
      
    }
    
  addEffect{ id = "sprinting",name = tl("冲刺","Sprinting"), description = tl("正在冲刺状态。","Sprinting state."),front_c = {0.1,0.1,0.1},back_c = {0.9,0.9,0.9},isAnim = true
  }
  addEffect{ id = "knock_back",name = tl("击退","Knock back"), description = tl("正在被击退状态。","Being beaten back."),front_c = {0.6,0.1,0.1},back_c = {0.9,0.9,0.9},isAnim = true
    }
  
  addEffect{ id = "test1",name = tl("测试效果1","Chanting"), description = tl("正在吟唱法术技能。较长的描述。","Casting a spell."), front_c = {1,0,0},back_c = {0.9,0.9,0.9}}
  addEffect{ id = "test2",name = tl("第二测试效果","Chanting"), description = tl("正在吟唱法术技能。较长的描述。较长的描述。较长的描述。较长的描述。","Casting a spell."), front_c = {0.2,1,0},back_c = {0.5,0.5,0.5}}
end