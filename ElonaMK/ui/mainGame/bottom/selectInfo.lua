
local suit = require "ui/suit"
local effectInfo = require "ui/mainGame/bottom/effectInfo"

local drawBar = ui.drawBar


local oneh = 20
local onew = 85
local lineH = c.font_c14:getHeight()
local lineD = math.floor((oneh-lineH)/2)
local function OneEffect(effect,x,y,w,h)
  local rate = effect.remain/math.max(0.001,effect.life +effect.remain)
  suit:registerDraw(function() 
      love.graphics.setColor(effect:getBackColor())
      love.graphics.rectangle("fill",x,y,w,h)
      love.graphics.setColor(0,0,0,0.2)
      love.graphics.rectangle("fill",x,y,w*rate,h)
      
      love.graphics.setColor(effect:getFrontColor())
      love.graphics.setFont(c.font_c14)
      love.graphics.printf(effect:getName(), x,y+lineD,w,"center")
    end)

end
local function unit_info(unit,x,y,w,h)
  
  local elist = unit.effects
  local eNum = #elist
  local ex_h = math.ceil(eNum/2)*24
  if ex_h>0 then 
    y = y-ex_h+5
    h = h+ex_h+5
  end
  local function draw_unit_info(unit,x,y,w,h)
    love.graphics.setColor(1,1,1,0.5)
    suit.theme.drawScale9Quad(c.pic["iteminfo_s9"],x,y,w,h)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(c.font_c18)
    love.graphics.printf(unit:getName(), x+10, y+18,w-20,"center")

    local iconlength = 22
    drawBar(unit:getHPRate(),3,x+10, y+43,w-20,22,4)
    drawBar(unit:getMPRate(),4,x+10, y+43+iconlength,w-20,22,4)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(string.format("%d/%d",unit.hp,unit.max_hp), x+10, y+43,w-20,"center")
    love.graphics.printf(string.format("%d/%d",unit.mp,unit.max_mp), x+10, y+43+iconlength,w-20,"center")
    --todo更多信息
  end
  suit:registerDraw(draw_unit_info,unit,x,y,w,h)
  local hoverEffect
  for i=1,eNum do
    local cx,cy,cw,ch = x+10,y+95+24*math.floor((i-1)/2),onew,oneh
    if i%2 ==0 then cx = cx+95 end
    
    local eff = elist[i]
    OneEffect(eff,cx,cy,cw,ch)
    local state = suit:registerHitbox(nil,eff,cx,cy,cw,ch)
    if state =="hovered" then hoverEffect = eff end
  end
  
  if hoverEffect then
    effectInfo(hoverEffect,love.mouse.getX(),love.mouse.getY())
  end
end



local tname = tl("地面","Ground")
local bname = tl("障碍","Obstacle")
local movecostname = tl("行走消耗:%d","Walk cost:%d")
local movecost_nopass = tl("行走消耗:不可通行","Walk cost:impassable")
local function draw_ter_info(map,tx,ty,x,y,w,h)
  
  local debugstr = string.format("(%d,%d)",tx,ty)
  love.graphics.setColor(1,1,1,0.5)
  suit.theme.drawScale9Quad(c.pic["iteminfo_s9"],x,y,w,h)
  love.graphics.setFont(c.font_c16)
  love.graphics.setColor(1,1,1)
  love.graphics.printf(tname, x+10, y+13,w-20,"left")
  love.graphics.printf(bname, x+10, y+13,w-20,"right")
  local tid = map:getTer(tx,ty)
  local bid = map:getBlock(tx,ty)

  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  love.graphics.setColor(1,1,1)
  
  local debugstr = string.format("%s(%d,%d)",tinfo.name,tx,ty)
  
  love.graphics.printf(debugstr, x+10, y+36,w-20,"left")
  love.graphics.printf(binfo.name, x+10, y+36,w-20,"right")
  
  --love.graphics.printf(debugstr, x+40, y+36,w-20,"left")

  if not binfo.pass then 
    love.graphics.setColor(1,0.2,0.2)
    love.graphics.printf(movecost_nopass, x+10, y+59,w-20,"left")
  else
    love.graphics.setColor(0.3,0.7,1)
    love.graphics.printf(string.format(movecostname,tinfo.move_cost), x+10, y+59,w-20,"left")
    love.graphics.printf(string.format("+%d",binfo.move_cost), x+10, y+59,w-20,"right")
  end
  --todo更多信息
end

return function(x,y,w)
  local target = p.mc.target
  if target==nil then return end

  local h = 100
  if target.unit then
    unit_info(target.unit,x-10,y-h-10,w,h)
    return
  end

  local map = p.mc.map
  if map and target.x then
    if map:inbounds(target.x,target.y) then
      suit:registerDraw(draw_ter_info,map,target.x,target.y,x-10,y-h-10,w,h)
    end
  end

end