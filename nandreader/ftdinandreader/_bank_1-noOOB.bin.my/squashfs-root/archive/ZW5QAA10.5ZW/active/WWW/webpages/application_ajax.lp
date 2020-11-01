<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/portmap.lp")
cgilua.lp.include("lp/usb.lp")
local QUERY = cgilua.QUERY
local print = cgilua.print
local tprint = require("tableprint")
if QUERY["isUSB"] == "true" then
        if QUERY["rmacess"] == "true" then
                local flag = "true"
                local usbname = QUERY["usbNames"]
                local usblist = get_usb_list_home()
                if usblist ~= nil then
                        for i=1,#usblist do
                                if usbname == usblist[i].device_name then
                                        flag = "false"
                                end
                        end
                end
                print(flag)
        else
                print(validateUSBStatus(QUERY["usbNames"]))
        end
else
	local APP_path = "NATAppList.App."
	local rulePath = APP_path .. tostring(QUERY["pathId"]) .. ".Rule"
	local ruleList, error = getList(rulePath, nil, "Protocol", "InboundPort", "OutboundPort", "OutboundPortRangeEnd")
	local internalRange, externalRange, protocol = getInternalAndExternal(ruleList)
	print(internalRange.."##"..externalRange.."##"..protocol)
end
%>

