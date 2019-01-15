function love.conf(c)
  --必须0.10.0以上
  c.title = "Elona Mercenary Kings"
  local window = c.window
  window.width = 1600
  window.height = 1000
  window.x = 160                    -- The x-coordinate of the window's position in the specified display (number)
  window.y = 30 
  window.vsync = true
  window.fullscreen = false 
end
