wificonf = {
  -- verificar ssid e senha
  ssid = "Victor's iPhone X",
  pwd = "bobmarley",
  got_ip_cb = function (iptable) print ("ip: ".. iptable.IP) end,
  save = false
}

print("doing")
wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
