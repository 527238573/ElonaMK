local s9util = {}

local function s9type(self,stype)
  return stype == "S9Table"
end

function s9util.createS9Table(img,x,y,w,h,top,bottom,left,right)
  
  if w<left+right then w= left+right+1 end
  if h<top+bottom then h= top+bottom+1 end
  
  local sw,sh = img:getDimensions()
  local s9t = {img = img, top =top, bottom = bottom, left = left,right = right,w=w,h=h}
  s9t.midw = w- left -right
  s9t.midh = h- top -bottom
  s9t[1] = love.graphics.newQuad(x,y,left,top,sw,sh)
  s9t[2] = love.graphics.newQuad(x+left,y,w-left-right,top,sw,sh)
  s9t[3] = love.graphics.newQuad(x+w-right,y,right,top,sw,sh)
  
  s9t[4] = love.graphics.newQuad(x,y+top,left,h-top-bottom,sw,sh)
  s9t[5] = love.graphics.newQuad(x+left,y+top,w-left-right,h-top-bottom,sw,sh)
  s9t[6] = love.graphics.newQuad(x+w-right,y+top,right,h-top-bottom,sw,sh)
  
  s9t[7] = love.graphics.newQuad(x,y+h-bottom,left,bottom,sw,sh)
  s9t[8] = love.graphics.newQuad(x+left,y+h-bottom,w-left-right,bottom,sw,sh)
  s9t[9] = love.graphics.newQuad(x+w-right,y+h-bottom,right,bottom,sw,sh)
  s9t.typeOf = s9type -- 兼容
  return s9t
end

return s9util
