<%
cgilua.lp.include("lp/util.lp")


function bigNumberCheck(n)
 if n == "2147480000" or n =="2147480001"  then
   return "0"
 else
   return n
 end
end

--Get the dsl info for welcome page.
function getDSLInfoHome()
    local result={}

    local reply, error = mbus.getParameters{ path = "DSL", param = {"Status_Value", "UpstreamCurrRate_Value", "UpstreamCurrRate_Unit", "DownstreamCurrRate_Value", "DownstreamCurrRate_Unit"}}
    result.dsl_status = reply["DSL"][1].param["Status_Value"]
	
    if (result.dsl_status == "Up") then 
        result.upstream = reply["DSL"][1].param["UpstreamCurrRate_Value"]..reply["DSL"][1].param["UpstreamCurrRate_Unit"]
        result.downstream = reply["DSL"][1].param["DownstreamCurrRate_Value"]..reply["DSL"][1].param["DownstreamCurrRate_Unit"]  
    else
        result.upstream = "0"
        result.downstream = "0"
    end      

    return result
end

function getDSLStatsInfo(type)
	local result={}
	local reply, error = mbus.getParameters{ path = "TI_STORE.DSLSTATS", param = {"ReceiveBlocks", "TransmitBlocks", "FECErrors", "TotalATUC_FECErrors", "CRCErrors", "TotalATUC_CRCErrors", "ErroredSecs", "TOTALATUC_ErrorSecond", "SeverelyErroredSecs"}}
	result.ReceiveBlocks = reply["TI_STORE.DSLSTATS"][1].param["ReceiveBlocks"]
	result.TransmitBlocks = reply["TI_STORE.DSLSTATS"][1].param["TransmitBlocks"]
	result.FECErrors = reply["TI_STORE.DSLSTATS"][1].param["FECErrors"]
	result.TotalATUC_FECErrors = reply["TI_STORE.DSLSTATS"][1].param["TotalATUC_FECErrors"]
	result.CRCErrors = reply["TI_STORE.DSLSTATS"][1].param["CRCErrors"]
	result.TotalATUC_CRCErrors = reply["TI_STORE.DSLSTATS"][1].param["TotalATUC_CRCErrors"]
	result.ErroredSecs = reply["TI_STORE.DSLSTATS"][1].param["ErroredSecs"]
	result.TOTALATUC_ErrorSecond = reply["TI_STORE.DSLSTATS"][1].param["TOTALATUC_ErrorSecond"]
	result.SeverelyErroredSecs = reply["TI_STORE.DSLSTATS"][1].param["SeverelyErroredSecs"]

    return result
end
--get adsl info
--type: if nil, get all info, if "simple", get few parameter for home page 

function getDSLInfo(type)
    local result={}

    local reply, error = mbus.getParameters{ path = "DSL", param = {"Status_Value", "Standard_Value", "ModulationType_Value", "UpstreamCurrRate_Value", "UpstreamCurrRate_Unit", "DownstreamCurrRate_Value", "DownstreamCurrRate_Unit", "Version_Value", "Enable", "UpstreamMaxRate_Value", "DownstreamMaxRate_Value", "CurrentProfile"}}
    result.dsl_status = reply["DSL"][1].param["Status_Value"]
    result.dsl_standard = reply["DSL"][1].param["Standard_Value"]
    result.dsl_ModulationType = reply["DSL"][1].param["ModulationType_Value"]
    result.dsl_version = reply["DSL"][1].param["Version_Value"]
    result.dsl_enable = reply["DSL"][1].param["Enable"]
    result.dsl_profile = reply["DSL"][1].param["CurrentProfile"]
    
    if (result.dsl_status == "Up") then 
        result.upstream = reply["DSL"][1].param["UpstreamCurrRate_Value"]..reply["DSL"][1].param["UpstreamCurrRate_Unit"]
        result.downstream = reply["DSL"][1].param["DownstreamCurrRate_Value"]..reply["DSL"][1].param["DownstreamCurrRate_Unit"]        
        result.upstreamValue = reply["DSL"][1].param["UpstreamCurrRate_Value"]
        result.downstreamValue = reply["DSL"][1].param["DownstreamCurrRate_Value"]
        result.upstreamMax = reply["DSL"][1].param["UpstreamMaxRate_Value"]
        result.downstreamMax = reply["DSL"][1].param["DownstreamMaxRate_Value"]
    else
        result.upstream = "0"
        result.downstream = "0"
        result.upstreamValue = "0"
        result.downstreamValue = "0"
        result.upstreamMax = "0"
        result.downstreamMax = "0"
    end
    
    reply, error = mbus.getParameters{ path = "ATM.Intf", param={"DestinationAddress", "LinkType", "Status"}}
    result.atmStatus = reply["ATM.Intf"][1].param["Status"]
    result.pvc = reply["ATM.Intf"][1].param["DestinationAddress"]
    result.atmStatus_1 = reply["ATM.Intf"][2].param["Status"]
    result.pvc_1 = reply["ATM.Intf"][2].param["DestinationAddress"]
    result.linktype = reply["ATM.Intf"][1].param["LinkType"]   

    local atmAALPath = reply["ATM.Intf"][1].path .. ".Stats.AAL5"
    local atmAALPath_2 = reply["ATM.Intf"][2].path .. ".Stats.AAL5"
    reply, error = mbus.getParameters{ path = atmAALPath, param={"CRCErrors", "SARTimeout", "SDUTooLong", "InvalidLength"}}
    result.crcErrors = reply[atmAALPath][1].param["CRCErrors"] 
    result.sarTimeout = reply[atmAALPath][1].param["SARTimeout"]
    result.sduTooLong = reply[atmAALPath][1].param["SDUTooLong"]
    result.invalidLength = reply[atmAALPath][1].param["InvalidLength"]

    reply, error = mbus.getParameters{ path = atmAALPath_2, param={"CRCErrors", "SARTimeout", "SDUTooLong", "InvalidLength"}}
    result.crcErrors_2 = reply[atmAALPath_2][1].param["CRCErrors"]
    result.sarTimeout_2 = reply[atmAALPath_2][1].param["SARTimeout"]
    result.sduTooLong_2 = reply[atmAALPath_2][1].param["SDUTooLong"]
    result.invalidLength_2 = reply[atmAALPath_2][1].param["InvalidLength"]

	result.down_noisemargin, result.latency_type, result.up_noisemargin, result.down_attenuation, result.up_attenuation, result.down_power, result.up_power, result.down_impulsemargin, result.up_impulsemargin  = "0", "", "0", "0", "0", "0", "0", "0", "0"

    if result.dsl_status=="Up" and type==nil then
        reply, error = mbus.getParameters{ path = "DSL.Stats.Showtime", param="Start_Value"}            
        result.uptime = reply["DSL.Stats.Showtime"][1].param["Start_Value"]
        
        reply, error = mbus.getParameters{ path = "DSL", param = {"Standard_Value", "DataPath_Value", 
                                           "DownstreamNoiseMargin_Value", "UpstreamNoiseMargin_Value", "DownstreamNoiseMargin_Scale", "UpstreamNoiseMargin_Scale", "DownstreamAttenuation_Value", "UpstreamAttenuation_Value", "DownstreamAttenuation_Scale", "UpstreamAttenuation_Scale", "DownstreamPower_Value", "UpstreamPower_Value", "DownstreamPower_Scale", "UpstreamPower_Scale","DownstreamImpulseNoiseProtection_Value","UpstreamImpulseNoiseProtection_Value","DownstreamImpulseNoiseProtection_Scale","UpstreamImpulseNoiseProtection_Scale"}}         
        
        result.latency_type = reply["DSL"][1].param["DataPath_Value"]

        result.down_noisemargin = scaleNum(bigNumberCheck(reply["DSL"][1].param["DownstreamNoiseMargin_Value"]), reply["DSL"][1].param["DownstreamNoiseMargin_Scale"])
        result.up_noisemargin = scaleNum(bigNumberCheck(reply["DSL"][1].param["UpstreamNoiseMargin_Value"]), reply["DSL"][1].param["UpstreamNoiseMargin_Scale"])
        result.down_attenuation = scaleNum(bigNumberCheck(reply["DSL"][1].param["DownstreamAttenuation_Value"]), reply["DSL"][1].param["DownstreamAttenuation_Scale"])
        result.up_attenuation = scaleNum(bigNumberCheck(reply["DSL"][1].param["UpstreamAttenuation_Value"]), reply["DSL"][1].param["UpstreamAttenuation_Scale"])
        result.down_power = scaleNum(bigNumberCheck(reply["DSL"][1].param["DownstreamPower_Value"]), reply["DSL"][1].param["DownstreamPower_Scale"])
        result.up_power = scaleNum(bigNumberCheck(reply["DSL"][1].param["UpstreamPower_Value"]), reply["DSL"][1].param["UpstreamPower_Scale"])
        result.down_impulsemargin = scaleNum(bigNumberCheck(reply["DSL"][1].param["DownstreamImpulseNoiseProtection_Value"]), reply["DSL"][1].param["DownstreamImpulseNoiseProtection_Scale"])
        --result.up_impulsemargin = reply["DSL"][1].param["UpstreamImpulseNoiseProtection_Value"]/reply["DSL"][1].param["UpstreamImpulseNoiseProtection_Scale"]
	reply, error = mbus.getParameters{path = "Device.DSL.Channel.1", param = {"ACTINP"}, datamodel = "second"}
	result.up_impulsemargin = reply["Device.DSL.Channel.1"][1].param["ACTINP"]
   end  

	result.downfec, result.downcrc, result.downhec, result.localframing, result.localsignal, result.localpower, result.errseconds, result.receivedBlocks = "0", "0", "0", "0", "0", "0", "0", "0"
	result.transmittedBlocks, result.severelyErroredSecs, result.upfec, result.upcrc, result.uphec =  "0", "0", "0", "0", "0"
        
    reply, error = mbus.getParameters{ path = "DSL.Stats.Total", param={"FECErrors_Value", "CRCErrors_Value", "HECErrors_Value", "LossOfFraming_Value", "LossOfSignal_Value", "LossOfPower_Value", "ErroredSecs_Value", "ReceiveBlocks_Value", "TransmitBlocks_Value", "SeverelyErroredSecs_Value"}}
    result.downfec = reply["DSL.Stats.Total"][1].param["FECErrors_Value"]
    result.downcrc = reply["DSL.Stats.Total"][1].param["CRCErrors_Value"]
    result.downhec = reply["DSL.Stats.Total"][1].param["HECErrors_Value"]
    result.localframing = reply["DSL.Stats.Total"][1].param["LossOfFraming_Value"]
    result.localsignal = reply["DSL.Stats.Total"][1].param["LossOfSignal_Value"]
    result.localpower = reply["DSL.Stats.Total"][1].param["LossOfPower_Value"]
    result.errseconds = reply["DSL.Stats.Total"][1].param["ErroredSecs_Value"]
    result.receivedBlocks =    reply["DSL.Stats.Total"][1].param["ReceiveBlocks_Value"]
    result.transmittedBlocks = reply["DSL.Stats.Total"][1].param["TransmitBlocks_Value"]
    result.severelyErroredSecs = reply["DSL.Stats.Total"][1].param["SeverelyErroredSecs_Value"]
        
    reply, error = mbus.getParameters{ path = "DSL.Stats.TotalATUC", param={"FECErrors_Value", "CRCErrors_Value", "HECErrors_Value", "ErrorSecond_Value"}}
    result.upfec = reply["DSL.Stats.TotalATUC"][1].param["FECErrors_Value"]
    result.upcrc = reply["DSL.Stats.TotalATUC"][1].param["CRCErrors_Value"]
    result.uphec = reply["DSL.Stats.TotalATUC"][1].param["HECErrors_Value"]     
    result.upErrSeconds = reply["DSL.Stats.TotalATUC"][1].param["ErrorSecond_Value"]     
    
    result.downfec=bigNumberCheck(result.downfec)
    result.downcrc=bigNumberCheck(result.downcrc)
    result.downhec=bigNumberCheck(result.downhec)
    result.localframing=bigNumberCheck(result.localframing)
    result.localsignal=bigNumberCheck(result.localsignal)
    result.localpower=bigNumberCheck(result.localpower)
    result.errseconds=bigNumberCheck(result.errseconds)
    result.receivedBlocks=bigNumberCheck(result.receivedBlocks)
    result.transmittedBlocks=bigNumberCheck(result.transmittedBlocks)
    result.severelyErroredSecs=bigNumberCheck(result.severelyErroredSecs)
    result.upfec=bigNumberCheck(result.upfec)
    result.upcrc=bigNumberCheck(result.upcrc)
    result.uphec=bigNumberCheck(result.uphec)
    result.upErrSeconds=bigNumberCheck(result.upErrSeconds)
	  
    return result
end
%>

