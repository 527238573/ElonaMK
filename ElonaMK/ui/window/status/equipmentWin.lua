local suit = require"ui/suit"

--local s_win = {name = tl("装备","Equipment"),x= c.win_W/2-500,y =c.win_H/2-300, w= 800,h =590,dragopt = {id= newid()}}
local picButton = require"ui/component/picButton"
local simpleTips = require"ui/component/info/simpleTips"
local rightClickMenu = require"ui/component/item/rightClickMenu"
local equipmentWin = {name = tl("装备","Equipment")}
local statusWin = ui.statusWin--父窗口。真正的当前窗口

local selected_item = nil
local rightClick_info = {{id = "take_off",name = tl("卸下","Take off")}}


local function drawBack(x,y,w,h)
  --love.graphics.oldColor(255,255,255)
  --suit.theme.drawScale9Quad(ui.res.common_backt,x+9,y+35,140,140)
  local jiange = 60
  local ystart = 212
  local res = ui.res
   --love.graphics.draw(res.common_img,res.common_eqbar, x+20, y+ystart,0,40,4)
  love.graphics.oldColor(183,186,210)
  local fillstart = ystart-6
  local fillw = w-16
  local weapon_startx = 180
  local weapon_starty = 120
  
  --love.graphics.oldColor(173,190,221)
  --love.graphics.rectangle("fill",x+8,y+fillstart,300,50)
  --love.graphics.rectangle("fill",x+8,y+fillstart+jiange,300,50)
  --love.graphics.rectangle("fill",x+8,y+fillstart+jiange*2,300,50)
  --love.graphics.rectangle("fill",x+8,y+fillstart+jiange*3,300,50)
  --love.graphics.rectangle("fill",x+8,y+fillstart+jiange*4,300,50)
  --love.graphics.rectangle("fill",x+8,y+fillstart+jiange*5,300,50)
  --love.graphics.oldColor(183,186,210)
  --love.graphics.oldColor(16,18,36)
  love.graphics.oldColor(216,218,236)
  love.graphics.rectangle("fill",x+8,y+fillstart,fillw,50)
  love.graphics.rectangle("fill",x+8,y+fillstart+jiange,fillw,50)
  love.graphics.rectangle("fill",x+8,y+fillstart+jiange*2,fillw,50)
  love.graphics.rectangle("fill",x+8,y+fillstart+jiange*3,fillw,50)
  love.graphics.rectangle("fill",x+8,y+fillstart+jiange*4,fillw,50)
  love.graphics.rectangle("fill",x+8,y+fillstart+jiange*5,fillw,50)
  love.graphics.rectangle("fill",x+weapon_startx,y+weapon_starty,500,50)
  
  love.graphics.oldColor(255,255,255)
  love.graphics.draw(res.common_img,res.common_head, x+20, y+ystart,0,2,2)
  love.graphics.draw(res.common_img,res.common_torso, x+20, y+ystart+jiange,0,2,2)
  love.graphics.draw(res.common_img,res.common_arms, x+20, y+ystart+jiange*2,0,2,2)
  love.graphics.draw(res.common_img,res.common_hands, x+20, y+ystart+jiange*3,0,2,2)
  love.graphics.draw(res.common_img,res.common_legs, x+20, y+ystart+jiange*4,0,2,2)
  love.graphics.draw(res.common_img,res.common_feet, x+20, y+ystart+jiange*5,0,2,2)
  love.graphics.draw(res.common_img,res.common_weapon, x+weapon_startx+6, y+weapon_starty+2,0,3,3)
  love.graphics.oldColor(102,102,102)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("部位","Body part"), x+20, y+ystart-25) --改成一次性的读取翻译
  love.graphics.print(tl("累赘度(保暖度)","Encumberance(Warmth)"), x+160, y+ystart-25)
  love.graphics.print(tl("装备","Equipment"), x+350, y+ystart-25)
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c18)
  ystart = 222
  love.graphics.print(tl("头部","Head"), x+60, y+ystart)
  love.graphics.print(tl("躯干","Torso"), x+60, y+ystart+jiange)
  love.graphics.print(tl("手臂","Arms"), x+60, y+ystart+jiange*2)
  love.graphics.print(tl("手掌","Hands"), x+60, y+ystart+jiange*3)
  love.graphics.print(tl("腿部","Legs"), x+60, y+ystart+jiange*4)
  love.graphics.print(tl("脚掌","Feet"), x+60, y+ystart+jiange*5)
  love.graphics.print(tl("武器","Weapon"), x+weapon_startx+65, y+weapon_starty+16)
  
end

local scrollrect_info = {opt = {id=newid(),horizontal = true},w = 400,h= 300}

local cur_wearing_data
local function load_displaylist()
  if player.wearing_data ==nil then
    player:on_wear_change() --重建数据结构，必须要有数据
  end
  if cur_wearing_data~= player.wearing_data then
    cur_wearing_data = player.wearing_data
    --修改宽度
    local display = cur_wearing_data.display
    local maxnum = math.max(#display.head,#display.torso,#display.arms,#display.hands,#display.legs,#display.feet)+1--所有部位最长的装备数+1
    scrollrect_info.w = maxnum*50+10--重置滚动空间长度
  end
end

local itemopt_mt = {__mode = "k"}
local itemopt = {}
setmetatable(itemopt,itemopt_mt) --弱键table

local function getItemOpt(witem)
  local opt = itemopt[witem]
  if opt ==nil then
    opt = {id =witem, pic_size = 1}
    itemopt[witem] = opt
  end
  return opt
end
local head_add_opt = {id =newid(), pic_size = 1}
local torso_add_opt = {id =newid(), pic_size = 1}
local arms_add_opt = {id =newid(), pic_size = 1}
local hands_add_opt = {id =newid(), pic_size = 1}
local legs_add_opt = {id =newid(), pic_size = 1}
local feet_add_opt = {id =newid(), pic_size = 1}
local weapon_reset_opt = {id =newid(), pic_size = 1}


local show_rightMenu =false
local rightClick_x,rightClick_y = 0,0

local function item_picbutton(witem,x,y)
  local opt = getItemOpt(witem)
  local img,quad = witem:getImgAndQuad()
  
  local state = picButton(quad,img,opt,x,y,44,48)
  if state.hit then selected_item = witem end
  if selected_item ==witem then
    opt.state = "active"
  end
  
  if suit:mouseRightOn(opt.id) then
    selected_item = witem
    show_rightMenu = true
    rightClick_x,rightClick_y = love.mouse.getX(),love.mouse.getY()
  end
  
end

local function head_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_head") or witem:covers_bodypart("bp_eyes")or witem:covers_bodypart("bp_mouth"))
end

local function torso_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_torso"))
end

local function arms_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_arm_l") or witem:covers_bodypart("bp_arm_r"))
end

local function hands_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_hand_l") or witem:covers_bodypart("bp_hand_r"))
end

local function legs_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_leg_l") or witem:covers_bodypart("bp_leg_r"))
end

local function feet_eq_filter(witem)
  return witem:is_armor() and (witem:covers_bodypart("bp_foot_l") or witem:covers_bodypart("bp_foot_r"))
end
local function weapon_eq_filter(witem)
  return witem:is_weapon() 
end


local function choose_item_to_wear(witem)
  --先测试能穿否，再脱离inventory
  --再穿
  if witem ==nil then return end
  if player:can_wear(witem,true) then
    local to_wear = player.inventory:removeItem(witem)
    if to_wear then
      player:wear_item(to_wear,true)
    else
      debugmsg("wearing item internal error")
    end
  end
end

local function choose_weapon_to_wield(witem)--todo 目前只搜索背包
  if witem ==nil then return end
  if player:can_wield(witem,true) then
    local to_wield = player.inventory:removeItem(witem)
    if to_wield then
      player:wield_item(to_wield,true)
    else
      debugmsg("wield item internal error")
    end
  end
end
ui.func.weapon_eq_filter = weapon_eq_filter
ui.func.choose_weapon_to_wield =choose_weapon_to_wield


local add_btn_hovered = false
local weapnreset_btn_hovered = false
local function equipmentList(x,y,w,h)
  load_displaylist()--查看列表是否改变，重load 
  
  local rectstate = suit:ScrollRect(scrollrect_info,scrollrect_info.opt,x,y,w,h)
  
  local gap_y = 60
  local gap_x = 50
  add_btn_hovered = false
  local display = cur_wearing_data.display
  local addbtn_state
  --head
  local curLen = #display.head
  for i=1,curLen do item_picbutton(display.head[i],scrollrect_info.x+gap_x*(i-1),y) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,head_add_opt,scrollrect_info.x+gap_x*curLen,y+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("头部装备","Head equipemnt"),head_eq_filter,choose_item_to_wear)
  end
  --torso
  curLen = #display.torso
  for i=1,curLen do item_picbutton(display.torso[i],scrollrect_info.x+gap_x*(i-1),y+gap_y) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,torso_add_opt,scrollrect_info.x+gap_x*curLen,y+gap_y+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("躯干装备","Torso equipemnt"),torso_eq_filter,choose_item_to_wear)
  end
  --arms
  curLen = #display.arms
  for i=1,curLen do item_picbutton(display.arms[i],scrollrect_info.x+gap_x*(i-1),y+gap_y*2) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,arms_add_opt,scrollrect_info.x+gap_x*curLen,y+gap_y*2+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("手臂装备","Arms equipemnt"),arms_eq_filter,choose_item_to_wear)
  end
  --hands
  curLen = #display.hands
  for i=1,curLen do item_picbutton(display.hands[i],scrollrect_info.x+gap_x*(i-1),y+gap_y*3) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,hands_add_opt,scrollrect_info.x+gap_x*curLen,y+gap_y*3+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("手掌装备","Hands equipemnt"),hands_eq_filter,choose_item_to_wear)
  end
  --legs
  curLen = #display.legs
  for i=1,curLen do item_picbutton(display.legs[i],scrollrect_info.x+gap_x*(i-1),y+gap_y*4) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,legs_add_opt,scrollrect_info.x+gap_x*curLen,y+gap_y*4+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("腿部装备","Legs equipemnt"),legs_eq_filter,choose_item_to_wear)
  end
  --feet
  curLen = #display.feet
  for i=1,curLen do item_picbutton(display.feet[i],scrollrect_info.x+gap_x*(i-1),y+gap_y*5) end
  addbtn_state = picButton(ui.res.common_ycross ,ui.res.common_img,feet_add_opt,scrollrect_info.x+gap_x*curLen,y+gap_y*5+5,34,38)
  add_btn_hovered = add_btn_hovered or addbtn_state.hovered
  if addbtn_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("脚部装备","Feet equipemnt"),weapon_eq_filter,choose_item_to_wear)
  end
  
  suit:endScissor()
end


local fist_text = tl("拳头","fists")
local function weaponButtons(x,y,w,h)
  local weapon_display = player.weapon 
  local weapon_text = fist_text
  if weapon_display~=nil then
    weapon_text = weapon_display:getName() --携带信息的name
    item_picbutton(weapon_display,x+140,y)
    
  end
  suit:registerDraw(function() 
        if weapon_display==nil then
          love.graphics.oldColor(255,255,255)
          love.graphics.draw(ui.res.common_img,ui.res.common_fists, x+140, y+5,0,2,2)
        end
        love.graphics.oldColor(55,55,55)
        love.graphics.setFont(c.font_c18)
        love.graphics.print(weapon_text, x+200, y+16)
      end)
  
  local weapon_reset_state = picButton(ui.res.common_reset,ui.res.common_img,weapon_reset_opt,x+w-40,y+5,34,38)
  weapnreset_btn_hovered = weapon_reset_state.hovered
  if weapon_reset_state.hit then
    selected_item = nil
    statusWin:OpenChild(ui.chooseItemWin,tl("更换武器","Change weapon"),weapon_eq_filter,choose_weapon_to_wield)
  end
  
end


local function printOnePart(base,add,all,warm,x,y)
  
  
  love.graphics.setFont(c.font_c16)
  local s1 = string.format("%2d+%2d=%2d",base,add,all)
  if all>5 then
    love.graphics.oldColor(128,40,40)
  elseif all>1 then
    love.graphics.oldColor(128,128,0)
  else
    love.graphics.oldColor(92,92,92)
  end
  love.graphics.print(s1, x, y)
  if warm>5 then
    love.graphics.oldColor(128,40,40)
  elseif warm>1 then
    love.graphics.oldColor(128,128,80)
  else
    love.graphics.oldColor(92,92,92)
  end
  love.graphics.print("("..warm..")", x+80, y)
end
local function printTwoPart(all1,all2,warm1,warm2,x,y)
  love.graphics.setFont(c.font_c16)
  love.graphics.oldColor(22,22,22)
  local s1 = string.format("%2d/%2d",all1,all2)
  love.graphics.print(s1, x, y)
  love.graphics.print(string.format("(%d/%d)",warm1,warm2), x+80, y)
end





--临时的，后面要改
local function encumberance_info(x,y)
  --love.graphics.oldColor(18,18,40,200)
  --love.graphics.rectangle("fill",s_win.x+160,s_win.y+222,100,300)
  
  local gap_y = 60
  local all1,base1,add1,all2,base2,add2,warmth1,warmth2
  all1,base1,add1 = player:get_bodypart_encumberance("bp_head")
  warmth1 = player:get_bodypart_warmth("bp_head")
  printOnePart(base1,add1,all1,warmth1,x,y)
  y=y+gap_y
  
  all1,base1,add1 = player:get_bodypart_encumberance("bp_torso")
  warmth1 = player:get_bodypart_warmth("bp_torso")
  printOnePart(base1,add1,all1,warmth1,x,y)
  y=y+gap_y
  
  all1,base1,add1 = player:get_bodypart_encumberance("bp_arm_l")
  all2,base2,add2 = player:get_bodypart_encumberance("bp_arm_r")
  warmth1 = player:get_bodypart_warmth("bp_arm_l")
  warmth2 = player:get_bodypart_warmth("bp_arm_r")
  if all1==all2 and warmth1==warmth2 then
    printOnePart(base1,add1,all1,warmth1,x,y)
  else
    printTwoPart(all1,all2,warmth1,warmth2,x,y)
  end
  y=y+gap_y
  
  
  all1,base1,add1 = player:get_bodypart_encumberance("bp_hand_l")
  all2,base2,add2 = player:get_bodypart_encumberance("bp_hand_r")
  warmth1 = player:get_bodypart_warmth("bp_hand_l")
  warmth2 = player:get_bodypart_warmth("bp_hand_r")
  if all1==all2 and warmth1==warmth2 then
    printOnePart(base1,add1,all1,warmth1,x,y)
  else
    printTwoPart(all1,all2,warmth1,warmth2,x,y)
  end
  y=y+gap_y
  
  
  all1,base1,add1 = player:get_bodypart_encumberance("bp_leg_l")
  all2,base2,add2 = player:get_bodypart_encumberance("bp_leg_r")
  warmth1 = player:get_bodypart_warmth("bp_leg_l")
  warmth2 = player:get_bodypart_warmth("bp_leg_r")
  if all1==all2 and warmth1==warmth2 then
    printOnePart(base1,add1,all1,warmth1,x,y)
  else
    printTwoPart(all1,all2,warmth1,warmth2,x,y)
  end
  y=y+gap_y
  
  all1,base1,add1 = player:get_bodypart_encumberance("bp_foot_l")
  all2,base2,add2 = player:get_bodypart_encumberance("bp_foot_r")
  warmth1 = player:get_bodypart_warmth("bp_foot_l")
  warmth2 = player:get_bodypart_warmth("bp_foot_r")
  if all1==all2 and warmth1==warmth2 then
    printOnePart(base1,add1,all1,warmth1,x,y)
  else
    printTwoPart(all1,all2,warmth1,warmth2,x,y)
  end
  y=y+gap_y
  
  
  --改用颜色text做 数据内含太复杂，推后
end

local weight_text = tl("装备总重量:%.2fkg","Equipment Weight:%.2fkg")
local storage_text =tl("总容纳空间:%d","Storage:%d")
local function top_info(x,y)
  statusWin.draw_player(x,y)
  
  love.graphics.oldColor(22,22,22)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(string.format(weight_text,cur_wearing_data.total_weight/100), x+220, y+45)
  love.graphics.print(string.format(storage_text,cur_wearing_data.total_storage), x+420, y+45)
  
  --全身装备总重
  --装备总容纳空间
end

--物品信息界面上的按钮
local take_off_opt = {name =tl("卸下","Take off"),font=c.font_c16,id= newid()}
local function info_buttons(x,y,w,h)
  local takeoff_st = suit:S9Button(take_off_opt.name,take_off_opt,x+10,y,70,35) 
  if takeoff_st.hit then
    if selected_item then 
      if player:take_off(selected_item,true)  then selected_item = nil end
    end
  end
end


function equipmentWin.win_close()
  selected_item = nil 
end--提前声明。keyinput要用（esc退出）

function equipmentWin.keyinput(key)
  if key=="escape" then  statusWin:Close() end
end

function equipmentWin.win_open()
  
  selected_item = nil
  --打开背包
end



function equipmentWin.window_do(dt,x,y,w,h)
  
  
  suit:registerDraw(drawBack,x,y,w,h)
  
  
  equipmentList(x+320,y+210,w-328,h-240)
  weaponButtons(x+180,y+120,500,50)
  suit:registerDraw(encumberance_info,x+160,y+222)
  suit:registerDraw(top_info,x,y)
  if selected_item then
    ui.iteminfo(selected_item,x+w,y,330,h,45)--等于发送的是缓存的物品指针。源物品可能因为后续的操作逻辑被销毁或改变等。但最多存在本帧内
    info_buttons(x+w,y+h-45,330,45)
  end
  
  if add_btn_hovered then
    simpleTips(tl("添加装备","Add equipment"))
  end
  
  if weapnreset_btn_hovered then
    simpleTips(tl("更换武器","Change weapon"))
  end
  
  if show_rightMenu then
    local ret = rightClickMenu(rightClick_info,rightClick_x,rightClick_y)
    if ret~=nil then
      show_rightMenu = false
      if ret=="take_off" then
        if selected_item then 
          if player:take_off(selected_item,true)  then selected_item = nil end
        end
      end
    end
  end
  
  
end

return equipmentWin