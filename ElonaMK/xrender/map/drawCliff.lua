
local _cliffHigh = c.cliffHeight


local function getTer(map,x,y)
  if (x>=-map.edge and x<=map.w+map.edge-1 and y>=-map.edge and y<=map.h+map.edge-1) then
    return map:getTer(x,y)
  else
    return nil
  end
end
local r0 = math.rad(0)
local r9 = math.rad(90)
local r18 = math.rad(180)
local r27 = math.rad(270)
-------------------1   2   3   4  5  6   7   8   9  A  B   C  D  E  F
local htileIndex= {4,  4,  3,  4, 5, 3,  6,  4,  3, 5, 6,  3, 6, 6, 2 }
local htileRad=   {r18,r9,r27,r0,r0,r18,r18,r27,r0,r9,r27,r9,r0,r9,r0}



local wallIndex= {4,3,1,2,8,7,5,6}
local topWallIndex = {12,11,9,10,12,11,9,10}
local topHalfIndex = {15,14,13,15}

local function drawOneCliff(camera,x,y,map)
  if not map:inbounds_edge(x,y) then return end 
  local cid,h = map:getCliffInfo(x,y)
  if h<=2 then return end --

  render.setSolidColor(map,x,y)



  local function checkDirContinue(dx,dy,ch)
    local ox,oy = x+dx,y+dy
    local cid2,h2
    if map:inbounds_edge(ox,oy) then
      cid2,h2 = map:getCliffInfo(ox,oy)
      return cid2==cid,h2
    else
      return false,2 --外部为true
    end
  end

  local info = data.cliff[cid]
  local up,   up_h  = checkDirContinue(0,1)
  local right,right_h  = checkDirContinue(1,0)
  local down, down_h  = checkDirContinue(0,-1)
  local left, left_h  = checkDirContinue(-1,0)
  local downLeft, downLeft_h  = checkDirContinue(-1,-1)
  local downRight, downRight_h  = checkDirContinue(1,-1)


  local function drawOneTer(ch)
    local isEdge = map:isCliffEdge(x,y,ch)
    local cur_p = -1 --当前优先级
    
    if not isEdge then
      local tid = map:getTer(x,y)
      local info = data.ter[tid]
      cur_p = info.priority
      local dy  = _cliffHigh* (ch-2)
      local screenx,screeny = camera:modelToCanvas(x*64+32,y*64+32+dy)
      love.graphics.draw(data.terImg,info[1],screenx,screeny,0,2,2,16,16)
    end
    --drawEdge
    --drawHierarchy
    local edgelist
    local function checkEdge(tx,ty,direction)
      if map:isCliffEdge(tx,ty,ch) then return end
      local edge = getTer(map,tx,ty)
      if edge==nil then return end
      local edge_ter_info = data.ter[edge]
      if (edge_ter_info.type =="hierarchy") and (edge_ter_info.priority > cur_p) then
        --add edge
        if(edgelist==nil) then edgelist = {}end
        for i = 1,4 do 
          if(edgelist[i]==nil) then 
            edgelist[i] = {index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info}
            break
          elseif edgelist[i].index == edge then
            edgelist[i].val = edgelist[i].val+direction
            break
          elseif edgelist[i].p>edge_ter_info.priority then
            table.insert(edgelist,i,{index =edge, val = direction,p =edge_ter_info.priority,info = edge_ter_info})
            break
          end
        end
      end
    end
    if up_h>=ch and up        then checkEdge(x,y+1,8) end
    if (right_h==ch or (downRight and downRight_h == ch and right_h>ch)) and right  then checkEdge(x+1,y,4) end
    if down_h==ch and down    then checkEdge(x,y-1,2) end
    if (left_h==ch or (downLeft and downLeft_h == ch and left_h>ch) ) and left    then checkEdge(x-1,y,1) end
    if edgelist~=nil then 
      for _,v in ipairs(edgelist) do
        local to_render_info = v.info
        local rotation = htileRad[v.val]
        local quad = to_render_info[htileIndex[v.val]]
        local dy  = _cliffHigh* (ch-2)
        local screenx,screeny = camera:modelToCanvas(x*64+32,y*64+32+dy)
        love.graphics.draw(data.terImg,quad,screenx,screeny,rotation,2,2,16,16)
      end
    end
    
    
  end
  


  local function drawLayer(ch)
    local draw_quad = ch>=down_h
    local draw_top = (ch == h) and  h>=(down_h-1)
    if not draw_quad and not draw_top then return end

    local c_up = up_h>=ch and up
    local c_right = right_h>=ch and right
    local c_down = down_h>=ch and down
    local c_left = left_h>=ch and left
    local c_dl = downLeft_h>=ch and downLeft
    local c_dr = downRight_h>=ch and downRight

    local dy  = _cliffHigh* (ch-3)
    if draw_quad then
      local state_code = 1 --绘制quad的state
      local tophalf_code =1 --上半部分，可能需要
      if c_down then 
        if c_dl then 
          state_code = state_code+1 
          if c_left then tophalf_code = tophalf_code+1 end
        end
        if c_dr then 
          state_code = state_code+2 
          if c_right then tophalf_code = tophalf_code+2 end
        end
      else
        state_code = state_code+4 
        if c_left then state_code = state_code+1 end
        if c_right then state_code = state_code+2 end
      end

      local screenx,screeny = camera:modelToCanvas(x*64+32,y*64+64+dy) --绘制主cord
      love.graphics.draw(data.terImg,info[ wallIndex[state_code] ],screenx,screeny,0,2,2,16,0)--绘制主cord
      if (c_down and tophalf_code ~= state_code) then
        love.graphics.draw(data.terImg,info[ topHalfIndex[tophalf_code] ],screenx,screeny,0,2,2,16,0)--绘制主quad上半部分变换，为了拼接
      end
      if h>ch and down_h == ch then
        drawOneTer(ch)
      end
      
    end
    if draw_top and not c_up then
      local top_state = 1
      if c_down then top_state = top_state+4 end
      if c_left then top_state = top_state+1 end
      if c_right then top_state = top_state+2 end

      local screenx,screeny = camera:modelToCanvas(x*64+32,y*64+64+dy)
      love.graphics.draw(data.terImg,info[ topWallIndex[top_state] ],screenx,screeny,0,2,2,16,16) --绘制top衔接
    end
  end

  for i=3,math.min(6,h) do
    drawLayer(i)
  end
  --绘制顶部
  drawOneTer(h)
  

end








function render.drawLineCliff(startx,endx,y,camera,map)
  love.graphics.setColor(1,1,1)
  for x = startx,endx do
    drawOneCliff(camera,x,y,map)
  end
end