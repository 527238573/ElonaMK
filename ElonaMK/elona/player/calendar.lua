
Calendar = {
  saveType = "Calendar",--注册保存类型
}

saveClass["Calendar"] = Calendar --注册保存类型
Calendar.__index = Calendar
Calendar.__newindex = function(o,k,v)
  if Calendar[k]==nil then error("使用了Calendar的意料之外的值:"..tostring(k)) else rawset(o,k,v) end
end
function Calendar:loadfinish()
  
end

function Calendar.new()
  local o= {}
  o.turnpast = 0
  o.year = 1
  o.month = 1
  o.day = 1
  o.hour = 0
  o.minute =0
  o.second =0
  setmetatable(o,Calendar)
  return o
end

local month_table = {31,28,31,30,31,30,31,31,30,31,30,31}



function Calendar:caculateTimeFromTurn()
  local total_sec = math.floor(self.turnpast*6)
  self.second = total_sec%60
  local total_minute = math.floor(total_sec/60)
  self.minute = total_minute%60
  local total_hour = math.floor(total_minute/60)
  self.hour = total_hour%24
  local total_day = math.floor(total_hour/24)
  self.year = 1+math.floor(total_day/365)
  if total_day >= 365 then total_day = total_day%365 end --不计闰年
  for mon = 1,12 do
    if total_day<month_table[mon] then
      self.month = mon
      self.day = total_day+1 --日期已得
      break;
    else
      total_day =total_day - month_table[mon]
    end
  end
end

function Calendar:caculateTurnFromTime()
  local total_day = (self.year-1)*365 +self.day-1
  local monpast = self.month
  for mon=1,(self.month-1) do
    total_day = total_day+month_table[mon]
  end
  self.turnpast = total_day*24*60*10 +self.hour*60*10 +self.minute*10+self.second/6
  debugmsg("turn set:"..self.turnpast)
end


local time_str 
local time_str_dirty = true
local month_name = {
  tl("1月","Jan."),tl("2月","Feb."),tl("3月","Mar."),tl("4月","Apr."),
  tl("5月","May."),tl("6月","Jun."),tl("7月","Jul."),tl("8月","Aug."),
  tl("9月","Sep."),tl("10月","Oct."),tl("11月","Nov."),tl("12月","Dec."),
}
local dayname =  tl("日","")
local yearname =  tl("年","")
function Calendar:getTimeStr()
  if time_str_dirty then
    time_str_dirty = false
    time_str = string.format("%d%s%s%d%s %02d:%02d",self.year+516,yearname,month_name[self.month],self.day,dayname,self.hour,self.minute)
  end
  return time_str 
end


--必须注意合法值
function Calendar:setDate(year,mon,d,h,m,s)
  self.year = year
  self.month = mon
  self.day = d
  self.hour =h or 8 
  self.minute = m or 0
  self.second = s or 0
  self:caculateTurnFromTime()
  time_str_dirty = true
end



function Calendar:updateRL(dt)
  --local last_min = self.minute
  self.turnpast = self.turnpast+dt*c.timeSpeed
  self:caculateTimeFromTurn()
  time_str_dirty = true
  --if last_min~= self.minute then g.map.zLevelCache.setLightDirty() end
end


function Calendar:seconds_past_midnight()
  return  self.second + (self.minute * 60) + (self.hour * 60 * 60);
end



local TWILIGHT_SECONDS = 2*60*60
--日出时间的seconds_past_midnight，和上面的比较   TWILIGHT_SECONDS 是一个小时渐变时间，跟在日出日落时间之后
function Calendar:sunrise_seconds() 
  local sunrise_min = 5* 60 * 60; --1月1日最小 --近似设定
  local sunrise_max = 7* 60 * 60;--7月1日最大
  if self.month<=6 then
    local daypercent = ((self.month-1)*30+self.day)/180 --估算
    return sunrise_min + daypercent*(sunrise_max - sunrise_min)
  else
    local daypercent = ((self.month-7)*30+self.day)/180 --估算
    return sunrise_max - daypercent*(sunrise_max - sunrise_min)
  end
end

function Calendar:sunset_seconds()
  local sunset_min = 17* 60 * 60; --1月1日最小 --近似设定
  local sunset_max = 20* 60 * 60;--7月1日最大
  if self.month<=6 then
    local daypercent = ((self.month-1)*30+self.day)/180 --估算
    return sunset_min + daypercent*(sunset_max - sunset_min)
  else
    local daypercent = ((self.month-7)*30+self.day)/180 --估算
    return sunset_max - daypercent*(sunset_max - sunset_min)
  end
end





