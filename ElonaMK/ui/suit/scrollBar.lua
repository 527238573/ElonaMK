local BASE = (...):match('(.-)[^%.]+$')
local s9util = require(BASE.."s9util")

local up_img = love.graphics.newImage(BASE.."/assets/scroll$up.png")
local down_img = love.graphics.newImage(BASE.."/assets/scroll$down.png")
local left_img = love.graphics.newImage(BASE.."/assets/scroll$left.png")
local right_img = love.graphics.newImage(BASE.."/assets/scroll$right.png")

local vbar_img = love.graphics.newImage(BASE.."/assets/vscroll$bar.png")
local hbar_img = love.graphics.newImage(BASE.."/assets/hscroll$bar.png")


local back_img = love.graphics.newImage(BASE.."/assets/scrollback.png")
local back2_img = love.graphics.newImage(BASE.."/assets/scrollclick.png")


local function create_btn_table(bimg)
  return {
    img = bimg,
    normal = love.graphics.newQuad(0,0,18,18,18,54),
    hovered= love.graphics.newQuad(0,18,18,18,18,54),
    active = love.graphics.newQuad(0,36,18,18,18,54)
  }
end

local up_quads=create_btn_table(up_img)
local down_quads=create_btn_table(down_img)
local left_quads=create_btn_table(left_img)
local right_quads=create_btn_table(right_img)
local vbar_quads=
{
  img = vbar_img,
  normal = s9util.createS9Table(vbar_img,0,0,18,18,4,4,4,4),
  hovered= s9util.createS9Table(vbar_img,0,18,18,18,4,4,4,4),
  active = s9util.createS9Table(vbar_img,0,36,18,18,4,4,4,4)
}
local hbar_quads=vbar_quads
--[[
{
  img = hbar_img,
  normal = s9util.createS9Table(hbar_img,0,0,21,17,3,3,3,3),
  hovered= s9util.createS9Table(hbar_img,0,17,21,17,3,3,3,3),
  active = s9util.createS9Table(hbar_img,0,34,21,17,3,3,3,3)
}
--]]

local back_quads=
{
  normal = back_img,
  hovered= back_img,
  active = back2_img
}

local function h_disabled_scroll(core,info,opt,x,y,w,h)
  local value_changed = false
  if(w<50) then w = 50 end -- 最小
  h=18 --固定的
  local fang = 18
  local midw =  w -fang*2
  info.sc_hback_opt = info.sc_hback_opt or {id ={}}
  info.sc_left_opt = info.sc_left_opt or {id ={}}
  info.sc_right_opt = info.sc_right_opt or {id ={}}
  
  info.sc_left_opt.img = left_img
  info.sc_right_opt.img = right_img
  
  local s1=core:Image(back_img,info.sc_hback_opt,x+fang,y,midw,h)
  local s2=core:Image(left_quads.normal,info.sc_left_opt,x,y,fang,h)
  local s3=core:Image(right_quads.normal,info.sc_right_opt,x+fang+midw,y,fang,h)
  
  local combineS = core:combineState(opt.id,s1,s2,s3)
  combineS.change = value_changed
  return combineS
end


local function h_scroll(core,info,opt,x,y,w,h)
  info.hbar_percent = info.hbar_percent or 0.5
  if info.hbar_percent >=1 or info.hbar_percent<=0 or info.h_value ==nil then 
    return h_disabled_scroll(core,info,opt,x,y,w,h) 
  end
  
  local value_changed = false
  if(w<50) then w = 50 end -- 最小
  h=18 --固定的
  local fang = 18
  local midw =  w -fang*2
  local min = info.h_min or 0
  local max = info.h_max or 1
  
  --bar宽度
  local bar_w = math.floor(info.hbar_percent * midw)
  local maxBarX = midw - bar_w
  info.h_step = info.h_step or (max - min) / maxBarX

  info.sc_hback_opt = info.sc_hback_opt or {id ={}}
  info.sc_left_opt = info.sc_left_opt or {id ={}}
  info.sc_right_opt = info.sc_right_opt or {id ={}}
  info.sc_hbar_opt = info.sc_hbar_opt or {id ={}}

  local bar_x
  -- doDrag
  local beforeActive = core:isActive(info.sc_hbar_opt.id)
  if beforeActive then-- doDrag
    -- mouse update
    local mx = love.mouse.getX()
    mx = mx - info.sc_hbar_opt.drag_offset -x -fang
    if mx <0 then mx =0 elseif mx>maxBarX then mx =maxBarX end
    bar_x = mx + x +fang
    --改变的
    local fraction = mx/maxBarX
    local v = fraction * (max - min) + min
    if v ~= info.h_value then
      info.h_value = v
      value_changed = true
    end
  else  --noDrag
    --根据数据算出bar_x
    info.h_value = math.min(max, math.max(min, info.h_value))--限制范围
    local fraction = (info.h_value - min) / (max - min)
    bar_x = math.floor(fraction *maxBarX) +x +fang
  end

  local s1=core:Image(back_img,info.sc_hback_opt,x+fang,y,midw,h)
  local s2=core:ImageButton(left_quads,info.sc_left_opt,x,y,fang,h)
  local s3=core:ImageButton(right_quads,info.sc_right_opt,x+fang+midw,y,fang,h)
  local s4=core:ImageButton(hbar_quads,info.sc_hbar_opt,bar_x,y,bar_w,h)

  if core:isActive(info.sc_hbar_opt.id) and not beforeActive then
    -- mouse update
    local mx = love.mouse.getX()
    info.sc_hbar_opt.drag_offset = mx -bar_x
  end

  --左left
  if s2.active then
    local dt = love.timer.getDelta()
    info.sc_left_opt.activeTime = (info.sc_left_opt.activeTime or 0) +dt
    if info.sc_left_opt.activeTime>0.5 then
      info.h_value = math.min(max, math.max(min, info.h_value -info.h_step))
      value_changed = true
    end
  end
  if s2.hit then
    info.sc_left_opt.activeTime = 0
    info.h_value = math.min(max, math.max(min, info.h_value -info.h_step))
    value_changed = true
  end
  -- 右right
  if s3.active then
    local dt = love.timer.getDelta()
    info.sc_right_opt.activeTime = (info.sc_right_opt.activeTime or 0) +dt
    if info.sc_right_opt.activeTime>0.5 then
      info.h_value = math.min(max, math.max(min, info.h_value +info.h_step))
      value_changed = true
    end
  end
  if s3.hit then
    info.sc_right_opt.activeTime = 0
    info.h_value = math.min(max, math.max(min, info.h_value +info.h_step))
    value_changed = true
  end
  if s1.hit then 
    local backstep = bar_w/maxBarX*(max - min)
    if love.mouse.getX()<bar_x + 0.5 * bar_w then backstep= backstep*-1 end
    info.h_value = math.min(max, math.max(min, info.h_value +backstep))
    value_changed = true
  end
  local combineS = core:combineState(opt.id,s1,s2,s3,s4)
  combineS.change = value_changed
  return combineS
end

local function v_disabled_scroll(core,info,opt,x,y,w,h)
  local value_changed = false
  if(h<50) then h = 50 end -- 最小
  w=18 --固定的
  local fang = 18
  local midh =  h -fang*2
  info.sc_vback_opt = info.sc_vback_opt or {id ={}}
  info.sc_up_opt = info.sc_up_opt or {id ={}}
  info.sc_down_opt = info.sc_down_opt or {id ={}}
  
  info.sc_up_opt.img= up_img
  info.sc_down_opt.img = down_img
  
  local s1=core:Image(back_img,info.sc_vback_opt,x,y+fang,w,midh)
  local s2=core:Image(up_quads.normal,info.sc_up_opt,x,y,w,fang)
  local s3=core:Image(down_quads.normal,info.sc_down_opt,x,y+fang+midh,w,fang)
  
  local combineS = core:combineState(opt.id,s1,s2,s3)
  combineS.change = value_changed
  return combineS
end

local function v_scroll(core,info,opt,x,y,w,h)
  info.vbar_percent = info.vbar_percent or 0.5
  if info.vbar_percent >=1 or info.vbar_percent<=0 or info.v_value==nil then 
    return v_disabled_scroll(core,info,opt,x,y,w,h) 
  end
  
  local value_changed = false
  if(h<50) then h = 50 end -- 最小
  w=18 --固定的
  local fang = 18
  local midh =  h -fang*2
  local min = info.v_min or 0
  local max = info.v_max or 1

  --bar宽度
  local bar_h = math.floor(info.vbar_percent * midh)
  local maxBarY = midh - bar_h
  info.v_step = info.v_step or (max - min) / maxBarY

  
  info.sc_vback_opt = info.sc_vback_opt or {id ={}}
  info.sc_up_opt = info.sc_up_opt or {id ={}}
  info.sc_down_opt = info.sc_down_opt or {id ={}}
  info.sc_vbar_opt = info.sc_vbar_opt or {id ={}}

  local bar_y
  -- doDrag
  local beforeActive = core:isActive(info.sc_vbar_opt.id)
  if beforeActive then-- doDrag
    -- mouse update
    local my = love.mouse.getY()
    my = my - info.sc_vbar_opt.drag_offset -y -fang
    if my <0 then my =0 elseif my>maxBarY then my =maxBarY end
    bar_y = my + y +fang
    --改变的
    local fraction = my/maxBarY
    local v = fraction * (max - min) + min
    if v ~= info.v_value then
      info.v_value = v
      value_changed = true
    end
  else  --noDrag
    --根据数据算出bar_y
    info.v_value = math.min(max, math.max(min, info.v_value))--限制范围
    local fraction = (info.v_value - min) / (max - min)
    bar_y = math.floor(fraction *maxBarY) +y +fang
  end

  local s1=core:Image(back_img,info.sc_vback_opt,x,y+fang,w,midh)
  local s2=core:ImageButton(up_quads,info.sc_up_opt,x,y,w,fang)
  local s3=core:ImageButton(down_quads,info.sc_down_opt,x,y+fang+midh,w,fang)
  local s4=core:ImageButton(vbar_quads,info.sc_vbar_opt,x,bar_y,w,bar_h)

  if core:isActive(info.sc_vbar_opt.id) and not beforeActive then
    -- mouse update
    local my = love.mouse.getY()
    info.sc_vbar_opt.drag_offset = my -bar_y
  end

  --上up
  if s2.active then
    local dt = love.timer.getDelta()
    info.sc_up_opt.activeTime = (info.sc_up_opt.activeTime or 0) +dt
    if info.sc_up_opt.activeTime>0.5 then
      info.v_value = math.min(max, math.max(min, info.v_value -info.v_step))
      value_changed = true
    end
  end
  if s2.hit then
    info.sc_up_opt.activeTime = 0
    info.v_value = math.min(max, math.max(min, info.v_value -info.v_step))
    value_changed = true
  end
  -- 下down
  if s3.active then
    local dt = love.timer.getDelta()
    info.sc_down_opt.activeTime = (info.sc_down_opt.activeTime or 0) +dt
    if info.sc_down_opt.activeTime>0.5 then
      info.v_value = math.min(max, math.max(min, info.v_value +info.v_step))
      value_changed = true
    end
  end
  if s3.hit then
    info.sc_down_opt.activeTime = 0
    info.v_value = math.min(max, math.max(min, info.v_value +info.v_step))
    value_changed = true
  end
  if s1.hit then 
    local backstep = bar_h/maxBarY*(max - min)
    if love.mouse.getY()<bar_y + 0.5 * bar_h then backstep= backstep*-1 end
    info.v_value = math.min(max, math.max(min, info.v_value +backstep))
    value_changed = true
  end
  local combineS = core:combineState(opt.id,s1,s2,s3,s4)
  combineS.change = value_changed
  return combineS
end




return function(core, info, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  
  if opt.vertical then -- 垂直
    return v_scroll(core,info,opt,x,y,w,h)
  else
    return h_scroll(core,info,opt,x,y,w,h)
  end

end
