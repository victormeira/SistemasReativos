function naimagem (mx, my, x, y) 
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
  
  return {
      draw =
        function ()
          love.graphics.rectangle("line", rx, ry, w, h)
        end,
      keypressed =
        function (key)
            local mx, my = love.mouse.getPosition() 
  
            if key == 'b' and naimagem (mx,my, x, y) then
              ry = 200
            elseif key == "down" then
              ry = ry + 10
            elseif key == "right" then
              rx = rx + 10
            elseif key == "up" then
              ry = ry - 10
            elseif key == "left" then
              rx = rx - 10
            end
        end
  }
end


function love.load()
  ret_array = {}
  
  n = math.random(500)
  
  for i=1, n do
    ret_array[i] = retangulo(math.random(800),math.random(500),math.random(50), math.random(50))
  end

end

function love.keypressed(key)
  for i=1, n do
    ret_array[i].keypressed(key)
  end
end

function love.update (dt)

end

function love.draw ()
  for i=1, n do
    ret_array[i].draw()
  end
end

