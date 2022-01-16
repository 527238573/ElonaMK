
--一些常数，常量，预定义等



c.win_W = love.graphics.getWidth()
c.win_H = love.graphics.getHeight()
c.RightPanel_W = 300--右侧面板宽度

c.SQUARE_L= 64  --以下常数，基本不修改，位运算
c.cliffHeight  =40

local testfont = "assets/fzh.ttf"

c.font_c20 = love.graphics.newFont(testfont,20);
c.font_c18 = love.graphics.newFont(testfont,18);
c.font_c16 = love.graphics.newFont(testfont,16);
c.font_c14 = love.graphics.newFont(testfont,14);
c.font_c12 = love.graphics.newFont(testfont,12);
c.font_x18 = love.graphics.newFont("assets/fzfs.ttf",18);
c.font_x16 = love.graphics.newFont("assets/fzfs.ttf",16);
c.font_x14 = love.graphics.newFont("assets/fzfs.ttf",14);
--c.font_x12 = love.graphics.newFont("assets/fzfs.ttf",12);
--c.font_c16:setLineHeight(1.5)--字体行间距，整段使用 不改为秒




local xid = 0
function newid()
  xid = xid+1
  return xid
end



--debug模式及初始化，控制开关。
local mobdebug
function c.initDebug()
  if arg and arg[#arg] == "-debug" then 
    mobdebug = require("mobdebug") 
    mobdebug.start()
    mobdebug.off()--开始时保持关闭，否则很卡
  end
end
--只在需要debug的代码段，开关
function debugOn()
  if mobdebug then mobdebug.on() end
end
function debugOff()
  if mobdebug then mobdebug.off() end
end 






local function s9type(self,stype)
  return stype == "S9Table"
end

function c.createS9Table(img,x,y,w,h,top,bottom,left,right)
  
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


c.shader_grey = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {
      vec4 cp = Texel(texture, tc) * color;
      number luminosity = 0.299 * cp.r + 0.587 * cp.g + 0.114 * cp.b;
      return vec4(luminosity,luminosity,luminosity,cp.a);
    }]]
    
c.shader_cooldown = love.graphics.newShader[[
    extern number c_rad;
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _) {
      vec4 cp = Texel(texture, tc) * color;
      number rad = atan(tc.x-0.5,tc.y-0.5);
      if (rad>c_rad)return cp;
      else return vec4(cp.r*0.3,cp.g*0.3,cp.b*0.3,cp.a);
    }]]



c.DES_WHITE = {0.9,0.9,0.9}
c.DES_GREY = {0.7,0.7,0.7}
c.DES_MAG = {0.5,0.5,0.9} --魔法技能数值（伤害） 字体颜色
c.DES_SKI = {0.9,0.6,0.3} --物理技能数值（伤害）字体颜色

function c.addDesLine(t,str,color)
  table.insert(t,color)
  table.insert(t,str)
end