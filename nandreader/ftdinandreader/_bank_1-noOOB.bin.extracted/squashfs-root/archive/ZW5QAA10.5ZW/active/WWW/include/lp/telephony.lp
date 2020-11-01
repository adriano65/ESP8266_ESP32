<%
--get telephony info


local VoicePath = "Voice.Profile"

function get_Handsets() 
  local result = {}
  local num = 0

  local reply, error =  mbus.getParameters{path = "Voice.DECT.Handset", param = {"Status", "TerminalName", "SoftwareVersion", "LastUpdatedTime","Port", "EMC"}}
  for i, v in pairs(reply["Voice.DECT.Handset"]) do
    if (v.param["Status"]=="Subscribed") or (v.param["Status"]=="InRange") or (v.param["Status"]=="Upgrading") then
        num = num + 1
        result[num] = {}
        local slot_path=v.param["Port"]
        local slot, slot_error= mbus.getParameters{path=slot_path, param="Number"}
        local ifnum=slot[slot_path][1].param["Number"]
        if v.param["EMC"]=="" or v.param["EMC"]=="0000" then
          result[num].name="Handset " ..ifnum 
        else
          if v.param["TerminalName"]=="" then
            result[num].name = ifnum ..": Hub Phone " ..ifnum 
          else
            result[num].name = ifnum .. ": " .. v.param["TerminalName"]
          end
        end

        result[num].version = v.param["SoftwareVersion"]
        local timestr = v.param["LastUpdatedTime"]
        if (timestr~=nil) then
            result[num].lastupdate = string.sub(timestr, 9, 10).."/"..string.sub(timestr, 6, 7).."/"..string.sub(timestr, 1, 4)
        else
            result[num].lastupdate = "-"
        end    
    end
  end
  
  return result, num
end


function changeURI(uri)
    local result = uri
    if (uri==nil) then
        result = ""
    elseif (string.len(uri)>2) and (string.sub(uri, 1, 2)=="44") then
        result = "0"..string.sub(uri, 3)
    end    
    return result
end


function get_Telephony()  
  local result = {}  
  result.havehandset = 0
  result.havebbt = 0
  result.uri, result.fxodest = "", ""
  result.status = 'There is no Broadband Talk account associated with your Home Hub.'
    
  local reply, error =  mbus.getParameters{ path = VoicePath, param = {"URI", "Status"} }
  
  if (reply[VoicePath][1]~=nil) then
    for i, v in pairs(reply[VoicePath]) do
        if (v.param["URI"]~=nil) and (v.param["URI"]~="default_uri") then
            result.havebbt = 1
            result.uri = changeURI(v.param["URI"])
            result.status = v.param["Status"]
            break
        end
    end
  end 
  
  reply, error =  mbus.getParameters{path = "Voice.FXO", param = "IncomingFXODest"}
  if (reply["Voice.FXO"][1]~=nil) then
    result.fxodest = reply["Voice.FXO"][1].param["IncomingFXODest"]
  end
  
  reply, error =  mbus.getParameters{path = "Voice.DECT.Handset", param = "Status"}
  for i, v in pairs(reply["Voice.DECT.Handset"]) do
    if (v.param["Status"]=="Subscribed") or (v.param["Status"]=="InRange") or (v.param["Status"]=="Upgrading") then
        result.havehandset = 1
        break
    end
  end

  return result
end


function getBBT(disable_str, status_str)
  local result = {}
  local count = 0
  local active = 0
  local enable = 0
  local errstatus = "Service temporarily unavailable"
  if status_str~=nil then
    errstatus = status_str
  end
  
  local voice_data, error = mbus.getParameters{path=VoicePath, param={"URI", "Enable", "Status"}}

  if #voice_data[VoicePath] > 0 then
    for i,v in pairs(voice_data[VoicePath]) do
        if (v.param["URI"]~=nil) and (v.param["URI"]~="default_uri") then
            active = 1
            count = count+1
            result[count] = {}      -- add a new table area
            result[count].path = v.path
            result[count].uri = changeURI(v.param["URI"])
                            
            if v.param["Status"] == "Up" then
                result[count].status = "Connected"
            else
                result[count].status = errstatus
            end   -- end status convert
                   
            if (v.param["Enable"]=="1") then
                enable = 1
            else
                if (disable_str~=nil) and (disable_str~="") then
                    result[count].status = disable_str
                end
            end
        end
    end     -- end loop
  end
  
  return result, active, enable
end
%>
