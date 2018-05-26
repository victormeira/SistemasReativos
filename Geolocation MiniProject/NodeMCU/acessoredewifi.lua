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
