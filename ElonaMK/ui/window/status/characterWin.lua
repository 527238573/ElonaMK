require"ui/component/info/infoEffect"
require"ui/component/info/infoTrait"
local suit = require"ui/suit"

local characterWin = {name = tl("人物","Character")}
local statusWin = ui.statusWin--父窗口。真正的当前窗口


local function drawHpbar(hp,maxhp,x,y,w,h)
  love.graphics.oldColor(143,59,59)
  love.graphics.rectangle("fill",x,y,w,h)
  if hp>0 then
    local hplen = hp/maxhp*(w-4)
    love.graphics.oldColor(121,213,68)
    love.graphics.rectangle("fill",x+2,y+2,hplen,h-4)
  end
end

local function setValColor(val,base)
  if val==base then
    love.graphics.oldColor(22,22,22)
  elseif val>base then
    love.graphics.oldColor(11,129,11)
  else
    love.graphics.oldColor(142,22,22)
  end
end

local function drawBack(x,y,w,h)

  love.graphics.oldColor(183,186,210)
  love.graphics.rectangle("fill",x+160,y+35,625,148)
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c18)
  love.graphics.print(tl("人物姓名    性别","Character Name         Sex"), x+170, y+38) --改成一次性的读取翻译
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_str,x+165,y+60,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_dex,x+165,y+85,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_int,x+165,y+110,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_per,x+165,y+135,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_speed,x+165,y+160,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_morale,x+395,y+60,0,2,2)
  love.graphics.draw(ui.res.hpstate_img,ui.res.hpquad_pain,x+395,y+85,0,2,2)
  love.graphics.oldColor(82,82,82)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("力量","Strength"), x+190, y+60) --改成一次性的读取翻译
  love.graphics.print(tl("敏捷","Dexterity"), x+190, y+85) --改成一次性的读取翻译
  love.graphics.print(tl("智力","Intelligence"), x+190, y+110) --改成一次性的读取翻译
  love.graphics.print(tl("感知","Perception"), x+190, y+135) --改成一次性的读取翻译
  love.graphics.print(tl("速度","Speed"), x+190, y+160) --改成一次性的读取翻译

  love.graphics.print(tl("情绪","Morale"), x+420, y+60) --改成一次性的读取翻译
  love.graphics.print(tl("疼痛","Pain"), x+420, y+85) --改成一次性的读取翻译

  love.graphics.print(tl("头部","Head"), x+610, y+40) 
  love.graphics.print(tl("躯干","Torso"), x+610, y+65) 
  love.graphics.print(tl("左臂","L Arm"), x+610, y+90) 
  love.graphics.print(tl("右臂","R Arm"), x+610, y+115) 
  love.graphics.print(tl("左腿","L Leg"), x+610, y+140) 
  love.graphics.print(tl("右腿","R Leg"), x+610, y+165) 

  --基础值
  local base_str= player.base.str


  love.graphics.print(string.format("(%d)",player.base.str), x+340, y+60) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",player.base.dex), x+340, y+85) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",player.base.int), x+340, y+110) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",player.base.per), x+340, y+135) --改成一次性的读取翻译
  love.graphics.print(string.format("(%d)",player.base.speed), x+335, y+160) --改成一次性的读取翻译



  --变化值
  local val = player:cur_str()
  setValColor(val,player.base.str)
  love.graphics.print(string.format("%d",val), x+310, y+60) --改成一次性的读取翻译
  val = player:cur_dex()
  setValColor(val,player.base.dex)
  love.graphics.print(string.format("%d",val), x+310, y+85) --改成一次性的读取翻译
  val = player:cur_int()
  setValColor(val,player.base.int)
  love.graphics.print(string.format("%d",val), x+310, y+110) --改成一次性的读取翻译
  val = player:cur_per()
  setValColor(val,player.base.per)
  love.graphics.print(string.format("%d",val), x+310, y+135) --改成一次性的读取翻译
  val = player:get_speed()
  setValColor(val,player.base.speed)
  love.graphics.print(string.format("%d",val), x+305, y+160) --改成一次性的读取翻译

  val = -1
  setValColor(val,0)
  love.graphics.print(string.format("%+d",val), x+505, y+60) --改成一次性的读取翻译
  val = 0
  setValColor(-val,0)
  love.graphics.print(string.format("%d",val), x+505, y+85) --改成一次性的读取翻译



  drawHpbar(player.hp_part["bp_head"],player:get_max_hp("bp_head"),x+660,y+38,120,20)
  drawHpbar(player.hp_part["bp_torso"],player:get_max_hp("bp_torso"),x+660,y+63,120,20)
  drawHpbar(player.hp_part["bp_arm_l"],player:get_max_hp("bp_arm_l"),x+660,y+88,120,20)
  drawHpbar(player.hp_part["bp_arm_r"],player:get_max_hp("bp_arm_r"),x+660,y+113,120,20)
  drawHpbar(player.hp_part["bp_leg_l"],player:get_max_hp("bp_leg_l"),x+660,y+138,120,20)
  drawHpbar(player.hp_part["bp_leg_r"],player:get_max_hp("bp_leg_r"),x+660,y+163,120,20)

  statusWin.draw_player(x,y)

  --特性

  love.graphics.oldColor(82,82,82)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("详细属性","Detailed attribute"), x+70, y+200) 
  love.graphics.print(tl("特性","Traits"), x+360, y+200) 
  love.graphics.print(tl("效果","Effects"), x+630, y+200) 
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(ui.res.common_contentS9,x+10,y+220,255,360)

  suit.theme.drawScale9Quad(ui.res.common_contentS9,x+290,y+220,215,360)
  suit.theme.drawScale9Quad(ui.res.common_contentS9,x+530,y+220,240,360)
end

local lasthover = nil
local hovertime = 0
local function setHover(something)
  if lasthover~= something then lasthover =something; hovertime = 0 end
end


local hover_trait
local hover_effect
local traits_list

local detail_list
local function loadState()
  traits_list = {}
  for _,v in pairs(player.traits) do
    traits_list[#traits_list +1] = v
  end

  detail_list = {}
  --重载入基本信息
  local numdice,sides = player:hit_roll_dice()
  detail_list[#detail_list+1] = {left = tl("近战命中骰子:","melee hit roll:"),right = string.format("%dd%d",numdice,sides)}
  numdice,sides = player:dodge_roll_dice()
  detail_list[#detail_list+1] = {left = tl("闪避骰子:","dodge roll:"),right = string.format("%dd%d",numdice,sides)}

end


local function oneTrait(num,x,y,w,h)
  local curTrait = traits_list[num]
  if not curTrait then return end 
  local state = suit:registerHitbox(nil,curTrait, x,y,w,h)
  if state =="hovered" then hover_trait = curTrait;setHover(curTrait) end

  local function drawOneTrait()
    if state =="hovered" then
      love.graphics.oldColor(111,147,210,150)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if curTrait:is_good() then
      love.graphics.oldColor(22,102,22)
    else
      love.graphics.oldColor(102,22,22)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(curTrait:getName(), x+6, y+4)
  end
  suit:registerDraw(drawOneTrait)
end



local traitsScroll = {w= 300,h = 360,itemYNum= 15,opt ={id= newid()}}
local function traitsWin(x,y,w,h)
  traitsScroll.h = (360/traitsScroll.itemYNum) * #traits_list
  suit:List(traitsScroll,oneTrait,traitsScroll.opt,x,y,w,h)
end



local function oneEffect(num,x,y,w,h)
  local eff_list = player.effect_list 
  local curEffect = eff_list[num]
  if not curEffect then return end 
  local state = suit:registerHitbox(nil,curEffect.type, x,y,w,h)--用type做id，防止和底层的effectview冲突
  if state =="hovered" then hover_effect = curEffect;setHover(curEffect) end

  local function drawOneEffect()
    if state =="hovered" then
      love.graphics.oldColor(111,147,210,150)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    local color = curEffect:get_color()
    love.graphics.oldColor(color[1],color[2],color[3])
    love.graphics.setFont(c.font_c16)
    love.graphics.print(curEffect:getName(), x+6, y+4)
  end
  suit:registerDraw(drawOneEffect)
end




local effectsScroll = {w= 400,h = 360,itemYNum= 15,opt ={id= newid()}}
local function effectWin(x,y,w,h)
  local eff_list = player.effect_list
  effectsScroll.h = (360/effectsScroll.itemYNum) * #eff_list
  suit:List(effectsScroll,oneEffect,effectsScroll.opt,x,y,w,h)

end

local function oneDetail(num,x,y,w,h)
  local curEntry = detail_list[num]
  if not curEntry then return end 

  local function drawOneDetail()
    love.graphics.oldColor(22,22,22)
    love.graphics.setFont(c.font_c16)
    love.graphics.print(curEntry.left, x+6, y+4)
    love.graphics.printf(curEntry.right, x+6, y+4,240,"right")
  end
  suit:registerDraw(drawOneDetail)
end

local detailScroll = {w= 400,h = 350,itemYNum= 15,opt ={id= newid()}}
local function detailWin(x,y,w,h)
  --调整高度
  detailScroll.h = (360/detailScroll.itemYNum) * #detail_list
  suit:List(detailScroll,oneDetail,detailScroll.opt,x,y,w,h)
end


function characterWin.keyinput(key)
  if key=="escape" then  statusWin:Close() end
end


function characterWin.win_open()
  loadState()
end

function characterWin.win_close()
  traits_list = nil
end

function characterWin.window_do(dt,x,y,w,h)
  suit:registerDraw(drawBack,x,y,w,h)

  hover_trait = nil
  hover_effect = nil
  detailWin(x+12,y+222,271,356)
  traitsWin(x+292,y+222,231,356)
  effectWin(x+532,y+222,256,356)

  hovertime = hovertime+dt
  if hover_trait and hovertime >0.5 then
    ui.traitInfo(hover_trait,love.mouse.getX(),love.mouse.getY())
  end
  if hover_effect and hovertime >0.5 then
    ui.effectInfo(hover_effect,love.mouse.getX(),love.mouse.getY())
  else
    ui.clearEffectInfo()
  end

end

return characterWin