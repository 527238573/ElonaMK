local suit = require"ui/suit"
--先声明本体
local weaponSkillsWin = {name = tl("武器技能","Weapon Skills"),icon_index = 13}

local skill_List = {"cutting","bashing","stabbing","polearm","martial_arts","bow","firearm","energy_gun","big_gun","throw","shield","magic_chant","soft_weapon",}
local select_skill_index = 1

local icons = c.pic.uiAttr

local drawBar = ui.drawBar


local function drawBack(x,y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+40,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+200,y+40,0,1,1)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("名称","Name"), x+73, y+40) --改成一次性的读取翻译
  love.graphics.print(tl("技能等级 经验","Skill Level and Exp"), x+223, y+40) --改成一次性的读取翻译
  love.graphics.line(x+53, y+58,x+140, y+58)
  love.graphics.line(x+203, y+58,x+330, y+58)
end

local function drawBack_list(x,y,w,h)
  --love.graphics.setColor(1,1,1)
  
  --love.graphics.rectangle("fill",x,y,w,h,5,5)
end

local function one_skill(num,x,y,w,h)
  local skillid = skill_List[num]
  if skillid ==nil then return end
  local entry = g.skills[skillid]
  
  local state = suit:registerHitbox(nil,entry, x,y,w,h)
  
  local function draw_skillEntry()
  if num%2==1 then
    love.graphics.setColor(0.5,0.5,0.4,0.2)
    love.graphics.rectangle("fill",x,y,w,h)
  end
    
  if state =="hovered" then
    love.graphics.setColor(111/255,147/255,210/255,150/255)
    love.graphics.rectangle("fill",x,y,w,h)
  end
  if select_skill_index==num then
    love.graphics.setColor(210/255,147/255,111/255,150/255)
    love.graphics.rectangle("fill",x,y,w,h)
  end
  local level,exprate = p.mc:getSkillLevelAndExp(skillid)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(icons.img,icons[entry.icon],x+2,y+2,0,2,2)
  
  love.graphics.setColor(0.1,0.1,0.1)
  love.graphics.setFont(c.font_c18)
  love.graphics.print(entry.name, x+48, y+7)
  
  local levelstr =string.format("Lv%d",level)
  love.graphics.setColor(0,0,0)
  love.graphics.print(levelstr, x+171, y+9)
  love.graphics.setColor(22/255,169/255,168/255)
  --love.graphics.oldColor(22,math.min(level*20,255),math.min(level*10,255))
  love.graphics.print(levelstr, x+170, y+8)
  love.graphics.setColor(1,1,1,1)
  --exprate
  drawBar(exprate,2,x+230,y+6,220,20,4)
  love.graphics.print(string.format("%.02f%%",exprate*100), x+320, y+6)
  
  end
  suit:registerDraw(draw_skillEntry)
  if suit:mouseReleasedOn(entry) then --hit one skill
    select_skill_index = num
    --ui.iteminfo_reset()--重置物品信息
  end
  return suit:standardState(entry)
end
local skillsScroll = {w= 500,h = 468,itemYNum= 13,opt ={id= newid(),hide_disable = true}}
local function skillList(x,y,w,h)
  
  suit:registerDraw(drawBack_list,x,y,w,h)
  skillsScroll.h = (h/skillsScroll.itemYNum) * #skill_List
  suit:List(skillsScroll,one_skill,skillsScroll.opt,x,y,w,h)
  
end


local function skill_info(x,y,w,h)
  local skillid = skill_List[select_skill_index]
  local entry = g.skills[skillid]
  
  local function draw_skill_info()
    love.graphics.setColor(183/255,186/255,210/255,0.2)
    love.graphics.rectangle("fill",x+10,y+60,w-40,300,5,5)
    if entry==nil or entry.typeid then return end
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.setFont(c.font_c20)
    love.graphics.print(entry.name, x+16, y+5)
    local level,exprate = p.mc:getSkillLevelAndExp(skillid)
    love.graphics.print(string.format("Lv%d",level), x+16, y+32)
    love.graphics.setColor(1,1,1)
    drawBar(exprate,2,x+65,y+32,200,20,4)
    love.graphics.setFont(c.font_c16)
    love.graphics.print(string.format("%.02f%%",exprate*100), x+145, y+33)
    
    local main_attr = g.main_attr[entry.main_attr]
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.setFont(c.font_c18)
    love.graphics.print(tl("主属性:","Base Attribute:"), x+20, y+370)
    love.graphics.print(main_attr.name, x+170, y+370)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(icons.img,icons[main_attr.icon],x+136, y+365,0,2,2)
    if entry.description then
      love.graphics.setColor(0.3,0.3,0.3)
      love.graphics.printf(entry.description, x+15, y+65,250)
    end
  end
  suit:registerDraw(draw_skill_info)
end


function weaponSkillsWin.keyinput(key)
  if key=="up" then  select_skill_index = c.clamp(select_skill_index-1,1,#skill_List) end
  if key=="down" then  select_skill_index = c.clamp(select_skill_index+1,1,#skill_List) end
end

function weaponSkillsWin.win_open()
end

function weaponSkillsWin.win_close()
  
end


function weaponSkillsWin.window_do(dt,s_win)
  suit:registerDraw(drawBack,s_win.x,s_win.y)
  skillList(s_win.x+30,s_win.y+64,skillsScroll.w,468)
  skill_info(s_win.x+510,s_win.y+30,300,540)
end

return weaponSkillsWin