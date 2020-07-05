
--一些常数，常量，预定义等

c= {}

c.empty = 0

c.win_W = love.graphics.getWidth()
c.win_H = love.graphics.getHeight()
c.WIN_W = love.graphics.getWidth()
c.WIN_H = love.graphics.getHeight()

c.SQUARE_L= 64  --以下常数，基本不修改，位运算


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


c.source_dir = love.filesystem.getSource().."/"
c.null_t = {}
c.timeSpeed = 2.25 /0.7 --行动点数，速度 和实际时间的换算  （行动点数/速度/tiemspeed = 实际时间）（回合数 = 实际时间秒*timeSpeed）1回合 = 0.444
c.one_turn = 1/c.timeSpeed
c.face_table = {7,6,5,8,8,4,1,2,3}
--face方向 face： 123
  --              884
  --              765
function c.face(dx,dy)
  return c.face_table[(dy+1)*3 +dx+2]
end

function c.clamp(x,min,max)
  --return x>max and max or x<min and min or x
  return math.max(min,math.min(max,x))
  
end

function c.dist_2d(x1,y1,x2,y2)
  return math.sqrt((x1-x2)*(x1-x2)+ (y1-y2)*(y1-y2))
end
function c.dist_3d(x1,y1,z1,x2,y2,z2)
  return math.sqrt((x1-x2)*(x1-x2)+ (y1-y2)*(y1-y2)+(z1-z2)*(z1-z2))
end


function tl(str,str2)
  return str
end

local xid = 0
function newid()
  xid = xid+1
  return xid
end

local out = io.stdout
function debugmsg(msg)
  out:write(msg)
  out:write("\n")
  out:flush()
end

--全局变量 随机函数
rnd = love.math.random
function rnd_float(f1,f2)
  return f1+(f2-f1)*rnd()
end

function one_in(num)  return rnd(num)<=1 end

function x_in_y(x,y) return rnd()<=(x/y) end
--掷骰子
function dice(number,side)
  local ret =0
  for i=1,number do
    ret = ret+rnd(1,side)
  end
  return ret
end


function c.random_shuffle(t)
  local length  = #t
  for i=length,1,-1 do
    local rnd_index = rnd(i)
    local tmp = t[rnd_index]
    t[rnd_index] = t[i]
    t[i] = tmp
  end
end



--查找在权重table t 中随机值v的index
local function search_weight(t,v)
    local left = 1;
    local right = #t
    local min = 0
    local max = t[right]
    while left < right do
      local mid = math.floor((left + right)/2)
      if t[mid] == v then
        return mid;
      elseif v<= t[mid]  then
        right = mid 
      else 
        left = mid +1
      end
    end
    return right
end
c.search_weight = search_weight

--[[从权重表中随机值：
权重表结构:
{ val = {v1,v2,v3...}
  weight = {w1,w2,w3...}
}

--]]
function c.getWeightValue(weightTable)
  --local rn  =rnd(weightTable.weight[#weightTable.weight])
  --for k,v in ipairs(weightTable.weight) do
  --  print(k,v)
  --end
  --io.flush()
  --debugmsg(rn)
  return weightTable.val[search_weight(weightTable.weight,rnd(weightTable.weight[#weightTable.weight]))]
end
--全局名称
pick = c.getWeightValue


--从一般表创建权重表
function c.weightT(wt)
  local r = {val = {},weight={}}
  local w = 0
  for k,v in pairs(wt) do
    w= w+v
    table.insert(r.val,k)
    table.insert(r.weight,w)
  end
  return r
end
function c.pushWeightVal(wt,val,weight)
  local lastwight = 0
  if( wt) then lastwight = wt.weight[#wt.weight] end
  wt= wt or {val = {},weight={}}
  table.insert(wt.val,val)
  table.insert(wt.weight,weight+lastwight)
  return wt
end



function c.closest_xypoint_first(x,y,radius)
  local mx,my = 0,0
  local dx,dy = 0,-1
  local rrr = radius*2+1
  return function()
    local rx,ry
    if mx>=-0.5*rrr and mx<=0.5*rrr and my>=-0.5*rrr and my<=0.5*rrr then
      rx,ry =  x+mx,y+my
    end
    if mx==my or (mx<0 and mx == -my) or( mx>0 and mx ==1-my) then
      dx,dy =dy,dx
      dx = -dx
    end
    mx = mx+dx
    my = my+dy
    return rx,ry
  end
end


function c.closest_xypoint_rnd(x,y,radius)
  local mx,my = 0,0
  local dx,dy = 0,-1
  local rrr = radius*2+1
  local fx = rnd()<0.5 and -1 or 1
  local fy = rnd()<0.5 and -1 or 1
  local switch = rnd()<0.5
  
  return function()
    local rx,ry
    if mx>=-0.5*rrr and mx<=0.5*rrr and my>=-0.5*rrr and my<=0.5*rrr then
      if switch then
        rx,ry =  x+mx*fx,y+my*fy
      else
        rx,ry =  x+my*fy,y+mx*fx
      end
    end
    if mx==my or (mx<0 and mx == -my) or( mx>0 and mx ==1-my) then
      dx,dy =dy,dx
      dx = -dx
    end
    mx = mx+dx
    my = my+dy
    return rx,ry
  end
end


--全局常量
--stringid转换数字id
function oid(name)
  local id = data.oter_name2id[name]
  if id ==nil then error("wrong oter name:"..name) end
  return id
end

function tid(name)
  local id = data.ster_name2id[name]
  if id ==nil then error("wrong ster name:"..name) end
  return id
end
function fid(name)
  local id = data.block_name2id[name]
  if id ==nil then error("wrong block name:"..name) end
  return id
end



function flagt(ftable)
  local nt = {}
  for k,v in ipairs(ftable) do
    nt[v] = true
  end
  return nt
end

function string.split(szFullString, szSeparator)  
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(szSeparator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
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

function c.damageIns(dmg,dtype,subtype,resist_pen,resist_mul)
  dmg = dmg or 0--伤害值
  dtype = dtype or 1-- 类型0真实1物理2魔法 
  subtype = subtype or nil --子类型抗性。
  resist_pen = resist_pen or 0
  resist_mul = resist_mul or 0
  return {dmg= dmg,dtype=dtype,subtype = subtype,resist_pen =resist_pen,resist_mul = resist_mul}
end

c.damageType =
{
  bash = 1,--钝击
  cut = 1,--劈砍
  stab =1,--穿刺
  fire = 2,--火焰，精神
  ice = 2,-- 冰水
  nature = 2, --自然
  earth = 2, --大地
  dark = 2, --暗
  light = 2, --光
}

function c.baseGrow(grow,costTime,level)
  return math.floor(level*grow*costTime*2.25)
end

function c.faceGrow(grow,costTime,level)
  return math.floor(level*grow*costTime*2.25)*2
end
