function  DoM4toM4IMSUpgrade_common()
   print("Do the M4 common part ");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.NumberTranslation", param={Globalnumbpostprocess="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice", param={CountryCode="0", DelayedDisconnect= "0",DelayedDisconnectTimer="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.Fax", param={VBDcodec="G711A",Transport="t38"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.SIP", param={Privacy="ignore",PRACK="when_supported",}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.Services.Service.bargein",param={Provisioned="0"},flags = "KEYPATH"}end)end)


      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.addObjects{path="Voice.numbtranslAC", param={level="1",areacode="+39", action= "hideareacode",delete="0",executeprefdel="insideareacode"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.addObjects{path="Voice.numbtranslAC", param={level="2",areacode="+", action="showareacode",prefix="00",delete="1", executeprefdel="insideareacode"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.deleteObjects{path="Voice.SIP.Responsemap.181",flags = "KEYPATH"}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.deleteObjects{path="Voice.SIP.Responsemap.488",flags = "KEYPATH"}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.addObjects{path="Voice.SIP.Responsemap", param={Responsecode="600",Tone="busy",Textmessage=""},flags = "KEYPATH"}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.addObjects{path="Voice.SIP.Responsemap", param={Responsecode="603",Tone="busy",Textmessage=""},flags = "KEYPATH"}end)end)


      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="DeviceConfig", param={UpgradeStsFileName="active/common.sts", UpgradeStsLoad="1"}}end)end)

   -- CPE_P00115550: set AdminPassword to Admin when not present
   reply, err =  mbus.getParameters{ path = "TI_STORE.TiUserIntf", param = "AdminPassword" }
   if not err then
      local AdminPassword = reply["TI_STORE.TiUserIntf"][1].param["AdminPassword"]
      if tostring(AdminPassword) == "" then
         replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="TI_STORE.TiUserIntf", param={AdminPassword="Admin"}}end)end)
      end
   end

   reply,err = mbus.getParameters{path ="ENV",param = "Value",filter = "(== Name ".. "IsFXONum" ..")" }
   replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(
       function()
          if reply["ENV"][1] == nil or reply["ENV"][1].param == nil then
               mbus.addObjects{ path = "ENV",param = {Name = "IsFXONum",Value = "Linea Fissa"},flags = "KEYPATH"}
          end
       end)end)
end
function  DoM4toM4IMSUpgrade_SIP_GW()
   print("Do the M4 SIP_GW part ");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.CAC", param={MaxPortsPerProfile="all"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.SIP", param={TelURI="0", PhoneContext= "+39"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer", param={MaxMapsPerExtua="all",StickyOutbProxy="1"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.Services.SOC.map", param={SOC="ignore"},filter="(== function Establish3Party)"}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.1", param={RegPort="5060"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.2", param={RegPort="5060"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.3", param={RegPort="5060"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.4", param={RegPort="5060"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundProxy.1", param={ProxyPort="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundProxy.2", param={ProxyPort="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundProxy.3", param={ProxyPort="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundProxy.4", param={ProxyPort="0"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer", param={ExtraReregistrations ="1"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.1", param={RegServer="telecomitalia.it"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.2", param={RegServer="telecomitalia.it"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.3", param={RegServer="telecomitalia.it"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="SIPServer.OutboundRegistrar.4", param={RegServer="telecomitalia.it"}}end)end)
end
function  DoM4toM4IMSUpgrade_Virtual_PBX()
   print("Do the M4 Virtual_PBX part ");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.SIP", param={TelURI="0", PhoneContext= "+39"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Voice.Services.Service.transfer", param={Status="1"},flags = "KEYPATH"}end)end)
end



function  DoM4IMStoM5Upgrade_common()
   print("Do the M5 common part ");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="DeviceConfig", param={UpgradeStsFileName="active/M5common.sts", UpgradeStsLoad="1"}}end)end)
      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="PPP.Intf.2", param={Enable="1"}}end)end)

   -- Fix for not able to login to GUI after upgrade from M4 to M5
   -- Solution is to update mlpuser parameters using the configured password value
   reply, err =  mbus.getParameters{ path = "TI_STORE.TiUserIntf", param = "AdminPassword" }
   if not err then
      local AdminPassword = reply["TI_STORE.TiUserIntf"][1].param["AdminPassword"]
      if tostring(AdminPassword) == "" then
         print ("admin password check")
      else
         replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="Users.User.admin", param={Password=AdminPassword},flags = "KEYPATH"}end)end)  
      end
   end

end


function MakeIntuaMappingBidrectional()
	
	-- Intua to Extua mapping
	local replyMaps, err =  mbus.getParameters{ path = "SIPServer.InternalUAMap", param = {"InternalUA","ExternalUA"}}
	if (replyMaps["SIPServer.InternalUAMap"][1]) == nil then
		print("MakeIntuaMappingBidrectional no InternalUAMap found");
	else
		local replys, errors = mbus.modify(
		function()
			for j,k in pairs(replyMaps["SIPServer.InternalUAMap"]) do
				local ValInternalUA  = k.param["InternalUA"]
				local ValExternalUA  = k.param["ExternalUA"]
				
				local reply1, err1 =  mbus.getParameters{ path = "SIPServer.ExternalUAMap", param = {"InternalUA","ExternalUA"},  filter = "(and(== InternalUA "..tostring(ValInternalUA)..")  (== ExternalUA "..tostring(ValExternalUA).."))" }
				
				if (reply1["SIPServer.ExternalUAMap"][1]) == nil then

					local reply, error = mbus.addObjects{ path="SIPServer.ExternalUAMap", param = {InternalUA = ValInternalUA,ExternalUA=ValExternalUA} }					
				end	
			end 
		end)
	end
	
	--Extua to Intua mapping
	local replyMapsExtua,errormap =  mbus.getParameters{ path = "SIPServer.ExternalUAMap", param = {"InternalUA","ExternalUA"}}
	if (replyMapsExtua["SIPServer.ExternalUAMap"][1]) == nil then
		print("MakeIntuaMappingBidirectional no ExternalUAMap found");
	else
		local replys, errors = mbus.modify(function()
			for l,m in pairs(replyMapsExtua["SIPServer.ExternalUAMap"]) do
				local ValInternalUA  = m.param["InternalUA"]
				local ValExternalUA  = m.param["ExternalUA"]

				local reply1, err1 =  mbus.getParameters{ path = "SIPServer.InternalUAMap", param = {"InternalUA","ExternalUA"},  filter = "(and(== InternalUA "..tostring(ValInternalUA)..")  (== ExternalUA "..tostring(ValExternalUA).."))" }

				if (reply1["SIPServer.InternalUAMap"][1]) == nil then

					local reply, error = mbus.addObjects{ path="SIPServer.InternalUAMap", param = {InternalUA = ValInternalUA,ExternalUA=ValExternalUA} }
				end	
			end 
		end)
	end
end

function WriteVoiceUamapToIntuas()
   print("WriteVoiceUamapToIntuas");

end

function DoM4IMStoM5Upgrade_SIP_GW()
   print("M5 SIP_GW part ");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

      replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="DeviceConfig", param={UpgradeStsFileName="active/M5SIPGW.sts", UpgradeStsLoad="1"}}end)end)

   -- increase directory number intua 2 to 10 and make bidirectional
   MakeIntuaMappingBidrectional()
   -- write the voice uamap to the sipserver intua (will write intua 1 and 12 to 17)
   WriteVoiceUamapToIntuas()
end

function DoM4IMStoM5Upgrade_Virtual_PBX()
   print("Do The M5 Virtual_PBX part");
   local replys, errors
   local reply, err
   local pcall_rep, pcall_err

 replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(function()reply, err = mbus.setParameters{path="DeviceConfig", param={UpgradeStsFileName="active/M5VPBX.sts", UpgradeStsLoad="1"}}end)end)

end

function DoUpgrade(argv)
   local pcall_rep, pcall_err

 -- 1) GET SOME PARAMETERS to determine which upgrade
 --    get them all now before changing anything

   -- 1.1) Determine IMS upgrade or not
   local ExtraReregistrations
   local reply, err =  mbus.getParameters{ path = "SIPServer", param = "ExtraReregistrations" }
   if err then
      ExtraReregistrations = "Not obtained so M4 IMS to D5"
   else
      ExtraReregistrations = reply["SIPServer"][1].param["ExtraReregistrations"]
   end
   print("DoUpgrade ExtraReregistrations: "..tostring(ExtraReregistrations))

   -- 1.2) Determine D2 upgrade or not
   local voiceServiceType
   reply, err =  mbus.getParameters{ path = "SIPServer", param = "VoIPServiceType" }
   if err then
      voiceServiceType = "Not obtained so D2 to D4"
   else
      voiceServiceType = reply["SIPServer"][1].param["VoIPServiceType"]
   end
   print("DoUpgrade voiceServiceType: "..tostring(voiceServiceType))

 -- 2) DO THE NECCESSARY UPGRADES
   -- 2.1) Do from D2 to M4 upgrade when neccessary
   if voiceServiceType ~= "SIP_GW" and voiceServiceType ~= "Virtual_PBX" then
       print("voiceServiceType unassigned so we need D2 to M4 upgrade")
      -- Do day2.sts
      local replys, errors = mbus.modify(function()pcall_rep, pcall_err = pcall(
        function()
           reply, err = mbus.setParameters{path="DeviceConfig", param={UpgradeStsFileName="active/Day2_upgrade.sts", UpgradeStsLoad="1"}}
         end)end)
      if err or errors then
        print("D2 to M4 upgrade failed")
      else
        print("D2 to M4 upgrade done")
      end
   end

   -- 2.2) Do D4 IMS upgrade when neccessary
   if ExtraReregistrations ~= "true" then
       print("ExtraReregistrations not on so we need the M4toM4IMS ")
       -- Do common, SIP_GW and Virtual_PBX part ...
       DoM4toM4IMSUpgrade_common()

       if voiceServiceType ~= "Virtual_PBX" then
          DoM4toM4IMSUpgrade_SIP_GW()
       end
       if voiceServiceType == "Virtual_PBX" then
          DoM4toM4IMSUpgrade_Virtual_PBX()
       end
       print("ExtraReregistrations not on M4toM4IMS done")
   end

   -- 2.3) Do D5 upgrade when neccessary

	print("Do M5 upgrade always")
   -- Do common, SIP_GW and Virtual_PBX part ...
   DoM4IMStoM5Upgrade_common()

   if voiceServiceType ~= "Virtual_PBX" then
       DoM4IMStoM5Upgrade_SIP_GW()
   end
   if voiceServiceType == "Virtual_PBX" then
       DoM4IMStoM5Upgrade_Virtual_PBX()
   end

   -- Delete the unwanted dect traces 
    os.remove("/rw/dl/Gf_UiTrace.log");
    os.remove("/rw/dl/Gf_Trace.log");

   print("upgrade.lua ENDED fine!")
end


local argv = argv
-- Main code
return DoUpgrade(argv)
