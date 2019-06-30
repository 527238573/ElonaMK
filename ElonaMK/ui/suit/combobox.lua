local BASE = (...):match('(.-)[^%.]+$')

local s9util = require(BASE.."s9util")

local back_img = love.graphics.newImage(BASE.."/assets/textback.png")
local back_s9table = s9util.createS9Table(back_img,0,0,91,23,2,2,2,2)
local combo_img = love.graphics.newImage(BASE.."/assets/combobox.png")
local combo_quads = 
{
  normal = s9util.createS9Table(combo_img,0,0,91,23,2,2,2,25),
  hovered= s9util.createS9Table(combo_img,0,23,91,23,2,2,2,25),
  active = s9util.createS9Table(combo_img,0,46,91,23,2,2,2,25)
}



local function defaultDraw(info, opt, x,y,w,h,theme)
  local s9t
  if info.showlist then s9t = combo_quads.active else s9t = combo_quads[opt.state] or combo_quads.normal end
  love.graphics.setColor(1,1,1)
  theme.drawScale9Quad(s9t,x,y,w,h)
  local text = opt.titleText or info.data[info.select]
  if text then
    love.graphics.setColor(66/255,66/255,66/255)
    love.graphics.setFont(opt.font)
    y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
    love.graphics.printf(text, x+2, y, w-27, opt.align or "center")
  end
end


local singleH = 20


return function(core,info,...)
  local opt, x,y,w,h = core.getOptionsAndSize(...)
  opt.id = opt.id or info
  opt.font = opt.font or c.font_c14
  w = w or 120
  h = h or 23
  info.select = info.select or 0
  assert(info.data,"combobox must have data")
  opt.state = core:registerHitbox(opt,opt.id, x,y,w,h)
  local hit = core:mouseReleasedOn(opt.id) 
  if hit then info.showlist = true end
  core:registerDraw(opt.draw or defaultDraw, info, opt, x,y,w,h,core.theme)
  if not info.showlist then 
    return {
      id = opt.id,
      hit = hit,
      active = core:isActive(opt.id),
      hovered = core:isHovered(opt.id) and core:wasHovered(opt.id),
      wasHovered = core:wasHovered(opt.id)
    }
  end
  --创建mask
  y = y+h
  info.mask_opt = info.mask_opt or {id = {}}
  core:registerHitFullScreen(info.mask_opt,info.mask_opt.id)
  hit = core:mouseReleasedOn(info.mask_opt.id)
  if hit then info.showlist = false end
  local allstates ={
    id = opt.id,
    hit = hit,
    active = core:isActive(info.mask_opt.id),
    hovered = core:isHovered(info.mask_opt.id) and core:wasHovered(info.mask_opt.id),
    wasHovered = core:wasHovered(info.mask_opt.id)
  }

  --创建
  local datalen = #info.data
  local imgh = math.max(datalen * singleH,singleH)
  local imgstate =core:Image(back_s9table,x,y,w,imgh+4)
  core:mergeState(allstates,imgstate)
  if datalen>0 then 
    local value_changed = false
    x = x+2
    y = y+2
    info.combolist_opt = info.combolist_opt or {id = {}}
    local listopt = info.combolist_opt
    listopt.state = core:registerHitbox(listopt,listopt.id, x,y,w-4,imgh)
    local hit_list = core:mouseReleasedOn(listopt.id)
    local mouseIndex = math.floor((core.mouse_y - y)/singleH) +1
    if(mouseIndex>datalen) then mouseIndex = datalen end
    core:registerDraw(function(x,y,w,theme)
        love.graphics.setFont(opt.font)
        for i = 1,datalen do
          local thisy = y+(i-1)*singleH
          if i == mouseIndex and listopt.state ~="normal" then 
            if listopt.state == "hovered" then 
              love.graphics.setColor(149/255,193/255,239/255)
            else
              love.graphics.setColor(133/255,169/255,191/255)
            end
            love.graphics.rectangle("fill", x, thisy, w, singleH)
            love.graphics.setColor(1,1,1)
          else 
            love.graphics.setColor(66/255,66/255,66/255)
          end
          thisy = thisy + theme.getVerticalOffsetForAlign(opt.valign, opt.font, singleH)
          love.graphics.printf(info.data[i], x+2, thisy, w-2, opt.align or "center")
        end
      end,x,y,w-4,core.theme)

    if hit_list then 
      if info.select ~=mouseIndex then
        info.select = mouseIndex
        value_changed = true
      end
      info.showlist = false 
    end

    local liststate = {
      hit = hit_list,
      active = core:isActive(info.combolist_opt.id),
      hovered = core:isHovered(info.combolist_opt.id) and core:wasHovered(info.combolist_opt.id),
      wasHovered = core:wasHovered(info.combolist_opt.id)
    }
    core:mergeState(allstates,liststate)
    allstates.changed = value_changed
  end
  return allstates

end
