local suit = require"ui/suit"

local skillWin = {name = tl("技能","Skills")}
local statusWin = ui.statusWin--父窗口。真正的当前窗口


local skill_type_list = {
  { typeid = "str",
    name = tl("力量型技能","Strength skills"),
    icon =ui.res.hpquad_str, 
    img = ui.res.hpstate_img,
  },
  { typeid = "per",
    name = tl("感知型技能","Perception skills"),
    icon =ui.res.hpquad_per, 
    img = ui.res.hpstate_img,
  },
  { typeid = "dex",
    name = tl("敏捷型技能","Dexterity skills"),
    icon =ui.res.hpquad_dex, 
    img = ui.res.hpstate_img,
  },
  { typeid = "int",
    name = tl("智力型技能","Intelligence skills"),
    icon =ui.res.hpquad_int, 
    img = ui.res.hpstate_img,
    },
}

local select_skill_index = 2
local skill_List
local function loadskillList()
  local p_skills = player.skills
  skill_List = {}-- 重建列表
  for _,skill_type in ipairs(skill_type_list) do
    skill_List[#skill_List+1] = skill_type
    for _,skill_data in ipairs(data.all_skills) do --遍历顺序，按初始化顺序
      if skill_data.main_attr == skill_type.typeid then
        if p_skills[skill_data.id] then
          skill_List[#skill_List+1] = {data =skill_data,p_info =p_skills[skill_data.id]} --数据装起来
        end
      end
    end
  end
  if skill_List[select_skill_index] ==nil or skill_List[select_skill_index].typeid then
    select_skill_index = 2--自动选中第二项
  end
  
end


local function drawBack_list(x,y,w,h)
  love.graphics.oldColor(233,233,255)
  love.graphics.rectangle("fill",x,y,w,h,5,5)
end




local function one_skill(num,x,y,w,h)
  local entry = skill_List[num]
  if entry ==nil then return end
  if entry.typeid then --仅仅是标头
    local function draw_titleEntry()
      love.graphics.oldColor(255,255,255)
      love.graphics.draw(entry.img,entry.icon,x+5,y+5,0,2,2)
      love.graphics.oldColor(82,82,82)
      love.graphics.setFont(c.font_c16)
      love.graphics.print(entry.name, x+30, y+8)
      
    end
    suit:registerDraw(draw_titleEntry)
    return 
  end
  --技能
  local state = suit:registerHitbox(nil,entry, x,y,w,h)
  
  
  local function draw_skillEntry()
  if state =="hovered" then
    love.graphics.oldColor(111,147,210,150)
    love.graphics.rectangle("fill",x,y,w,h)
  elseif select_skill_index==num then
    love.graphics.oldColor(210,147,111,150)
    love.graphics.rectangle("fill",x,y,w,h)
  end
  local level = entry.p_info.level
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(entry.data.name, x+16, y+5)
  love.graphics.oldColor(22,122,122)
  --love.graphics.oldColor(22,math.min(level*20,255),math.min(level*10,255))
  love.graphics.print(string.format("Lv%d",entry.p_info.level), x+170, y+8)
  
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(ui.res.common_pbackS9,x+210,y+6,220,18)
  if entry.p_info.exp>0 then
    local length = entry.p_info.exp/100*220
    suit.theme.drawScale9Quad(ui.res.common_pfrontS9,x+210,y+6,length,18)
  end
  love.graphics.print(string.format("%.02f%%",entry.p_info.exp), x+300, y+8)
  
  end
  suit:registerDraw(draw_skillEntry)
  if suit:mouseReleasedOn(entry) then --hit one skill
    select_skill_index = num
    --ui.iteminfo_reset()--重置物品信息
  end
  
  
  return suit:standardState(entry)
end


local skillsScroll = {w= 500,h = 540,itemYNum= 18,opt ={id= newid()}}
local function skillList(x,y,w,h)
  
  suit:registerDraw(drawBack_list,x,y,w,h)
  skillsScroll.h = (h/skillsScroll.itemYNum) * #skill_List
  suit:List(skillsScroll,one_skill,skillsScroll.opt,x,y,w,h)
  
end


local function skill_info(x,y,w,h)
  local entry = skill_List[select_skill_index]
  
  
  local function draw_skill_info()
    love.graphics.oldColor(183,186,210)
    love.graphics.rectangle("fill",x+10,y+60,w-40,300,5,5)
    if entry==nil or entry.typeid then return end
    love.graphics.oldColor(22,22,22)
    love.graphics.setFont(c.font_c20)
    love.graphics.print(entry.data.name, x+16, y+5)
    love.graphics.print(string.format("Lv%d",entry.p_info.level), x+16, y+32)
    love.graphics.oldColor(255,255,255)
    suit.theme.drawScale9Quad(ui.res.common_pbackS9,x+65,y+32,200,18)
    if entry.p_info.exp>0 then
      local length = entry.p_info.exp/100*200
      suit.theme.drawScale9Quad(ui.res.common_pfrontS9,x+65,y+32,length,18)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(string.format("%.02f%%",entry.p_info.exp), x+145, y+34)
    
    love.graphics.oldColor(22,22,22)
    love.graphics.printf(entry.data.description, x+15, y+65,250)
    
  end
  suit:registerDraw(draw_skill_info)
end

function skillWin.keyinput(key)
  if key=="escape" then  statusWin:Close() end
end


function skillWin.win_open()
  loadskillList()
end

function skillWin.win_close()
  
end

function skillWin.window_do(dt,x,y,w,h)
  skillList(x+10,y+35,500,540)
  skill_info(x+510,y+35,300,540)
  
end

return skillWin