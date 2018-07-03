id  = 0
sda = 5
scl = 4
dev_addr = 0x77
led1 = 6
led2 = 3
ledstate = 0

-- split a string
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end


function parseSensorString(payload)
    --h 1;o 0;b 0;m 0;110
    sensorTable = split(payload,";")
    hallValue = string.sub(sensorTable[1],3,3)
    opticValue = string.sub(sensorTable[2],3,3)
    buttonValue = string.sub(sensorTable[3],3,3)
    metalValue = string.sub(sensorTable[4],3,3)
    ledsState = sensorTable[5]
    
    if hallValue == "0" then
        _G.hall = "NO CURRENT"
    else
        _G.hall = "CURRENT DETECTED"
    end
    
    if opticValue == "0" then
        _G.optic = "BRIGHT"
    else
        _G.optic = "DARK"
    end
    
    if buttonValue == "0" then
        _G.button = "NOT PRESSED"
    else
        _G.button = "PRESSED"
    end
    
    if metalValue == "0" then
        _G.metal = "NO CONTACT"
    else
        _G.metal = "CONTACT"
    end

    if string.sub(ledsState,1,1) == "0" then
        _G.led1 = "OFF"
    else
        _G.led1 = "ON"
    end

    if string.sub(ledsState,2,2) == "0" then
        _G.led2 = "OFF"
    else
        _G.led2 = "ON"
    end

    if string.sub(ledsState,3,3) == "0" then
        _G.led3 = "OFF"
    else
        _G.led3 = "ON"
    end    
end

-- initialize i2c, set pin1 as sda, set pin2 as scl
i2c.setup(id, sda, scl, i2c.SLOW)

function writeToArduino(data)
    print(data)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(0, data)
    i2c.stop(id)
end

function readFromArduino(bytes)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    data = i2c.read(id, bytes)
    i2c.stop(id)
    return data
end

function reloadSensorData()
    if ledstate == 0 then
        ledstate = 1
        gpio.write  (led1, gpio.HIGH)
        gpio.write  (led2, gpio.LOW)
    else
        ledstate = 0
        gpio.write  (led1, gpio.LOW)
        gpio.write  (led2, gpio.HIGH)
    end
    
    writeToArduino("req")
    sensorString = readFromArduino(20)
    print(sensorString)
    parseSensorString(sensorString) 
end
