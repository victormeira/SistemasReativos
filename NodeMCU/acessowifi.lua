-- Print AP list that is easier to read
listdeap = {}

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    local i = 0
    for ssid,v in pairs(t) do
        local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
        --listdeap[i]={}
        listdeap[i] = "{ \"macAddress\": \"" .. bssid .. "\"" .. ", \"signalStrength\": " .. rssi .. ", \"channel\": " .. channel .. "}"
        --print(listdeap[i]["bssid"]);
        --listdeap[i]["channel"] = channel
        --listdeap[i]["rssi"] = rssi
        i = i + 1
    end

    json = "[[ { \"wifiAccessPoints\": ["
    json = json .. table.concat(listdeap,",")

    json = json .. "]}]]"

    print(json)

    http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyB_PcDv6uslYq0Z1EuyiHHUFrPIFU56eCA',
  'Content-Type: application/json\r\n',json,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed :", code)
    else
      print(code, data)
    end
  end)
   
end
wifi.sta.getap(listap)



