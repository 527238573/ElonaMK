local suit = require"ui/suit"
--先声明本体
local traitsWin = {name = tl("特性和效果","Traits/Buffs"),icon_index = 12}

local itemlist = {}
local cache_mc
--读取出来的列表是一个快照。
local res_table = {
  {id = "res_bash",name = tl("钝击耐性","Bash resistance")},
  {id = "res_cut",name = tl("劈砍耐性","Cut resistance")},
  {id = "res_stab",name = tl("穿刺耐性","Stab resistance")},
  {id = "res_fire",name = tl("火焰耐性","Fire resistance")},
  {id = "res_ice",name = tl("冰水耐性","Ice resistance")},
  {id = "res_nature",name = tl("自然耐性","Nature resistance")},
  {id = "res_earth",name = tl("岩土耐性","Earth resistance")},
  {id = "res_dark",name = tl("黑暗耐性","Dark resistance")},
  {id = "res_light",name = tl("光电耐性","Light resistance")},
}

local function loadList()
  local t_unit = p.mc--后面可能要改
  cache_mc = t_unit
  itemlist = {}
  table.insert(itemlist,{itype = "title",name =tl("特性","Traits")})
  local traitsList = t_unit.traits 
  for i=1,#traitsList do
    local tra = traitsList[i]
    table.insert(itemlist,{itype = "trait",name = tra:getName(),des=tra:getDescription(),good = tra:isGood()})
  end
  if #traitsList ==0 then
    table.insert(itemlist,{itype = "info",name = tl("(无)","(none)")})
  end
  table.insert(itemlist,{itype = "title",name =tl("抗性","Resistance")})
  for i=1,#res_table do
    table.insert(itemlist,{itype = "res",name = res_table[i].name,val = t_unit:getResistanceByResId(res_table[i].id)})
  end
  table.insert(itemlist,{itype = "title",name =tl("效果","Effects")})
  local effList = t_unit.effects 
  for i=1,#effList do
    table.insert(itemlist,{itype = "effect",eff = effList[i]})
  end
  if #effList ==0 then
    table.insert(itemlist,{itype = "info",name = tl("(无)","(none)")})
  end
end

local function one_item(num,x,y,w,h)
  x =x+20;w= w-20
  local curItem = itemlist[num]
  if curItem ==nil then return end
  local function draw_entry()
    if num%2==1 then
      love.graphics.setColor(0.5,0.5,0.4,0.2)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if curItem.itype =="title" then
      love.graphics.setColor(1,1,1)
      love.graphics.draw(c.pic.ui_clip.img,c.pic.ui_clip.attr,x+10,y+8,0,1,1)
      love.graphics.setColor(0.5,0.5,0.5)
      love.graphics.setFont(c.font_c18)
      love.graphics.print(curItem.name, x+95, y+6)
      love.graphics.line(x+5, y+28,x+180, y+28)
    elseif curItem.itype =="info" then
      love.graphics.setColor(0.5,0.5,0.5)
      love.graphics.setFont(c.font_c18)
      love.graphics.print(curItem.name, x+125, y+6)
    elseif curItem.itype =="trait" then
      if curItem.good then
        love.graphics.setColor(0.4,0.4,0.9)
      else
        love.graphics.setColor(0.9,0.2,0.2)
      end
      love.graphics.setFont(c.font_c18)
      love.graphics.print(curItem.name, x+10, y+6)
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.print(curItem.des, x+145, y+6)
    elseif curItem.itype =="effect" then
      local eff = curItem.eff
      love.graphics.setColor(eff:getBackColor())
      love.graphics.rectangle("fill",x+5,y+3,125,h-6)
      love.graphics.setColor(eff:getFrontColor())
      love.graphics.setFont(c.font_c18)
      love.graphics.print(eff:getName(), x+10, y+6)
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.print(eff:getDescription(), x+145, y+6)
    elseif curItem.itype =="res" then
      love.graphics.setColor(0.1,0.1,0.1)
      love.graphics.setFont(c.font_c18)
      love.graphics.print(curItem.name, x+10, y+6)
      local taken = 100
      if curItem.val>0 then
        love.graphics.setColor(0.1,0.6,0.1)
        taken = 100*(2/(2+curItem.val))
      elseif curItem.val<0 then
        love.graphics.setColor(0.9,0.2,0.2)
        taken = 100*((2-curItem.val)/2)
      end
      local des_str = string.format(tl("%+d  (受到伤害:%d%%)","%+d  (Damage taken:%d%%)"),curItem.val,taken)
      love.graphics.print(des_str, x+145, y+6)
    end
  end
  suit:registerDraw(draw_entry)
end

--local function drawBack_list(x,y,w,h) end
local itemsScroll = {w= 500,h = 500,itemYNum=17,win_w =760,win_h =544,opt ={id= newid(),hide_disable = true},wheel_step = 32}
local function itemList(x,y)
  local w,h = itemsScroll.win_w,itemsScroll.win_h
  --suit:registerDraw(drawBack_list,x,y,w,h)
  itemsScroll.h = (h/itemsScroll.itemYNum) *#itemlist-- #skill_List
  suit:List(itemsScroll,one_item,itemsScroll.opt,x,y,w,h)
end


function traitsWin.keyinput(key)

end

function traitsWin.win_open()
  loadList()
end

function traitsWin.win_close()
  itemlist = nil
  cache_mc = nil
end


function traitsWin.window_do(dt,s_win)
  if cache_mc ~= p.mc then --后面会改
    loadList()
  end
  --suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  itemList(s_win.x+10,s_win.y+35)
end

return traitsWin