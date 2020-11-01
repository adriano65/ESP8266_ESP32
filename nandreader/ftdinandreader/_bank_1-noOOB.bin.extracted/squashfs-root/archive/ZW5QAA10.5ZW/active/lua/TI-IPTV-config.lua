local wsd = require("wsd")
local print=print
--local tprint = require("tableprint")


function DeleteExtuaToIntuaMappings()

	 mbus.modify(
                 function()
          print ("Deleting mapping for all voice application INTUAs")

          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 1 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 12 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 13 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 14 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 15 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 16 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver intua map delete intua 17 extua 1"}}
     
	  mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 1 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 12 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 13 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 14 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 15 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 16 extua 1"}}
          mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="sipserver extua map delete intua 17 extua 1"}}

       end)


end


--Fix for Tessa 472
-- [ Sensing code ] ------------------------------------------------------------
function iptvconfig(argv)
	local mode, msg = "NONE", nil 
	local res, err = nil, nil
	local res1, err1 = nil, nil
	local t = nil
	local wan_ll_up = nil
	local cur_mode = nil

	print("entering iptv config function")

	res, err = mbus.get(
		{ dsl_type='DSL.ModulationType_Value', ge_status='ETH.Phys.ethif5.Status', dsl_status='DSL.Status_Value', }, 'KEYPATH')
	if err then
		print("ERROR when trying to get DSL.ModulationType_Value")
		mode = "NONE"
		return mode, msg
	end
	if res.dsl_type ~= 'VDSL' and res.dsl_status == 'Up' then
		print(" mode is now ADSL")
		mode = 'ADSL'
	elseif res.dsl_type=='VDSL' and res.dsl_status=='Up' then
		print("mode is now VDSL")
		mode = 'VDSL'
	elseif res.ge_status=='Connected' and res.dsl_status~='Up' then
		print("mode is now ETH")
		mode = 'ETH'
	end

        res, err = mbus.get({provisioningCode = 'ENV.CONF_PROVIDER.Value'}, 'KEYPATH')
        if err then
                print("ERROR when trying to get ENV.CONF_PROVIDER.Value")
        end

	    print("Before checking provisioningCode")

       res1, err1 = mbus.get(
                {extua_status='SIPServer.ExternalUA.1.Status'}, 'KEYPATH')
        if err1 then
                print("ERROR when trying to get SipServer.ExternalUA")
	end

        if res.provisioningCode ~= nil and res.provisioningCode ~= "" then
                print("ProvisioningCode present")
		print(res.provisioningCode)
		if res1.extua_status ~= nil and res1.extua_status == "Disabled" then
		 print ("EXTUA Status Disabled")
		 DeleteExtuaToIntuaMappings()
		end

	else
	
          print ("Not Provisioned Before deleting the mappings")
	  DeleteExtuaToIntuaMappings()
        
	end

        res, err = mbus.get({iptvconfigpresent = 'ENV.IPTVConfigPresent.Value'}, 'KEYPATH')
        if err then
                print("ERROR when trying to get ENV.IPTVConfigPresent.Value")
        end
        if res.iptvconfigpresent ~= nil then
                print("IPTV stack configuration present")
		return
	end


-- setup adsl senario --------------------------------------------------------------
	if mode == 'ADSL' then
		print('enter adsl IPTV config')
		t = {}
		table.insert(t, 'ip ifadd intf=IPTV dest=ethoa_8_36')
		table.insert(t, 'ip ifconfig intf=IPTV mtu=1500 group=wan linksensing=disabled hwaddr=$_WL_MACADDR ipv6=disabled arpcachetimeout=1800 ipv4=disabled')
		table.insert(t, 'dhcp client ifadd intf IPTV')
		table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classfull-static-routes index=1')
		table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classless-static-routes index=2')
		table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-specific_info value=(clientid)666c617368 index=1')
		table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-class-id value=(clientid)706972656c6c692d737462 index=2')
		table.insert(t, 'igmp proxy ifconfig intf=IPTV state=upstream')
		table.insert(t, 'nat tmpladd intf=IPTV type=nat inside_addr=192.168.1.2-192.168.1.254 outside_addr=0.0.0.1')
		table.insert(t, 'nat ifconfig intf IPTV translation disabled')	
		table.insert(t, 'env set var IPTVConfigPresent value 1')
		local res1, err1
		local res, err = mbus.modify(
		function()
		  --local cli = 'ppp relay ifdelete intf user_835'
		  for i, cli in pairs(t) do
			res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd=cli}}
		  	if err1 then
				print("ADSL mbus error")
				return
			end
		  end
		end)

-- setup vdsl senario --------------------------------------------------------------
	elseif  mode == 'VDSL' then
		print('enter vdsl IPTV config')
		t = {}
                table.insert(t, 'ip ifadd intf=IPTV dest=video_836')
                table.insert(t, 'ip ifconfig intf=IPTV mtu=1500 group=wan linksensing=disabled hwaddr=$_WL_MACADDR ipv6=disabled arpcachetimeout=1800 ipv4=disabled')
                table.insert(t, 'dhcp client ifadd intf IPTV')
                table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classfull-static-routes index=1')
                table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classless-static-routes index=2')
                table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-specific_info value=(clientid)666c617368 index=1')
                table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-class-id value=(clientid)706972656c6c692d737462 index=2')
                table.insert(t, 'igmp proxy ifconfig intf=IPTV state=upstream')
                table.insert(t, 'nat tmpladd intf=IPTV type=nat inside_addr=192.168.1.2-192.168.1.254 outside_addr=0.0.0.1')
                table.insert(t, 'nat ifconfig intf IPTV translation disabled')
		table.insert(t, 'env set var IPTVConfigPresent value 1')

		local res1, err1
		local res, err = mbus.modify(
		function()
		  for i, cli in pairs(t) do
			  --print(cli)
			  res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd=cli}}
			  if err1 then
				print("VDSL mbus error")
				return
			  end
		  end
		end)

-- setup eth senario --------------------------------------------------------------
	elseif mode == 'ETH' then
		print('enter eth IPTV config')
		t = {}
                table.insert(t, 'ip ifadd intf=IPTV dest=video_836')
                table.insert(t, 'ip ifconfig intf=IPTV mtu=1500 group=wan linksensing=disabled hwaddr=$_WL_MACADDR ipv6=disabled arpcachetimeout=1800 ipv4=disabled')
                table.insert(t, 'dhcp client ifadd intf IPTV')
                table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classfull-static-routes index=1')
                table.insert(t, 'dhcp client rqoptions add intf=IPTV option=classless-static-routes index=2')
                table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-specific_info value=(clientid)666c617368 index=1')
                table.insert(t, 'dhcp client txoptions add intf=IPTV option=vendor-class-id value=(clientid)706972656c6c692d737462 index=2')
                table.insert(t, 'igmp proxy ifconfig intf=IPTV state=upstream')
                table.insert(t, 'nat tmpladd intf=IPTV type=nat inside_addr=192.168.1.2-192.168.1.254 outside_addr=0.0.0.1')
                table.insert(t, 'nat ifconfig intf IPTV translation disabled')
		table.insert(t, 'env set var IPTVConfigPresent value 1')

		local res1, err1
		local res, err = mbus.modify(
		function()
		for i, cli in pairs(t) do
			--print(cli)
			res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd=cli}}
			if err1 then
				print("ETH mbus error")
				return
			end
		end
		end)
	end
    


end

-- [ Main code ] ---------------------------------------------------------------
local argv = argv
--Enable logging by removing comments on next line
wsd.log()
return iptvconfig(argv)
