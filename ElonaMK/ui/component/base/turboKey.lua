



local tkey
local tfunc
local args
local time = 0

function ui.registerTurboKey(key,func,...)
  tkey = key
  tfunc = func
  args = {...}
  time = 0.7
  
end
function ui.clearTurboKey()
  tkey = nil
  
end


function ui.updateTurboKey(dt)
  if tkey then
    if love.keyboard.isDown(tkey) then
      time =  time -dt
      if time<=0 then
        time = time+0.15
        tfunc(unpack(args))
      end
    else
      tkey = nil
      tfunc = nil
      args = nil
    end
  end
end