require("i2c")
require("TelegramBot")

MQTT_SERV   = "io.adafruit.com"
MQTT_PORT   = 1883
MQTT_NAME   = "rokane21"
MQTT_PASS   = "4ed557abd7af43a1bfcfaf83182f36f0"
MQTT_TIME   = 120
MQTT_TOPC   = "rokane21/feeds/assistantfeed"

function messageReceivedCallback(client)
    local function messageTreatment(userdata, topic, message)
        print("Received message:", message)
        if message == "metal" then
            sendToTelegram("The state of the metal sensor is ".. _G.metal)
        elseif message == "button" then
            sendToTelegram("The state of the button is ".. _G.button) 
        elseif message == "optic" then
            sendToTelegram("The state of the optic sensor is ".. _G.optic)
        elseif message == "hall" then
            sendToTelegram("The state of the hall sensor is ".. _G.hall)   
        elseif string.find(message,"led") then
            --led<num><act> from MQTT
            lednum = string.sub(message,4,4)
            ledact = string.sub(message,6,6)
            writeToArduino("l"..lednum..ledact)
            print("l"..lednum..ledact)  
        end                 
    end

    client:on("message",messageTreatment)
end


-- Reconnect to MQTT when we receive an "offline" message.

function reconn()
    print("Disconnected, reconnecting....")
    conn()
end


-- Establish a connection to the MQTT broker with the configured parameters.

function conn()
    print("Making connection to MQTT broker")
    mqttBroker:connect(MQTT_SERV, MQTT_PORT, 0, 
        function(client) 
            print ("connected")
            mqttBroker:subscribe(MQTT_TOPC, 0, messageReceivedCallback) 
        end,
        function(client, reason) print("failed reason: "..reason) end)
end



function makeConn()
    -- Instantiate a global MQTT client object
    print("Initiating mqttBroker")
    mqttBroker = mqtt.Client("nodemcu", MQTT_TIME, MQTT_NAME, MQTT_PASS, 1)

    -- Set up the event callbacks
    print("Setting up callbacks")
    mqttBroker:on("connect", function(client) print ("connected") end)
    mqttBroker:on("offline", reconn)

    -- Connect to the Broker
    conn()

    -- Use the watchdog to call our sensor publication routine
    -- every dataInt seconds to send the sensor data to the 
    -- appropriate topic in MQTT.
    --tmr.alarm(0, (dataInt * 1000), 1, pubEvent)
end
