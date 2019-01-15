local BASE = (...):match('(.-)[^%.]+$')


return function(core, info, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  
  local useV = opt.vertical
  local useH = opt.horizontal
  
  local hstate
  local vstate
  
  if useH then 
    info.h_value=info.h_value or 0
    info.h_min =0
    info.h_max =info.w -w
    info.hbar_percent = w/info.w
    info.hscroll_opt = info.hscroll_opt or {id={},vertical = false}
    hstate = core:ScrollBar(info,info.hscroll_opt, x,y+h,w,18)
    info.x = math.floor(x-info.h_value)
  end
  
  if useV then 
    local vsc_h = h
    if useH then vsc_h = h+18 end
    info.v_value=info.v_value or 0
    info.v_min =0
    info.v_max = math.max(info.h -h,0)--修正wheelroll失误
    info.vbar_percent = h/info.h
    info.vscroll_opt = info.vscroll_opt or {id={},vertical = true}
    vstate = core:ScrollBar(info,info.vscroll_opt, x+w,y,18,vsc_h)
    info.y = math.floor(y-info.v_value)
    core:wheelRoll(vstate,info)
  end
  
  core:pushScissor(x,y,w,h)
  -- return  state
  if hstate then 
    if vstate then  return core:combineState(opt.id,hstate,vstate) end
    return hstate 
  else
    if vstate then return vstate end
    return {id = opt.id,hit = false, active = false, hovered = false, wasHovered = false}
  end
end