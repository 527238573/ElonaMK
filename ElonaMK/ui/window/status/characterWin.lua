local suit = require"ui/suit"
--先声明本体
local characterWin = {name = tl("人物","Character"),icon_index = 9}

local function valColor(cur,base)
  if cur<base then 
    love.graphics.setColor(0.5,0.1,0.1)
  elseif cur>base then
    love.graphics.setColor(0.1,0.5,0.1)
  else
    love.graphics.setColor(0.1,0.1,0.1)
  end
end

local potential_s = {tl("拙劣","Hopeless"),tl("平庸","Bad  "),tl("良好","Good"),tl("优秀","Great"),tl("极佳","Superb")}
local function potenrial_str(p)
  p = math.floor(p*100)
  local index =1
  if p<=50 then index =1 
  elseif p<=100 then index =2 
  elseif p<=150 then index =3 
  elseif p<=200 then index =4
  else index= 5 end
  return string.format("%s%d%%",potential_s[index],p)
end



local function drawBar(value,style,x,y,w,h,border)
  local pb = c.pic.progressBar
	local xb, yb, wb, hb -- size of the progress bar
  xb, yb, wb, hb = x+border,y+ border, (w-2*border)*value, h-2*border
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(pb[1],x,y,w,h)
  suit.theme.drawScale9Quad(pb[style],xb,yb,wb,hb)
end


local lineH = 24
local function drawBack(x,y,w,h)
  
  local mc = p.mc
  love.graphics.setFont(c.font_x18)
  --love.graphics.setColor(82/255,82/255,82/255)
  love.graphics.setColor(0.1,0.1,0.1)
  love.graphics.print(tl("名字","Name"), x+50, y+60) --改成一次性的读取翻译
  love.graphics.print(tl("别名","Aka"), x+50, y+60+lineH) --改成一次性的读取翻译
  love.graphics.print(tl("种族","Race"), x+50, y+60+lineH*2) --改成一次性的读取翻译
  love.graphics.print(tl("职业","Class"), x+50, y+60+lineH*3) --改成一次性的读取翻译
  
  love.graphics.print(tl("性别","Sex"), x+250, y+60) --改成一次性的读取翻译
  love.graphics.print(tl("年龄","Age"), x+250, y+60+lineH) --改成一次性的读取翻译
  love.graphics.print(tl("身高","Height"), x+250, y+60+lineH*2) --改成一次性的读取翻译
  love.graphics.print(tl("体重","Weight"), x+250, y+60+lineH*3) --改成一次性的读取翻译
  
  love.graphics.print(tl("等级","Level"), x+425, y+60) --改成一次性的读取翻译
  love.graphics.print(tl("经验","EXP"), x+425, y+60+lineH) --改成一次性的读取翻译
  love.graphics.print(tl("必要值","NextLV"), x+425, y+60+lineH*2) --改成一次性的读取翻译
  love.graphics.print(tl("所属","Faction"), x+425, y+60+lineH*3) --改成一次性的读取翻译
  love.graphics.setColor(0.1,0.1,0.1)
  love.graphics.setFont(c.font_c18)
  love.graphics.print(mc:getName(), x+110, y+60) 
  love.graphics.print(mc:getAkaName(), x+110, y+60+lineH) 
  love.graphics.print(mc:getRaceName(), x+110, y+60+lineH*2) 
  love.graphics.print(mc:getClassName(), x+110, y+60+lineH*3) 
  
  love.graphics.print(mc:getSexName(), x+310, y+60) 
  love.graphics.print(string.format("%d",mc:getAge()), x+310, y+60+lineH) 
  love.graphics.print(string.format("%d cm",mc:getHeight()), x+310, y+60+lineH*2) 
  love.graphics.print(string.format("%d kg",mc:getWeight()), x+310, y+60+lineH*3) 
  
  love.graphics.print(string.format("%d",mc.level), x+485, y+60) 
  love.graphics.print(string.format("%d",mc.exp), x+485, y+60+lineH) 
  love.graphics.print(string.format("%d",1234), x+485, y+60+lineH*2) 
  love.graphics.print("无",        x+485, y+60+lineH*3) 
  
  
  love.graphics.setColor(1,1,1)
  local head_pic = mc:getPortrait()
  suit.theme.drawScale9Quad(c.pic.titleKuang,x+650,y+40,84,120)
  love.graphics.draw(head_pic,x+656,y+46,0,1.5,1.5)
  local anim = mc:get_unitAnim()
  love.graphics.draw(anim.img,anim[anim.stillframe],x+700,y+154,0,1.5,1.5,0,anim.h)
  
  --attr
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+164,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+410,y+164,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+460,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+540,y+460,0,1,1)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("主要属性 (本来值)","Attributes  (Org)"), x+73, y+162) --改成一次性的读取翻译
  love.graphics.print(tl("潜力","Potential"), x+290, y+162) --改成一次性的读取翻译
  love.graphics.print(tl("其他属性","Others"), x+433, y+162)
  love.graphics.print(tl("攻击修正","Attack Rolls"), x+73, y+458)
  love.graphics.print(tl("防御修正","Defense Rolls"), x+563, y+458)
  love.graphics.line(x+73, y+180,x+363, y+180)
  love.graphics.line(x+410, y+180,x+740, y+180)
  love.graphics.line(x+73, y+476,x+443, y+476)
  love.graphics.line(x+540, y+476,x+740, y+476)
  --attrIcon
  love.graphics.setColor(1,1,1)
  local iconlength = 34 
  local icons = c.pic.uiAttr
  love.graphics.draw(icons.img,icons[1],x+40,y+185+iconlength*0,0,2,2)
  love.graphics.draw(icons.img,icons[2],x+40,y+185+iconlength*1,0,2,2)
  love.graphics.draw(icons.img,icons[3],x+40,y+185+iconlength*2,0,2,2)
  love.graphics.draw(icons.img,icons[4],x+40,y+185+iconlength*3,0,2,2)
  love.graphics.draw(icons.img,icons[5],x+40,y+185+iconlength*4,0,2,2)
  love.graphics.draw(icons.img,icons[6],x+40,y+185+iconlength*5,0,2,2)
  love.graphics.draw(icons.img,icons[7],x+40,y+185+iconlength*6,0,2,2)
  love.graphics.draw(icons.img,icons[8],x+40,y+185+iconlength*7,0,2,2)
  
  
  love.graphics.draw(icons.img,icons[16],x+400,y+185+iconlength*0,0,2,2)
  love.graphics.draw(icons.img,icons[30],x+400,y+185+iconlength*1,0,2,2)
  love.graphics.draw(icons.img,icons[9], x+400,y+185+iconlength*2,0,2,2)
  love.graphics.draw(icons.img,icons[10],x+400,y+185+iconlength*3,0,2,2)
  love.graphics.draw(icons.img,icons[11],x+400,y+185+iconlength*4,0,2,2)
  love.graphics.draw(icons.img,icons[13],x+400,y+185+iconlength*5,0,2,2)
  love.graphics.draw(icons.img,icons[12],x+400,y+185+iconlength*6,0,2,2)
  love.graphics.draw(icons.img,icons[14],x+400,y+185+iconlength*7,0,2,2)
  --love.graphics.draw(icons.img,icons[15],x+400,y+185+iconlength*8,0,2,2)
  
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c18)
  love.graphics.print(tl("力量","Strength"), x+79, y+192+iconlength*0) --改成一次性的读取翻译
  love.graphics.print(tl("体质","Constitution"), x+79, y+192+iconlength*1) --改成一次性的读取翻译
  love.graphics.print(tl("灵巧","Dexterity"), x+79, y+192+iconlength*2) --改成一次性的读取翻译
  love.graphics.print(tl("感知","Perception"), x+79, y+192+iconlength*3) --改成一次性的读取翻译
  love.graphics.print(tl("学习","Learning"), x+79, y+192+iconlength*4) --改成一次性的读取翻译
  love.graphics.print(tl("意志","Will"), x+79, y+192+iconlength*5) --改成一次性的读取翻译
  love.graphics.print(tl("魔力","Magic"), x+79, y+192+iconlength*6) --改成一次性的读取翻译
  love.graphics.print(tl("魅力","Charisma"), x+79, y+192+iconlength*7) --改成一次性的读取翻译
  
  love.graphics.print(tl("HP","HP"), x+439, y+192+iconlength*0) --改成一次性的读取翻译
  love.graphics.print(tl("MP","MP"), x+439, y+192+iconlength*1) --改成一次性的读取翻译
  love.graphics.print(tl("生命力","Life"), x+439, y+192+iconlength*2) --改成一次性的读取翻译
  love.graphics.print(tl("法力","Mana"), x+439, y+192+iconlength*3) --改成一次性的读取翻译
  love.graphics.print(tl("速度","Speed"), x+439, y+192+iconlength*4) --改成一次性的读取翻译
  love.graphics.print(tl("名声","Fame"), x+439, y+192+iconlength*5) --改成一次性的读取翻译
  love.graphics.print(tl("善恶值","Karma"), x+439, y+192+iconlength*6) --改成一次性的读取翻译
  love.graphics.print(tl("最大负重","Carry Lmt"), x+439, y+192+iconlength*7) --改成一次性的读取翻译
  --love.graphics.print(tl("装备重量","Equip Wt"), x+439, y+192+iconlength*8) --改成一次性的读取翻译
  
  --value
  local c_str,b_str = mc:cur_str(),mc:base_str()
  local c_con,b_con = mc:cur_con(),mc:base_con()
  local c_dex,b_dex = mc:cur_dex(),mc:base_dex()
  local c_per,b_per = mc:cur_per(),mc:base_per()
  local c_ler,b_ler = mc:cur_ler(),mc:base_ler()
  local c_wil,b_wil = mc:cur_wil(),mc:base_wil()
  local c_mag,b_mag = mc:cur_mag(),mc:base_mag()
  local c_chr,b_chr = mc:cur_chr(),mc:base_chr()
  
  valColor(c_str,b_str);love.graphics.print(string.format("%d",c_str), x+175, y+192+iconlength*0) --改成一次性的读取翻译
  valColor(c_con,b_con);love.graphics.print(string.format("%d",c_con), x+175, y+192+iconlength*1) --改成一次性的读取翻译
  valColor(c_dex,b_dex);love.graphics.print(string.format("%d",c_dex), x+175, y+192+iconlength*2) --改成一次性的读取翻译
  valColor(c_per,b_per);love.graphics.print(string.format("%d",c_per), x+175, y+192+iconlength*3) --改成一次性的读取翻译
  valColor(c_ler,b_ler);love.graphics.print(string.format("%d",c_ler), x+175, y+192+iconlength*4) --改成一次性的读取翻译
  valColor(c_wil,b_wil);love.graphics.print(string.format("%d",c_wil), x+175, y+192+iconlength*5) --改成一次性的读取翻译
  valColor(c_mag,b_mag);love.graphics.print(string.format("%d",c_mag), x+175, y+192+iconlength*6) --改成一次性的读取翻译
  valColor(c_chr,b_chr);love.graphics.print(string.format("%d",c_chr), x+175, y+192+iconlength*7) --改成一次性的读取翻译
  
  love.graphics.setColor(0.1,0.1,0.1)
  love.graphics.print(string.format("(%d)",b_str), x+215, y+192+iconlength*0) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_con), x+215, y+192+iconlength*1) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_dex), x+215, y+192+iconlength*2) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_per), x+215, y+192+iconlength*3) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_ler), x+215, y+192+iconlength*4) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_wil), x+215, y+192+iconlength*5) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_mag), x+215, y+192+iconlength*6) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",b_chr), x+215, y+192+iconlength*7) --改成一次性的读取翻译
  
  love.graphics.setColor(0.3,0.3,0.3)
  love.graphics.print(potenrial_str(mc:potential_str()), x+265, y+192+iconlength*0) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_con()), x+265, y+192+iconlength*1) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_dex()), x+265, y+192+iconlength*2) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_per()), x+265, y+192+iconlength*3) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_ler()), x+265, y+192+iconlength*4) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_wil()), x+265, y+192+iconlength*5) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_mag()), x+265, y+192+iconlength*6) --改成一次性的读取翻译
  love.graphics.print(potenrial_str(mc:potential_chr()), x+265, y+192+iconlength*7) --改成一次性的读取翻译
  
  drawBar(1,3,x+530, y+192+iconlength*0-2,230,22,4)
  drawBar(1,4,x+530, y+192+iconlength*1-2,230,22,4)
  love.graphics.setColor(1,1,1)
  love.graphics.printf(string.format("%d/%d",mc.hp,mc:getMaxHP()), x+530, y+192+iconlength*0,230,"center")
  love.graphics.printf(string.format("%d/%d",mc.mp,mc:getMaxMP()), x+530, y+192+iconlength*1,230,"center")
  
  local c_life,b_life = mc:cur_life(),mc:base_life()
  local c_mana,b_mana = mc:cur_mana(),mc:base_mana()
  local c_speed,b_speed = mc:cur_speed(),mc:base_speed()
  valColor(c_life,b_life);love.graphics.print(string.format("%d",c_life), x+530, y+192+iconlength*2)
  valColor(c_mana,b_mana);love.graphics.print(string.format("%d",c_mana), x+530, y+192+iconlength*3)
  valColor(c_speed,b_speed);love.graphics.print(string.format("%d",c_speed), x+530, y+192+iconlength*4)
  love.graphics.setColor(0.1,0.1,0.1);
  love.graphics.print(string.format("(%d)",b_life), x+570, y+192+iconlength*2)
  love.graphics.print(string.format("(%d)",b_mana), x+570, y+192+iconlength*3)
  love.graphics.print(string.format("(%d)",b_speed), x+570, y+192+iconlength*4)
  
  love.graphics.print(string.format("%d",mc.fame), x+540, y+192+iconlength*5)
  love.graphics.print(string.format("%d",mc.karma), x+540, y+192+iconlength*6)
  love.graphics.print(string.format("%.1f kg",mc:getMaxCarry()), x+540, y+192+iconlength*7)
  
  ui.drawFix(x,y,w,h)
end



function characterWin.keyinput(key)
  
end

function characterWin.win_open()
end

function characterWin.win_close()
  
end


function characterWin.window_do(dt,s_win)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
end

return characterWin