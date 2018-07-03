
require("TelegramBot")
require("googleAssist")
require("arduinoComm")
require("webServer")

--sendToTelegram("HELLO TEST")
makeConn()
upServer()

local myTimer = tmr.create()
myTimer:register(1000, tmr.ALARM_AUTO, reloadSensorData)
myTimer:start()
