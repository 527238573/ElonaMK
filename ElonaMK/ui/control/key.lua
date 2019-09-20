
local keyMapping_UI =
{
  up = {"up","w"},
  down = {"down","s"},
  right = {"right","d"},
  left = {"left","a"},
  
  f1 ={"f1"}, 
  f2 ={"f2"}, 
  f3 ={"f3"}, 
  f4 ={"f4"}, 
  tab = {"tab"},
  cancel = {"q","escape"},
  comfirm = {"e","return"},
  key_r = {"r"},
  key_g = {"g"},
}

local reverseKey_UI

local keyMapping_Game =
{
  up = {"up","w"},
  down = {"down","s"},
  right = {"right","d"},
  left = {"left","a"},
  
  f1 ={"f1"}, 
  f2 ={"f2"}, 
  f3 ={"f3"}, 
  f4 ={"f4"}, 
  tab = {"tab"},
  character = {"c"},
  inventory = {"x"},
  pickup = {"g"},
  drop = {"q"},
  useItem = {"e"},
  space ={"space"},
}

local reverseKey_Game





function ui.initKeyMapping()
  reverseKey_UI = {}
  for order,keytable in pairs(keyMapping_UI) do
    for _,key in ipairs(keytable) do
      reverseKey_UI[key] = order
    end
  end
  reverseKey_Game = {}
  for order,keytable in pairs(keyMapping_Game) do
    for _,key in ipairs(keytable) do
      reverseKey_Game[key] = order
    end
  end
  
end
--不在mapping的只会为false
function ui.isDown_UI(order)
  local keytable =keyMapping_UI[order]
  if keytable then
    for _,key in ipairs(keytable) do
      if love.keyboard.isDown(key) then return true end
    end
  end
  return false
end
--陌生的key返回本身。
function ui.convertKey_UI(key)
  return reverseKey_UI[key] or key
end

function ui.isDown_Game(order)
  local keytable =keyMapping_Game[order]
  if keytable then
    for _,key in ipairs(keytable) do
      if love.keyboard.isDown(key) then return true end
    end
  end
  return false
end
--陌生的key返回本身。
function ui.convertKey_Game(key)
  return reverseKey_Game[key] or key
end


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
  if not ui.isKeyfocusMainGame() then return end
  
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



function ui.overmapKeyCheck(dt)
  if not ui.isKeyfocusMainGame() then return end
  
  for i=1,4 do
    if(keyD(priority[i])) then
      if(priority[i] == "up") then
        if(keyD("left")) then
          p:moveAction(-1,1)
        elseif(keyD("right")) then
          p:moveAction(1,1)
        else
          p:moveAction(0,1)
        end
      elseif (priority[i] =="down") then
        if(keyD("left")) then
          p:moveAction(-1,-1)
        elseif(keyD("right")) then
          p:moveAction(1,-1)
        else
          p:moveAction(0,-1)
        end
      elseif (priority[i] =="right") then
        if(keyD("up")) then
          p:moveAction(1,1)
        elseif(keyD("down")) then
          p:moveAction(1,-1)
        else
          p:moveAction(1,0)
        end
      elseif (priority[i] =="left") then
        if(keyD("up")) then
          p:moveAction(-1,1)
        elseif(keyD("down")) then
          p:moveAction(-1,-1)
        else
          p:moveAction(-1,0)
        end
      end
      return
    end
  end
end


