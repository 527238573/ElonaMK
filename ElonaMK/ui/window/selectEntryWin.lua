local suit = require"ui/suit"
--e键的弹出选择
local selectEntryWin = ui.new_window()
ui.selectEntryWin = selectEntryWin

local blockScreen_id = newid()
local entryList
local canClose_win =false
local callback_func
local eActionS9 = ui.res.common_eActionS9
local opt_list = {}
local key_focus= 1


local function squareEntry(index,x,y,w,h)
  local opt = opt_list[index]
  if opt ==nil then opt = {id = newid()}; opt_list[index] = opt end
  opt.state = suit:registerHitbox(opt,opt.id, x,y,w,h-1)
  local function drawEntry()
    local name = entryList[index]
    if key_focus ==index then 
      love.graphics.oldColor(180,180,180)
      love.graphics.rectangle("fill",x+10,y,w-20,h)
      love.graphics.oldColor(30,30,30)
    else
      love.graphics.oldColor(215,215,215)
    end
    if opt.state== "hovered" then
      x = x+5
      if key_focus ==index  then
        love.graphics.oldColor(50,50,180)
      else
        love.graphics.oldColor(120,120,220)
      end
    end
    
    love.graphics.setFont(c.font_c20)
    love.graphics.print(name, x+12, y+6)
  end
  suit:registerDraw(drawEntry)
  if suit:mouseReleasedOn(opt.id) then selectEntryWin:Close();callback_func(index) end
end


function selectEntryWin.keyinput(key)
  if (key=="escape"or key=="q") and canClose_win then  selectEntryWin:Close() end
  if (key =="w" or key == "up") then key_focus = c.clamp(key_focus -1,1,#entryList)  end
  if (key =="s" or key == "down") then key_focus = c.clamp(key_focus +1,1,#entryList)  end
  if (key =="e" or key == "return") then selectEntryWin:Close(); callback_func(key_focus) end
end

--canClose表示是否能不选中任何一个选项直接关闭退出本窗口
function selectEntryWin.win_open(entrylist,canClose,callBack)
  entryList = entrylist;canClose_win = canClose
  callback_func = callBack --返回index
  key_focus = 1
end

function selectEntryWin.win_close()
end



local startx,starty = c.win_W/2-130,c.win_H/2-50
function selectEntryWin.window_do(dt)
  
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  --计算出主角人物的屏幕坐标
  local oneh = 30
  local w,h = 260,20+#entryList*oneh
  local x,y = startx-0.5*w,starty-0.5*h
  local function drawBack()
    love.graphics.oldColor(255,255,255)
    suit.theme.drawScale9Quad(eActionS9,x,y,w,h)
  end
  suit:registerDraw(drawBack)
  for i=1,#entryList do squareEntry(i,x,y-20+30*i,w,oneh) end
  
end
