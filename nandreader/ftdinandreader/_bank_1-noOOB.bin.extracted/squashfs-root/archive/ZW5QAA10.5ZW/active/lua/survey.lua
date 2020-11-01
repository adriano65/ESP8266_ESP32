local xmlStr = "<ROOT>"
local xmlFile = ""

--Change the number of rssi to signal level
local function rssiToLevel(rssi)
    local result = 0
    if rssi>=0 then
        result = 0
    elseif rssi>=-55 then
        result = 5
    elseif rssi>=-65 then
        result = 4
    elseif rssi>=-75 then
        result = 3
    elseif rssi>=-80 then
        result = 2
    elseif rssi>=-85 then
        result = 1
    end

    return result+1
end

local function writeSurveyToXmlFile()
  local reply, error =  mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name _PROD_SERIAL_NBR)" }
  local sn = reply["ENV"][1].param["Value"]
  reply, error =  mbus.getParameters{ path = "Time", param = "DateTime" }
  local datetime = reply["Time"][1].param["DateTime"]
  datetime = string.gsub(datetime, ":", "")

  xmlFile = tostring(sn .. "_wifisurvey_" .. datetime .. ".xml")
  local fh = io.open ("/tmp/" .. xmlFile, "w")
  if fh~=nil then
    local xmlStart="\<?xml version=\"1.0\" encoding=\"UTF-8\"?\>"
    fh:write(xmlStart .. tostring(xmlStr))
    fh:close()
  end

  reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_File_2)"}
  mbus.modify(
    function()
      if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil and reply["ENV"][1].param["Value"]~=nil then
        mbus.setParameters{path = "ENV", param = {Value = xmlFile}, filter = "(== Name %Vendor_Log_File_2)" }
      else
        mbus.addObjects{path = "ENV", param = {Name = "%Vendor_Log_File_2", Value = xmlFile} }
      end
    end)
end

ret, error = mbus.getParameters{ path = "WLAN.Intf", param= "Status" }
if ret["WLAN.Intf"][1].param["Status"]~="enabled" and ret["WLAN.Intf"][2].param["Status"]~="enabled" then
  return "NOK"
end

local scanList = {}
local strfind = string.find
local WIntfPath
for n=1, 3, 2 do
  if ret["WLAN.Intf"][n].param["Status"] == "enabled" then
    if n==1 then
        WIntfPath ="WLAN.Intf.wlif1"
    elseif n==2 then
        WIntfPath="WLAN.Intf.wl_ssid1_local0"
    elseif n==3 then
        WIntfPath="WLAN.Intf.wle_radio1_ssid0"
    elseif n==4 then
        WIntfPath="WLAN.Intf.wle_radio1_ssid1"
    end

    local acs_path = WIntfPath .. ".ACS"
    mbus.modify(
      function()
        mbus.setParameters{ path = acs_path, param= {Rescan="1"} }
      end)
    
    local wlan_acs_data, error = mbus.getParameters{ path = acs_path, param= "BssList" ,flags="KEYPATH"}
    local apList_T = wlan_acs_data[acs_path][1].param["BssList"]
    local freqVal = "2.4GHz"
    local networkVal = table.concat({"b", "g", "n"}, ",")

    -- Fix for TESSA 496 Scan Wi-Fi from ACS is not showing 5 Ghz networks
    -- 5 GHz networks and missed information network type are added to the xml file 

    if n==3 then 
	freqVal = "5GHz" 
	networkVal = table.concat({"a", "n"}, ",")
    end
 
 if apList_T ~= nil then
    for apList in string.gmatch(apList_T, "([^;]+)") do
     if apList ~= nil then
      for bssidVal,ssidVal,channelVal,rssiVal, secmode, unknown in string.gmatch(apList, "([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)") do
        local privacyVal = "False"
        local authVal = "Open"
        local s, e = strfind(secmode, "WEP")
        if s ~= nil then
          privacyVal = "True"
        else
          s, e = strfind(secmode, "WPA")
          if s ~= nil then
            privacyVal = "True"
            authVal = "WPA/WPA2"
          end
        end
        table.insert(scanList, {ssid=ssidVal, channel=channelVal, bssid=bssidVal, rssi=rssiVal, frequency=freqVal, privacy=privacyVal, auth=authVal, network=networkVal})
      end
     end
    end
   end 
  end
end

xmlStr = xmlStr .. "<NearWLANNumberofentries>" .. #scanList .. "</NearWLANNumberofentries>"

if #scanList > 0 then
  for i,v in pairs(scanList) do
    local level = rssiToLevel(tonumber(v["rssi"]))
    xmlStr = xmlStr .. "<NearWLAN id=\"" .. i .. "\">"
    xmlStr = xmlStr .. "<SSID>" .. v["ssid"] .. "</SSID>"
    xmlStr = xmlStr .. "<PrivacyEnabled>" .. v["privacy"] .. "</PrivacyEnabled>"
    xmlStr = xmlStr .. "<Authentication>" .. v["auth"] .. "</Authentication>"
    xmlStr = xmlStr .. "<BSSID>" .. v["bssid"] .. "</BSSID>"
    xmlStr = xmlStr .. "<Channel>" .. v["channel"] .. "</Channel>"
    xmlStr = xmlStr .. "<Frequency>" .. v["frequency"] .. "</Frequency>"
    xmlStr = xmlStr .. "<PowerLevel>" .. level .. "</PowerLevel>"

    -- Adding the Network Type information to the WiFi Survey xml file

    xmlStr = xmlStr .. "<NetworkType>" .. v["network"] .. "</NetworkType>"
    xmlStr = xmlStr .. "</NearWLAN>"
  end
end

xmlStr = xmlStr .. "</ROOT>"
writeSurveyToXmlFile()

return "OK"
