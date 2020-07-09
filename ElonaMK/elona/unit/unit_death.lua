
-- 基本没用，一般是直接访问dead ，例如 if unit.dead then ... 这样
function Unit:is_dead()
  return self.dead
end

--只有被标记为死亡才真正死亡，HP降为0暂不代表死亡。
function Unit:is_alive()
  return not self.dead
end




function Unit:die(killer,dam_ins)
  if self.dead then return end --只能死一次
  self:die_message(killer,dam_ins)

  self.dead = true
  rawset(self,"killer",killer)--设置killer


  self:drop_frames_to_map()--掉落特效到地图上

  --解除在地图上的位置，activeUnit列表里靠自己清理。

  local map =self.map
  if map then
    map:unitLeave(self)
  end
  --安排死亡动画。
  --
  local frame = FrameClip.createUnitFrame("red_dead")
  if map then map:addSquareFrame(frame,self.x,self.y,0,30) end --map存在时才能添加
  g.playSound("kill",self.x,self.y) 

  --drop物品

end



--播放死亡讯息。dam_ins里面有伤害来源原因。即便不是因dam_ins而死，也要创建dam_ins对象并把原因填入cause传过来。
function Unit:die_message(killer,dam_ins)
  local show_msg = self:isInPlayerTeam() or (killer==p.mc) or p.mc:seesUnit(self)
  if not show_msg then 
    debugmsg("death not show")
    return 
  end --看不见的不显示，不制造垃圾信息
  local cause = dam_ins.cause 
  local selfname = self:getShortName()
  if cause =="attack" then
    local sec = dam_ins.subtype
    if sec =="cut" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被切成两半。","%s was cut into half pieces."),selfname),"death")
      else
        addmsg(string.format(tl("%s被斩成碎片。","%s was chopped into pieces."),selfname),"death")
      end
    elseif sec =="bash" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被砸成肉饼。","%s was smashed into a meat pie."),selfname),"death")
      else
        addmsg(string.format(tl("%s散成碎片。","%s was torn apart."),selfname),"death")
      end
    elseif sec =="stab" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被肢解了。","%s was dismembered."),selfname),"death")
      else
        addmsg(string.format(tl("%s被完全贯穿了。","%s is completely penetrated."),selfname),"death")
      end
    elseif sec =="fire" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被烧成灰了。","%s was burnt to ashes."),selfname),"death")
      else
        addmsg(string.format(tl("%s变成焦炭了。","%s has turned to coke."),selfname),"death")
      end
    elseif sec =="ice" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s碎成了冰渣。","%s broke into ice slag."),selfname),"death")
      else
        addmsg(string.format(tl("%s化为冰水。","%s turns into ice water."),selfname),"death")
      end
    elseif sec =="natrue" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被溶解了。","%s is dissolved."),selfname),"death")
      else
        addmsg(string.format(tl("%s成了一滩烂肉。","%s turns into rotten meat."),selfname),"death")
      end
    elseif sec =="earth" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被埋葬了。","%s was buried."),selfname),"death")
      else
        addmsg(string.format(tl("%s成了大地的肥料。","%s becomes the manure of the earth."),selfname),"death")
      end
    elseif sec =="dark" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s被黑暗吞噬了。","%s was swallowed by the darkness."),selfname),"death")
      else
        addmsg(string.format(tl("%s淹没于黑暗中。","%s drowned in darkness."),selfname),"death")
      end
    elseif sec =="light" then
      local rndindex = rnd(1,2)
      if rndindex ==1 then
        addmsg(string.format(tl("%s消散在强光中。","%s dissipated in the bright light."),selfname),"death")
      else
        addmsg(string.format(tl("%s变成了闪光。","%s becomes flash light."),selfname),"death")
      end
    else
      if dam_ins.dtype ==2 then--受到无属性魔法攻击
        local rndindex = rnd(1,4)
        if rndindex ==1 then
          addmsg(string.format(tl("%s被炸成灰灰。","%s was blasted to ashes."),selfname),"death")
        elseif rndindex ==2 then
          addmsg(string.format(tl("%s被轰杀成渣。","%s was blown to pieces."),selfname),"death")
        elseif rndindex==3 then
          addmsg(string.format(tl("%s四散一地。","%s scatter to the ground."),selfname),"death")
        else
          addmsg(string.format(tl("%s被分解了。","%s is decomposed."),selfname),"death")
        end
      else --无属性物理攻击或真实攻击
        local rndindex = rnd(1,4)
        if rndindex ==1 then
          addmsg(string.format(tl("%s被切成肉末了。","%s transformed into several pieces of meat."),selfname),"death")
        elseif rndindex ==2 then
          addmsg(string.format(tl("%s四分五裂了。","%s is slain."),selfname),"death")
        elseif rndindex==3 then
          addmsg(string.format(tl("%s被杀死了。","%s is killed."),selfname),"death")
        else
          addmsg(string.format(tl("%s变成肉酱了。","%s is minced."),selfname),"death")
        end
      end
    end
  else
    addmsg(string.format(tl("%s死了!","%s dies!"),selfname),"death")
  end
end