<%
-- get PPP info by mbus path,  came is mbus path

function getPPP(cname)
    local result={}
    local reply, error = mbus.getParameters{path = cname, param = {"Name"}}

    if error~=nil then
       return nil 
    end

    local reply, error = mbus.getParameters{path = cname, param = {"Name", "TI_Enable", "Status", "PPPStatus", "LastConnectionError", "Uptime", "ReceivedLocalAddress", "ReceivedRemoteAddress", "PrimDNSServer", "SecDNSServer", "Password", "NATStartIPAddress","NATEndIPAddress","ConnectionTrigger"}}
    result.ppp_path = cname
    result.name = reply[cname][1].param["Name"]    
    result.enable = reply[cname][1].param["TI_Enable"]
    result.status = reply[cname][1].param["Status"]
    result.ppp_error = reply[cname][1].param["LastConnectionError"]
    result.ppp_status = reply[cname][1].param["PPPStatus"]
    result.ipaddr = reply[cname][1].param["ReceivedLocalAddress"]
    result.gateway = reply[cname][1].param["ReceivedRemoteAddress"]
    result.primdns = reply[cname][1].param["PrimDNSServer"]
    result.secdns = reply[cname][1].param["SecDNSServer"]
    result.pw = reply[cname][1].param["Password"]
    result.ppp_user = result.username
    result.natStartIPAddress = reply[cname][1].param["NATStartIPAddress"]
    result.natEndIPAddress = reply[cname][1].param["NATEndIPAddress"]  
    result.uptime = "0"
    if result.ppp_status=="Connected" then
       result.uptime = reply[cname][1].param["Uptime"] 
    end

    if result.name == "ppp_0" then 
    	result.name = "User session"
    end

    result.connectionTrigger = reply[cname][1].param["ConnectionTrigger"]

    reply, error = mbus.getParameters{ path = "IP.Intf",filter = "(== LowerIntf "..cname..")" } 
    result.ipintf = reply["IP.Intf"][1].path

    reply, error = mbus.getParameters{ path = result.ipintf..".Stats", param = {"TxBytes", "RxBytes","TxBytesHigh", "RxBytesHigh", "RxBCPackets", "RxUCPackets", "RxMCPackets", "TxBCPackets", "TxUCPackets", "TxMCPackets"} }
    result.datasent = reply[result.ipintf..".Stats"][1].param["TxBytes"]
    result.datasentH = reply[result.ipintf..".Stats"][1].param["TxBytesHigh"]
    result.datarecv = reply[result.ipintf..".Stats"][1].param["RxBytes"]
    result.datarecvH = reply[result.ipintf..".Stats"][1].param["RxBytesHigh"] 
    result.ethPacketsReceived = reply[result.ipintf..".Stats"][1].param["RxBCPackets"] + reply[result.ipintf..".Stats"][1].param["RxUCPackets"] + reply[result.ipintf..".Stats"][1].param["RxMCPackets"]
    result.ethPacketsSent = reply[result.ipintf..".Stats"][1].param["TxBCPackets"] + reply[result.ipintf..".Stats"][1].param["TxUCPackets"] + reply[result.ipintf..".Stats"][1].param["TxMCPackets"]      	
     

    return result
end

function getDevice_PPP()
	local result={}
	local reply, error = mbus.getParameters{path = "Device.PPP.Interface.2", param = {"Name","Status","ConnectionTrigger","Enable","ConnectionStatus"} ,datamodel = "second"}	 
	result.name = reply["Device.PPP.Interface.2"][1].param["Name"] 
	result.status = reply["Device.PPP.Interface.2"][1].param["Status"] 
	result.connectionTrigger = reply["Device.PPP.Interface.2"][1].param["ConnectionTrigger"] 
	result.enable = reply["Device.PPP.Interface.2"][1].param["Enable"]
	result.connectionStatus = reply["Device.PPP.Interface.2"][1].param["ConnectionStatus"]
	
	return result
end
%>

