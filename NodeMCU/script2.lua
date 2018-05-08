

http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyB_PcDv6uslYq0Z1EuyiHHUFrPIFU56eCA',
  'Content-Type: application/json\r\n',[[ { "wifiAccessPoints": [{ "macAddress": "f4:6d:04:5d:75:bc"},{ "macAddress": "f8:1a:67:a4:bc:80"},{ "macAddress": "98:fc:11:d0:a8:36"},{ "macAddress": "64:e9:50:11:df:50"},{ "macAddress": "64:70:02:93:e4:44"},{ "macAddress": "64:e9:50:11:df:51"},{ "macAddress": "c0:25:e9:bb:fb:36"}]}]],
  function(code, data)
    if (code < 0) then
      print("HTTP request failed :", code)
    else
      print(code, data)
    end
  end)

