function startup()
    if abort == true then
        print('startup aborted')
        return
    end
    gpio.write  (led1, gpio.LOW)
    gpio.write  (led2, gpio.LOW)
    print('in startup')
    dofile('mainTest.lua')
end


led1 = 6
led2 = 3
gpio.mode   (led1, gpio.OUTPUT)
gpio.mode   (led1, gpio.OUTPUT)
gpio.write  (led1, gpio.HIGH)
gpio.write  (led2, gpio.HIGH)
abort = false
print("timer started")
tmr.alarm(0,10000,0,startup)
wificonf = {
  -- verificar ssid e senha
  ssid = "Victor's iPhone X",
  pwd = "bobmarley",
  got_ip_cb = function (iptable) print ("ip: ".. iptable.IP) end,
  save = false
}

print("Connecting")
wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
