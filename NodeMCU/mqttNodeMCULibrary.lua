local MQTT = {}

local HOST = 'test.mosquitto.org' -- substitute for the ip adress of the broker host
local PORT = 1883 -- default port, substitute if necessary

local userId = nil
local mqttClient = nil
local ERROR_LED = 3

retry = true

-- private functions

function handleMqttError()
	gpio.write(ERROR_LED,gpio.HIGH)
	tmr.create():alarm(10*1000, tmr.ALARM_SINGLE, mqttConnect)

end

function mqttConnected()
	print('Connected to broker')
	channel = userId..'love'
	mqttClient:subscribe(channel,0,function(conn)
	print('succesfuly subscribed to '.. channel) end)
end

function mqttConnect()
	print('Attempt to connect')
	mqttClient:connect(HOST,PORT,0,0, mqttConnected, function(con,reason) 
    		print("Couldn't connect to broker: ".. reason)
    		handleMqttError() end)

end

--[[
	function to start the mqttClient. It connects to the broker and subscribes to a predefined channel.
	id: unique id for the user
	callbackFunction: optional, function to be called when the application receives a message. 
					  If nil, a 'messageReceived' function will be called
]]
function MQTT.start(id,callbackFunction)

	defaultTopic = "requests"
	mqttClient = mqtt.Client(id,120) -- subscribing to defaultTopic instead of id to make love and nodeMCU id's different.
	userId = id
	
	callback = callbackFunction or messageReceived

	mqttClient:on("connect", function(client) print ("connected") end)
	mqttClient:on("offline", function(client) print ("offline") end)

	mqttClient:on("message", function(client, topic, message)
	print("Message Received " .. topic .. "  " .. message)
	callback(message)
	end)

	print("Try to connect")

	tmr.create():alarm(10*1000, tmr.ALARM_SINGLE, mqttConnect)

	-- mqttConnect()


end


--[[
	function to send a message
	message: message to be sent
	topic: optional, channel to send the message. If nil the message will be sent to a default channel
]]
function MQTT.sendMessage(message,topic)

	topic = topic or defaultTopic
	print("Sending message " .. message)
	mqttClient:publish(topic,message,0,0, function(client) end)

end



return MQTT
