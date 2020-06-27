data.effect ={}
local function addEffect(etable)
  assert(data.effect[etable.id]==nil)
  setmetatable(etable,data.dataMeta)
  data.effect[etable.id] = etable
end


return function()
  addEffect{ id = "chanting",name = tl("吟唱","Chanting"), description = tl("正在吟唱法术技能。","Casting a spell."),front_c = {250/255,250/255,221/255},back_c = {28/255,107/255,221/255}
      
    }
  addEffect{ id = "test1",name = tl("测试效果1","Chanting"), description = tl("正在吟唱法术技能。较长的描述。","Casting a spell."), front_c = {1,0,0},back_c = {0.9,0.9,0.9}}
  addEffect{ id = "test2",name = tl("第二测试效果","Chanting"), description = tl("正在吟唱法术技能。较长的描述。较长的描述。较长的描述。较长的描述。","Casting a spell."), front_c = {0.2,1,0},back_c = {0.5,0.5,0.5}}
end