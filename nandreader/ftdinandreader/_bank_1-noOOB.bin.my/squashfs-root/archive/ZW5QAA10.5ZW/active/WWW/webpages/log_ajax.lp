<%
	cgilua.lp.include("lp/usb.lp")
	local isUsbDisconnected = "true";
	local cs_state, cs_name = get_cs_state()
	local usbdisk_info
	if cs_state == "true" then
	    usbdisk_info = get_usbdisk_info()
	end
	
	if usbdisk_info ~= nil then
		isUsbDisconnected = "false";
	end
	
	cgilua.print(isUsbDisconnected);
%>
