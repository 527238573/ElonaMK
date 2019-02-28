



--key bounding
function kb(key)
  return key
end


local loveKeyD = love.keyboard.isDown

local function keyD(key)
  if key =="up" then
    return loveKeyD("up") or loveKeyD("w")
  elseif key =="down" then
    return loveKeyD("down") or loveKeyD("s")
  elseif key =="right" then
    return loveKeyD("right") or loveKeyD("d")
  elseif key =="left" then
    return loveKeyD("left") or loveKeyD("a")
  end
end





local priority = {"up","down","right","left"}


function ui.mainGameKeyCheck(dt)
  local mc= p.mc 
  
  
  for i=1,4 do
    if(keyD(priority[i])) then
      if(priority[i] == "up") then
        if(keyD("left")) then
          mc:moveAction(-1,1)
        elseif(keyD("right")) then
          mc:moveAction(1,1)
        else
          mc:moveAction(0,1)
        end
      elseif (priority[i] =="down") then
        if(keyD("left")) then
          mc:moveAction(-1,-1)
        elseif(keyD("right")) then
          mc:moveAction(1,-1)
        else
          mc:moveAction(0,-1)
        end
      elseif (priority[i] =="right") then
        if(keyD("up")) then
          mc:moveAction(1,1)
        elseif(keyD("down")) then
          mc:moveAction(1,-1)
        else
          mc:moveAction(1,0)
        end
      elseif (priority[i] =="left") then
        if(keyD("up")) then
          mc:moveAction(-1,1)
        elseif(keyD("down")) then
          mc:moveAction(-1,-1)
        else
          mc:moveAction(-1,0)
        end
      end
      return
    end
  end
end
