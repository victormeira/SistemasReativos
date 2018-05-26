

http.get("http://www.inf.puc-rio.br/~noemi/sr-18/",0,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed :", code)
    else
      print(code, data)
    end
  end)

