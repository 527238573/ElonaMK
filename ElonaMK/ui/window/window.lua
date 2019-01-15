--window组件使用面向对象，因为太复杂
local window_mt = {}
window_mt.__index = window_mt

function ui.new_window()
  local new_win = {}
  setmetatable(new_win,window_mt)
  return new_win
end

--4个函数需自定义
--window_do(dt) --必须，可无参数
--win_open(...)--可选,任意参数
--win_close(...)--可选,任意参数
--keyinput(key) --可选，但是必会占用键盘焦点

--根节点的 入口函数，每帧都进入
function ui.windowRoot(dt)
  --以ui.win_root为根指针
  if ui.win_root then
    ui.win_root.window_do(dt)
  end
  --此时parent可能在执行后close了
  local parent = ui.win_root
  local num=1
  while(parent and parent.child) do --层级调用
    parent.child.window_do(dt) --此时child可能在执行后close了
    parent = parent.child
    num=num+1
    if num>10 then 
      debugmsg("loop too deep (win_root)")
      break 
    end--不能太深
  end
end



--从ui根节点展开
function window_mt:Open(...)
  if ui.win_root then ui.win_root:Close() end--关闭旧的
  ui.win_root = self
  self.child = nil--防出错吧
  if self.win_open then self.win_open(...) end --可选
  
end

function window_mt:OpenChild(child,...)
  if self.child then self.child:Close() end--关闭旧的
  self.child = child
  child.child = nil--防出错吧
  if child.win_open then child.win_open(...) end --可选函数
end

function window_mt:keypressed(key)
  if self.child then self.child:keypressed(key);return end
  if self.keyinput then self.keyinput(key) end --可选函数
end

function window_mt:Close(...)
  if self.child then self.child:Close() end--关闭子层
  if self.win_close then self.win_close(...) end--可选
  if ui.win_root then
    if ui.win_root==self then
      ui.win_root = nil
    else
      local parent = ui.win_root
      local num=1
      while(parent.child) do 
        if parent.child ==self then
          parent.child = nil
          break
        else
          parent = parent.child
          num=num+1
          if num>10 then 
            debugmsg("loop too deep(close)")
            break 
          end--不能太深
        end
      end
    end
  end
end
