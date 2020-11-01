local xmlStr = ""
local xmlFile = ""

local function mysplit(inputstr, sep)
  local t={} 
  local i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end


local function writeChanMeasDataToXmlFile()
  local reply, error =  mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name _PROD_SERIAL_NBR)" }
  local sn = reply["ENV"][1].param["Value"]
  reply, error =  mbus.getParameters{ path = "Time", param = "DateTime" }
  local datetime = reply["Time"][1].param["DateTime"]
  datetime = string.gsub(datetime, ":", "")

  xmlFile = tostring(sn .. "_channelmeasurements_" .. datetime .. ".xml")
  local fh = io.open ("/tmp/" .. xmlFile, "w")
  if fh~=nil then
    local xmlStart="\<?xml version=\"1.0\" encoding=\"UTF-8\"?\>\n"
    fh:write(xmlStart .. tostring(xmlStr))
    fh:close()
  end

  reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_File_4)"}
  mbus.modify(
    function()
      if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil and reply["ENV"][1].param["Value"]~=nil then
        mbus.setParameters{path = "ENV", param = {Value = xmlFile}, filter = "(== Name %Vendor_Log_File_4)" }
      else
        mbus.addObjects{path = "ENV", param = {Name = "%Vendor_Log_File_4", Value = xmlFile} }
      end
    end)

end

ret, error = mbus.getParameters{ path = "WLAN.Intf", param= "RadioEnable" }
if ret["WLAN.Intf"][1].param["RadioEnable"]~="true" and ret["WLAN.Intf"][3].param["RadioEnable"]~="true" then
  return "NOK"
end


local radioinfoList = {}
local avlblchanneldataList_24ghz = {}
local samplesdataList_24ghz = {}
local avlblchanneldataList_5ghz = {}
local samplesdataList_5ghz = {}
local measdurationVal = 0
local WIntfPath
for n=1, 3, 2 do
  if ret["WLAN.Intf"][n].param["RadioEnable"] == "true" then
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
    local wlan_acs_data, error = mbus.getParameters{ path = acs_path, param= "ChanMeasData",flags="KEYPATH" }
    local chanmeasdataList = wlan_acs_data[acs_path][1].param["ChanMeasData"]

    if chanmeasdataList == "ERROR: Channel measurement data not available" then
      return "NOK"
    end

    local avlblchanneldataList = avlblchanneldataList_24ghz
    if n==3 then avlblchanneldataList = avlblchanneldataList_5ghz end

    local samplesdataList = samplesdataList_24ghz
    if n==3 then samplesdataList = samplesdataList_5ghz end

    --Channel measurement data will occur in the following format
    --avlblchannelcount:measduration:channum1,chanload1,noisepower1;channum2,chanload2,noisepower2;...channumN,chanloadN,noisepowerN:currchannelnum:currchannelmeasduration:samplingperiod:numsamples:chanload1,noisepwr1;chanload2,noisepwr2;...chanloadM,noiseprwM
    for avlblchannelcountVal, measdurationVal,avlblchanneldata,currchannelnumVal,currchannelmeasdurationVal,samplingperiodVal,numsamplesVal,samplesdata  in string.gmatch( chanmeasdataList, "([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)") do
      local temp1 = {}
      temp1 = mysplit(avlblchanneldata, ";")
      for i,v in ipairs(temp1) do
        local temp2 = {}
        temp2 = mysplit(v,",")
        table.insert(avlblchanneldataList, {channelnum=temp2[1], channelload=temp2[2], noisepower=temp2[3]})
      end

      temp1 = {}
      temp1 = mysplit(samplesdata, ";")
      for i,v in ipairs(temp1) do
        local temp2 = {}
        temp2 = mysplit(v,",")
        table.insert(samplesdataList, {channelload=temp2[1], noisepower=temp2[2]})
      end
      
      table.insert(radioinfoList, {currchannelnum=currchannelnumVal, currchannelmeasduration=currchannelmeasdurationVal, samplingperiod=samplingperiodVal, numsamples=numsamplesVal, samplesData_T=samplesdataList})
    end
  end
end

local avlblchancount = (#avlblchanneldataList_24ghz+#avlblchanneldataList_5ghz)

xmlStr = xmlStr .. "\t<WiFiChannelMeasurements>\n"
xmlStr = xmlStr .. "\t\t<SupportedChannelsNumberOfEntries>" .. avlblchancount .. "</SupportedChannelsNumberOfEntries>\n"
xmlStr = xmlStr .. "\t\t<OperatingChannelNumberOfEntries>" .. #radioinfoList .. "</OperatingChannelNumberOfEntries>\n"

local count = 1

for n=1, 3, 2 do
  local avlblchanneldataList = avlblchanneldataList_24ghz
  if n==3 then avlblchanneldataList = avlblchanneldataList_5ghz end
  if #avlblchanneldataList > 0 then
    for i,v in pairs(avlblchanneldataList) do
      xmlStr = xmlStr .. "\t\t<SupportedChannels id=\"" .. count .. "\">\n"
      xmlStr = xmlStr .. "\t\t\t<Channel>" .. v["channelnum"] .. "</Channel>\n"
      xmlStr = xmlStr .. "\t\t\t<MeasDuration>" .. measdurationVal .. "</MeasDuration>\n"
      xmlStr = xmlStr .. "\t\t\t<ChannelLoad>" .. v["channelload"] .. "</ChannelLoad>\n"
      xmlStr = xmlStr .. "\t\t\t<NoisePower>" .. v["noisepower"] .. "</NoisePower>\n"
      xmlStr = xmlStr .. "\t\t</SupportedChannels>\n"
      count = count + 1
    end
  end
end


if #radioinfoList > 0 then
  for i,v in pairs(radioinfoList) do
    local samplesdataList = v["samplesData_T"]

    xmlStr = xmlStr .. "\t\t<OperatingChannel id=\"" .. i .. "\">\n"
    xmlStr = xmlStr .. "\t\t\t<Channel>" .. v["currchannelnum"] .. "</Channel>\n"
    xmlStr = xmlStr .. "\t\t\t<MeasDuration>" .. v["currchannelmeasduration"] .. "</MeasDuration>\n"
    xmlStr = xmlStr .. "\t\t\t<MeasSamplingPeriod>" .. v["samplingperiod"] .. "</MeasSamplingPeriod>\n"
    xmlStr = xmlStr .. "\t\t\t<MeasNumberOfEntries>" .. v["numsamples"] .. "</MeasNumberOfEntries>\n"

    if #samplesdataList > 0 then
      for k,s in pairs(samplesdataList) do
        xmlStr = xmlStr .. "\t\t\t<Meas id=\"" .. k .. "\">\n"
        xmlStr = xmlStr .. "\t\t\t\t<ChannelLoad>" .. s["channelload"] .. "</ChannelLoad>\n"
        xmlStr = xmlStr .. "\t\t\t\t<NoisePower>" .. s["noisepower"] .. "</NoisePower>\n"
        xmlStr = xmlStr .. "\t\t\t</Meas>\n"
      end 
    end
    xmlStr = xmlStr .. "\t\t</OperatingChannel>\n"
  end
end



 xmlStr = xmlStr .. "\t</WiFiChannelMeasurements>\n"
writeChanMeasDataToXmlFile()

return "OK"
