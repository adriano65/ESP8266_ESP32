<%
require "lfs"

--Get the state of media server content sharing
function get_media_cs_state()
    local cs_name = "modemtelecom"
    local cs_path = "ContentSharing.UPnPAV"
    local data, error = mbus.getParameters{path = cs_path, param = {"Enable", "ServerFriendlyName"}}
    if data[cs_path][1].param["ServerFriendlyName"]~="" then
        cs_name = data[cs_path][1].param["ServerFriendlyName"]
    end
    return data[cs_path][1].param["Enable"], cs_name
end

--Get the state of content sharing
function get_cs_state()
    local cs_name = "modemtelecom"
    local cs_path = "ContentSharing.CIFS"
    local data, error = mbus.getParameters{path = cs_path, param = {"Enable", "ServerName"}}   
    if data[cs_path][1].param["ServerName"]~="" then
        cs_name = data[cs_path][1].param["ServerName"]
    end
    return data[cs_path][1].param["Enable"], cs_name
end

--get the state of print server 
function get_ps_state()	
	local envPath, envState = read_print_server_state()
	if envState~="" then
		return envState
	else
		local synState = syn_ps_state()
		add_env_state(envPath, synState)
		return synState
	end
end

--synchronized the print server state
function syn_ps_state()
	local ps_path = "PrinterSharing.LPD"
	local data, error = mbus.getParameters{path = ps_path, param = "Enable"}
	return data[ps_path][1].param["Enable"]
end

--Judge whether the print server is exist, if it exist then return its path.
function read_print_server_state()
	local envPath = "ENV"
	local envState = ""
	local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %PS_GUI_STATE)"}
	if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
		envPath = reply["ENV"][1].path
		if reply["ENV"][1].param["Value"]~="none" then
			envState = reply["ENV"][1].param["Value"]
		end
		return envPath, envState
	end 
	return envPath, envState
end

--Set or add the state of print server to Env
function add_env_state(env_path, ps_state)
     mbus.modify(
        function()
            if env_path=="ENV" then
                mbus.addObjects{path = env_path, param = {Name = "%PS_GUI_STATE", Value = ps_state} }
            else
                mbus.setParameters{path = env_path, param = {Value = ps_state} }
            end
        end)
end

--Get the usb device object
function get_usb_device_obj()
	local usbDevicePath = "USB.Host.1.Device"
	local info, error = mbus.getParameters{path = usbDevicePath}
	return info[usbDevicePath]
end

function storage_script_busy()
	local res = {}
   	res =lfs.attributes("/tmp/storage_script_busy")
	if res == nil then
		return "0"
	else
		return "1"
	end
end

--Get the description of the usb
function get_usb_desc(usbHostPath)
	local usbDesc = ""
	local hostinfo, error, pcall_status, pcall_error
	pcall_status, pcall_error = pcall(
    function()
	local hostinfo, error = mbus.getParameters{path = usbHostPath, param = {"USBDeviceDescription"}}
	if hostinfo[usbHostPath] ~= nil then
		usbDesc = hostinfo[usbHostPath][1].param["USBDeviceDescription"]
	end
	end)
	return usbDesc
end

--Get the usb info for home page
function get_usb_list_home()
	local cs_name = "modemtelecom"
	local sdp = "Storage.Disk"
	local usbInfo = {}

	--if storage_script_busy() == "1" then
	--		return nil
	--end

	local info, error = mbus.getParameters{path = sdp, param = {"Device"}}
	if info[sdp] == nil then
		return nil
	end
	
	local idx = 0		
	for i = 1, #info[sdp] do
		local usbHostPath = info[sdp][i].param["Device"]
		local path = info[sdp][i].path .. ".Partition"
		local part, error = mbus.getParameters{path = path, param = {"DeviceName", "FriendlyName"}}
		if #info[sdp] == 1 and part[path][1] == nil then
			return nil
		end

		for j = 1, #part[path] do
			idx = idx + 1
			--if idx > 5 then
				--return usbInfo
			--end

			usbInfo[idx] = {}
			usbInfo[idx].device_name = part[path][j].param["DeviceName"]
			usbInfo[idx].friendly_name = part[path][j].param["FriendlyName"]
			--If the parts of usb are more than one, it would show the usb description.	
			if #part[path] == 1 then
				usbInfo[idx].friendly_name = get_usb_desc(usbHostPath)
			end
			usbInfo[idx].sharing_addr = "\\\\" .. cs_name .. "\\Disk_" .. string.gsub(usbInfo[idx].device_name, "sd", "")		
		end
	end

	return usbInfo
end

function get_usbdisk_info()
    local cs_name = "modemtelecom"
    local sdp = "Storage.Disk"
    local dn = 1
    local pn = 1
    local sd_info = {}

--	if storage_script_busy() == "1" then
--		return nil
--	end

    local info, error = mbus.getParameters{path = sdp, param = {"DeviceName", "DevNumber", "Device", "CapacityInMBytes"}}
    if #info[sdp]<1 then
        return nil
    end

    for i = 1, #info[sdp] do
        local dev = {}
        local hostinfo = {}
        sd_info[i] = {}
        sd_info[i].part = {}
        dev = info[sdp][i].param["Device"]
        if dev == nil or dev == "" then
			return nil
        end
        hostinfo, error = mbus.getParameters{path = dev, param = {"USBDeviceDescription", "USBVersion"}}

        if info[sdp][i].param["DeviceName"] ~= nil and hostinfo[dev] ~= nil and hostinfo[dev][1] ~= nil and hostinfo[dev][1].param["USBDeviceDescription"] ~= nil and info[sdp][i].param["CapacityInMBytes"] ~= nil then
            sd_info[i].devname = info[sdp][i].param["DeviceName"]
            sd_info[i].description = hostinfo[dev][1].param["USBDeviceDescription"]
            sd_info[i].usbversion = string.gsub(hostinfo[dev][1].param["USBVersion"], ".$", "")
            sd_info[i].total_size = info[sdp][i].param["CapacityInMBytes"]
            sd_info[i].devBusy= info[sdp][i].param["Busy"]
        else
            return nil
        end
        local path = info[sdp][i].path .. ".Partition"
        if path == nil then
            return nil
        end
        local part, error = mbus.getParameters{path = path, param = {"DeviceName", "FriendlyName", "SizeInKBytes", "ErrorMessage", "FreeSpaceInKBytes", "FileSystem", "MountPoint", "ReadOnly"}}
        if #info[sdp] == 1 and part[path][1] == nil then
            return nil
        end
        for j = 1, #part[path] do
            sd_info[i].part[j] = {}
			sd_info[i].part[j].readOnly= part[path][j].param["ReadOnly"]
			sd_info[i].part[j].mount_point = part[path][j].param["MountPoint"]
			sd_info[i].part[j].fstype = part[path][j].param["FileSystem"]
            sd_info[i].part[j].device_name = part[path][j].param["DeviceName"]
            sd_info[i].part[j].friendly_name = part[path][j].param["FriendlyName"]
            sd_info[i].part[j].part_size = part[path][j].param["SizeInKBytes"]/1024
			if sd_info[i].part[j].part_size > 1024 then
				sd_info[i].part[j].part_size = string.format("%.1f", sd_info[i].part[j].part_size/1024) .. " GB"
			else
				sd_info[i].part[j].part_size = string.format("%.1f", sd_info[i].part[j].part_size) .. " MB"
			end

			if tonumber(part[path][j].param["SizeInKBytes"]) > tonumber(part[path][j].param["FreeSpaceInKBytes"]) then
				sd_info[i].part[j].part_used_size = (tonumber(part[path][j].param["SizeInKBytes"]) - tonumber(part[path][j].param["FreeSpaceInKBytes"]))
			else
				sd_info[i].part[j].part_used_size = 0
			end

			if sd_info[i].part[j].part_used_size > (1024*1024) then
				sd_info[i].part[j].part_used_size = string.format("%.1f", sd_info[i].part[j].part_used_size/1024/1024) .. " GB"
			else 
				if sd_info[i].part[j].part_used_size > 1024 then
					sd_info[i].part[j].part_used_size = string.format("%.1f", sd_info[i].part[j].part_used_size/1024) .. " MB"
				else
					sd_info[i].part[j].part_used_size = sd_info[i].part[j].part_used_size .. " KB"
				end
			end
            sd_info[i].part[j].sharing_addr = "\\\\" .. cs_name .. "\\Disk_" .. string.gsub(sd_info[i].part[j].device_name, "sd", "")
            sd_info[i].part[j].sharing_addr_smb = "smb://" .. cs_name .. "/Disk_" .. string.gsub(sd_info[i].part[j].device_name, "sd", "")
            if part[path][j].param["ErrorMessage"] ~= "Mounted successfully" then
                sd_info[i].part[j].ok = 0
            else
                sd_info[i].part[j].ok = 1
            end
        end -- partition loop
    end --disk loop
    return sd_info
end

--Get the print server info which connected to the modem
function get_printer_info()
	local j = 1
	local prinfo = {};	

	local prp = "USB.Host.1.Device"
	local info, error = mbus.getParameters{path = prp}
	    
	for i = 1, #info[prp] do
		local path = info[prp][i].path .. ".Configuration.1.Interface.1"
		local pri, error = mbus.getParameters{path = path, param = "DriverDescription"}
		if pri[path][1].param["DriverDescription"] == "usblp" then
			path = info[prp][i].path
			pri, error = mbus.getParameters{path = path, param = {"Product", "USBDeviceDescription", "DeviceNumber", "USBVersion", "Manufacturer", "SerialNumber"}}
			prinfo[j] = {}
			prinfo[j].description = pri[path][1].param["USBDeviceDescription"]
			prinfo[j].usbversion = pri[path][1].param["USBVersion"]
			prinfo[j].product = pri[path][1].param["Product"]
			prinfo[j].devnum = pri[path][1].param["DeviceNumber"]
 			local manufacturer = pri[path][1].param["Manufacturer"]
			local serialnumber = pri[path][1].param["SerialNumber"]
                        local name = "printer"
                        if ((string.len(manufacturer) > 0) and (string.len(serialnumber) > 0)) then
				name = manufacturer .. "_" .. serialnumber
			end
			name = string.gsub(name, " ", "_")
			local var = string.len(name)
			if (var > 20) then
                       		prinfo[j].name = string.sub(name,0,20)
			else
				prinfo[j].name = name
			end 
			j = j + 1
		end
	end

	if prinfo[1] == nil then
		return nil
	end
    
	return prinfo    
end


--To judge whether the usb is busy or not.
function is_usbdisk_busy(devName)
	local diskPath = "Storage.Disk"
	local devicePath = ""
	local info, error = mbus.getParameters{path = diskPath, param = "Busy", filter = "(== DeviceName " .. devName.. ")"}
	
	if info[diskPath]~=nil then
		devicePath = info[diskPath][1].path
		if info[diskPath][1].param["Busy"]=="true" then
			return true, devicePath
		end
	end

	return false, devicePath
end

--To judge whether the usb is busy or not, when read/write operations is done via GUI.
--Adding write operation i.e., uploading to set the is_usbdisk_busy_GUI flag
--Parameter mode will indicate the mode of operation (download/upload)
--local parameters usbPortOne and usbPortTwo handles the devname, either sda or sda1

function is_usbdisk_busy_GUI(devName)
	local usbPortOne = devName.."1"
	local usbPortTwo = devName
	local fNameWrMode = "/var/tmp/"..usbPortOne.."_w"
	local fPtrWrMode = io.open (tostring(fNameWrMode), "r")
	local fNameRdMode = "/var/tmp/"..usbPortOne
	local fPtrRdMode = io.open (tostring(fNameRdMode), "r")
	local mode = "read"	
        if fPtrWrMode~=nil then
		mode = "write"
		fPtrWrMode:close()
		return true, mode
	end
        if fPtrRdMode~=nil then
		mode = "read"
		fPtrRdMode:close()
		return true, mode
	end
	fNameWrMode = "/var/tmp/"..usbPortTwo.."_w"
	fPtrWrMode = io.open (tostring(fNameWrMode), "r")
	fNameRdMode = "/var/tmp/"..usbPortTwo
	fPtrRdMode = io.open (tostring(fNameRdMode), "r")
        if fPtrWrMode~=nil then
		mode = "write"
		fPtrWrMode:close()
		return true, mode
	end
        if fPtrRdMode~=nil then
		mode = "read"
		fPtrRdMode:close()
		return true, mode
	end
	return false, mode
end


function stop_USB_activity_GUI(devName)
        local usbPortOne = devName.."1"
        local usbPortTwo = devName
        local fNameWrMode = "/var/tmp/"..usbPortOne.."_w"
        local fPtrWrMode = io.open (tostring(fNameWrMode), "r")
        local fNameRdMode = "/var/tmp/"..usbPortOne
        local fPtrRdMode = io.open (tostring(fNameRdMode), "r")
        local mode = "read"
        --tprint("stop_USB_activity_GUI")
        if fPtrWrMode~=nil then
                mode = "write"
                fPtrWrMode:close()
                --tprint("remove for upload")
                --tprint(fNameWrMode)
		os.remove(tostring(fNameWrMode))
                return
        end
        if fPtrRdMode~=nil then
                mode = "read"
                fPtrRdMode:close()
                --tprint("remove for download")
                --tprint(fNameRdMode)
		os.remove(tostring(fNameRdMode))
		sleep(5)
                return
        end
        fNameWrMode = "/var/tmp/"..usbPortTwo.."_w"
        fPtrWrMode = io.open (tostring(fNameWrMode), "r")
        fNameRdMode = "/var/tmp/"..usbPortTwo
        fPtrRdMode = io.open (tostring(fNameRdMode), "r")
        if fPtrWrMode~=nil then
                mode = "write"
                fPtrWrMode:close()
                --tprint("remove for upload")
                --tprint(fNameWrMode)
		os.remove(tostring(fNameWrMode))
                return
        end
        if fPtrRdMode~=nil then
                mode = "read"
                fPtrRdMode:close()
                --tprint("remove for download")
                --tprint(fNameRdMode)
		os.remove(tostring(fNameRdMode))
		sleep(5)
                return
        end
        return
end

function remount_usbdisk()
    local usbpath = "USB.Host.1.Device"
    local devnum = "DeviceNumber"
    local dn, err = mbus.getParameters{path = usbpath, param = devnum}
    local spath = "Storage.Disk"
    local sto, err = mbus.getParameters{path = spath}
    local usb_mod = {}
    local drvDesc = "DriverDescription"

    if sto[spath]["DevNumber"] ~= nil then
        return
    end
    if #dn[usbpath] == 0 then
        return
    end
    for i = 1, #dn[usbpath] do
        local drvpath = dn[usbpath][i].path .. ".Configuration.1.Interface.1"
        local drvtype, err = mbus.getParameters{path = drvpath, param = drvDesc}
        if drvtype[drvpath][1].param[drvDesc] == "usb-storage" then
            table.insert(usb_mod, {path = dn[usbpath][i].path, param = {Remount="true"}})
			setMBUS(usb_mod)
			usb_mod = {}
			sleep(1)
			while storage_script_busy() == "1" do
				sleep(1)
			end
        end
    end
end
function getUSBNameList()
	local namelist = {}
	local usbinfo, error = mbus.getParameters{path = "Storage.Disk",  param = "DeviceName"}
	for j=1, #usbinfo["Storage.Disk"] do
		namelist[j] = {}
		namelist[j].name = usbinfo["Storage.Disk"][j].param["DeviceName"]
	end	
	return namelist
end

function validateUSBStatus(pname)
	local namelist = {}
	local count = 1
	local result = "false" 
	for name in string.gmatch(pname, "[^|]+") do		 
		namelist[count]=name
		count = count + 1
	end
	local usbinfo, error = mbus.getParameters{path = "Storage.Disk",  param = "DeviceName"}
	for i=1, #namelist do
		local flag = false
		for j=1, #usbinfo["Storage.Disk"] do		
			if namelist[i] == usbinfo["Storage.Disk"][j].param["DeviceName"] then
				flag = true
			end
		end
		if flag == false then
			result = "true"
		end
	end
	return result
end

%>
