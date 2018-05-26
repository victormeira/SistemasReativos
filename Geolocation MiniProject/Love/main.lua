local mqtt = require("mqtt_library")
local https = require("ssl.https")
local latitude = 0
local longitude = 0
local precisao = 0
local address_json = ''
local mode = -1  -- mode -1: initial; mode 0: waiting for location; mode 1: success; mode 2: waiting for address; mode -2: failed location

--https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY

function findAddress()
  
  url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' .. latitude .. ',' .. longitude ..'&key=AIzaSyA5Z5xai0SkBDbbjHueWLggvXvV_rLMG5E&result_type=street_address'
  
  
  local body, code, headers, status = https.request(url)
  
  address_json = body
  
  local addStart, addEnd = string.find(body,"formatted_address")
  local geoStart, geoEnd = string.find(body,"geometry")
  
  if(addStart == nil or geoStart == nil) then
    address_json = "No address found."
  else
    address_json = string.sub(body, addEnd + 6, geoStart - 14)
  end
  
  filename = "address-".. os.date('%d_%m_%y %H_%M.txt')
  -- Opens a file in append mode
  file = io.open(filename, "w")

  -- sets the default output file as test.lua
  io.output(file)

  -- appends a word test to the last line of the file
  io.write(address_json)

  -- closes the open file
  io.close(file)
  
  modo = 3
  
end


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
  if key == 'd' then
    mode = 2
    findAddress()
  end
  
end

function love.load()
  
  WIDTH = 200
  HEIGHT = 100
  
  love.window.setMode(WIDTH,HEIGHT)
  love.window.setTitle("People Locator")

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("MiniProjeto-MatheusEVictor-Love123")
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
    love.graphics.print("Press A for location.", 10,70)
  elseif(mode == 1) then
    love.graphics.print("Press D for address.", 10,80)
  elseif(mode == 0) then
    love.graphics.print("Waiting for location data.", 10,70)
  elseif(mode == 2) then
    love.graphics.print("Waiting for address data.", 10,70)
  elseif(mode == -2) then
    love.graphics.print("Request failed.", 10,70)
  elseif(mode == 3) then
    love.graphics.print("New address file created.", 10,70)
  end

end

function love.update(dt)
  mqtt_client:handler()
end