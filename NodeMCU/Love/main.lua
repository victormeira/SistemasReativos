local mqtt = require("mqtt_library")

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function print_list_list(list)

for i = 1, #list, 1 do
  for j = 1, #list, 1 do
    print(list[i][j])
  end
end

end

function split_message(message)
  
  local list_1 = {}
  local list_2 = {{}}

  --Splita a string message pelo ;
  list_1 = split(message, ";")
  
  for i = 1, #list_1, 1 do
    list_2[i] = split(list_1[i], ",")
  end
  
  print_list_list(list_2)
  
end

function mqttcb(topic, message)
  
  split_message(message)
  
end

function love.keypressed(key)
  if key == 'a' then
    mqtt_client:publish("requestData", "Requesting location")
  end
end

function love.load()

  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("MiniProjeto-MatheusEVictor")
  mqtt_client:subscribe({"locationData"})
end

function love.draw()

end

function love.update(dt)
  mqtt_client:handler()
end


--split_message("a:1,a:2,a:3;b:1,b:2,b:3;c:1,c:2,c:3;d:1,d:2,d:3")