--8（9）个方向中选择一个，传给回调函数。不传就返回主界面了。
local suit = require"ui/suit"

local arrow_img = ui.res.dir_arrow_img
local infolabel_img = love.graphics.newImage("assets/ui/info_label.png")
local infoS9 = suit.createS9Table(infolabel_img,0,0,16,16,4,4,4,4)
local blockScreen_id = newid()
local up_id = newid()
local up_left_id = newid()
local up_right_id = newid()
local left_id = newid()
local right_id = newid()
local down_id = newid()
local down_left_id = newid()
local down_right_id = newid()
local arrow_opt = {id = newid()}
local dtime = 0
local interval = 1.5
local callback = nil
local title = nil
local allowSelfGround = false

local function baseDraw(screenx,screeny,scale)
  local rate  = math.abs(dtime/interval*2 -1)
  love.graphics.oldColor(255,255,255,100+155*rate)
  love.graphics.draw(arrow_img,screenx-32*scale,screeny-64*scale,0,scale,scale)
  love.graphics.oldColor(255,255,255)
  local w,h = 220,34
  local x,y =screenx+16*scale-w/2,50
  suit.theme.drawScale9Quad(infoS9,x,y,w,h)
  love.graphics.setFont(c.font_c20)
  love.graphics.printf(title, x+6, y+6,w -12,"center")

end




local function winClose()
  ui.directionSelectWin:Close()

  --callback = nil
  --title = nil
end--提前声明。keyinput要用（esc退出）

local function keyinput(key)
  if key=="escape"or key=="q" then  winClose()end
  if key =="up" then
    if love.keyboard.isDown("left") then
      winClose();callback(-1,1);
    elseif love.keyboard.isDown("right") then
      winClose();callback(1,1);
    else
      winClose();callback(0,1);
    end
  elseif key =="down" then
    if love.keyboard.isDown("left") then
      winClose();callback(-1,-1);
    elseif love.keyboard.isDown("right") then
      winClose();callback(1,-1);
    else
      winClose();callback(0,-1);
    end
  elseif key =="right" then
    if love.keyboard.isDown("up") then
      winClose();callback(1,1);
    elseif love.keyboard.isDown("down") then
      winClose();callback(1,-1);
    else
      winClose();callback(1,0);
    end
  elseif key =="left" then
    if love.keyboard.isDown("up") then
      winClose();callback(-1,1);
    elseif love.keyboard.isDown("down") then
      winClose();callback(-1,-1);
    else
      winClose();callback(-1,0);
    end
  elseif key =="w" then
    if love.keyboard.isDown("a") then
      winClose();callback(-1,1);
    elseif love.keyboard.isDown("d") then
      winClose();callback(1,1);
    else
      winClose();callback(0,1);
    end
  elseif key =="s" then
    if love.keyboard.isDown("a") then
      winClose();callback(-1,-1);
    elseif love.keyboard.isDown("d") then
      winClose();callback(1,-1);
    else
      winClose();callback(0,-1);
    end
  elseif key =="d" then
    if love.keyboard.isDown("w") then
      winClose();callback(1,1);
    elseif love.keyboard.isDown("s") then
      winClose();callback(1,-1);
    else
      winClose();callback(1,0);
    end
  elseif key =="a" then
    if love.keyboard.isDown("w") then
      winClose();callback(-1,1);
    elseif love.keyboard.isDown("s") then
      winClose();callback(-1,-1);
    else
      winClose();callback(-1,0);
    end
  elseif key =="kp1" then
    winClose();callback(-1,-1);
  elseif key =="kp2" then
    winClose();callback(0,-1);
  elseif key =="kp3" then
    winClose();callback(1,-1);
  elseif key =="kp4" then
    winClose();callback(-1,0);
  elseif key =="kp5" then
    if allowSelfGround then winClose();callback(0,0); end
  elseif key =="kp6" then
    winClose();callback(1,0);
  elseif key =="kp7" then
    winClose();callback(-1,1);
  elseif key =="kp8" then
    winClose();callback(0,1);
  elseif key =="kp9" then
    winClose();callback(1,1);
  end


end

local function self_open(call,titleString,allowSelf)
  dtime = 0
  title = titleString
  callback = call
  allowSelfGround = allowSelf or false
end


local function window_do(dt)
--function ui.directionSelectWin(dt)
  --计算时间闪烁值
  dtime = dtime +dt
  if dtime>interval then dtime = dtime -interval end

  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  --计算出主角人物的屏幕坐标
  local screenx,screeny = ui.camera.modelToScreen(player.x*64,player.y*64)
  local scale = ui.camera.zoom*2
  suit:registerDraw(baseDraw,screenx,screeny,scale)
  local side_l = scale*32

  suit:registerHitbox(nil,up_id, screenx,screeny-2*side_l,side_l,side_l)
  suit:registerHitbox(nil,up_left_id, screenx-side_l,screeny-2*side_l,side_l,side_l)
  suit:registerHitbox(nil,up_right_id, screenx+side_l,screeny-2*side_l,side_l,side_l)
  suit:registerHitbox(nil,left_id, screenx-side_l,screeny-side_l,side_l,side_l)
  suit:registerHitbox(nil,right_id, screenx+side_l,screeny-side_l,side_l,side_l)
  suit:registerHitbox(nil,down_id, screenx,screeny,side_l,side_l)
  suit:registerHitbox(nil,down_left_id, screenx-side_l,screeny,side_l,side_l)
  suit:registerHitbox(nil,down_right_id, screenx+side_l,screeny,side_l,side_l)

  if suit:mouseReleasedOn(up_id) then  winClose();callback(0,1);
  elseif suit:mouseReleasedOn(up_left_id) then winClose();callback(-1,1);
  elseif suit:mouseReleasedOn(up_right_id) then winClose();callback(1,1);
  elseif suit:mouseReleasedOn(left_id) then winClose();callback(-1,0);
  elseif suit:mouseReleasedOn(right_id) then winClose();callback(1,0);
  elseif suit:mouseReleasedOn(down_id) then winClose();callback(0,-1);
  elseif suit:mouseReleasedOn(down_left_id) then winClose();callback(-1,-1);
  elseif suit:mouseReleasedOn(down_right_id) then winClose();callback(1,-1);
  end

end

local new_win = ui.new_window()
new_win.window_do = window_do
new_win.win_open = self_open
new_win.keyinput = keyinput

ui.directionSelectWin = new_win

