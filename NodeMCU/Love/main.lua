local mqtt = require("mqtt_library")
local latitude = 0
local longitude = 0
local precisao = 0

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end


function split_message(message)
  
  local list_1 = {}

  --Splita a string message pelo ;
  list_1 = split(message, ";")
  
  latitude = list_1[1]
  longitude = list_1[2]
  precisao = list_1[3]
  
end

function mqttcb(topic, message)
  
  split_message(message)
  
end

function love.keypressed(key)
  if key == 'a' then
    latitude = 10
    mqtt_client:publish("requestData", "A")
  end
end

function love.load()
  
  WIDTH = 500
  HEIGHT = 500
  
  love.window.setMode(WIDTH,HEIGHT)

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("MiniProjeto-MatheusEVictor-Love8")
  mqtt_client:subscribe({"locationData"})
  
  
end

function love.draw()
  love.graphics.print("Latitude: ", 10,10)
  love.graphics.print(latitude, 80,10)
  love.graphics.print("Longitude: ", 10,30)
  love.graphics.print(longitude, 80,30)
  love.graphics.print("Precisão: ", 10,50)
  love.graphics.print(precisao, 80,50)
end

function love.update(dt)
  mqtt_client:handler()
end

