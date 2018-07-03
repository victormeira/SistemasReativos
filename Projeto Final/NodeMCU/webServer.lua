_G.optic   = "BRIGHT"
_G.button  = "NOT PRESSED"
_G.metal   = "NO CONTACT"
_G.hall    = "NO CURRENT"
_G.led1    = "OFF"
_G.led2    = "OFF"
_G.led3    = "OFF"


function receiver(sck, data)
  print(data)
  sck:close()
end


function upServer()
  sv = net.createServer(net.TCP, 30)

  if sv then
    sv:listen(80, function(conn)
      conn:on("receive", receiver)
       -- HTML Header Stuff
          conn:send('HTTP/1.1 200 OK\n\n')
          conn:send('<!DOCTYPE HTML>\n')
          conn:send('<html>\n')
          conn:send('<head><meta  content="text/html; charset=utf-8">\n')
          conn:send('<title>Servidor NodeMCU</title></head>\n')
          conn:send('<body><h1>Node MCU Sensors</h1>\n')
          conn:send('<body><h5>OPTIC: ' .. _G.optic .. '</h5>\n')
          conn:send('<body><h5>BUTTON: ' .. _G.button .. '</h5>\n')
          conn:send('<body><h5>METAL: ' .. _G.metal .. '</h5>\n')
          conn:send('<body><h5>HALL: ' .. _G.hall .. '</h5>\n')
          conn:send('<body><h5>LED1: ' .. _G.led1 .. '</h5>\n')
          conn:send('<body><h5>LED2: ' .. _G.led2 .. '</h5>\n')
          conn:send('<body><h5>LED3: ' .. _G.led3 .. '</h5>\n')
          conn:send('</body></html>\n')
          conn:on("sent", function(conn) conn:close() end)
    end)
  end
end

