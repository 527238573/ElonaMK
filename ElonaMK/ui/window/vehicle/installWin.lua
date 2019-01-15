local suit = require"ui/suit"
local ItemBox = require"ui/component/item/itembox"
--大量抄写了craftWin的代码
local installWin = ui.new_window()
ui.vehicleWin.installWin = installWin

local blockScreen_id = newid()
local s_win = {name = tl("安装组件","Install component"),x= c.win_W/2-500,y =c.win_H/2-300, w= 800,h =597,dragopt = {id= newid()}}
local close_quads = ui.res.close_quads
local close_opt = {id= newid()}


local cur_veh
local cur_x,cur_y

local can_mount_list--所有能mount的 componenttype列表

local tablist = {
  { opt = {id = newid(),text=  tl("全部","All"),font = c.font_c16},
    filter=function(ctype) return true; end

  },

  {opt = {id = newid(),text = tl("结构","structure"),font = c.font_c16},

    filter=function(ctype)
      return ctype.location == "structure"
    end

  },

}


local curTab = 1--默认tab。全部
local showList
local selectEntryIndex = 1
local curEntry

local curIcon_opt = nil --当前选定物品信息的opt
local loadEntry

--粗略检查是否能安装。
local function can_currently_install(ctype)
  local craft_inv = player:getCraftingInventory()
  local has_item = craft_inv:has_n_items(ctype.item_id,1)
  local has_skill = player.skills:get_skill_level("mechanics")
  return has_item and has_skill

end


--载入所有可以安装的组件的列表
local function loadInstallList()
  local allcomponents = data.veh_components
  can_mount_list ={}
  local divider_index = 0 --分割优先亮着的
  for _,ctype in pairs(allcomponents) do
    if ctype.item_id ~=nil then
      --如果没有item_id，就不能安装。这种组件可以出现在刷新的车里，但不能被玩家安装。
      if cur_veh:can_mount(cur_x,cur_y,ctype.id) then --能装在此处
        local entry= {ctype = ctype}
        entry.basic_check = can_currently_install(ctype)
        table.insert(can_mount_list,entry)
        entry.img,entry.quad = g.vehicle.getComponentTypeFirstQuadAndImg(ctype) --取得标准quad和img 可能为nil
      end
    end
  end

  --排序 ,basic_check通过的在前,剩下按id排序。
  local function compareTwoCtype(entry1,entry2)
    local result = entry1.ctype.id <entry2.ctype.id
    if entry1.basic_check then 
      if entry2.basic_check then
        return result
      else
        return true 
      end
    else
      if entry2.basic_check then
        return false
      else
        return result 
      end
    end
  end
  table.sort(can_mount_list,compareTwoCtype)

end

--根据tab将要显示entry列在一个列表中
local function loadShowList(new_tab)
  curTab = new_tab
  if new_tab> #tablist then curTab = 1 elseif new_tab<1 then  curTab =#tablist end

  showList = {}
  local cur_tab = tablist[curTab]
  for i=1,#can_mount_list do
    local entry = can_mount_list[i]
    if cur_tab.filter(entry.ctype) then
      showList[#showList+1] = entry
    end
  end 
  selectEntryIndex =1 --选择
  curEntry = showList[selectEntryIndex]
  loadEntry()
end

--
local length_max_w = 520 --使用横向滚动条的限制距离
local panel_h_limit = 427

function loadEntry()
  if curEntry==nil then return end
  if curEntry.main_opt then --已有值
    curIcon_opt = curEntry.main_opt
    return 
  end
  local ctype = curEntry.ctype --component type
  curEntry.main_opt = {id = newid(),ctype = ctype} --主opt
  curIcon_opt = curEntry.main_opt
  curEntry.meet_all = true
  
  local length = 45;
  local Rtext = love.graphics.newText(c.font_c16);curEntry.Rtext = Rtext
  local text1 = {{22/255,22/255,22/255},tl("需要技能: ","Required skill: ")}
  local mainlevel = player.skills:get_skill_level("mechanics")--机械学为主技能
  local requireLevel = ctype.difficulty
  local skillName = player.skills:get_skill_name("mechanics")..string.format(" Lv%d(%d)    ",requireLevel,mainlevel)
  curEntry.meet_all = curEntry.meet_all and mainlevel>=requireLevel
  if mainlevel>=requireLevel then
    text1[#text1+1] = {22/255,120/255,22/255}
    text1[#text1+1] = skillName
  else
    text1[#text1+1] = {120/255,22/255,22/255}
    text1[#text1+1] = skillName
  end
  if ctype.required_skills then
    for skill_id,require_level in pairs(ctype.required_skills) do
      local playerlevel = player.skills:get_skill_level(skill_id)
      local skillName = player.skills:get_skill_name(skill_id)..string.format(" Lv%d(%d)    ",require_level,playerlevel)
      curEntry.meet_all = curEntry.meet_all and playerlevel>=require_level
      if playerlevel>=require_level then
        text1[#text2+1] = {22/255,120/255,22/255}
        text1[#text2+1] = skillName
      else
        text1[#text2+1] = {120/255,22/255,22/255}
        text1[#text2+1] = skillName
      end
    end
  end
  Rtext:add(text1,0,length)
  length = length+ Rtext:getHeight()+3
  
  
  local costTime = ctype.install_time--可能要其他修正
  curEntry.costTime = costTime
  
  local text3
  local hour = math.floor(costTime/3600)
  local minute = math.floor((costTime%3600)/60)
  if hour>0 then
    text3= string.format(tl("完成耗时: %d 小时 %d 分钟","Time to complete: %d hour %d minite"),hour,minute)
  elseif minute>0 then 
    text3= string.format(tl("完成耗时: %d 分钟","Time to complete: %d minite"),minute)
  else
     text3= tl("完成耗时: 小于 1 分钟","Time to complete: less than 1 minite")
  end
  Rtext:add({{22/255,22/255,22/255},text3},0,length)
  length = length+ Rtext:getHeight()+3

  --取得
  local qualities_table,weilding = g.vehicle.getComponentTypeQualitesAndWeilding(ctype)
  
  local tools_table = {} --tool充能的table
  if weilding>0 then
    tools_table[#tools_table+1] = {{"stick",10},{"sharpened_rebar",10},{"crude_sword",10},} --临时
  end
  if ctype.flags["WHEEL"] then
    if cur_veh:total_mass()>=1000 then
      tools_table[#tools_table+1] = {{"bat",-1}}
    end
  end
  
  local material_table = {}
  material_table[1] = {{ctype.item_id,1}}
  
  
  curEntry.meet_all = curEntry.meet_all and player:recipe_meet_qualities(qualities_table)
  curEntry.meet_all = curEntry.meet_all and player:recipe_meet_tools(tools_table)
  curEntry.meet_all = curEntry.meet_all and player:recipe_meet_components(material_table)

  local text4 = {{22/255,22/255,22/255},tl("需要工具: ","Tools required: ")}
  local toolLength = 0
  curEntry.qualities = {}
  for tool_id,tool_level in pairs(qualities_table) do 
    local qua = {tool_id = tool_id,level = tool_level,data = data.qualities[tool_id],icon_opt = {id=newid(),tool_id = tool_id,tool_level = tool_level}}
    qua.meet = player:recipe_meet_one_quality(tool_id,tool_level)
    qua.str = string.format(tl("需要工具至少有 %s 等级%d。","Need tool with %s of level %d or more."),qua.data.name,qua.level)
    curEntry.qualities[#curEntry.qualities+1] = qua
    qua.self_height = 40 
    toolLength = toolLength +qua.self_height --长度+40
  end

  local function compare_two_entry(tool1,tool2)
    local p1 = tool1.org_index
    local p2 = tool2.org_index
    if tool1.find_item then p1 = p1 -100 end
    if tool2.find_item then p2 = p2 -100 end
    return p1<p2
  end

  curEntry.tools = {}
  for _,tooltable in ipairs(tools_table) do
    local tool_list = {}
    for i=1,#tooltable do
      local toolitem_id,charges = tooltable[i][1],tooltable[i][2]
      local one_tool = {tool_id = toolitem_id,charges = charges,icon_opt = {id=newid()},opt={id=newid()}}
      tool_list[#tool_list+1] = one_tool
      one_tool.org_index = i--原本的顺序，为排序提供
      one_tool.item_type = data.itemTypes[toolitem_id] --火焰也是个假itype，可以看到信息
      one_tool.icon_opt.itemtype = one_tool.item_type--附加opt上
      one_tool.find_item = player:recipe_meet_one_tool_charges(toolitem_id,charges)
      one_tool.str = one_tool.item_type.name
      if charges> 0 then one_tool.str = string.format(tl("%s(%d单位)","%s(%d charges)"),one_tool.str,charges) end
      one_tool.str_length = c.font_c16:getWidth(one_tool.str)+50
      one_tool.show_or = true
      one_tool.str_length = one_tool.str_length+30
    end
    --重排序，
    table.sort(tool_list,compare_two_entry)--可以用的tool排前，其他保持原始优先级
    if tool_list[1].find_item then --将默认选择第一项可用的
      tool_list.select = 1
      if #tool_list>1 then
        tool_list.use_select= true --数量多于1开启选择功能
      end
    end

    tool_list[#tool_list].show_or = false
    tool_list[#tool_list].str_length = tool_list[#tool_list].str_length-30  --最后一个没有 或 缩减距离
    --统计距离
    local total_length = 0
    for i=1,#tool_list do total_length = total_length+tool_list[i].str_length  end

    if total_length>length_max_w then  --一旦距离超标，就使用滚动条
      tool_list.self_height = 40 +18
      tool_list.useScroll = {w =total_length,h = 40,opt = {id =newid(),horizontal = true}} --使用滚动条
    else
      tool_list.self_height = 40 
    end

    curEntry.tools[#curEntry.tools+1] = tool_list
    toolLength = toolLength +tool_list.self_height --长度 增加本行，使用滚动条会变长
  end

  if toolLength==0 then 
    text4[#text4+1] = {22/255,120/255,22/255}
    text4[#text4+1] = tl("无"," NONE")
  end
  Rtext:add(text4,0,length)
  length = length+ Rtext:getHeight()+3
  curEntry.textLength1 = length
  length = length+ toolLength

  Rtext:add({{22/255,22/255,22/255},tl("需要材料:","Components required:")},0,length)
  length = length+ Rtext:getHeight()+3
  curEntry.textLength2 = length
  --材料，与tool基本相同
  curEntry.components = {}
  for _,mat_table in ipairs(material_table) do
    local mat_list = {}
    for i=1,#mat_table do
      local matitem_id,number = mat_table[i][1],mat_table[i][2]
      local one_mat = {item_id = matitem_id,number = number,icon_opt = {id=newid()},opt={id=newid()}}
      mat_list[#mat_list+1] = one_mat
      one_mat.org_index = i--原本的顺序，为排序提供
      one_mat.item_type = data.itemTypes[matitem_id] --火焰也是个假itype，可以看到信息
      one_mat.icon_opt.itemtype = one_mat.item_type
      one_mat.find_item = player:recipe_meet_one_components(matitem_id,number)
      one_mat.str = string.format("%d %s",number,one_mat.item_type.name)
      one_mat.str_length = c.font_c16:getWidth(one_mat.str)+50
      one_mat.show_or = true
      one_mat.str_length = one_mat.str_length+30
    end
    table.sort(mat_list,compare_two_entry) --重排序
    if mat_list[1].find_item then --将默认选择第一项可用的
      mat_list.select = 1
      if #mat_list>1 then
        mat_list.use_select= true --数量多于1开启选择功能
      end
    end
    local last_entry = mat_list[#mat_list]
    last_entry.show_or = false
    last_entry.str_length = last_entry.str_length-30  --最后一项取消显示OR 并缩减实际距离
     --统计距离
    local total_length = 0
    for i=1,#mat_list do total_length = total_length+mat_list[i].str_length  end
    
    if total_length>length_max_w then  --一旦距离超标，就使用滚动条
      mat_list.self_height = 40 +18
      mat_list.useScroll = {w =total_length,h = 40,opt = {id =newid(),horizontal = true}} --使用滚动条
    else
      mat_list.self_height = 40 
    end
    curEntry.components[#curEntry.components+1] = mat_list
    length = length +mat_list.self_height --长度 增加本行，使用滚动条会变长
  end
  
  --附加条件
  curEntry.additional_re_meet = true
  local UseAdditional = false
  local function new_additional()
    if UseAdditional==false then
      UseAdditional = true
      Rtext:add({{22/255,22/255,22/255},tl("额外条件:","Additional requirements:")},0,length)
      length = length+ Rtext:getHeight()+3
    end
  end
  
  
  if ctype.flags["ENGINE"]  and  not ctype.flags["MUSCLE"] then --非肌肉引擎
    local diff = 0
    for i=1,#cur_veh.engines do
      local engine = cur_veh.engines[i]
      if not engine:hasFlag("MUSCLE") then
        diff = diff+8
      end
    end
    if diff>0 then
      new_additional()
      local mainlevel = player.skills:get_skill_level("mechanics")--机械学为主技能
      local skillName = player.skills:get_skill_name("mechanics")
      local meet = mainlevel>= diff
      local textn= {}
      if meet then
        textn[#textn+1] = {22/255,120/255,22/255}
      else
        textn[#textn+1] = {120/255,22/255,22/255}
      end
      textn[#textn+1] = string.format("%s Lv%d",skillName,diff)
      textn[#textn+1] = {62/255,62/255,62/255}
      textn[#textn+1] = tl("来增加额外引擎。 "," for extra engines. ")
      Rtext:add(textn,0,length)
      length = length+ Rtext:getHeight()+3
      curEntry.additional_re_meet =curEntry.additional_re_meet and  meet
    end
  end
  
  if ctype.flags["STEERABLE"] then --转向轮
    local axles = {}
    local axles_num = 0
    for i=1,#cur_veh.steering do
      local swheel = cur_veh.steering[i]
      if not swheel:hasFlag("TRACKED") then
        if not axles[swheel.part.y] then 
          axles_num = axles_num+1
          axles[swheel.part.y] = true
        end
      end
    end
    
    if #cur_veh.steering>0 and not axles[cur_y] then
      local diff =axles_num*2+4 
      new_additional()
      local mainlevel = player.skills:get_skill_level("mechanics")--机械学为主技能
      local skillName = player.skills:get_skill_name("mechanics")
      local meet = mainlevel>= diff
      local textn= {}
      if meet then
        textn[#textn+1] = {22/255,120/255,22/255}
      else
        textn[#textn+1] = {120/255,22/255,22/255}
      end
      textn[#textn+1] = string.format("%s Lv%d",skillName,diff)
      textn[#textn+1] = {62/255,62/255,62/255}
      textn[#textn+1] = tl("来增加额外转向轴。 "," for extra steering axles. ")
      Rtext:add(textn,0,length)
      length = length+ Rtext:getHeight()+3
      curEntry.additional_re_meet =curEntry.additional_re_meet and  meet
    end
    
  end
  
  curEntry.meet_all = curEntry.meet_all and curEntry.additional_re_meet
  
  
  
  
  
  local h_limit =panel_h_limit
  if length>h_limit then curEntry.useScroll = {w =620,h = length,opt = {id =newid(),vertical = true}} end
end








local function drawBack(x,y,w,h)
  love.graphics.oldColor(30,30,30)
  love.graphics.rectangle("fill",x+8,y+69,w-16,2)
  love.graphics.oldColor(180,180,180)
  love.graphics.rectangle("fill",x+6,y+71,225,h-79)

  love.graphics.oldColor(216,218,236)
  love.graphics.rectangle("fill",x+237,y+76,w-248,h-160,10,10)

end

local function categoryButtons(x,y)
  for i=1,#tablist do
    local cur_opt = tablist[i].opt
    local cateTab = suit:ImageButton(ui.res.tab_quads,cur_opt,x +(i-1)*90,y,90,35)
    if curTab ==i then  cur_opt.state = "active" end
    if cateTab.hit  and curTab~=i then
      
      loadShowList(i)
    end
    
  end
  
end

local function oneComponent(index,x,y,w,h)
  local entry = showList[index]
  if entry==nil then return end
  local ctype = entry.ctype
  entry.state =suit:registerHitbox(entry,ctype, x,y,w,h)
  local function drawOneComponent()
    if entry.state=="hovered" then
      love.graphics.oldColor(200,200,255)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif entry.state=="active" then
      love.graphics.oldColor(170,170,233)
      love.graphics.rectangle("fill",x,y,w,h)
    elseif entry == curEntry then
      love.graphics.oldColor(180,255,180)
      love.graphics.rectangle("fill",x,y,w,h)
    end
    if entry.img then
      love.graphics.oldColor(255,255,255)
      love.graphics.draw(entry.img,entry.quad,x,y,0,1,1)
    end

    if entry.basic_check then
      love.graphics.oldColor(0,0,0)
    else
      love.graphics.oldColor(110,110,110)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(ctype.name, x+36, y+6)
  end
  suit:registerDraw(drawOneComponent)
  local allstate = suit:standardState(ctype)
  if allstate.hit and entry ~= curEntry then
    curEntry = entry 
    --刷新子面板  
    loadEntry()
  end
  return allstate
  
  
end
local listScroll = {w= 220,h = 512,itemYNum= 16,opt ={id= newid()}}
local function left_componentList(x,y,w,h)
  listScroll.h = #showList * 32
  suit:List(listScroll,oneComponent,listScroll.opt,x+2,y+3,220,h-6)
end






local function one_quality(qua,x,y)
  local boxState = ItemBox(qua.data.quad,qua.data.img,qua.icon_opt,x,y,38,40)
  if curIcon_opt == qua.icon_opt then
    qua.icon_opt.state = "active"
  end
  local function drawQText()
    if  qua.meet then
      love.graphics.oldColor(22,120,22)
    else
      love.graphics.oldColor(120,22,22)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(qua.str, x+50, y+15)
  end
  suit:registerDraw(drawQText)
  if boxState.hit then
    curIcon_opt = qua.icon_opt
  end
end



local or_str = tl("或","OR") --tool 与componets 共用
local function one_entry_requirement(entry_list,one_entry,x,y,self_index)
  
  local entry_w = one_entry.str_length
  if one_entry.show_or then entry_w = entry_w -30 end
  
  if one_entry.find_item  and entry_list.use_select then
    one_entry.opt.state = suit:registerHitbox(one_entry.opt,one_entry.opt.id, x,y,entry_w,40)
  end
  
  local function drawQText()
    if entry_list.select == self_index and entry_list.use_select then
      love.graphics.oldColor(220,220,120)
      love.graphics.rectangle("fill",x,y,entry_w,40,5,5)
    elseif one_entry.opt.state =="hovered" then
      love.graphics.oldColor(120,220,120)
      love.graphics.rectangle("fill",x,y,entry_w,40,5,5)
    elseif one_entry.opt.state =="active" then
      love.graphics.oldColor(180,255,120)
      love.graphics.rectangle("fill",x,y,entry_w,40,5,5)
    end
    
    if  one_entry.find_item then
      love.graphics.oldColor(22,120,22)
    else
      love.graphics.oldColor(120,22,22)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(one_entry.str, x+42, y+15)
    if one_entry.show_or then
      love.graphics.oldColor(22,22,22)
      love.graphics.print(or_str, x+one_entry.str_length-25, y+15)
    end
  end
  suit:registerDraw(drawQText)
  local boxState = ItemBox(one_entry.item_type.quad,one_entry.item_type.img,one_entry.icon_opt,x,y,38,40)
  if curIcon_opt == one_entry.icon_opt then
    one_entry.icon_opt.state = "active"
  end
  
  if boxState.hit then
    curIcon_opt = one_entry.icon_opt
  end
  if suit:mouseReleasedOn(one_entry.opt.id) then --点击切换
    entry_list.select = self_index 
  end
  
end

-- 共用的横向显示list,传输不同的entry_func显示不同条目
local function one_entry_list(tool_list,entry_func,x,y)
  local startx = x
  if tool_list.useScroll then
    --使用滚动条
    suit:ScrollRect(tool_list.useScroll,tool_list.useScroll.opt,x,y,length_max_w,40)
    startx = tool_list.useScroll.x
  end
  
  
  for i=1,#tool_list do
    local one_tool =tool_list[i]
    entry_func(tool_list,one_tool,startx,y,i)
    startx = startx+one_tool.str_length
  end
  if tool_list.useScroll then
    suit:endScissor()
  end
end




local function ctypePanel(x,y)
  if curEntry==nil then return end
  local ctype = curEntry.ctype
  --内部面板（放在内部的）
  local function interPanel(x,y)
    --标头物品名字
    local img,quad = curEntry.img,curEntry.quad
    local boxState = ItemBox(quad,img,curEntry.main_opt,x+10,y+0,38,40)
    if curIcon_opt == curEntry.main_opt then
      curEntry.main_opt.state = "active"
    end
    if boxState.hit then
      curIcon_opt = curEntry.main_opt
    end
    
    local starty1 = y
    local function drawInterPanel()
      love.graphics.oldColor(22,22,22)
      love.graphics.setFont(c.font_c20)
      love.graphics.print(curEntry.ctype.name, x+60, y+15)
      love.graphics.oldColor(255,255,255)
      love.graphics.draw(curEntry.Rtext,x+5,starty1)
    end
    suit:registerDraw(drawInterPanel)
    local y_a = starty1+curEntry.textLength1
    for _,qua in ipairs(curEntry.qualities) do 
      one_quality(qua,x+5,y_a)
      y_a = y_a+ qua.self_height
    end
    
    for _,tool_list in ipairs(curEntry.tools) do 
      one_entry_list(tool_list,one_entry_requirement,x+5,y_a)
      y_a = y_a+ tool_list.self_height
    end
    
    y_a = starty1+curEntry.textLength2 --第二个开始
    
    for _,mat_list in ipairs(curEntry.components) do 
      one_entry_list(mat_list,one_entry_requirement,x+5,y_a)
      y_a = y_a+ mat_list.self_height
    end
  end
  
  local startx,starty = x+10,y+10
  if curEntry.useScroll then
    --使用滚动条
    suit:ScrollRect(curEntry.useScroll,curEntry.useScroll.opt,x+10,y+10,5+length_max_w,panel_h_limit)
    starty = curEntry.useScroll.y
  end

  interPanel(startx,starty)
  if curEntry.useScroll then
    
    suit:endScissor()
    suit:wheelRollInRect(x+10,y+10,5+length_max_w,panel_h_limit,curEntry.useScroll)
  end
  
end

local do_install--提前声明函数
local install_opt = {id= newid(),text = tl("安装[e/Enter]","Install[e/Enter]"),font=c.font_c16}
local function install_button(x,y)
  
  if curEntry ==nil then return end
  install_opt.disable = not curEntry.meet_all
  local craft_state  = suit:S9Button(install_opt.text,install_opt,x,y,200,35) 
  
  if craft_state.hit then do_install() end
end



--执行安装  --可能需要选择color style，后续再加
function do_install()
  if not curEntry.meet_all then return end
  --与make craft不同，直接在一个函数里完成
  local ctype = curEntry.ctype
  
  --无需详细检查。因为不会循环制造。
  --检查工具并找出扣除充能的物品，储存着。
  local cost_charges= {}
  for i=1,#curEntry.tools do
    local one_list = curEntry.tools[i]
    local select_one = one_list[one_list.select]
    local tool_id = select_one.tool_id
    local charges = select_one.charges
    local finditem = player:recipe_meet_one_tool_charges(tool_id,charges)
    if finditem then
      if charges>0 then
        table.insert(cost_charges,{item = finditem,charges = charges})--记录下工具耗能，将来消耗掉。注意能够耗能的都是不可堆叠的物品。万一出现在材料中被取走了也能正确消耗。
      end
    else--没有合适的工具，可能是充能耗尽？
      local itype = data.itemTypes[tool_id]
      local warning_str = string.format( tl("你找不到工具:%s!", "You can't find a tool: %s!" ),itype.name)
      if charges>0 then warning_str=warning_str..tl("可能是充能耗尽了。","It may be running out of charges.") end
      addmsg(warning_str,"warning")
      return 
    end
  end
  
  --整理材料至component_list table。
  local component_list= {}
  for i=1,#curEntry.components do
    local one_list = curEntry.components[i]
    local select_one = one_list[one_list.select]
    local item_id = select_one.item_id
    local number = select_one.number
    local find_prev = false
    for j=1,#component_list do
      if component_list[j].item_id == item_id then --可能之前有相同的id材料，数量叠加。此时可能出现材料不足的结果？配方有同种材料在不同行会出现这种情况，需要尽量避免
        find_prev = true
        component_list[j].number = command.components[j].number+number
      end
    end
    if not find_prev then
      table.insert(component_list,{item_id = item_id,number = number})--单一的部件选择。
    end
  end
  --检查材料
  for i=1,#component_list do
    local item_id = component_list[i].item_id
    local number = component_list[i].number
    if not player:recipe_meet_one_components(item_id,number) then
      local itype = data.itemTypes[item_id]
      addmsg(string.format( tl("缺少材料:%s !",  "Lack of material: %s!"),itype.name),"warning")
      return
    end
  end
  installWin:Close() --确定不会return了
  
  --整理扣除材料
  local cost_material ={}
  for i=1,#component_list do
    player:get_recipe_one_components(cost_material,component_list[i].item_id,component_list[i].number)
  end
  local citem 
  for i=1,#cost_material do --核心item
    if cost_material[i].type.id == ctype.item_id then
      citem = cost_material[i]
    end
  end
  
  local activity = g.activity.create_activity()
  local costtime = curEntry.costTime
  local recipe_time = costtime/13.5 --使用了常数，实际对应2.25的timespeed。 换算为实际秒数 
  --未来可能对制造时间做系数修正。
  activity:setTotalTime(recipe_time)
  activity.minRealTime = math.max(1.5,costtime/900) --使用和craft 单体一样的
  activity.name = string.format(tl("安装组件: %s","Installing component: %s"),ctype.name)
  
  --注册中断和完成的方法。 使用闭包
  --结束函数
  local function complete_activity(activity)
    --消耗能量。
    for i=1,#cost_charges do
      cost_charges[i].item:cost_charges(cost_charges[i].charges)
    end
    --component已被消耗掉
    --提升技能。
    
    cur_veh:intstall_component_from_item(cur_x,cur_y,ctype.id,citem)
    
    addmsg(string.format( tl("你成功将%s安装到%s。", "You install a %s into the %s."),ctype.name,cur_veh.name),"info")
    --重开
    ui.vehicleWin:Open(cur_veh)--重打开
  end
  --中断函数。
  local function cancel_activity(activity)
    addmsg(string.format( tl("你停止安装%s。", "You stop installing %s."),ctype.name),"info")
    for i=1,#cost_material do --返还
    --还要检测
      player.inventory:addItem(cost_material[i])    
    end
    ui.vehicleWin:Open(cur_veh)--重打开
  end
  
  activity.manuallyCancel =true
  activity.complete_func = complete_activity
  activity.cancel_func = cancel_activity
  player:assign_activity(activity)--开始activity。
  --debugmsg("past time:"..activity.timePast.."totalTime:"..activity.totalTime)
end




function installWin.keyinput(key)
  if key=="escape" or key=="q" then  installWin:Close() end
  if key == "return" or key == "e" then do_install() end
end

--
function installWin.win_open(vehicle,x,y) 
  cur_veh = vehicle
  cur_x,cur_y= x,y
  loadInstallList()
  loadShowList(1)
end

function installWin.win_close()

end
function installWin.window_do()
  suit:registerHitFullScreen(nil,blockScreen_id)--全屏遮挡
  suit:DragArea(s_win,true,s_win.dragopt)
  --使用该窗口的名字
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  categoryButtons(s_win.x+8,s_win.y+36)
  left_componentList(s_win.x+6,s_win.y+71,225,s_win.h-79)
  ctypePanel(s_win.x+237,s_win.y+76)
  install_button(s_win.x+400,s_win.y+s_win.h-55)
  
  if curIcon_opt  then
    if curIcon_opt.itemtype then
      ui.itemtypeInfo(curIcon_opt.itemtype,s_win.x+s_win.w,s_win.y,330,s_win.h)
    elseif curIcon_opt.tool_id then
      ui.toolLevelInfo(curIcon_opt.tool_id,curIcon_opt.tool_level,s_win.x+s_win.w,s_win.y,330,s_win.h)
    elseif curIcon_opt.ctype then
      ui.componentInfo(curIcon_opt.ctype,s_win.x+s_win.w,s_win.y,330,s_win.h)
    end
  end
  
  if close_st.hit then installWin:Close() end
end