



local tkey
local tfunc
local args
local time = 0
local interval = 0.15

function ui.registerTurboKey(key,interval_time,func,...)
  tkey = key
  tfunc = func
  args = {...}
  time = 0.4
  interval = interval_time
end
function ui.clearTurboKey()
  tkey = nil
end

--只能是UI界面的key作为turbokey
function ui.updateTurboKey(dt)
  if tkey then
    if ui.isDown_UI(tkey) then
      time =  time -dt
      if time<=0 then
        time = time+interval
        tfunc(unpack(args))
      end
    else
      tkey = nil
      tfunc = nil
      args = nil
    end
  end
end