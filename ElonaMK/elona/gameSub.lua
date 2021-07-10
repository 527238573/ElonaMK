--子线程专用
g={
  
}

cmap = nil --当前地图
wmap = nil --大世界地图。
p = nil --当前player数据


g.curFrame = 1
g.dt_rl = 0--标记RL的dt。
function g.update(dt)
  p.calendar:updateRL(dt) --日期更新
  cmap:updateRL(dt)
  cmap:updateAnim(dt)
end



function g.main()
  
  print("thread sub start!")
  io.flush()
  data.init()
  
  
  local channel = love.thread.getChannel ( "a" );
  while(true) do
    local value = channel:demand()
    if type(value) == "string" then
      print(value)
      io.flush()
    elseif type(value) == "table" then
      table.saveAdv(  value,love.filesystem.getSourceBaseDirectory().."/Save/testSve.lua" )
    end
  end
end