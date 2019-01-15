--车辆编辑窗口
local suit = require"ui/suit"
local picButton = require"ui/component/picButton"
local vehicleWin = ui.new_window()
ui.vehicleWin = vehicleWin
require "ui/window/vehicle/installWin"
require "ui/window/vehicle/removeWin"
require "ui/window/vehicle/repairWin"
require "ui/window/vehicle/tireChangeWin"

local s_win = {name = tl("查看载具","Examine vehicle"),x= c.win_W/2-550,y =c.win_H/2-320, w= 900,h =590,dragopt = {id= newid()}}
local close_quads = ui.res.close_quads
local close_opt = {id= newid()}
local install_opt = {id= newid(),text = tl("安装","Install"),font=c.font_c16}
local refill_opt = {id= newid(),text = tl("注油","Refill"),font=c.font_c16}
local siphon_opt = {id= newid(),text = tl("抽油","Siphon"),font=c.font_c16}
local show_detail_info = {text = tl("显示载具信息","Show vehicle info"),opt= {id= newid(),font=c.font_c16},checked = true}

local part_text= love.graphics.newText(c.font_c16)
local veh_text1= love.graphics.newText(c.font_c14)
local veh_text1_length = 0

local cur_veh --当前窗口查看的vehicle
local cur_part_info --是个list，里面既有各个component的信息也有part自己的信息
local selct_part_x,select_part_y =8,8


local function loadVehicleInfo()
  local free_cargo =1200
  local total_cargo =1900
  
  
  
  local info_color = {162/255,162/255,162/255}
  local w_limit = 200
  veh_text1:clear()
  local textlength = 0
  local text1 = {info_color,tl("名字:","Name:"),{90/255,225/255,90/255},cur_veh.name}
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("安全/最高速度:  ","Safe/Top Speed:  ")}
  text1[#text1+1] = {90/255,225/255,90/255}
  text1[#text1+1] = string.format("%d",cur_veh:convert_velocity(cur_veh:safe_velocity()))
  text1[#text1+1] = info_color
  text1[#text1+1] = "/"
  text1[#text1+1] = {190/255,120/255,120/255}
  text1[#text1+1] = string.format("%d",cur_veh:convert_velocity(cur_veh:max_velocity()))
  text1[#text1+1] = info_color
  text1[#text1+1] = "km/h"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("加速度:  ","Acceleration:  ")}
  text1[#text1+1] = {150/255,150/255,250/255}
  text1[#text1+1] = string.format("%.1f",cur_veh:convert_velocity(cur_veh:acceleration()))
  text1[#text1+1] = info_color
  text1[#text1+1] = " km/h/t"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("质量: ","Mass: ")}
  text1[#text1+1] = {150/255,150/255,250/255}
  text1[#text1+1] = string.format("%d",cur_veh:total_mass())
  text1[#text1+1] = info_color
  text1[#text1+1] = "kg"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("K质量: ","K mass: ")}
  text1[#text1+1] = {150/255,150/255,250/255}
  text1[#text1+1] = string.format("%.1f",cur_veh:k_mass()*100)--百分比显示
  text1[#text1+1] = info_color
  text1[#text1+1] = "%"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("K摩擦力: ","K friction: ")}
  text1[#text1+1] = {150/255,150/255,250/255}
  text1[#text1+1] = string.format("%.1f",cur_veh:k_friction()*100)--百分比显示
  text1[#text1+1] = info_color
  text1[#text1+1] = "%"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  text1 = {info_color,tl("K气动力: ","K aerodynamics: ")}
  text1[#text1+1] = {150/255,150/255,250/255}
  text1[#text1+1] = string.format("%.1f",cur_veh:k_aerodynamics()*100)--百分比显示
  text1[#text1+1] = info_color
  text1[#text1+1] = "%"
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  
  text1 = {info_color,string.format(tl("载货量: %d/%d","Cargo Volume: %d/%d"),total_cargo-free_cargo,total_cargo)}
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  local durability_color= {80/255,150/255,80/255}
  local durability_text = tl("全新","like new")
  
  text1 = {info_color,tl("车辆状态: ","Status: ")}
  text1[#text1+1] = durability_color
  text1[#text1+1] = durability_text
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  local wheels_color= {90/255,225/255,90/255}
  local wheels_text = tl("足够","enough")
  
  text1 = {info_color,tl("轮胎: ","Wheels: ")}
  text1[#text1+1] = wheels_color
  text1[#text1+1] = wheels_text
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  text1 = {info_color,tl("汽油: ","gasoline: ")}
  text1[#text1+1] = {190/255,135/255,135/255}
  text1[#text1+1] = string.format("%.0f%%",12.1)
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  
  text1 = {info_color,tl("电池: ","battery: ")}
  text1[#text1+1] = {190/255,190/255,90/255}
  text1[#text1+1] = string.format("%.0f%%",16.1)
  veh_text1:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+veh_text1:getHeight()+1
  
  
  
  veh_text1_length = textlength
end


local function loadPart(x,y) --0-15
  x = c.clamp(x,0,15)
  y = c.clamp(y,0,15)
  
  selct_part_x,select_part_y = x,y
  
  cur_part_info = {}
  local vpart = cur_veh:get_part(x,y)
  install_opt.disable = not cur_veh:can_install(x,y)
  
  local function pushComponent(comp)
    local comp_info = {comp =comp }
    local isframe = comp.type.location == "structure"
    comp_info.name= comp.type.name
    if isframe then comp_info.name = "["..comp_info.name.."]" end
    comp_info.hp_percent = comp.hp / comp.type.durability*100 --根据血量显示颜色
    
    if comp.quad then
      comp_info.quad = comp.quad
      comp_info.img = data.vehicleBatch_img --总img
      comp_info.scale = comp.scale
    end
    
    
    comp_info.repair_opt = {id = newid(),pic_size=1,noside = true}
    comp_info.remove_opt = {id = newid(),pic_size=1,noside = true}
    comp_info.repair_opt.disable = not comp:can_repair()
    comp_info.remove_opt.disable = not cur_veh:can_unmount(x,y,comp)
    if comp:can_changeTire() then comp_info.changeTire_opt = {id = newid(),pic_size=1,noside = true} end
    
    
    
    --插入列表，frame始终排第一个
    if isframe then
      table.insert(cur_part_info,1,comp_info)
    else
      table.insert(cur_part_info,comp_info)
    end
  end
  if vpart then
    for _,component in ipairs(vpart.components) do pushComponent(component) end
  end
  --part--info
  local w_limit = 360-25
  part_text:clear()
  local textlength = 0
  
  local text1 = {{102/255,102/255,102/255},string.format(tl("载具部件(%d,%d):","Vehicle part(%d,%d):"),x,y)}
  text1[#text1+1]={22/255,22/255,22/255}
  text1[#text1+1]=tl("   外部","   Exterior")
  
  part_text:addf(text1,w_limit,"left",0,textlength)
  textlength = textlength+part_text:getHeight()+1
  
  cur_part_info.textlength = textlength
  if cur_part_info.textlength>147 then --h limit
    cur_part_info.useScroll = {w =w_limit,h = textlength,opt = {id =newid(),vertical = true}} --使用滚动条
  end
  
end


local function hpSetColor(hp_percent)
  if hp_percent>=95 then 
    love.graphics.oldColor(50,120,50)
  elseif hp_percent>=65 then
    love.graphics.oldColor(110,180,50)
  elseif hp_percent>=30 then
    love.graphics.oldColor(180,180,60)  
  elseif hp_percent>0 then
    love.graphics.oldColor(180,60,60)  
  else
    love.graphics.oldColor(110,110,110)
  end
end



local panel_opt = {id=newid()}
local function veh_grid(x,y,w,h)
  
  panel_opt.state = suit:registerHitbox(panel_opt,panel_opt.id,x,y,w,h)
  local state = suit:standardState(panel_opt.id)
  
  local mousex,mousey = love.mouse.getX(),love.mouse.getY()
  local inRect = false
  if mousex>=x and mousex< x+w and mousey>y and mousey<=y+h then
    inRect = true
    mousex = math.floor((mousex-x)/32)
    mousey = math.floor((y+h-mousey)/32)
  end
  
  local function draw_veh()
    love.graphics.oldColor(110,110,110)
    love.graphics.rectangle("fill",x,y,w,h)
    
    --画出车子
    
    local offsetx  = cur_veh.center_x*32
    local offsety  = (16-cur_veh.center_y)*32
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(cur_veh.batch,x+offsetx,y+offsety,0,1,1)
    
    --画出选择
    love.graphics.oldColor(220,220,110,110)
    love.graphics.rectangle("fill",x+selct_part_x*32,y+(15-select_part_y)*32,32,32,4)
    if state.hovered and inRect then
    --确定鼠标位置
      love.graphics.oldColor(110,110,220,140)
      love.graphics.rectangle("fill",x+mousex*32,y+(15-mousey)*32,32,32,4)
    end
  end
  suit:registerDraw(draw_veh)
  
  
  
  if state.hit and inRect then
    loadPart(mousex,mousey)
  end
  
end

local function draw_veh_info(x,y,w,h)
  if not show_detail_info.checked then return end
  
  local function draw_info()
    love.graphics.oldColor(0,0,0,70)
    local sx,sy = x,y+h- veh_text1_length-10
    local sw,sh = 210,veh_text1_length+10
    
    
    love.graphics.rectangle("fill",sx,sy,sw,sh)
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(veh_text1,sx+5,sy+5)
  end
  suit:registerDraw(draw_info)
  
  
  
end




local function oneComponent(index,x,y,w,h)
  local curComponent = cur_part_info[index]
  if not curComponent then return end 
  
  
  local function drawOneComponent()
    if curComponent.quad then
      love.graphics.oldColor(255,255,255)
      love.graphics.draw(curComponent.img,curComponent.quad,x+2,y,0,curComponent.scale,curComponent.scale)
    end
    love.graphics.setFont(c.font_c18)
    love.graphics.oldColor(0,0,0)
    love.graphics.print(curComponent.name, x+41, y+5)
    hpSetColor(curComponent.hp_percent)
    love.graphics.print(curComponent.name, x+40, y+4)
  end
  suit:registerDraw(drawOneComponent)
  
  
  
  local repair_state= picButton(ui.res.common_repair ,ui.res.common_img,curComponent.repair_opt,x+w-70,y,32,32)
  local remove_state= picButton(ui.res.common_remove ,ui.res.common_img,curComponent.remove_opt,x+w-36,y,32,32)
  if curComponent.changeTire_opt then 
    local change_state = picButton(ui.res.common_changeTire ,ui.res.common_img,curComponent.changeTire_opt,x+w-104,y,32,32)
    if change_state.hit then vehicleWin:OpenChild(vehicleWin.tireChangeWin,cur_veh,curComponent.comp) end
  end
  
  if repair_state.hit then vehicleWin:OpenChild(vehicleWin.repairWin,cur_veh,curComponent.comp) end
  if remove_state.hit then vehicleWin:OpenChild(vehicleWin.removeWin,cur_veh,curComponent.comp) end
  
end

local componentsScroll = {nametext =tl("组件","Component"),w= 280,h = 320,itemYNum= 10,opt ={id= newid()}}
local function componentList(x,y,w,h)
  local function drawback()
    love.graphics.oldColor(102,102,102)
    love.graphics.setFont(c.font_c16)
    love.graphics.print(componentsScroll.nametext, x+6, y-20)
    
    love.graphics.oldColor(255,255,255)
    suit.theme.drawScale9Quad(ui.res.common_contentS9,x,y-2,w+3,h+4)
  end
  suit:registerDraw(drawback)
  
  
  
  componentsScroll.h = (360/componentsScroll.itemYNum) * #cur_part_info
  suit:List(componentsScroll,oneComponent,componentsScroll.opt,x,y,w,h)
  
  
end


local function button_list(x,y)
  local install_state  = suit:S9Button(install_opt.text,install_opt,x+0,y,100,35) 
  local refill_state  = suit:S9Button(refill_opt.text,refill_opt,x+120,y,100,35)
  local siphon_state  = suit:S9Button(siphon_opt.text,siphon_opt,x+240,y,100,35)
  
  if install_state.hit then
    vehicleWin:OpenChild(vehicleWin.installWin,cur_veh,selct_part_x,select_part_y)
  end
  
end


local function part_info(x,y,w,h)
  
  
  
  local function drawback()
    
    love.graphics.oldColor(183,186,210)
    love.graphics.rectangle("fill",x,y,w,h,5)
  end
  suit:registerDraw(drawback)
  
  local starty = y+3
  if cur_part_info.useScroll  then
    --使用滚动条
    suit:ScrollRect(cur_part_info.useScroll,cur_part_info.useScroll.opt,x,y+3,w-20,h-6)
    starty = cur_part_info.useScroll.y
  end
  
  local function draw_inner()
    love.graphics.oldColor(255,255,255)
    love.graphics.draw(part_text,x+5,starty)
  end
  suit:registerDraw(draw_inner)
  if cur_part_info.useScroll then
    suit:registerHitbox(nil,part_text, x,y+3,w-20,h-6)
    suit:endScissor()
    suit:wheelRoll(suit:standardState(part_text),cur_part_info.useScroll)
  end
  
end






function vehicleWin.keyinput(key)
  if key=="escape" then  vehicleWin:Close() end
  if key=="left" or key=="a" then loadPart(selct_part_x-1,select_part_y) end
  if key=="right" or key=="d" then loadPart(selct_part_x+1,select_part_y) end
  if key=="up" or key=="w" then loadPart(selct_part_x,select_part_y+1) end
  if key=="down" or key=="s" then loadPart(selct_part_x,select_part_y-1) end
  
  
end

function vehicleWin.win_open(vehicle,x,y)
  selct_part_x = x or selct_part_x
  select_part_y = y or select_part_y
  
  cur_veh = vehicle
  loadVehicleInfo()
  loadPart(selct_part_x,select_part_y)
end

function vehicleWin.win_close()
  
end
function vehicleWin.window_do()
  suit:DragArea(s_win,true,s_win.dragopt)
  
  --使用该窗口的名字
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  
  veh_grid(s_win.x+10,s_win.y+35,512,512)
  draw_veh_info(s_win.x+10,s_win.y+35,512,512)
  componentList(s_win.x+530,s_win.y+60,360,320)
  button_list(s_win.x+530,s_win.y+385)
  part_info(s_win.x+530,s_win.y+425,360,153)
  local check_state  = suit:Checkbox(show_detail_info,show_detail_info.opt,s_win.x+10,s_win.y+560,160,20)
  
   if close_st.hit then vehicleWin:Close() end
end