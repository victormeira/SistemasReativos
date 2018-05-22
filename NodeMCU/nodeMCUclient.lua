led1    = 6
led2    = 3
sw1     = 1
sw2     = 2
gpio.mode   (led1, gpio.OUTPUT)
gpio.mode   (sw1,gpio.INT,gpio.PULLUP)
gpio.mode   (sw2,gpio.INT,gpio.PULLUP)
gpio.write  (led1, gpio.LOW)
gpio.write  (led2, gpio.LOW)
locationJSON = ""   


local m = mqtt.Client("MiniProjeto-MatheusEVictor", 120)

function publishLocationData()
	if(locationJSON != "") then
		print("Publishing Location Data.")
		--publish na fila locationData
		print("Publish successful.")
	end
	else
		print("Publish failed. Data was empty")
	end 
end

--topic te diz a fila que recebeu e message a string
function messageReceivedCallback(topic, message)
  if(message == "Requesting location") then
	  locationJSON = ""
	  wifi.sta.getap(listap)
	  publishLocationData()
  end     
end

function connected(client)
  client:publish("connectionSuccess", "NodeMCU has connected.",0,0, 
			  	  function(client, reason) print("Connection failed. Reason for failure:"..reason) end)
  client:subscribe("requests",0,messageReceivedCallback)
end

function parseLocationData(message)
	local startLat,endLat = string.find(message,"lat")
	local startLoc,endLoc = string.find(message,"loc")
	local startAcc,endAcc = string.find(message,"accuracy")

	return string.sub(message,endLat + 3, startLoc - 4) .. ";" .. string.sub(message,endLoc + 3 , startAcc - 4) .. ";" .. string.sub(message,endAcc-4,string.len(message) - 5)
end

-- Print AP list that is easier to read
listdeap = {}

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
	local i = 0 
	
	for ssid,v in pairs(t) do
		local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")

		listdeap[i] = "{ \"macAddress\": \"" .. bssid .. "\"" .. ", \"signalStrength\": " .. rssi .. ", \"channel\": " .. channel .. "}"

		i = i + 1
	end

	json = "[[{ \"wifiAccessPoints\": ["
	json = json .. table.concat(listdeap,",")

	json = json .. "]}]]"
	
	print(json)
	
	--empty table for next call
	for k in pairs (listdeap) do
		listdeap [k] = nil
	end
	
	http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyA5Z5xai0SkBDbbjHueWLggvXvV_r', --LMG5E
  'Content-Type: application/json\r\n',json,
  	function(code, data)
		if (code < 0) then
	  		print("HTTP request failed :", code)
		else
	  		print(code, data)
	  		locationJSON = parseLocationData(data)       
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
				
			locationJSON = ""

			gpio.write  (led1, gpio.HIGH)
			wifi.sta.getap(listap)
			gpio.write  (led1, gpio.LOW)

			publishLocationData()

	end
end
gpio.trig   (sw1, "down", buttonpressed())


m:connect("test.mosquitto.org", 1883, 0, 
			 connected,
			 function(client, reason) print("Connection failed. Reason for failure:"..reason) end)

--wifi.sta.getap(listap)

