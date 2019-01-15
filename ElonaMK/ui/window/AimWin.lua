--瞄准窗口，虽然不是一个实际的窗口，但将其视为窗口，覆盖操作并且不能和其他主窗口共存

local suit = require"ui/suit"
local aimWin = ui.new_window()
ui.aimWin = aimWin

--瞄准点
aimWin.aim_x,aimWin.aim_y,aimWin.aim_z = 0,0,0

aimWin.show_aimCross= true

local cur_target -- 当前目标
local available_target_list =nil --可用目标的list
local available_target_index = 0 --指向可用目标的

--最长delay，在动作中，如果因意外超过了这个delay时间就退出瞄准模式
local max_delay = 0
local can_control = true --能否控制，

--寻找可用目标
local function search_available_target()
  --debugmsg("search target")
  --必须是远程武器
  local range = player.weapon:get_gun_range(nil)
  debugmsg("search range:"..range)
  
  available_target_list = {}
  local neutrality_unit = {}
  local monsterList = g.monster.getList()
  for _,mon in ipairs(monsterList) do
    if not player:isFriendly(mon) then--非友好的都是可攻击目标
      local cur_range = c.dist_3d(player.x,player.y,player.z*1.5,mon.x,mon.y,mon.z*1.5) 
      if cur_range<range and player:seesUnit(mon) then --see最复杂，所以作为最后的条件
        
        if player:isHostile(mon) then
          available_target_list[#available_target_list+1] = {mon,cur_range}
        else
          neutrality_unit[#neutrality_unit+1] = {mon,cur_range}
        end
      end
    end
  end
  --按距离排序
  local function sort_monster(mon1,mon2)
    return mon1[2]<mon2[2] --比较距离
  end
  table.sort(neutrality_unit,sort_monster)
  table.sort(available_target_list,sort_monster)
  for i=1,#neutrality_unit do
    table.insert(available_target_list,neutrality_unit[i]) --添加到末尾
  end
end
local load_panel_text --提前声明，刷新面板信息函数





local function aim_unit(unit)
  cur_target = unit 
  aimWin.aim_x,aimWin.aim_y,aimWin.aim_z = unit.x,unit.y,unit.z
  player:fire_change_face(unit.x,unit.y) --朝向改变
  load_panel_text()--刷新瞄准面板的信息
end

local function aim_point(x,y,z)
  aimWin.aim_x,aimWin.aim_y,aimWin.aim_z = x,y,z
  cur_target = g.map.getUnitInGrid(x,y,z)
  player:fire_change_face(x,y) --朝向改变
  load_panel_text()--刷新瞄准面板的信息
end



local function move_aim(dx,dy,dz)
  local nx = c.clamp(aimWin.aim_x+dx,player.x-60,player.x+60)
  local ny = c.clamp(aimWin.aim_y+dy,player.y-60,player.y+60)
  local nz = c.clamp(aimWin.aim_z+dz,player.z-2,player.z+2)
  aim_point(nx,ny,nz)
  --g.cameraLock.cameraSet(nx,ny,nz)
  ui.camera.focusSquare(nx,ny,nz)
end

--
function aimWin.rightClick(clickx,clicky)
  if not can_control then return end
  local x,y = ui.camera.screenToModel(clickx,clicky)
  x = math.floor(x/64);y = math.floor(y/64)
  local z =ui.camera.cur_Z
  if g.map.isSquareInGrid(x,y,z) then
    aim_point(x,y,z)
    
  end
end

local function pressTab()
  if available_target_list ==nil then
    search_available_target()--重搜索
    if #available_target_list>0 then
      available_target_index = 1
      aim_unit(available_target_list[available_target_index][1])
      return 
    end
  elseif #available_target_list>0 then
    available_target_index = available_target_index+1
    if available_target_index>#available_target_list then available_target_index = 1 end
    if cur_target == available_target_list[available_target_index][1] then --再增一格，如果本来就瞄准第一位
      available_target_index = available_target_index+1
      if available_target_index>#available_target_list then available_target_index = 1 end
    end
    
    aim_unit(available_target_list[available_target_index][1])
    return 
  end
  --没有目标
end



local function enterAction()
  if player.delay>0 then
    can_control = false
    max_delay =player.delay+0.5  
    available_target_list = nil --消除旧列表，因为位置可能后面全变了
    available_target_index = 0
  end
  
end

local function pressFire()
  if aimWin.aim_x == player.x and aimWin.aim_y == player.y and aimWin.aim_z == player.z  then return end
  
  player:fire_gun(cur_target,player.weapon, aimWin.aim_x,aimWin.aim_y,aimWin.aim_z)
  player.burst_shot = player.weapon:get_burst_size();--获得burst次数
  player.burst_shot = player.burst_shot-1;--已经射击过一次
  
  enterAction()
  aimWin.show_aimCross = false--开火中不显示光标
end
--持续连射
local function pressBrust()
  player.burst_shot = player.burst_shot-1;--已经射击过一次
  if player.weapon:get_gun_mode()~= "burst"  and  player.burst_shot<0  then return end --非burst武器不能用此功能，除非burst_shot有设定连射值
  
  player:fire_gun(cur_target,player.weapon, aimWin.aim_x,aimWin.aim_y,aimWin.aim_z)--目标已确定
  enterAction()--进入不可控状态
  aimWin.show_aimCross = false--开火中不显示光标
end


local function pressReload()
  player:reloadAction()
  enterAction()
end

local function pressV()
  
  
end




--四项主方法
function aimWin.win_open()
  aimWin.show_aimCross= true
  cur_target = nil
  available_target_list = nil
  available_target_index= 0
  can_control = true --状态
  max_delay = 0
  
  search_available_target()
  debugmsg("enter aim. target number:"..#available_target_list)
  
  if #available_target_list>0 then
    available_target_index = 1
    aim_unit(available_target_list[1][1])
  else
    aim_point(player.x,player.y,player.z)--没有任何目标，瞄准自己脚下
  end
  
end

function aimWin.win_close()
  aimWin.show_aimCross= true
  cur_target = nil
  available_target_list = nil
  available_target_index= 0
  can_control = true
  max_delay = 0
end


function aimWin.keyinput(key)
  if key=="escape" or key=="q" then  aimWin:Close() end --无论何时按下都会解除瞄准界面
  if not g.checkControl() or not can_control then return end --处在不可控状态中
  if key=="left" or key=="a" then move_aim(-1,0,0);ui.registerTurboKey(key,move_aim,-1,0,0); end
  if key=="right" or key=="d" then move_aim(1,0,0);ui.registerTurboKey(key,move_aim,1,0,0); end
  if key=="up" or key=="w" then move_aim(0,1,0);ui.registerTurboKey(key,move_aim,0,1,0); end
  if key=="down" or key=="s" then move_aim(0,-1,0);ui.registerTurboKey(key,move_aim,0,-1,0); end
  if key=="tab" then pressTab() end--切换目标
  if key=="f" then pressFire() end--发射
  if key=="r" then pressReload() end--换子弹
  if key=="v" then pressV() end--瞄准
end


local default_text =
{tl("使用方向键或鼠标右键选择目标","Use directional keys or mouse right click to select target"),
tl("Tab-切换目标  F-射击","Tab-Switch target   F-Fire"),
tl("V-瞄准  shift+F-切换射击模式","V-Carefully aim   shift+F-Switch fireing modes"),
tl("Q/Esc-退出瞄准模式","Q/Esc-Cancel aiming"),
}


local ptext = love.graphics.newText(c.font_c16)
local ptextlength = 0
function load_panel_text()
  ptext:clear()--清空之前的
  local textWidth = 260--默认文字宽
  local length = 0;
  local function addOneLineInfo(table)--必须是一行，带换行
    ptext:addf(table,textWidth,"left",0,length)
    length = length+ ptext:getHeight()
  end
  local dist = c.dist_3d(player.x,player.y,player.z*1.5,aimWin.aim_x,aimWin.aim_y,aimWin.aim_z*1.5) 
  addOneLineInfo{{170/255,170/255,170/255},string.format("%s%.1f","瞄准目标  距离:",dist),}
  addOneLineInfo{{170/255,170/255,170/255},"子弹数:xx/xx",}
  length = length+20
  
  
  addOneLineInfo{{210/255,210/255,210/255},"一些目标信息  敌对的？",}
  addOneLineInfo{{210/255,210/255,210/255},"受伤状态",}
  addOneLineInfo{{210/255,210/255,210/255},"很多的字，目标描述很多的字，目标描述很多的字，目标描述很多的字，目标描述很多的字，目标描述很多的字，目标描述很多的字，目标描述",}
  length = length+20
  
  for _,v in ipairs(default_text) do
    addOneLineInfo{{170/255,170/255,170/255},v,}
  end
  ptextlength = length
end



local function draw_aim_panel()
  local panel_w ,panel_h = 280,ptextlength+20
  local startx,starty = c.win_W -ui.camera.right_w-panel_w -4,c.win_H - panel_h -10
  love.graphics.oldColor(255,255,255)
  suit.theme.drawScale9Quad(ui.res.iteminfo_quad,startx,starty,panel_w,panel_h)
  love.graphics.draw(ptext,startx+10,starty+10)
  
end



function aimWin.window_do(dt)
  if not can_control then
    if g.checkControl() then
      --解除封锁状态进入可控状态
      can_control = true
      aimWin.show_aimCross= true
      --检查还能射击否
      if not player:check_gun(false) then
        aimWin:Close()--不能射击，退出瞄准模式
        return
      end
      
      
      --重新选定目标
      if cur_target then
        if not cur_target:is_dead_state() and player:seesUnit(cur_target)then --还能看见并且没死，超出范围不管
          aim_unit(cur_target) --继续跟踪瞄准
        elseif player.weapon:get_gun_mode()== "burst" then   --连射模式下不能立即切换目标
          aim_point(aimWin.aim_x,aimWin.aim_y,aimWin.aim_z)--没有任何目标，瞄准原位
        else--原目标被打死或脱离原位，重选目标
          search_available_target()
          if #available_target_list>0 then
            available_target_index = 1
            aim_unit(available_target_list[1][1])
          else
            aim_point(aimWin.aim_x,aimWin.aim_y,aimWin.aim_z)--没有任何目标，瞄准原位
          end
        end
      else
        aim_point(aimWin.aim_x,aimWin.aim_y,aimWin.aim_z) --还是瞄准原位，刷新信息
      end
      
      --选完目标后，连射
      if love.keyboard.isDown("f") or player.burst_shot >0 then 
        --尝试连射
        pressBrust()
      end
      
    elseif max_delay<0 then
      --未解除但是超时，退出瞄准模式
      can_control = true
      aimWin:Close()
      return
    end
    max_delay = max_delay- dt
    --处于非可控状态中，也没超时
    --如果一直显示光标，如果有目标且目标移动，
    if aimWin.show_aimCross and cur_target then
      if cur_target.x ~=aimWin.aim_x or cur_target.y ~=aimWin.aim_y or cur_target.z ~=aimWin.aim_z then
        --刷新目标位置
        aim_unit(cur_target)
      end
    end 
    
  else --可控状态中  
    
  end
  
  suit:registerDraw(draw_aim_panel)
  
end