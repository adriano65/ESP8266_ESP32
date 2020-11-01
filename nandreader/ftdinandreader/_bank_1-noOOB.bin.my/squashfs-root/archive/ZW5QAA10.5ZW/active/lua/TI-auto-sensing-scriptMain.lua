local wsd = require("wsd")
local print=print
--local tprint = require("tableprint")

-- [ Sensing code ] ------------------------------------------------------------
function sense(argv)
	local mode, msg = "NONE", nil 
	local res, err = nil, nil
	local t = nil
	local wan_ll_up = nil
	local cur_mode = nil

	res, err = mbus.get(
		{ dsl_type='DSL.ModulationType_Value', ge_status='ETH.Phys.ethif5.Status', dsl_status='DSL.Status_Value', }, 'KEYPATH')
	if err then
		print("ERROR when trying to get DSL.ModulationType_Value")
		mode = "NONE"
		return mode, msg
	end
	if res.dsl_type ~= 'VDSL' and res.dsl_status == 'Up' then
		--print(" mode is now ADSL")
		mode = 'ADSL'
	elseif res.dsl_type=='VDSL' and res.dsl_status=='Up' then
		--print("mode is now VDSL")
		mode = 'VDSL'
	elseif res.ge_status=='Connected' and res.dsl_status~='Up' then
		--print("mode is now ETH")
		mode = 'ETH'
	end

	res, err = mbus.get({ws_mode = 'ENV.%ws_mode.Value'}, 'KEYPATH')
	if err then
		--print("ERROR when trying to get ENV.%ws_mode.Value")
	end
	if res.ws_mode ~= nil then
		--print("res.ws_mode ~= nil")
		cur_mode = res.ws_mode
	else
		--print("res.ws_mode == nil,setting cur_mode to NONE")
		cur_mode = 'NONE' 
	end

	-- mode and cur_mode are obtained. First try the switch now, when successful
	-- do the set of "env set var %ws_mode" to mode at the end of this function
	-- because otherwise we will not try again upon mbus errors between here and the ending of this script

	if mode ~= cur_mode then
		print('ws: restore setting')
		t = {}
		table.insert(t, 'ppp ifdetach intf Telecom_Italia')
		table.insert(t, 'ppp ifconfig intf Telecom_Italia dest RELAY')
		table.insert(t, 'eth bridge vlan ifadd intf vdsl2 name mgmt untagged=disabled')
		table.insert(t, 'eth bridge vlan ifadd intf vdsl2 name data untagged=disabled')
		table.insert(t, 'eth bridge vlan ifadd intf bri_ge name mgmt untagged=disabled')
		table.insert(t, 'eth bridge vlan ifadd intf bri_ge name data untagged=disabled')
		table.insert(t, 'ppp relay ifadd intf ethoa_8_35')
		table.insert(t, 'ppp relay ifadd intf user_835')
		local res1, err1
		local res, err = mbus.modify(
		function()
		  for i, cli in pairs(t) do
			  --print(cli)
			  res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd=cli}}
			  if err1 then
				print("restore setting mbus error")
				return
			  end
		  end
		  res1, err1 = mbus.setParameters{path = "TI_STORE", param = {WANLowerLayerUp = "0",}}
		end)
		if err or err1 then
			print("ERROR when trying to restore settings!!!!")
			mode = "NONE"
			return mode, msg
		end
	else
		--print("ws: return because mode ="..mode.."  == cur_mode   "..cur_mode) 
		return mode, msg
	end

-- setup adsl senario --------------------------------------------------------------
	if mode == 'ADSL' then
		print('enter adsl ws')
		local res1, err1
		local res, err = mbus.modify(
		function()
		  local cli = 'ppp relay ifdelete intf user_835'
		  res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd=cli}}
		  if err1 then
			print("ADSL mbus error")
			return
		  end
		  res1, err1 = mbus.setParameters{path = "TI_STORE", param = {WANLowerLayerUp = "1",}}
		end)
		if err or err1 then
			print("ERROR when trying to set TI STORE settings!!!!")
			mode = "NONE"
			return mode, msg
		end


-- setup vdsl senario --------------------------------------------------------------
	elseif  mode == 'VDSL' then
		print('enter vdsl ws')
		t = {}
		table.insert(t, 'ppp ifdetach intf Telecom_Italia')
		table.insert(t, 'ppp ifconfig intf Telecom_Italia dest mgmt_837')
		table.insert(t, 'eth bridge vlan ifdelete intf bri_ge name mgmt')
		table.insert(t, 'eth bridge vlan ifdelete intf bri_ge name data')
		table.insert(t, 'ppp relay ifdelete intf ethoa_8_35')
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
		  res1, err1 = mbus.setParameters{path = "TI_STORE", param = {WANLowerLayerUp = "1",}}
		end)
		if err or err1 then
			print("ERROR when trying to enter vdsl ws!!!!!!")
			mode = "NONE"
			return mode, msg
		end

-- setup eth senario --------------------------------------------------------------
	elseif mode == 'ETH' then
		print('enter eth ws')
		t = {}
		table.insert(t, 'ppp ifdetach intf Telecom_Italia')
		table.insert(t, 'ppp ifconfig intf Telecom_Italia dest mgmt_837')
		table.insert(t, 'eth bridge vlan ifdelete intf vdsl2 name mgmt')
		table.insert(t, 'eth bridge vlan ifdelete intf vdsl2 name data')
		table.insert(t, 'ppp relay ifdelete intf ethoa_8_35')
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
		res1, err1 = mbus.setParameters{path = "TI_STORE", param = {WANLowerLayerUp = "1",}}
		end)
		if err or err1 then
			print("ERROR when trying to enter eth ws!!!!!!")
			mode = "NONE"
			return mode, msg
		end
	end

	if cur_mode ~= mode then
		local res1, err1
		local res, err = mbus.modify(
		function()
			  --print('mode is ' .. mode)
			  --print('cur_mode is '.. cur_mode)
			  res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="env set var %ws_mode value " .. mode}}
			  if err1 then
			    print("error setting env for wansensing mode cur_mode "..cur_mode.." mode "..mode)
			    return
			  else
			     res1, err1 = mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="system config WANMode " .. mode .. " WANEthPort ethif5"}}
			  end
		end)
		if err or err1 then
			print("Error when trying to set TI_STORE values!!!!! curmode "..cur_mode.." mode "..mode)
			mode = "NONE"
			return mode, msg
		end
		print("Wansensing successfull switch cur_mode "..cur_mode.." mode "..mode)
	end
end

-- [ Main code ] ---------------------------------------------------------------
local argv = argv
--Enable logging by removing comments on next line
wsd.log()
return sense(argv)
