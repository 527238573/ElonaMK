local BASE = (...):match('(.-)[^%.]+$')


return function(core, info,doDrag, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  
  --提前进行drag的部分
  if doDrag then
    if core:isActive(opt.id) then
      -- mouse update
      local mx,my = love.mouse.getX(),love.mouse.getY()
      info.x = mx - info.dragX
      info.y = my - info.dragY
    end
    return
  end
  -- drag部分结束


  local beforeActive = core:isActive(opt.id)
  opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  if core:isActive(opt.id) and not beforeActive then
    -- mouse update
    local mx,my = love.mouse.getPosition()
    info.x = info.x or 0
    info.y = info.y or 0
    info.dragX = mx - info.x 
    info.dragY = my - info.y 
  end
  
  return {
    id = opt.id,
    hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
    hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
  }
end