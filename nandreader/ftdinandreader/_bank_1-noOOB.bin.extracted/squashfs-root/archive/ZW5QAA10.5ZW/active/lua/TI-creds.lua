-- [ Utility functions ] -------------------------------------------------------

local dbgtrc = 1

local function get_mac_address()
   local res, err = mbus.get({  MAC = 'ENV._MACADDR.Value'}, 'KEYPATH')
   if err then
      return false, nil
   else
      return true, res.MAC
   end
end

local function get_serial()
   local res, err = mbus.get({  SERIAL = 'ENV._BOARD_SERIAL_NBR.Value'}, 'KEYPATH')
   if err then
      return false, nil
   else
      return true, res.SERIAL
   end
end

local function get_OUI()
   local res, err = mbus.get({  OUI = 'ENV._OUI.Value'}, 'KEYPATH')
   if err then
      return false, nil
   else
      return true, res.OUI
   end
end

-- [ Function to determine the user's name and password ] ----------------------
--------------------------------------------------------------------------------
-- returns TI Internet username
-- current scenario defines same ppp user pass for all three scenarios ADSL, VDSL, ETH
-- ATTENTION!! ToBeDefined how to retrieve the sync rate for the realm for the PPP
function get_user_mgnt_ppp(intf)
   --local ok, serial = get_serial(), oui = get_OUI()
   local ok = nil
   if ok then
-- enable the following line for TI
--      return serial..'-'..'oui'..'@'..'<SYNC>'..'alicenewborn.mgmt'

--remove this line for TI
    return 'bench50@juniper'
   end

--remove this line for TI
   return 'bench50@juniper' 
end

function sensing_changed(argv)
	local mode, msg = nil, 'NONE' 
	local res, err = nil, nil
	local rtdf = "0"
    --print('argv is ' .. argv)
    res, err = mbus.get(
		{ cur_mode='WANSensing.CurrentMode', req_mode='WANSensing.RequestedMode', dsl_type='DSL.ModulationType_Value', ge_status='ETH.Phys.ethif5.Status', wan_phy_up = 'TI_STORE.WANLowerLayerUp', dsl_status='DSL.Status_Value', }, 'KEYPATH')

    if err then
        print("Failed to get mbus values")
        --mode = 'NONE'
        return argv, msg
    end
    --print('res.dsl_type is ' .. res.dsl_type)
    --print('res.cur_mode is ' .. res.cur_mode)
    --print('res.req_mode is ' .. res.req_mode)
    --print('res.ge_status is ' .. res.ge_status)
    --print('res.dsl_status is ' .. res.dsl_status)
    --print('res.wan_phy_up is ' .. res.wan_phy_up)

	if res.dsl_type ~= 'VDSL' and res.dsl_status == 'Up' then
		mode = 'ADSL'
        --print("setting mode to ADSL")
    elseif res.dsl_type=='VDSL' and res.dsl_status=='Up' then
		mode = 'VDSL'
        --print("setting mode to VDSL")
    elseif res.ge_status=='Connected' and res.dsl_status~='Up' then
		mode = 'ETH'
        --print("setting mode to ETH")
	else
        --print("returning argv only, i guess this where it will stop")
        --mode = 'NONE'
		--return mode, msg
		return argv, msg
    end

	if res.cur_mode=='ADSL' or res.cur_mode=="VDSL" or res.cur_mode=="ETH" then
		if mode~=res.cur_mode then 
			rtdf = "1"
		end
	end
	if res.req_mode=='ADSL' or res.req_mode=="VDSL" or res.req_mode=="ETH" then
		if mode~=res.req_mode then 
			rtdf = "1"
		end
	end
	if rtdf == "1" then
		mbus.modify(
		function()
            --Workaroud: Disable upnp before system reset to factory default to avoid dead lock
			mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="system config upnp disabled"}}
			mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="system reset factory yes proceed yes"}}
		end)
                print("WANSENSING keep state and factory reset")
		return argv, msg
	end
    
    if mode ~= 'NONE' then
        if res.ge_status=='Connected' or res.dsl_status == 'Up' then
            --if res.wan_phy_up=='0' or res.wan_phy_up== 'Uninitailized' then 
            if res.wan_phy_up=='0' or res.wan_phy_up== 'Uninitailized' then 
                --print("mode = ADSL will set WANLowerLayerUp=1")
		        mbus.modify(
    		function()
                  mbus.setParameters{path = "TI_STORE", param = {WANLowerLayerUp = "1",}}
                  mbus.setParameters{path = "TI_STORE.TiUserIntf", param = {tclCmd="env set var %ws_mode value " .. mode}}
    		    end)
            else
                --print(" In else res.wan_phy_up==0 or res.wan_phy_up==Unitialized")
            end
        else
            --printf("In else res.ge_status==Connected or res.dsl_status == Up");
        end
    else
        --print(" In else mode ~= NONE")
    end

	return mode, msg
end


-- returns TI Internet password
-- ToBeDefined if auto-sensing scenario changes but currently password is default alicenewag for out of the box CPE




