local mqtt = require("mqtt_library")
local latitude = 0
local longitude = 0
local precisao = 0
local mode = -1  -- mode -1: initial; mode 0: waiting for location; mode 1: success; mode 2: waiting for address; mode -2: failed location

--https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY

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
  if(message == "Failure") then
    mode = -2
  else
    split_message(message)
  end
  
end

function love.keypressed(key)
  if key == 'a' then
    mode = 0
    mqtt_client:publish("requestData", "Requesting location")
  end
end

function love.load()
  
  WIDTH = 200
  HEIGHT = 150
  
  love.window.setMode(WIDTH,HEIGHT)

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("MiniProjeto-MatheusEVictor-Love8")
  mqtt_client:subscribe({"locationData"})
  
  
end

function love.draw()
  love.graphics.print("Latitude: ", 10,10)
  love.graphics.print("Longitude: ", 10,30)
  love.graphics.print("Precisão: ", 10,50)
  
  if(mode == 1) then
    love.graphics.print(latitude, 80,10)
    love.graphics.print(longitude, 80,30)
    love.graphics.print(precisao, 80,50)
  else
    love.graphics.print("-----", 80,10)
    love.graphics.print("-----", 80,30)
    love.graphics.print("-----", 80,50)
  end

  if(mode == -1) then
    love.graphics.print("Press A for location.", 80,80)
  elseif(mode == 1) then
    love.graphics.print("Success.", 80,80)
  elseif(mode == 0) then
    love.graphics.print("Waiting for location data.", 80,80)
  elseif(mode == 2) then
    love.graphics.print("Waiting for address data.", 80,80)
  elseif(mode == -2) then
    love.graphics.print("Request failed.", 80,80)
  end

end

function love.update(dt)
  mqtt_client:handler()
end

