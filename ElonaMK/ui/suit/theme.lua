-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

local theme = {}
theme.cornerRadius = 4

theme.color = {
	normal   = {bg = {188/255,188/255,188/255}, fg = {66/255, 66/255, 66/255}},
	hovered  = {bg = { 50/255,153/255,187/255}, fg = {1,1,1}},
	active   = {bg = {255/255,153/255,  0}, fg = {225/255,225/255,225/255}},
  activeR   = {bg = {0,153/255,255/255}, fg = {225/255,225/255,225/255}}
}


-- HELPER
function theme.getColorForState(opt)
	local s = opt.state or "normal"
	return (opt.color and opt.color[opt.state]) or theme.color[s]
end

function theme.drawBox(x,y,w,h, colors, cornerRadius)
	cornerRadius = cornerRadius or theme.cornerRadius
	w = math.max(cornerRadius/2, w)
	if h < cornerRadius/2 then
		y,h = y - (cornerRadius - h), cornerRadius/2
	end

	love.graphics.setColor(colors.bg)
	love.graphics.rectangle('fill', x,y, w,h, cornerRadius)
end

function theme.getVerticalOffsetForAlign(valign, font, h)
	if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
	end
	-- else: "middle"
	return (h - font:getHeight()) / 2
end

theme.defalut_img = love.graphics.newImage(BASE.."/assets/button.png")
theme.spriteBatch = love.graphics.newSpriteBatch(theme.defalut_img,50,"stream")

function theme.drawScale9Quad(s9t,x,y,w,h)
  local img = s9t.img
  local top,bottom,left,right = s9t.top,s9t.bottom,s9t.left,s9t.right
  if w<left+right then w= left+right+1 end
  if h<top+bottom then h= top+bottom+1 end
  local midw = w-left-right
  local midh = h-top -bottom
  local scale_midx = midw/s9t.midw
  local scale_midy = midh/s9t.midh
  
  theme.spriteBatch:clear()
  theme.spriteBatch:setTexture(img)
  theme.spriteBatch:add(s9t[1],x,y)
  theme.spriteBatch:add(s9t[2],x+left,y,0,scale_midx,1)
  theme.spriteBatch:add(s9t[3],x+left+midw,y)
  
  theme.spriteBatch:add(s9t[4],x,y+top,0,1,scale_midy)
  theme.spriteBatch:add(s9t[5],x+left,y+top,0,scale_midx,scale_midy)
  theme.spriteBatch:add(s9t[6],x+left+midw,y+top,0,1,scale_midy)
  
  theme.spriteBatch:add(s9t[7],x,y+top+midh)
  theme.spriteBatch:add(s9t[8],x+left,y+top+midh,0,scale_midx,1)
  theme.spriteBatch:add(s9t[9],x+left+midw,y+top+midh)
  theme.spriteBatch:flush()
  love.graphics.draw(theme.spriteBatch,0,0)
end


function theme.drawS9Border(s9t,x,y,w,h)
  local img = s9t.img
  local top,bottom,left,right = s9t.top,s9t.bottom,s9t.left,s9t.right
  if w<left+right then w= left+right+1 end
  if h<top+bottom then h= top+bottom+1 end
  local midw = w-left-right
  local midh = h-top -bottom
  local scale_midx = midw/s9t.midw
  local scale_midy = midh/s9t.midh
  
  theme.spriteBatch:clear()
  theme.spriteBatch:setTexture(img)
  theme.spriteBatch:add(s9t[1],x,y)
  theme.spriteBatch:add(s9t[2],x+left,y,0,scale_midx,1)
  theme.spriteBatch:add(s9t[3],x+left+midw,y)
  
  theme.spriteBatch:add(s9t[4],x,y+top,0,1,scale_midy)--删去5
  theme.spriteBatch:add(s9t[6],x+left+midw,y+top,0,1,scale_midy)
  
  theme.spriteBatch:add(s9t[7],x,y+top+midh)
  theme.spriteBatch:add(s9t[8],x+left,y+top+midh,0,scale_midx,1)
  theme.spriteBatch:add(s9t[9],x+left+midw,y+top+midh)
  theme.spriteBatch:flush()
  love.graphics.draw(theme.spriteBatch,0,0)
end



return theme
