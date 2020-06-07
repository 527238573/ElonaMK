local suit = require"ui/suit"

local empty_img = c.pic["empty_member"]
local button_quads = c.pic["teamBtn_quads"]
local button1_opt = {id= newid()}
local button2_opt = {id= newid()}
local button3_opt = {id= newid()}
local button4_opt = {id= newid()}

local shader = c.shader_grey
local lifebar_q = c.pic["lifebar_quads"]



local function oneMember(index,btn_opt,x,y)
  local unit = p.team[index]
  local btn1_st = suit:ImageButton(button_quads,btn_opt,x,y-60,70,84)
  if unit then
    local canO = unit:canOperate()
    local dead = unit:is_dead()
    suit:registerDraw(function()
        love.graphics.setColor(1,1,1)
        local anim = unit:get_unitAnim()
        if canO then
          love.graphics.draw(anim.img,anim[anim.stillframe],x,y,0,2,2,0,anim.h)
        else
          love.graphics.setShader(shader)
          love.graphics.draw(anim.img,anim[anim.stillframe],x,y,0,2,2,0,anim.h)
          love.graphics.setShader()
        end
        if dead then
          love.graphics.draw(button_quads.img,button_quads.skull,x+4,y-28,0,1,1)
          love.graphics.setFont(c.font_c14)
          love.graphics.setColor(0,0,0)
          love.graphics.printf("DEAD", x-5, y,80,"center")
        else
          love.graphics.setColor(1,1,1)
          local liferate = unit:getHPRate()
          love.graphics.draw(lifebar_q.img,lifebar_q.green,x+4,y+3,0,liferate,1,0,0)
          local mprate = unit:getMPRate()
          love.graphics.draw(lifebar_q.img,lifebar_q.blue,x+4,y+8,0,mprate,1,0,0)
        end
      end)
    if not canO then
      btn_opt.state ="disable"
    elseif p.mc ==unit then
      btn_opt.state ="active"
    else
      if btn1_st.hit then  p:changeMC(index) end
    end
  else
    --draw empty
    btn_opt.state ="disable"
    suit:registerDraw(function()
        love.graphics.setFont(c.font_c14)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("EMPTY", x-5, y,80,"center")
        love.graphics.setColor(1,1,1)
        love.graphics.draw(empty_img,x+3,y,0,2,2,0,32)
      end)
  end
end

local btn_gap = 74
return function(x,y)
  oneMember(1,button1_opt,x+btn_gap*0,y)
  oneMember(2,button2_opt,x+btn_gap*1,y)
  oneMember(3,button3_opt,x+btn_gap*2,y)
  oneMember(4,button4_opt,x+btn_gap*3,y)
end