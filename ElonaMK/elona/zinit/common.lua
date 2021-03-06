--一些常数，常量，预定义等
--子线程和主线程共通的部分

c= {}

c.empty = 0


c.source_dir = love.filesystem.getSource().."/"
c.null_t = {}
c.timeSpeed = 2.25 /0.7 --行动点数，速度 和实际时间的换算  （行动点数/速度/tiemspeed = 实际时间）（回合数 = 实际时间秒*timeSpeed）1回合 = 0.444
c.one_turn = 1/c.timeSpeed
c.face_table = {7,6,5,8,8,4,1,2,3}
local reverse_face_x = {-1, 0, 1, 1, 1, 0,-1,-1}
local reverse_face_y = { 1, 1, 1, 0,-1,-1,-1, 0}
--face方向 face： 123
  --              884
  --              765
function c.face(dx,dy)
  return c.face_table[(dy+1)*3 +dx+2]
end

function c.face_dir(face)
  --debugmsg(tostring(face))
  return reverse_face_x[face],reverse_face_y[face]
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

local out = io.stdout
function debugmsg(msg)
  out:write(msg)
  out:write("\n")
  out:flush()
end


--全局变量 随机函数
rnd = math.random
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

--返回迭代器,遍历区域内所有点。可以只传wh
function c.pointInRect(w,h,startx,starty)
  startx = startx or 0
  starty = starty or 0
  local mx,my = 0,0
  return function()
    local rx,ry
    if my<h then
      rx,ry =  startx+mx,starty+my
    end
    mx = mx+1
    if mx>=w then
      mx = 0
      my = my+1
    end
    return rx,ry
  end
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




function string.split(szFullString, szSeparator)  
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while true do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex,true)
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

function c.baseGrow(grow,costTime,level)
  return math.floor(level*grow*costTime*2.25)
end

function c.faceGrow(grow,costTime,level)
  return math.floor(level*grow*costTime*2.25)*2
end

function tl(str,str2)
  return str
end