<%
cgilua.lp.include("lp/lan.lp")
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/xmlRestore.lp")


local QUERY=cgilua.QUERY
local filename = cgilua.urlcode.unescape(cgilua.QUERY["filename"])

local function getVendorLogFilename()
  local result = ""
  local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_File_1_tmp)"}
  if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
    result = reply["ENV"][1].param["Value"] or ""
  end
  return result
end

local function getVendorLogAddress()
  local result = ""
  local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_Address_1)"}
  if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
    result = reply["ENV"][1].param["Value"] or ""
  end
  return result
end

local function setVendorLogFilename(address)
  local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_File_1_tmp)"}
  mbus.modify(
    function()
      if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil and reply["ENV"][1].param["Value"]~=nil then
        mbus.setParameters{path = "ENV", param = {Value = address}, filter = "(== Name %Vendor_Log_File_1_tmp)" }
      else
        mbus.addObjects{path = "ENV", param = {Name = "%Vendor_Log_File_1_tmp", Value = address} }
      end
    end)
end

local function setVendorLogAddress(address)
  local reply, error = mbus.getParameters{path = "ENV", param = "Value", filter = "(== Name %Vendor_Log_Address_1)"}
  mbus.modify(
    function()
      if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil and reply["ENV"][1].param["Value"]~=nil then
        mbus.setParameters{path = "ENV", param = {Value = address}, filter = "(== Name %Vendor_Log_Address_1)" }
      else
        mbus.addObjects{path = "ENV", param = {Name = "%Vendor_Log_Address_1", Value = address} }
      end
    end)
end

local logFileTemp = ""
local logFileAddress = ""

if filename ~= nil and filename ~= "" then

    logFileTemp = getVendorLogFilename() 
    logFileAddress = getVendorLogAddress()

    mbus.modify(
	       function()
		  mbus.setParameters{path="DeviceConfig", param= {ConfigLoadFileName="/tmp/" .. filename, ConfigIpLoad="1", ConfigLoad="1"} }
	       end)

    setVendorLogFilename(logFileTemp)
    setVendorLogAddress(logFileAddress)

  -- workaround for CPE_P00093724: enable PPP interfaces after config load
  local modify = {}
  local reply, error = mbus.getParameters{ path = "PPP.Intf", param = {"TI_Enable", "Enable"} }
  for i, v in pairs(reply["PPP.Intf"]) do
    if v.param["TI_Enable"] == "true" and v.param["Enable"] == "false" then
      table.insert(modify, { path = v.path, param = {Enable = "true"} })
    end
  end
  if #modify>0 then
    setMBUS(modify)
  end

end

restoreXml(QUERY["physUpdateFlag"], QUERY["natIpInit"], QUERY["natIpFinal"])
phyChangeSetting()
saveall(0, 1)
--Fix for security issue in TI_M5
--Merge Label MOD_ARCHIVE_DANT-V_r10.5_r10.5.e_WIPRO_V1.0.2-x from TI_BHS
--Delete the AGConfig.xml file after xml restore is completed
os.remove ("/tmp/AGConfig.xml")
%>
