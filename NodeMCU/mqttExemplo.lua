local meuid = "preenchercomsuamatricula"
local m = mqtt.Client("clientid " .. meuid, 120)

function publica(c)
  c:publish("puc-rio-inf1805","alo de " .. meuid,0,0, 
            function(client) print("mandou!") end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  publica(client)
  client:subscribe("puc-rio-inf1805", 0, novaInscricao)
end 

m:connect("test.mosquitto.org", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)



        


