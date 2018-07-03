

function sendToTelegram(messageText)

    webHooksKey = "cB2Z3ma0b6FHUsDl0AVF_vm7mCMmg0ftj9ohwbwDsBH"
    event = "nodeMCURequest"
    address = "http://maker.ifttt.com/trigger/" .. event .. "/with/key/" .. webHooksKey

    postData = [[ {"value1": "]] .. messageText .. [["  }  ]]

    local numberOfTries = 5
        local function callbackPost(code,data)
            if (code < 0) then
                print("HTTP request failed :", code)
                numberOfTries = numberOfTries - 1
                print("Number of remaining tries: " .. numberOfTries)
                tmr.delay(1000000)
                if(numberOfTries > 0) then
                       http.post(address, 'Content-Type: application/json\r\n',postData, callbackPost)
                end
            else
                print(code, data)   
            end
        end
   print(address, postData)
   http.post(address, 'Content-Type: application/json\r\n',postData, callbackPost)
end
