
local suit = require "ui/suit"

local function drawBar(value,style,x,y,w,h,border)
  local pb = c.pic.progressBar
	local xb, yb, wb, hb -- size of the progress bar
  xb, yb, wb, hb = x+border,y+ border, (w-2*border)*value, h-2*border
  love.graphics.setColor(1,1,1)
  suit.theme.drawScale9Quad(pb[1],x,y,w,h)
  suit.theme.drawScale9Quad(pb[style],xb,yb,wb,hb)
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
local tname = tl("地面","Ground")
local bname = tl("障碍","Obstacle")
local movecostname = tl("行走消耗:%d","Walk cost:%d")
local movecost_nopass = tl("行走消耗:不可通行","Walk cost:impassable")
local function draw_ter_info(map,tx,ty,x,y,w,h)
  love.graphics.setColor(1,1,1,0.5)
  suit.theme.drawScale9Quad(c.pic["iteminfo_s9"],x,y,w,h)
  
  love.graphics.setColor(1,1,1)
  love.graphics.printf(tname, x+10, y+13,w-20,"left")
  love.graphics.printf(bname, x+10, y+13,w-20,"right")
  local tid = map:getTer(tx,ty)
  local bid = map:getBlock(tx,ty)
  
  local tinfo = data.ter[tid]
  local binfo = data.block[bid]
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(c.font_c16)
  love.graphics.printf(tinfo.name, x+10, y+36,w-20,"left")
  love.graphics.printf(binfo.name, x+10, y+36,w-20,"right")
  
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
    suit:registerDraw(draw_unit_info,target.unit,x-10,y-h-10,w,h)
    return
  end
  
  local map = p.mc.map
  if map and target.x then
    if map:inbounds(target.x,target.y) then
      suit:registerDraw(draw_ter_info,map,target.x,target.y,x-10,y-h-10,w,h)
    end
  end
  
  
end