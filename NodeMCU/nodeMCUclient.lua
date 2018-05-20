led1    = 6
led2    = 3
sw1     = 1
sw2     = 2
gpio.mode   (led1, gpio.OUTPUT)
gpio.mode   (sw1,gpio.INT,gpio.PULLUP)
gpio.mode   (sw2,gpio.INT,gpio.PULLUP)
gpio.trig   (sw1, "down", buttonpressed())
gpio.write  (led1, gpio.LOW)
gpio.write  (led2, gpio.LOW)

local MQTT  = require("mqttNodeMCULibrary")
MQTT.start("requestData",mqttcb)
--mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
--mqtt_client:connect("MiniProjeto-MatheusEVictor")
--mqtt_client:subscribe({"requests"})

function mqttcb(message)
  if(message == "requesting") then
    wifi.sta.getap(listap)
  end
   --topic te diz a fila que recebeu e message a string
end

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
    
    --empty table for next call
    for k in pairs (listdeap) do
        listdeap [k] = nil
    end

    http.get('https://google.com',nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
    end)
    
    http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=zaSyB_PcDv6uslYq0Z1EuyiHHUFrPIFU56eCA',
  'Content-Type: application/json\r\n',json,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed :", code)
    else
      print(code, data)
      
      --data format: { "location": { "lat": 51.0, "lng": -0.1 }, "accuracy": 1200.4 }

      latStart,latEnd = string.find(data,"lat")
      lngStart,lngEnd = string.find(data,"lng")
      accStart,accEnd = string.find(data,"accuracy")

      payload = string.sub(data,latEnd+4,lngStart-4) .. ";" .. string.sub(data,lngEnd+4,accStart-5)

      --MQTT.sendMessage(payload,"locationData")

      print("Location Data sent.")
    end
  end)   
end

function buttonpressed ()
  local delay = 500000
  local last = 0
  return
  function (level, timestamp)
    local now = tmr.now()

    -- debouncing
    if now - last < delay then return end
    last = now
    
    gpio.write  (led1, gpio.HIGH)
    wifi.sta.getap(listap)
    gpio.write  (led1, gpio.LOW)
        
  end
end

--wifi.sta.getap(listap)

