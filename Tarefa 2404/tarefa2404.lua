led1 = 6
led2 = 3
sw1 = 1
sw2 = 2
ledstate = false

last_but1 = 0
last_but2 = 0
button_interval = 500000
time_interval = 1000

gpio.mode(led1, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);
ledstate = false

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

function turnoff ()
    gpio.write(led1, gpio.LOW);
    timer:stop()
end


function slowdown (led)
  local delay = 500000
  local last = 0
  return
  function (level, timestamp)
    local now = tmr.now()
    last_but1 = now

    -- debouncing
    if now - last < delay then return end
    last = now

    if now - last_but2 < button_interval then
        turnoff()
        print("off")
    end
    

    time_interval = time_interval + 200
    timer:interval(time_interval)
    print("slow")

  end
end

function speedup (led)
  local delay = 500000
  local last = 0
  return
  function (level, timestamp)
    local now = tmr.now()
    last_but2 = now
    -- debouncing
    if now - last < delay then return end
    last = now

    if now - last_but1 < button_interval then
        turnoff()
        print("off")
    end

    time_interval = time_interval - 200
    timer:interval(time_interval)
    print("speed")

  end    
end

function changeledstate ()
    ledstate = not ledstate
    if ledstate then 
        gpio.write(led1, gpio.HIGH);
    else
        gpio.write(led1, gpio.LOW)
    end
    print("change")

end

gpio.trig(sw1, "down", slowdown(led1))
gpio.trig(sw2, "down", speedup(led1))

timer = tmr.create()
timer:register(time_interval, tmr.ALARM_AUTO, changeledstate)
timer:start()


