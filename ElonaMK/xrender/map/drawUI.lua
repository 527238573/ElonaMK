--这个是ui图层，不是ui。位于UI和内容之间。

local selectImg = love.graphics.newImage("assets/ui/selectMark.png")


local function drawSelectMark(camera,map)
  local mc = p.mc
  if map~=mc.map then return end
  local sx,sy,dx,dy =0,0,0,0
  if mc.target==nil then return end
  if mc.target.unit then
    local tu = mc.target.unit 
    if tu.map ~= mc.map then --目标不可能
      mc.target= nil --清除目标
      return
    end
    sx=tu.x
    sy=tu.y
    dx,dy = tu:get_anim_dxdy()
  elseif mc.target.x then
    sx=mc.target.x
    sy= mc.target.y
  else
    mc.target= nil --清除目标
    return
  end
  --中心点。
  local cx,cy = sx*64+32+dx,sy*64+32+dy
  if not camera:canSee(cx,cy,48) then return end
  local screenx,screeny = camera:modelToScreen(cx,cy)
  local oneTime  = 0.8
  local ctime = love.timer.getTime() % (oneTime*2)
  local offset = math.abs(oneTime-ctime)/oneTime *8
  offset = (16+offset)*camera.workZoom 
  local scale = camera.workZoom *2
  love.graphics.setColor(1,1,1)
  love.graphics.draw(selectImg,screenx-offset,screeny-offset,0,scale,scale,8,8)
  love.graphics.draw(selectImg,screenx+offset,screeny-offset,math.pi/2,scale,scale,8,8)
  love.graphics.draw(selectImg,screenx+offset,screeny+offset,math.pi,scale,scale,8,8)
  love.graphics.draw(selectImg,screenx-offset,screeny+offset,math.pi*3/2,scale,scale,8,8)
  
end


function render.drawUILayer(camera,map)
  drawSelectMark(camera,map)
  
  
end