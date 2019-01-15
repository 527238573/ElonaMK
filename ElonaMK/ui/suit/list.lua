local BASE = (...):match('(.-)[^%.]+$')


return function(core, info,itemFunc, ...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  if w<50 then w= 50 end
  if h<50 then h= 50 end
  local itemNum = info.itemYNum or 2
  
  local singleh = h/itemNum
  info.scrollrect_opt =info.scrollrect_opt or {id={},vertical = true}
  
  local rectstate = core:ScrollRect(info,info.scrollrect_opt,x,y,w-18,h)
  core:registerHitbox(opt,opt.id, x,y,w-18,h) -- 底板
  local itemstates ={
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
    active = core:isActive(opt.id),
		hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
    wasHovered = core:wasHovered(opt.id)
	}
  local todraw_num = (y-info.y)/singleh +1
  local startnum =math.floor(todraw_num)
  if todraw_num> startnum  then todraw_num = itemNum  else todraw_num = itemNum-1 end
  for i =startnum+ todraw_num,startnum,-1 do --倒序，上可盖下为标准效果
    local newstate = itemFunc(i,x,info.y+(i-1)*singleh,w-18,singleh)
    if newstate then core:mergeState(itemstates,newstate) end
  end
  core:endScissor()
  core:wheelRoll(itemstates,info)
  core:mergeState(itemstates,rectstate)
  return itemstates
end
