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


local m = mqtt.Client("VictorTeste132", 120)

function publishLocationData()
	if(string.len(locationJSON) > 0) then
		print("Publishing Location Data.")
		m:publish("locationData", locationJSON, 0,  0, 
                  function(client, reason) print("Location Data Published.") end)
	else
		print("Publish failed. Data was empty")
	end 
end

--topic te diz a fila que recebeu e message a string
function messageReceivedCallback(client)

    local function messageTreatment(userdata, topic, message)
            if(message == "Requesting location") then
                print("Received location request.")
                locationJSON = ""
                wifi.sta.getap(listap)
            end
    end

    client:on("message",messageTreatment)
end

function connected(client)
    client:publish("connectionSuccess", "NodeMCU has connected.",0,  0, 
			  	  function(client, reason) print("Connection success.") end)
    client:subscribe("requestData",0,messageReceivedCallback)
end

function parseLocationData(message)
	local startLat,endLat = string.find(message,"lat")
	local startLng,endLng = string.find(message,"lng")
	local startAcc,endAcc = string.find(message,"accuracy")

	return string.sub(message,endLat + 4, startLng - 6) .. ";" .. string.sub(message,endLng + 4 , startAcc - 8) .. ";" .. string.sub(message,endAcc+4,string.len(message) - 3)
end

-- Print AP list that is easier to read
listdeap = {}

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
	local i = 0 
	
	for ssid,v in pairs(t) do
		local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")

		listdeap[i] = [[{ "macAddress":  "]] .. bssid .. [[]] .. [[","signalStrength": ]] .. rssi .. [[,"channel": ]] .. channel .. [[}]]
        if (i == 6) then break end
		i = i + 1
	end

    json = [[{"wifiAccessPoints": [ ]]
    json = json .. table.concat(listdeap,",")

    json = json .. [[]}]]
    
    print(json)
	
	--empty table for next call
	for k in pairs (listdeap) do
		listdeap [k] = nil
	end

    local numberOfTries = 5

    local function callbackPost(code,data)
            if (code < 0) then
                print("HTTP request failed :", code)
                numberOfTries = numberOfTries - 1
                print("Number of remaining tries: " .. numberOfTries)
                tmr.delay(1000000)
                if(numberOfTries > 0) then
                   http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDKcCPg4oxcRCVu-sYs97V1VHNYCdVKn_o',
                    'Content-Type: application/json\r\n',json,callbackPost)
                else
                    m:publish("locationData", "Failure", 0,  0, 
                  function(client, reason) print("Failure to get location published.") end)
                end
            else
                print(code, data)
                locationJSON = parseLocationData(data)
                print(locationJSON)
                publishLocationData()      
            end
    end

    http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyA5Z5xai0SkBDbbjHueWLggvXvV_rLMG5E',
      'Content-Type: application/json\r\n',json,callbackPost)
        
    gpio.write  (led1, gpio.LOW)

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
			

	end
end
gpio.trig   (sw1, "down", buttonpressed())


m:connect("test.mosquitto.org", 1883, 0, 
			 connected,
			 function(client, reason) print("Connection failed. Reason for failure:"..reason) end)

--wifi.sta.getap(listap)
