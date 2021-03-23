local suit = require"ui/suit"
--先声明本体
local equipmentWin = {name = tl("装备","Equipment"),icon = 14,opt = {id= newid()}}

local button_quads = c.pic["teamBtn_quads"]
local button_1_id= newid()
local button_2_id= newid()
local button_3_id= newid()
local button_4_id= newid()
local button_5_id= newid()
local colorBlue = {111/255,147/255,210/255,150/255}
local colorRed = {210/255,147/255,111/255,150/255}
local lineh = 68
local iconlist = c.pic["uiIcon"]
local uiClip = c.pic.ui_clip
local selectIndex = 1


local function selectEquipmentCallback(item,index)
  if item then
    p.mc:wearEquipment(item,selectIndex,true)
  end
end

local function chooseEquipment()
  local mc = p.mc
  local equipl = mc.equipment
  if equipl[selectIndex] then
    mc:takeoffEquipment(selectIndex,true)
  else
    local itemlist = p.inv.list --直接获取items.只读。增删物品要通过inventory的方法
    local curList = {}
    local slot = selectIndex
    --筛选列表
    
    for i=1,#itemlist do
      local curitem = itemlist[i]
      if (not curitem:isHidden()) and mc:canWearItem(curitem,slot,false) then
        curList[#curList+1] = curitem
      end
    end
    ui.equipWin:OpenChild(ui.itemChooseWin,curList,selectEquipmentCallback,tl("选择装备","Wear"),0)
  end
end



local function drawBack(x,y,w,h)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+40,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+200,y+40,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+660,y+40,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+50,y+460,0,1,1)
  love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+640,y+460,0,1,1)
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.setFont(c.font_c16)
  love.graphics.print(tl("部位","Category"), x+73, y+40) --改成一次性的读取翻译
  love.graphics.print(tl("装备名称","Name"), x+223, y+40) --改成一次性的读取翻译
  love.graphics.print(tl("重量","Weight"), x+683, y+40) --改成一次性的读取翻译
  
  love.graphics.print(tl("武器: 伤害(DPS,命中)","Weapon: Damage(DPS,Hit rate)"), x+73, y+458)
  love.graphics.print(tl("战斗修正","Battle Rolls"), x+663, y+458)
  
  love.graphics.line(x+53, y+58,x+140, y+58)
  love.graphics.line(x+203, y+58,x+330, y+58)
  love.graphics.line(x+663, y+58,x+750, y+58)
  
  love.graphics.line(x+73, y+476,x+543, y+476)
  love.graphics.line(x+590, y+476,x+740, y+476)

  love.graphics.setColor(0.5,0.5,0.4,0.2)
  love.graphics.rectangle("fill",x+30,y+64,w-60,lineh)
  love.graphics.rectangle("fill",x+30,y+64+lineh*2,w-60,lineh)
  love.graphics.rectangle("fill",x+30,y+64+lineh*4,w-60,lineh)
  
  local weaponlist = p.mc.weapon_list
  love.graphics.setFont(c.font_c18)
  love.graphics.setColor(0.3,0.3,0.3)
  love.graphics.printf(string.format("%s  %.1fkg","装备总重量:",weaponlist.totalWeight), x+491, y+410,270,"right")
  ui.drawFix(x,y,w,h)
  
  
end






local function oneItem(curItem,num,id,x,y,w,h)
  local name
  if curItem ==nil then
    name = "-   "
  else
    name = curItem:getDisplayName()
  end
  local state = suit:registerHitbox(nil,id,x,y,w,h-1)
  local function draw_entry()

    local nameLength = c.font_c18:getWidth(name)
    local nameHeight = c.font_c18:getHeight(name)
    if state =="hovered" then
      love.graphics.setColor(111/255,147/255,210/255,90/255)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif state =="active" then
      love.graphics.setColor(151/255,107/255,150/255,90/255)
      love.graphics.rectangle("fill",x,y,w,h)
    end

    if selectIndex==num then
      love.graphics.setColor(colorRed)
      love.graphics.rectangle("fill",x,y,w,h)
      love.graphics.setColor(1,1,1,0.6)
      love.graphics.rectangle("fill",x+161,y+18,nameLength+40,nameHeight+8)
      love.graphics.setColor(0.7,0.7,1,0.6)
      love.graphics.rectangle("line",x+161,y+18,nameLength+40,nameHeight+8)
      love.graphics.setColor(1,1,1)
      love.graphics.draw(uiClip.img,uiClip.select,x+185+nameLength,y+h/2,0,1,1,8,8)
    end

    if curItem==nil then
      love.graphics.setColor(0,0,0)
      love.graphics.setFont(c.font_c18)
      love.graphics.print(name, x+165, y+22)
    else
      render.drawUIItem(curItem,x+140,y+h/2,0.75)
      love.graphics.setColor(curItem:getDisplayNameColor())
      love.graphics.setFont(c.font_c18)
      love.graphics.print(name, x+165, y+22)
      love.graphics.setColor(0.2,0.2,0.2)
      love.graphics.printf(string.format("%.1f kg",curItem:getWeight()), x+w-100, y+24,80,"right")
    end
  end
  suit:registerDraw(draw_entry)
  local entry_st = suit:standardState(id)
  if entry_st.hit then
    --if curTab.selectIndex~=num then
    --curTab.selectIndex=num
    selectIndex = num
    g.playSound("click1")
    chooseEquipment()
    --ui.equipWin:OpenChild(ui.itemChooseWin,p.inv.list,selectEquipmentCallback,tl("选择装备","Wear"),0)
  end
  return entry_st
end

local function equipmentlList(x,y,w)
  local mc = p.mc
  local equipl = mc.equipment

  oneItem(equipl[1],1,button_1_id,x+30,y+64+lineh*0,w-60,lineh)
  oneItem(equipl[2],2,button_2_id,x+30,y+64+lineh*1,w-60,lineh)
  oneItem(equipl[3],3,button_3_id,x+30,y+64+lineh*2,w-60,lineh)
  oneItem(equipl[4],4,button_4_id,x+30,y+64+lineh*3,w-60,lineh)
  oneItem(equipl[5],5,button_5_id,x+30,y+64+lineh*4,w-60,lineh)
end

local function drawIcon(x,y,w,h)

  love.graphics.setColor(1,1,1)
  local img = iconlist.img
  love.graphics.draw(img,iconlist[33],x+30,y+66,0,2,2)
  love.graphics.draw(img,iconlist[34],x+30,y+66+lineh,0,2,2)
  love.graphics.draw(img,iconlist[35],x+30,y+66+lineh*2,0,2,2)
  love.graphics.draw(img,iconlist[36],x+30,y+66+lineh*3,0,2,2)
  love.graphics.draw(img,iconlist[36],x+30,y+66+lineh*4,0,2,2)

  love.graphics.setColor(0.1,0.1,0.1)
  love.graphics.setFont(c.font_c20)
  love.graphics.print(tl("主手","Mainhand"), x+90, y+85) --改成一次性的读取翻译
  love.graphics.print(tl("副手","Offhand"), x+90, y+85+lineh) --改成一次性的读取翻译
  love.graphics.print(tl("身体","Body"), x+90, y+85+lineh*2) --改成一次性的读取翻译
  love.graphics.print(tl("饰品","Accessory"), x+90, y+85+lineh*3) --改成一次性的读取翻译
  love.graphics.print(tl("饰品","Accessory"), x+90, y+85+lineh*4) --改成一次性的读取翻译

end




function equipmentWin.keyinput(key)
  if key=="up" then  selectIndex = c.clamp(selectIndex-1,1,5);g.playSound("pop1");end
  if key=="down" then  selectIndex = c.clamp(selectIndex+1,1,5);g.playSound("pop1");end
  if key=="comfirm" then  chooseEquipment() end
end

function equipmentWin.win_open()
end

function equipmentWin.win_close()

end


function equipmentWin.window_do(dt,s_win)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  equipmentlList(s_win.x,s_win.y,s_win.w)
  suit:registerDraw(drawIcon,s_win.x,s_win.y,s_win.w,s_win.h)
end

return equipmentWin