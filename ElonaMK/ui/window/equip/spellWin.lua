local suit = require"ui/suit"
--先声明本体
local spellWin = {name = tl("招式/魔法","Skills/Spells"),icon = 15,opt = {id= newid()}}

local icons = c.pic.uiAttr
local abiButton = require"ui/component/abilityBtn"
local cur_unit
local cur_list
local selectIndex = 1

--条目的opt，按需增多。
local optList = {}
local function getOptInfo(index)
  local info = optList[index]
  if info==nil then
    info = {opt1 = {id =newid(), pic_size= 2},opt2 = {id =newid(),quads = c.pic.btn_quads,font = c.font_c16},opt3={id =newid()}}
    optList[index] = info
  end
  return info
end

local function shortCutCall(clear,shortcut)
  if clear then
    cur_unit.actionBar:clearAbility(cur_list[selectIndex])
  elseif shortcut then
    if cur_list[selectIndex] ==nil then return end
    cur_unit:assignAbilityToActionBar(selectIndex,shortcut)
    g.playSound("log")
  end
end


local magstr = tl("魔法","Spell")
local skistr = tl("招式","Skill")
local function oneSpell(index,x,y,w,h,dark)
  local c_spell = cur_list[index]
  if c_spell ==nil then return end
  local img = c_spell:getAbilityIcon()
  local optinfo = getOptInfo(index)
  local opt3 = optinfo.opt3
  local keystr = cur_unit.actionBar:getAbilityIndexStr(c_spell)
  opt3.state = suit:registerHitbox(opt3,opt3.id,x,y,w-1,h-1)

  local function draw_entry2()
    if dark then
      love.graphics.setColor(0.5,0.5,0.4,0.2)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if opt3.state =="hovered"  then
      love.graphics.setColor(111/255,147/255,210/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif opt3.state =="active" then
      love.graphics.setColor(151/255,107/255,150/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if selectIndex==index then
      love.graphics.setColor(210/255,147/255,111/255,150/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    love.graphics.setColor(0,0,0)
    love.graphics.setFont(c.font_c18)
    love.graphics.printf(c_spell:getName(),x+90,y+10,260,"left")
    if c_spell:isMagic() then
      love.graphics.setColor(0.1,0.1,0.6)
      love.graphics.printf(magstr,x+90,y+10,260,"right")
    else
      love.graphics.setColor(0.6,0.2,0.1)
      love.graphics.printf(skistr,x+90,y+10,260,"right")
    end
    local levelstr =string.format("Lv%d",c_spell:getLevel())
    love.graphics.setFont(c.font_c20)
    love.graphics.setColor(0,0,0)
    love.graphics.print(levelstr, x+91, y+39)
    love.graphics.setColor(22/255,169/255,168/255)
    love.graphics.print(levelstr, x+90, y+39)

    local exp = c_spell:getExp()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(c.font_c16)
    ui.drawBar(exp,2,x+150,y+39,210,20,4)
    love.graphics.print(string.format("%.02f%%",exp*100), x+235, y+39)

    local main_attr = g.main_attr[c_spell:getMainAttr()]
    love.graphics.setColor(0.3,0.3,0.3)
    --love.graphics.setFont(c.font_c18)
    love.graphics.print(tl("主属性:","Base Attr:"), x+90, y+69)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(icons.img,icons[main_attr.icon],x+160, y+64,0,2,2)
    love.graphics.draw(icons.img,icons[10],x+210, y+64,0,2,2)
    love.graphics.draw(icons.img,icons[41],x+290, y+66,0,2,2)
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.setFont(c.font_c18)
    love.graphics.print(tostring(c_spell:getCostMana()), x+245, y+69)
    love.graphics.print(tostring(c_spell:getCooldown()), x+325, y+69)
  end
  suit:registerDraw(draw_entry2)
  local state_abi = abiButton(img,c_spell:getCoolRate(),optinfo.opt1,x+5,y+5,60,64)
  local state_key = suit:S9Button(keystr,optinfo.opt2,x+5,y+70,60,26)
  local entry_st = suit:standardState(opt3.id)
  if entry_st.hit then 
    if selectIndex~=index then
      selectIndex=index
      g.playSound("click1")
    end
  end
  if state_abi.hit then 
    if selectIndex~=index then
      selectIndex=index
    end
    local suc = cur_unit:useAbility(c_spell,true)
    if suc then
      ui.equipWin:Close()
    else
      g.playSound("click1")
    end
  end

  if state_key.hit then
    selectIndex=index
    ui.equipWin:OpenChild(ui.shortCutWin,shortCutCall)
  end
  local combineState = suit:combineState(opt3.id,state_abi,state_key,entry_st)
  return combineState
end

local function oneLine(numline,x,y,w,h)
  oneSpell(numline*2-1,x,y,w/2,h,numline%2==0)
  oneSpell(numline*2,x+w/2,y,w/2,h,numline%2==1)
end

local spellScroll = {w= 500,h = 500,itemYNum=5,win_w =760,win_h =500,opt ={id= newid(),hide_disable = false},wheel_step = 32}
local function spellList(alist,x,y)
  local w,h = spellScroll.win_w,spellScroll.win_h

  spellScroll.h = math.floor((math.max(1,#cur_list)+1)/2)*50--800--(cur_list.itemYNum) *#itemlist-- #skill_List
  suit:List(spellScroll,oneLine,spellScroll.opt,x,y,w,h)
end

local info_str = tl("快捷键1~8:指定技能快捷键   方向键:选择技能  E键/点击图标:使用技能","Shortcuts 1~8: [Specify shortcuts] Arrow keys: [Select] E button/Click: [Use ability]")
local function drawBack(x,y,w,h)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.line(x+20, y+h-45,x+w-50, y+h-45)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(info_str, x+30, y+h-41)
end

--使当前条目完整可见。
local function seeEntry()
  local lineNum = math.max(1,math.floor((selectIndex+1)/2))
  local singleH = spellScroll.win_h/spellScroll.itemYNum

  local upLine = singleH*(lineNum-1)
  if spellScroll.v_value >upLine then spellScroll.v_value = upLine end
  local downLine = singleH*(lineNum)
  if spellScroll.v_value+spellScroll.win_h<downLine then spellScroll.v_value = downLine-spellScroll.win_h end
  --如果超过了合法值会自动调整
end

local function pressUp()
  if #cur_list ==0 then return end
  if selectIndex-2 <1 then return end
  selectIndex =c.clamp(selectIndex-2,1,#cur_list)
  seeEntry()
  g.playSound("pop1")
end
local function pressDown()
  if #cur_list ==0 then return end
  if selectIndex ==#cur_list then return end
  selectIndex = c.clamp(selectIndex+2,1,#cur_list)
  seeEntry()
  g.playSound("pop1")
end
local function pressLeft()
  if #cur_list ==0 then return end
  if selectIndex%2==1 then return end
  selectIndex = c.clamp(selectIndex-1,1,#cur_list)
  seeEntry()
  g.playSound("pop1")
end
local function pressRight()
  if #cur_list ==0 then return end
  if selectIndex%2==0 then return end
  if selectIndex == #cur_list then return end
  selectIndex = c.clamp(selectIndex+1,1,#cur_list)
  seeEntry()
  g.playSound("pop1")
end
local function pressComfirm()
  --ui.equipWin:Close()
  local c_spell = cur_list[selectIndex]
  if c_spell ==nil then return end
  local suc = cur_unit:useAbility(c_spell,true)
  if suc then
    ui.equipWin:Close()
  else
    g.playSound("click1")
  end
end

function spellWin.keyinput(key)
  if key=="up" then  pressUp(); ui.registerTurboKey("up",0.07,pressUp)
  elseif key=="down" then  pressDown(); ui.registerTurboKey("down",0.07,pressDown)
  elseif key=="left" then  pressLeft(); 
  elseif key=="right" then  pressRight();
  elseif key=="comfirm" then  pressComfirm();
  else
    local shortcut = ui.keyToActionIndex(key)
    if shortcut then shortCutCall(false,shortcut) end
  end
end

function spellWin.win_open()

end

function spellWin.win_close()
  ui.clearTurboKey()
end


function spellWin.window_do(dt,s_win)
  cur_unit = p.mc
  cur_list = cur_unit.abilities
  selectIndex = c.clamp(selectIndex,1,#cur_list)
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  spellList(nil,s_win.x+20,s_win.y+45)
end

return spellWin