--制造窗口，所有制作物品的配方集中

local suit = require"ui/suit"
local ItemBox = require"ui/component/item/itembox"
--先声明本体
local craftingWin = ui.new_window()
ui.craftingWin = craftingWin
--通用dialogue等
local s_win = {name = tl("制作物品","Crafting items"),x= c.win_W/2-600,y =c.win_H/2-380, w= 900,h =700,dragopt = {id= newid()}}
local close_quads = ui.res.close_quads
local close_opt = {id= newid()}


local listScroll = {w= 220,h = 580,itemYNum= 20,opt ={id= newid()}}
local category_infos
local curCategory = 1
local curSubcat = 0 --注意这个0是全部！目录中没有的

local curIcon_opt = nil
--初始化类型按钮，只一次
local function initCategoryBtns()
  if category_infos then return end
  --重建一个类似的数据结构 --XXX 用原来的加个opt
  local data_cat = data.recipe_categories
  category_infos =data_cat
  for _,v in ipairs(data_cat) do
    v.opt ={id = newid(),text = v.name,font = c.font_c16,saved_subcat = 0} --默认子类型：全部
    for _,sv in ipairs(v.sub_cats) do
      sv.opt = {id = newid()}
    end
    v.sub_cats[0] = {name=tl("全部","All"),opt ={id = newid()}} --添加一个0（全部）
  end
end




--返回true r1 在r2之前
local function compareRecipe(r1,r2)
  local p1 = r1.recipe.main_level
  local p2 = r2.recipe.main_level
  --添加可制造性比较
  if r1.meet_component then p1 =p1+1000 end
  if r2.meet_component then p2 =p2+1000 end
  
  return p1>p2
  
end

--载入当前列表
local cate_list
local curEntry --当前entry
local loadEntry


local function pushEntry(recipe)
  if player:know_recipe(recipe) then
    local cur_entry = {recipe = recipe,meet_skill=player:recipe_meet_skills(recipe),meet_component = player:recipe_meet_toolAndComponent(recipe),index=#cate_list+1}
    cur_entry.meet_all = cur_entry.meet_skill and cur_entry.meet_component
    cate_list[#cate_list+1] = cur_entry
  end--全部输入 
end

local function loadCategoryList()
  curIcon_opt = nil
  cate_list = {}
  local cat1 = category_infos[curCategory]
  if curSubcat ==0 then
    for i=1,#cat1.sub_cats do
      for _,v in ipairs(cat1.sub_cats[i]) do
        pushEntry(v)
      end
    end
  else
    local cat2 = cat1.sub_cats[curSubcat]
    for _,v in ipairs(cat2) do
      pushEntry(v)
    end
  end
  
  table.sort(cate_list,compareRecipe)
  for i=1,#cate_list do
    cate_list[i].thisindex =i 
  end
  
  listScroll.h = (580/listScroll.itemYNum) * #cate_list
  
  local entry_set = false
  if curEntry then --寻找相同的配方，
    for _,entry in ipairs(cate_list) do
      if entry.recipe == curEntry.recipe then
        curEntry = entry--寻找到同样的就
        entry_set = true
        break;
      end
    end
  end
  if not entry_set then
    if #cate_list>0 then
      curEntry = cate_list[1]
    else
      curEntry = nil
    end
  end
  --刷新具体面板
  loadEntry()
  
end







local function drawBack(x,y,w,h)
  love.graphics.oldColor(30,30,30)
  love.graphics.rectangle("fill",x+8,y+69,w-16,2)
  love.graphics.oldColor(218,218,218)
  love.graphics.rectangle("fill",x+8,y+71,w-16,35)
  love.graphics.oldColor(180,180,180)
  love.graphics.rectangle("fill",x+6,y+106,225,586)
  
  love.graphics.oldColor(216,218,236)
  love.graphics.rectangle("fill",x+237,y+110,650,470,10,10)
  
end


local function changeCategory(new_index)
  if new_index>#category_infos then new_index = 1 end
  
  category_infos[curCategory].opt.saved_subcat = curSubcat --保存当前子类型
  curCategory = new_index --点击切换条目。重载
  curSubcat = category_infos[curCategory].opt.saved_subcat --同时切换子类型。
  loadCategoryList()
end

local function changeSubcat(new_index)
  local sub_list = category_infos[curCategory].sub_cats
  if new_index>#sub_list then new_index = 0 end
  if new_index<0 then new_index = #sub_list end
  
  curSubcat = new_index
  loadCategoryList()
end
local function changeRecipe(dindex)
  if curEntry ==nil then return end
  
  local new_index = curEntry.thisindex +dindex
  if new_index>#cate_list then new_index = 1 end
  if new_index<1 then new_index = #cate_list end
  curEntry = cate_list[new_index]
  loadEntry()
end



--分类和子分类文件
local function categoryButtons(x,y)
  for i=1,#category_infos do
    local cur_opt = category_infos[i].opt
    local cateTab = suit:ImageButton(ui.res.tab_quads,cur_opt,x +(i-1)*90,y,90,35)
    if curCategory ==i then  cur_opt.state = "active" end
    if cateTab.hit  and curCategory~=i then
      
      changeCategory(i)
    end
  end
  --子类型按钮
  local sub_list = category_infos[curCategory].sub_cats
  
  for i=0,#sub_list do
    local name = sub_list[i].name
    local opt = sub_list[i].opt
    local subx,suby =x+10+i*85,y+38 
    opt.state = suit:registerHitbox(opt,opt.id, subx,suby,85,28)
    local function draw_sub_cat_btn()
      if opt.state=="hovered" then
        love.graphics.oldColor(200,200,255)
        love.graphics.rectangle("fill",subx,suby,85,28,4,4)
      elseif opt.state=="active" then
        love.graphics.oldColor(170,170,233)
        love.graphics.rectangle("fill",subx,suby,85,28,4,4)
      elseif curSubcat == i then
        love.graphics.oldColor(255,255,255)
        love.graphics.rectangle("fill",subx,suby,85,28,4,4)
      end
      love.graphics.oldColor(22,22,22)
      love.graphics.setFont(c.font_c16)
      love.graphics.printf(name, subx,suby+4,85,"center")
    end
    suit:registerDraw(draw_sub_cat_btn)
    if suit:mouseReleasedOn(opt.id) and curSubcat~=i then
      curSubcat = i
      loadCategoryList()
    end
  end
end




local function oneRecipe(num,x,y,w,h)
  local entry = cate_list[num]
  if entry==nil then return end
  local recipe = entry.recipe
  entry.state =suit:registerHitbox(entry,recipe, x,y,w,h)
  local function drawOneRecipe()
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
    
    
    love.graphics.oldColor(255,255,255)
    local img,quad = recipe.result_itype.img,recipe.result_itype.quad
    love.graphics.draw(img,quad,x,y,0,1,1)
    if not entry.meet_component then
      --love.graphics.oldColor(0,100,100)
      love.graphics.oldColor(110,110,110)
    elseif not entry.meet_skill then
      love.graphics.oldColor(200,0,0)
    else
      love.graphics.oldColor(0,0,0)
    end
    love.graphics.setFont(c.font_c16)
    love.graphics.print(entry.recipe.result_itype.name, x+34, y+5)
  end
  suit:registerDraw(drawOneRecipe)
  local allstate = suit:standardState(recipe)
  if allstate.hit and entry ~= curEntry then
    curEntry = entry 
    --刷新子面板  
    loadEntry()
  end
  return allstate
end

--一个重排序方法，会被下面使用两次
local function compare_two_entry(tool1,tool2)
  local p1 = tool1.org_index
  local p2 = tool2.org_index
  if tool1.find_item then p1 = p1 -100 end
  if tool2.find_item then p2 = p2 -100 end
  return p1<p2
end


local length_max_w = 620 --使用横向滚动条的限制距离
local panel_h_limit = 460
function loadEntry()
  if curEntry==nil then return end
  if curEntry.main_opt then --已有值
    curIcon_opt = curEntry.main_opt
    return 
  end
  local recipe = curEntry.recipe
  curEntry.result_itype = data.itemTypes[recipe.result]
  curEntry.main_opt = {id = newid(),itemtype = curEntry.result_itype} --主opt
  curIcon_opt = curEntry.main_opt
  
  local length = 45;
  local Rtext = love.graphics.newText(c.font_c16);curEntry.Rtext = Rtext
  local text1 = {{22/255,22/255,22/255},tl("主要技能: ","Main skill: ")}
  local mainlevel = player.skills:get_skill_level(recipe.main_skill)
  local requireLevel = recipe.main_level
  local skillName = player.skills:get_skill_name(recipe.main_skill)..string.format(tl(" Lv%d(自身等级:%d)"," Lv%d(Your Level:%d)"),requireLevel,mainlevel)
  if mainlevel>=requireLevel then
    text1[#text1+1] = {22/255,120/255,22/255}
    text1[#text1+1] = skillName
  else
    text1[#text1+1] = {120/255,22/255,22/255}
    text1[#text1+1] = skillName
  end
  Rtext:add(text1,0,length)
  length = length+ Rtext:getHeight()+3
  if recipe.required_skills then
    --次要技能等级
    local text2 = {{22/255,22/255,22/255},tl("次要技能: ","Required skill: ")}
    for skill_id,require_level in pairs(recipe.required_skills) do
      local playerlevel = player.skills:get_skill_level(skill_id)
      local skillName = player.skills:get_skill_name(skill_id)..string.format(" Lv%d(%d)    ",require_level,playerlevel)
      if playerlevel>=require_level then
        text2[#text2+1] = {22/255,120/255,22/255}
        text2[#text2+1] = skillName
      else
        text2[#text2+1] = {120/255,22/255,22/255}
        text2[#text2+1] = skillName
      end
    end
    Rtext:add(text2,0,length)
    length = length+ Rtext:getHeight()+3
    
  end
  local text2p5 = {{22/255,22/255,22/255},tl("暗处制造: ","Dark craftable: ")}
  if recipe.flags["BLIND_EASY"] then
    text2p5[#text2p5+1] = {22/255,22/255,22/255}
    text2p5[#text2p5+1] = tl("简单","Easy")
  elseif recipe.flags["BLIND_HARD"] then
    text2p5[#text2p5+1] = {22/255,22/255,22/255}
    text2p5[#text2p5+1] = tl("困难","Hard")
  else
    text2p5[#text2p5+1] = {22/255,22/255,22/255}
    text2p5[#text2p5+1] = tl("不可能","Impossible")
  end
  Rtext:add(text2p5,300,length)
  
  local text3
  local hour = math.floor(recipe.costtime/3600)
  local minute = math.floor((recipe.costtime%3600)/60)
  if hour>0 then
    text3= string.format(tl("完成耗时: %d 小时 %d 分钟","Time to complete: %d hour %d minite"),hour,minute)
  elseif minute>0 then 
    text3= string.format(tl("完成耗时: %d 分钟","Time to complete: %d minite"),minute)
  else
    text3= tl("完成耗时: 小于 1 分钟","Time to complete: less than 1 minite")
  end
  Rtext:add({{22/255,22/255,22/255},text3},0,length)
  length = length+ Rtext:getHeight()+3
  local text4 = {{22/255,22/255,22/255},tl("需要工具: ","Tools required: ")}
  local toolLength = 0
  curEntry.qualities = {}
  for tool_id,tool_level in pairs(recipe.qualities) do 
    local qua = {tool_id = tool_id,level = tool_level,data = data.qualities[tool_id],icon_opt = {id=newid(),tool_id = tool_id,tool_level = tool_level}}
    qua.meet = player:recipe_meet_one_quality(tool_id,tool_level)
    qua.str = string.format(tl("需要工具至少有 %s 等级%d。","Need tool with %s of level %d or more."),qua.data.name,qua.level)
    curEntry.qualities[#curEntry.qualities+1] = qua
    qua.self_height = 40 
    toolLength = toolLength +qua.self_height --长度+40
  end
  curEntry.tools = {}
  for _,tooltable in ipairs(recipe.tools) do
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
  for _,mat_table in ipairs(recipe.components) do
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
  
  if recipe.byproducts then
    Rtext:add({{22/255,22/255,22/255},tl("附加产物:","Byproducts:")},0,length)
    length = length+ Rtext:getHeight()+3
    curEntry.textLength3 = length
    curEntry.byproducts  = {}
    for item_id,number in pairs(recipe.byproducts) do
      local oneByproduct = {id = item_id,number = number,icon_opt = {id=newid()},}
      oneByproduct.item_type = data.itemTypes[item_id] --
      oneByproduct.icon_opt.itemtype = oneByproduct.item_type
      oneByproduct.str = string.format("%d %s",number,oneByproduct.item_type.name)
      oneByproduct.str_length = c.font_c16:getWidth(oneByproduct.str)+50
      curEntry.byproducts[#curEntry.byproducts+1] = oneByproduct
    end
     --统计距离
    local total_length = 0
    for i=1,#curEntry.byproducts do total_length = total_length+curEntry.byproducts[i].str_length  end
    
    if total_length>length_max_w then  --一旦距离超标，就使用滚动条
      curEntry.byproducts.self_height = 40 +18
      curEntry.byproducts.useScroll = {w =total_length,h = 40,opt = {id =newid(),horizontal = true}} --使用滚动条
    else
      curEntry.byproducts.self_height = 40 
    end
    length = length +curEntry.byproducts.self_height --长度 增加本行，使用滚动条会变长
  end
  
  local h_limit =panel_h_limit
  if length>h_limit then curEntry.useScroll = {w =620,h = length,opt = {id =newid(),vertical = true}} end
  
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

local function one_entry_byproduct(entry_list,one_entry,x,y,self_index)
  local function drawQText()
    love.graphics.oldColor(22,22,22)
    love.graphics.setFont(c.font_c16)
    love.graphics.print(one_entry.str, x+42, y+15)
  end
  suit:registerDraw(drawQText)
  local boxState = ItemBox(one_entry.item_type.quad,one_entry.item_type.img,one_entry.icon_opt,x,y,38,40)
  if curIcon_opt == one_entry.icon_opt then
    one_entry.icon_opt.state = "active"
  end
  if boxState.hit then
    curIcon_opt = one_entry.icon_opt
  end
  
end


local craft_opt = {id= newid(),text = tl("制作","Craft"),font=c.font_c16}
local craft_all_opt = {id= newid(),text = tl("全部制作","Batch"),font=c.font_c16}
local make_craft

local function recipePanel(x,y,w)
  if curEntry==nil then return end
  local recipe = curEntry.recipe
  
  --内部面板（放在内部的）
  local function interPanel(x,y,w,h)
    --标头物品名字
    local img,quad = curEntry.result_itype.img,curEntry.result_itype.quad
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
      love.graphics.print(curEntry.result_itype.name, x+60, y+15)
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
    if recipe.byproducts then
      y_a = starty1+curEntry.textLength3 --第三个开始
      one_entry_list(curEntry.byproducts,one_entry_byproduct,x+5,y_a)
      y_a = y_a+ curEntry.byproducts.self_height
    end
  end
  
  local startx,starty = x+10,y+10
  if curEntry.useScroll then
    --使用滚动条
    suit:ScrollRect(curEntry.useScroll,curEntry.useScroll.opt,x+10,y+10,5+length_max_w,panel_h_limit)
    starty = curEntry.useScroll.y
  end

  interPanel(startx,starty,620)
  if curEntry.useScroll then
    
    suit:endScissor()
    suit:wheelRollInRect(x+10,y+10,5+length_max_w,panel_h_limit,curEntry.useScroll)
  end
  
  craft_opt.disable = not curEntry.meet_all
  craft_all_opt.disable = not curEntry.meet_all
  
  local craft_state  = suit:S9Button(craft_opt.text,craft_opt,x+110,y+530,100,35) 
  local batch_state  = suit:S9Button(craft_all_opt.text,craft_all_opt,x+400,y+530,100,35)
  
  if curEntry.meet_all then --
    if craft_state.hit then make_craft(1) end
    if batch_state.hit then craftingWin:OpenChild(ui.askNumberWin,make_craft,1,10,5,nil,nil,tl("制作数量","Craft Number")) end
  end
end


-- 建立一个command，里面存放了选定的工具和材料。
function make_craft(batch)
  if batch<=0 then return end
  local command = {}
  command.recipe = curEntry.recipe
  command.toollist= {}
  for i=1,#curEntry.tools do
    local one_list = curEntry.tools[i]
    local select_one = one_list[one_list.select]
    table.insert(command.toollist,{tool_id = select_one.tool_id,charges =select_one.charges})--单一的toolid和charge
    --debugmsg("tool_id:"..select_one.tool_id)
    
  end
  command.components= {}
  for i=1,#curEntry.components do
    local one_list = curEntry.components[i]
    local select_one = one_list[one_list.select]
    local item_id = select_one.item_id
    local number = select_one.number
    local find_prev = false
    for j=1,#command.components do
      if command.components[j].item_id == item_id then --可能之前有相同的id材料，数量叠加。此时可能出现材料不足的结果？配方有同种材料在不同行会出现这种情况，需要尽量避免
        find_prev = true
        command.components[j].number = command.components[j].number+number
      end
    end
    if not find_prev then
      table.insert(command.components,{item_id = item_id,number = number})--单一的部件选择。
    end
    
  end
  command.total_num =batch
  command.left_num = batch --一个或多个
  
  command.batch_time_mult = 1--批量制作时的时间减少，暂时没有
  command.return_craftwin = true--完成后返回制作窗口。
  
  --制作
  craftingWin:Close()--关闭本窗口
  player:make_craft(command)
  player:releaseCraftingInventory() --makecraft之后必会释放临时物品背包。里面的物品已被取用。
end





function craftingWin.keyinput(key)
  if key=="escape" then  craftingWin:Close() end
  if key=="e" or key=="return" then 
    if curEntry and curEntry.meet_all then make_craft(1) end
  end
  if key=="b" then if curEntry and curEntry.meet_all then craftingWin:OpenChild(ui.askNumberWin,make_craft,1,10,5,nil,nil,tl("制作数量","Craft Number")) end end
  if key=="tab" then changeCategory(curCategory+1) end
  if key=="left" or key=="a" then changeSubcat(curSubcat-1) end
  if key=="right" or key=="d" then changeSubcat(curSubcat+1) end
  if key=="up" or key=="w" then changeRecipe(-1) end
  if key=="down" or key=="s" then changeRecipe(1) end
end
function craftingWin.win_open()
  curIcon_opt = nil
  initCategoryBtns()
  loadCategoryList()
  
end

function craftingWin.win_close()
  curIcon_opt = nil
  player:releaseCraftingInventory()--退出窗口会释放。
end

function craftingWin.window_do(dt)
  suit:DragArea(s_win,true,s_win.dragopt)
  
  --使用该窗口的名字
  suit:Dialog(s_win.name,s_win.x,s_win.y,s_win.w,s_win.h)
  suit:DragArea(s_win,false,s_win.dragopt,s_win.x,s_win.y,s_win.w,32)
  local close_st = suit:ImageButton(close_quads,close_opt,s_win.x+s_win.w-34,s_win.y+4,30,24)
  suit:registerDraw(drawBack,s_win.x,s_win.y,s_win.w,s_win.h)
  categoryButtons(s_win.x+8,s_win.y+36)
  suit:List(listScroll,oneRecipe,listScroll.opt,s_win.x+8,s_win.y+110,220,580)
  recipePanel(s_win.x+230,s_win.y+110,660,580)
  if curIcon_opt  then
    if curIcon_opt.itemtype then
      ui.itemtypeInfo(curIcon_opt.itemtype,s_win.x+s_win.w,s_win.y,330,s_win.h)
    elseif curIcon_opt.tool_id then
      ui.toolLevelInfo(curIcon_opt.tool_id,curIcon_opt.tool_level,s_win.x+s_win.w,s_win.y,330,s_win.h)
    end
  end
  if close_st.hit then craftingWin:Close() end
  
  
end