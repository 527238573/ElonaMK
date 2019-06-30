Window={
  window_do = function(dt) end,
  win_open = function() end,
  win_close = function() end,
  keyinput = function(key) end,
}

Window.__index = Window
Window.__newindex = function(o,k,v)
  if Window[k]==nil and k~="child" then error("使用了Window的意料之外的值。") else rawset(o,k,v) end
end
function Window.new()
  local o = {}
  setmetatable(o,Window)
  return o
end


local win_root

function Window.getRoot()
  return win_root
end


--根节点的 入口函数，每帧都进入
function Window.windowRoot(dt)
  --以win_root为根指针
  if win_root then
    win_root:window_do(dt)
  end
  --此时parent可能在执行后close了
  local parent = win_root
  local num=1
  while(parent and parent.child) do --层级调用
    parent.child:window_do(dt) --此时child可能在执行后close了
    parent = parent.child
    num=num+1
    if num>10 then 
      debugmsg("loop too deep (win_root)")
      break 
    end--不能太深
  end
end



--从ui根节点展开
function Window:Open(...)
  if win_root then win_root:Close() end--关闭旧的
  win_root = self
  self.child = nil--防出错吧
  self:win_open(...)
  
end

function Window:OpenChild(child,...)
  if self.child then self.child:Close() end--关闭旧的
  self.child = child
  child.child = nil--防出错吧
  child:win_open(...)
end

function Window:keypressed(key)
  if self.child then self.child:keypressed(key);return end
  self:keyinput(key)
end

function Window:Close(...)
  if self.child then self.child:Close() end--关闭子层
  self:win_close(...)
  if win_root then
    if win_root==self then
      win_root = nil
    else
      local parent = win_root
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