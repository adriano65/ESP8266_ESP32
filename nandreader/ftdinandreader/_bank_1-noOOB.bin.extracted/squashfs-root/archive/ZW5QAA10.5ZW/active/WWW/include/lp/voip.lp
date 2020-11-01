<%
local tprint = require("tableprint")
local portTypePath = "Device.Services.VoiceService.1.PhyInterface"
local ingressPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
local egressPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
local ingressPath1 = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"
local egressPath1 = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"

--Get the serviceDECT enable
function getServiceDECTEnable()
    local serviceDECTPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local reply, error = mbus.getParameters{ path = serviceDECTPath, param = {"X_TELECOMITALIA_IT_Enable"}, datamodel = "second"}
    return reply[serviceDECTPath][1].param["X_TELECOMITALIA_IT_Enable"]
end

--Get the Fax_T38 enable
function getFaxTEnable()
    local FaxTPath = "Device.Services.VoiceService.1.VoiceProfile.1.FaxT38"
    local replyFax, error = mbus.getParameters{ path = FaxTPath, param = {"Enable"}, datamodel = "second"}
    return replyFax[FaxTPath][1].param["Enable"]
end

--Define the param of serviceDECTState is Actived or Inactived
local serviceDECTPath = "Device.Services.VoiceService.1.PhyInterface.3"

local replyDECT, error = mbus.getParameters{ path = serviceDECTPath, param = {"X_TELECOMITALIA_IT_Enable"}, datamodel = "second"}

local serviceDECTState = translate([==[Inactived]==])
if replyDECT[serviceDECTPath][1].param["X_TELECOMITALIA_IT_Enable"]=="true" then
    serviceDECTState = translate([==[Actived]==])
end

--Get the DECTHandsetMaxNumberOfEntries
function getDECTHandsetMaxNumber()
    local DECTHandsetMaxNumberPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyMax, error = mbus.getParameters{ path = DECTHandsetMaxNumberPath, param = {"X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"}, datamodel = "second"}
    local DECTHandsetMaxNumber = replyMax[DECTHandsetMaxNumberPath][1].param["X_TELECOMITALIA_IT_DECTHandsetMaxNumberOfEntries"]
    return DECTHandsetMaxNumber
end

--Get the active value which is true
function getDECTHandsetActive()
    local DECTHandsetActivePath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset"
    local replyActive, error = mbus.getParameters{ path = DECTHandsetActivePath, param = {"Active"}, datamodel = "second"}
    local DECTHandsetActive = replyActive[DECTHandsetActivePath][1].param["Active"]
    return DECTHandsetActive
end

--check the checkbox is checked or not
function isCheckedService(flag)
    local isChecked = 'checked="checked"'
    if flag~="true" then
        isChecked = ""
    end
    return isChecked
end

--get the port type and enable
function getConnectionInfo()    
    local phyIntf_T = {}
    local replyType, error = mbus.getParameters{ path = portTypePath, param = {"Description", "X_TELECOMITALIA_IT_Enable", "X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut", "X_TELECOMITALIA_IT_POSConfig"}, datamodel = "second" }
    for i,v in pairs(replyType[portTypePath]) do
        phyIntf_T[i] = {}
        phyIntf_T[i].name = v.param["Description"]	
        phyIntf_T[i].enable = v.param["X_TELECOMITALIA_IT_Enable"]
        phyIntf_T[i].posConfig = v.param["X_TELECOMITALIA_IT_POSConfig"]
        phyIntf_T[i].switchToPSTNIn = v.param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]
        phyIntf_T[i].switchToPSTNOut = v.param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]
        phyIntf_T[i].path = v.path
	--phyIntf_T[i].path = "Device.Services.VoiceService.3.VoiceProfile.1.Line.1"
    end	
	local phyPathFXS = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
	local replyType, error = mbus.getParameters{ path = phyPathFXS ,  param= { "X_TELECOMITALIA_IT_LineName","PhyReferenceList","DirectoryNumber" }, datamodel = "second" }  

	for i,w in pairs(replyType[phyPathFXS]) do
       	if w.param["PhyReferenceList"] ~= nil then
		  if phyIntf_T[i] == nil then
			phyIntf_T[i] = {}		  		
		  end
		  phyIntf_T[i].linename = w.param["X_TELECOMITALIA_IT_LineName"]
		  phyIntf_T[i].val = w.param["DirectoryNumber"] 
                end
	end	
    return phyIntf_T
end

--get line path from UAMap by interface path
function getLinePathFromUAMap(phyIntfPath)
    local uaMapPath, fromUA
    local replyIngress, error = mbus.getParameters{ path = ingressPath, param = {"ToVoicePort", "FromUA"}, filter="(== ToVoicePort "..phyIntfPath..")", datamodel = "second" }
    if replyIngress[ingressPath][1]~=nil and replyIngress[ingressPath][1].param~=nil then
        uaMapPath = replyIngress[ingressPath][1].path
        fromUA = replyIngress[ingressPath][1].param["FromUA"]	 
    end
    return fromUA, uaMapPath
end

--get line path from UAMap by interface path
function getLinePathFromUAMap1(phyIntfPath)
    local uaMapPath, fromUA
    local replyIngress, error = mbus.getParameters{ path = ingressPath, param = {"ToVoicePort", "FromUA"}, filter="(== ToVoicePort "..phyIntfPath..")", datamodel = "second" }
    if replyIngress[ingressPath][1]~=nil and replyIngress[ingressPath][1].param~=nil then
        uaMapPath = replyIngress[ingressPath][1].path
        fromUA = replyIngress[ingressPath][1].param["FromUA"]	 
    end
    return fromUA, uaMapPath
end

--get line path from VoicePortMap by interface path
function getLinePathFromPortMap(phyIntfPath)
    local portMapPath, toUA
    local replyEgress, error = mbus.getParameters{ path = egressPath, param = {"FromVoicePort", "ToUA"}, filter="(== FromVoicePort "..phyIntfPath..")", datamodel = "second" }
    if replyEgress[egressPath][1]~=nil and replyEgress[egressPath][1].param~=nil then
        portMapPath = replyEgress[egressPath][1].path
        toUA = replyEgress[egressPath][1].param["ToUA"]	
    end
    return toUA, portMapPath
end

--get incomingCallNum or outgoingCallNum by line path
function getCallNum(linePath)
    local reply, error = mbus.getParameters{ path = linePath, param = "DirectoryNumber", datamodel = "second" }
    return reply[linePath][1].param["DirectoryNumber"]
end

--get DECTAll line number for incomingCall in the interface3
function getDECTAllInCallNum()
    local lineDECTAll,lineNumber
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECTAll, error = mbus.getParameters{ path = ingressPath, param = {"ToUA", "FromUA", "Preassigned"}, filter="(== ToUA "..DECTAllPath..")", datamodel = "second" }
    if replyDECTAll[ingressPath]~=nil and replyDECTAll[ingressPath][1]~=nil then
        for i,v in pairs(replyDECTAll[ingressPath]) do
            local linePath = v.param["FromUA"]
            linePreassigned = v.param["Preassigned"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                if linePreassigned==tostring("true") then
                    lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")" 
                end 
            end
            if lineNumber~=nil then
                if lineDECTAll==nil then
                    lineDECTAll = lineNumber
                else
                    lineDECTAll = tostring(lineDECTAll) .. "<br/>" .. tostring(lineNumber)
                end
            end
        end
    end
    return lineDECTAll
end

--get All line number for incomingCall in the interface path
function  getAllInCallNum(phyIntfPath)
    
    local lineNumberAll, lineNumber, linePath, linePreassigned
    local replyIngress, error = mbus.getParameters{ path = ingressPath1, param = {"ToUA", "FromUA", "Preassigned"}, filter="(== ToUA "..phyIntfPath..")", datamodel = "second" }
    if replyIngress[ingressPath1][1]~=nil and replyIngress[ingressPath1][1].param~=nil then
        for j,k in pairs(replyIngress[ingressPath1]) do
            linePath = k.param["FromUA"]
            linePreassigned = k.param["Preassigned"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                if linePreassigned==tostring("true") then
                    lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")"
                end
            else
                lineNumber = "-"
            end
            if lineNumber~="-" then
                if lineNumberAll==nil then
                    lineNumberAll = lineNumber
                else
                    lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)
                end
            else
                lineNumberAll = "-"
            end
        end
    end
    return lineNumberAll
end

--get All line number for incomingCall in the interface path
function  getAllInCallNum1(phyIntfPath)
    
    local lineNumberAll, lineNumber, linePath, linePreassigned
    local replyIngress, error = mbus.getParameters{ path = ingressPath1, param = {"ToUA", "FromUA"}, filter="(== ToUA "..phyIntfPath..")", datamodel = "second" }

    if replyIngress[ingressPath1][1]~=nil and replyIngress[ingressPath1][1].param~=nil then
        for j,k in pairs(replyIngress[ingressPath1]) do
            linePath = k.param["FromUA"]
            -- linePreassigned = k.param["Preassigned"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                --if linePreassigned==tostring("true") then
                    --lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")"
                --end
            else
                lineNumber = "-"
            end
            if lineNumber~="-" then
                if lineNumberAll==nil then
                    lineNumberAll = lineNumber
                else
                    lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)
                end
            else
                lineNumberAll = "-"
            end
        end
    else 
	lineNumberAll = "-"	
    end
    return lineNumberAll
end


--get DECTAll line number for outgoingCall in the interface3
function getDECTAllOutCallNum()
    local lineDECTAll,lineNumber
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECTAll, error = mbus.getParameters{ path = egressPath, param = {"FromUA", "ToUA", "Preassigned"}, filter="(== FromUA "..DECTAllPath..")", datamodel = "second" }
    if replyDECTAll[egressPath]~=nil and replyDECTAll[egressPath][1]~=nil then
        for i,v in pairs(replyDECTAll[egressPath]) do
            local linePath = v.param["ToUA"]
            linePreassigned = v.param["Preassigned"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                if linePreassigned==tostring("true") then
                    lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")" 
                end 
            end
            if lineNumber~=nil then
                if lineDECTAll==nil then
                    lineDECTAll = lineNumber
                else
                    lineDECTAll = tostring(lineDECTAll) .. "<br/>" .. tostring(lineNumber)
                end
            end
        end
    end
    return lineDECTAll
end


--get DECTAll line number for outgoingCall in the interface3
function getDECTAllPriority()    
    local lineDECTAll,linePriorityAll,lineNumber
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECTAll, error = mbus.getParameters{ path = egressPath, param = {"FromUA", "ToUA", "Preassigned","Priority"}, filter="(== FromUA "..DECTAllPath..")", datamodel = "second" }
    if replyDECTAll[egressPath]~=nil and replyDECTAll[egressPath][1]~=nil then
        for i,v in pairs(replyDECTAll[egressPath]) do
            local linePath = v.param["ToUA"]
            linePreassigned = v.param["Preassigned"]
            linePriority = 	 v.param["Priority"]	     		
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                if linePreassigned==tostring("true") then
                    lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")" 
                end 
            end
            if lineNumber~=nil then
                if lineDECTAll==nil then
                    lineDECTAll = lineNumber
		    linePriorityAll = linePriority  
                else
                    lineDECTAll = tostring(lineDECTAll) .. "<br/>" .. tostring(lineNumber)
                    linePriorityAll = tostring(linePriority) .. "<br/>" .. tostring(linePriority)
                end
            end
        end
    end    
    return linePriorityAll
end
--get All line number for outgoingCall in the interface path
function  getAllOutCallNum(phyIntfPath)    
    local lineNumberAll,lineNumber, linePath, linePreassigned
    local replyEgress, error = mbus.getParameters{ path = egressPath1, param = {"FromUA", "ToUA", "Preassigned"}, filter="(== FromUA "..phyIntfPath..")", datamodel = "second" }
    if replyEgress[egressPath1][1]~=nil and replyEgress[egressPath1][1].param~=nil then
        for j,k in pairs(replyEgress[egressPath1]) do
            linePath = k.param["ToUA"]
            linePreassigned = k.param["Preassigned"]	    
	    	
            if linePath~=nil then
                lineNumber = getCallNum(linePath)
                if linePreassigned==tostring("true") then
                    lineNumber = tostring(lineNumber) .. "(" .. translate([==[preassigned]==]) .. ")"
                end
            else
                lineNumber = "-"
            end
            if lineNumber~="-" then
                if lineNumberAll==nil then
                    lineNumberAll = lineNumber                      
                else
                    lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)                    
			
                end
            else
                lineNumberAll = "-"
		
            end
        end
    end
    return lineNumberAll
end

-- For CPE_P00106895
function  getAllInOutCallNum(phyIntfPath)  
    local lineInNumberAll,lineOutNumberAll,linePriorityAll,lineNumber,linePriority, linePath, linePreassigned

    local inRow = {}
    local replyIngress, error = mbus.getParameters{ path = ingressPath1, param = {"ToUA", "FromUA"}, filter="(== ToUA "..phyIntfPath..")", datamodel = "second" }

    if replyIngress[ingressPath1][1]~=nil and replyIngress[ingressPath1][1].param~=nil then
        for j,k in pairs(replyIngress[ingressPath1]) do
            linePath = k.param["FromUA"]           
            if linePath~=nil then
                lineNumber = getCallNum(linePath)  
		inRow[j] =  lineNumber        
            end            
        end    
    end
    local inSize = #inRow

    local replyEgress, error = mbus.getParameters{ path = egressPath1, param = {"FromUA", "ToUA","Priority"}, filter="(== FromUA "..phyIntfPath..")", datamodel = "second" }    
    if replyEgress[egressPath1][1]~=nil and replyEgress[egressPath1][1].param~=nil then
        for j,k in pairs(replyEgress[egressPath1]) do
            linePath = k.param["ToUA"]
	    linePriority = 	 k.param["Priority"] 	
            if linePath~=nil then
                lineNumber = getCallNum(linePath)                
            else
                lineNumber = "-"
            end	      
	
	    local inFlag = "false"
	    for g=1,#inRow do 
		--if ( (lineNumber == inRow[g]) and (inFlag == "false") )then
		if lineNumber == inRow[g]then
			inFlag = "true"			
			table.remove(inRow,g)
			break
		end
	    end		
	    
            if lineNumber~="-" then
                if lineOutNumberAll==nil then
                    lineOutNumberAll = lineNumber
		    linePriorityAll = linePriority  	
		    if inFlag == "true" then
			lineInNumberAll = lineNumber			
		    else
			lineInNumberAll = "&nbsp;&nbsp;"
		    end			                      
                else
                    lineOutNumberAll = tostring(lineOutNumberAll) .. "<br/>" .. tostring(lineNumber) 
		    linePriorityAll = tostring(linePriorityAll) .. "<br/>" .. tostring(linePriority)
		    if inFlag == "true" then
			lineInNumberAll = tostring(lineInNumberAll) .. "<br/>" .. tostring(lineNumber) 
		    else
			lineInNumberAll = tostring(lineInNumberAll) .. "<br/>".."&nbsp;&nbsp;" 
		    end	 	                   
			
                end
            else
		lineInNumberAll = "-"
                lineOutNumberAll = "-"
		linePriorityAll = "-"
            end
        end
    else 
	lineInNumberAll = "-"
        lineOutNumberAll = "-"
	linePriorityAll = "-"	
    end

    if inSize == 0 then
	lineInNumberAll = "-"
    end
 			
    for g=1,#inRow do 
	if lineInNumberAll==nil or lineInNumberAll=="-"  then
		lineInNumberAll = inRow[g]
	else
		lineInNumberAll = tostring(lineInNumberAll) .. "<br/>" .. tostring(inRow[g]) 
	end
	if lineOutNumberAll==nil or lineOutNumberAll=="-"  then
		--lineOutNumberAll = "&nbsp;&nbsp;"
		--linePriorityAll = "&nbsp;&nbsp;"	
	else
		lineOutNumberAll = tostring(lineOutNumberAll) .. "<br/>" .. "&nbsp;&nbsp;" 
		linePriorityAll = tostring(linePriorityAll) .. "<br/>" .. "&nbsp;&nbsp;" 
	end
    end    	
    return lineInNumberAll.."##"..lineOutNumberAll.."##"..linePriorityAll
end


function  getAllOutCallNum1(phyIntfPath) 
   
    local lineNumberAll,lineNumber, linePath, linePreassigned
    local replyEgress, error = mbus.getParameters{ path = egressPath1, param = {"FromUA", "ToUA"}, filter="(== FromUA "..phyIntfPath..")", datamodel = "second" }

    if replyEgress[egressPath1][1]~=nil and replyEgress[egressPath1][1].param~=nil then
        for j,k in pairs(replyEgress[egressPath1]) do
            linePath = k.param["ToUA"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)                
            else
                lineNumber = "-"
            end
            if lineNumber~="-" then
                if lineNumberAll==nil then
                    lineNumberAll = lineNumber                      
                else
                    lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)                    
			
                end
            else
                lineNumberAll = "-"
		
            end
        end
    else 
	lineNumberAll = "-"	
    end
    return lineNumberAll
end




--get All line number for outgoingCall in the interface path
function  getAllOutPriority(phyIntfPath)
    local lineNumberAll,linePriorityAll, lineNumber, linePath, linePreassigned,linePriority
    local replyEgress, error = mbus.getParameters{ path = egressPath1, param = {"ToUA", "ToUA", "Priority"}, filter="(== FromUA "..phyIntfPath..")", datamodel = "second" }
    if replyEgress[egressPath1][1]~=nil and replyEgress[egressPath1][1].param~=nil then
        for j,k in pairs(replyEgress[egressPath1]) do
            linePath = k.param["ToUA"]            
	    linePriority = 	 k.param["Priority"]
            if linePath~=nil then
                lineNumber = getCallNum(linePath)                
            else
                lineNumber = "-"
            end
            if lineNumber~="-" then
                if lineNumberAll==nil then
                    lineNumberAll = lineNumber
                    linePriorityAll = linePriority  
                else
                    lineNumberAll = tostring(lineNumberAll) .. "<br/>" .. tostring(lineNumber)
                    linePriorityAll = tostring(linePriorityAll) .. "<br/>" .. tostring(linePriority)
			
                end
            else
                lineNumberAll = "-"
		linePriorityAll = "-"
            end
        end
    else 
	linePriorityAll = "-"	
    end
    
    return linePriorityAll
end
--Get the preassigned incoming tele number
function getPreassignedInNum(portName)
    local linePath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local lineFromUA, lineNum
    local reply, error = mbus.getParameters{path=linePath, param={"FromUA", "ToVoicePort", "Preassigned"}, filter="(and (== ToVoicePort "..portName..") (== Preassigned "..tostring("true").."))", datamodel="second"}
    if reply[linePath][1]~=nil and reply[linePath][1].param~=nil then
        for j,k in pairs(reply[linePath]) do
            lineFromUA = k.param["FromUA"]
            lineNum = getCallNum(lineFromUA)
        end
    end
    return lineNum
end

--Get the preassigned outgoing tele number
function getPreassignedOutNum(portName)
    local linePath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local lineToUA, lineNum
    local reply, error = mbus.getParameters{path=linePath, param={"ToUA", "FromVoicePort", "Preassigned"}, filter="(and (== FromVoicePort "..portName..") (== Preassigned "..tostring("true").."))", datamodel="second"}
    if reply[linePath][1]~=nil and reply[linePath][1].param~=nil then
        for j,k in pairs(reply[linePath]) do
            lineToUA = k.param["ToUA"]
            lineNum = getCallNum(lineToUA)
        end
    end
    return lineNum
end

--Get the VoiceService enable
function getFXOVoiceServiceEnable()
    local VoiceServicePath = "Device.Services.VoiceService.1.PhyInterface.4"
    local reply, error = mbus.getParameters{ path = VoiceServicePath, param = {"X_TELECOMITALIA_IT_Enable"}, datamodel = "second" }
    return reply[VoiceServicePath][1].param["X_TELECOMITALIA_IT_Enable"]
end

--Get FXO num from ENV
function getFXONum()
    local FXONum = ""
    local reply, error = mbus.getParameters{ path = "ENV", param = "Value", filter = "(== Name ".. "IsFXONum" ..")" }
    if reply["ENV"][1]~=nil and reply["ENV"][1].param~=nil then
        FXONum = reply["ENV"][1].param["Value"]
    end
    return FXONum
end

--Get FXS Enable value
function getFXSEnable(FXSPath)
    local replyEnable, error = mbus.getParameters{ path = FXSPath, param = "X_TELECOMITALIA_IT_Enable", datamodel = "second" }
    return replyEnable[FXSPath][1].param["X_TELECOMITALIA_IT_Enable"]
end

--Get Number of FXS Map
function isFXSMapNumExist(FXSPath)
    local lineNoNum = "true"
    local mapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local reply, error = mbus.getParameters{ path = mapPath, param = {"ToVoicePort", "FromUA"}, filter = "(== ToVoicePort " .. FXSPath .. ")", datamodel = "second" }
    if reply[mapPath][1]~=nil then
        lineNoNum = "false"
    end
    return lineNoNum
end

--Judge if there is any DECTAll UAMap or not
function isDECTAllObjExistInUAMap()
    local UAMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local DECTAllObjExist = "false"
    local DECTAllNumber
    local reply, error = mbus.getParameters{ path = UAMapPath, param = {"ToVoicePort", "FromUA"}, filter = "(== ToVoicePort " .. DECTAllPath .. ")", datamodel = "second" }
    if reply[UAMapPath]~=nil or reply[UAMapPath][1]~=nil then
        DECTAllObjExist = "true"
    end
    return DECTAllObjExist
end

--Judge if there is any DECTAll VoiceportMap or not
function isDECTAllObjExistInVpMap()
    local VpMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local DECTAllObjExist = "false"
    local reply, error = mbus.getParameters{ path = VpMapPath, param = {"ToUA", "FromVoicePort"}, filter = "(== FromVoicePort " .. DECTAllPath .. ")", datamodel = "second" }
    if reply[VpMapPath]~=nil or reply[VpMapPath][1]~=nil then
        DECTAllObjExist = "true"
    end
    return DECTAllObjExist
end

--Delete DECTAll obj in UAMap
function delDECTAllInUAMap()
    local UAMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local reply, error = mbus.modify(
        function()
            local reply1, error1 = mbus.deleteObjects{path = UAMapPath, filter="(and (== ToVoicePort " .. DECTAllPath .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
        end, {datamodel="second"})
    return
end

--Delete DECTAll obj in VpMap
function delDECTAllInVpMap()
    local VpMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local reply, error = mbus.modify(
        function()
            local reply1, error1 = mbus.deleteObjects{path = VpMapPath, filter="(and (== FromVoicePort " .. DECTAllPath .. ") (== Preassigned " .. "false" .. "))", datamodel = "second"}
        end, {datamodel="second"})
    return
end

--Add UAMap obj after delete the DECTAll obj
function addOtherThreeUAMapObj(DECTPath)
    local DECTHandset = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset."
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECTAll, error = mbus.getParameters{ path = ingressPath, param = {"FromUA", "ToVoicePort"}, filter = "(== ToVoicePort " .. DECTAllPath .. ")", datamodel = "second" }
    for j,k in pairs(replyDECTAll[ingressPath]) do
        local fromUAPath = k.param["FromUA"]
        local DECTAllObj = isDECTAllObjExistInUAMap()
        if DECTAllObj=="true" then
            delDECTAllInUAMap()
        end
        for i=1,4 do
            DECTHandsetPath = DECTHandset .. tostring(i)
            if tostring(DECTHandsetPath)~=tostring(DECTPath) then
                local reply, error = mbus.modify(
                    function()
                        local reply1, error1 = mbus.addObjects{ path = ingressPath, param = { FromUA = fromUAPath, ToVoicePort = DECTHandsetPath }, datamodel = "second" }
                    end, {datamodel="second"})
            end
        end
    end
end

--Add VoiceportMap obj after delete the DECTAll obj
function addOtherThreeVpMapObj(DECTPath)
    local DECTHandset = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset."
    local DECTAllPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local replyDECTAll, error = mbus.getParameters{ path = egressPath, param = {"ToUA", "FromVoicePort"}, filter = "(== FromVoicePort " .. DECTAllPath .. ")", datamodel = "second" }
    for j,k in pairs(replyDECTAll[egressPath]) do
        local ToUAPath = k.param["ToUA"]
        local DECTAllObj = isDECTAllObjExistInVpMap()
        if DECTAllObj=="true" then
            delDECTAllInVpMap()
        end
        for i=1,4 do
            DECTHandsetPath = DECTHandset .. tostring(i)
            if tostring(DECTHandsetPath)~=tostring(DECTPath) then
                local reply, error = mbus.modify(
                    function()
                        local reply1, error1 = mbus.addObjects{ path = egressPath, param = { ToUA = ToUAPath, FromVoicePort = DECTHandsetPath }, datamodel = "second" }
                    end, {datamodel="second"})
            end
        end
    end
end

--Get each DECT handset active value.
function getDECTHandsetAssociato(DECTPath)
    local reply, error = mbus.getParameters{ path = DECTPath, param = {"Active"}, datamodel = "second" }
    local DECTHandsetActive = reply[DECTPath][1].param["Active"]
    return DECTHandsetActive
end

--Judge the number is truly exist or not in the UAMap.
function findUAMapNumExist(switchPath, numPath)
    local isExist = "false"
    local UAMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local replyNumExist, error = mbus.getParameters{ path = UAMapPath, param = "FromUA", filter="(== ToVoicePort "..switchPath..")", datamodel = "second" }
    if replyNumExist[UAMapPath]~=nil and replyNumExist[UAMapPath][1]~=nil then
        for j,k in pairs(replyNumExist[UAMapPath]) do
            if k.param["FromUA"]==numPath then
                isExist = "true"
            end         
        end         
    end         
    return isExist
end

--Judge the number is truly exist or not in the UAMap.
function findUAMapNumExist1(switchPath, numPath)
    local isExist = "false"
    --local UAMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local replyNumExist, error = mbus.getParameters{ path = ingressPath1, param = "FromUA", filter="(== ToUA "..switchPath..")", datamodel = "second" }
    if replyNumExist[ingressPath1]~=nil and replyNumExist[ingressPath1][1]~=nil then
        for j,k in pairs(replyNumExist[ingressPath1]) do
            if k.param["FromUA"]==numPath then
                isExist = "true"
            end         
        end         
    end         
    return isExist
end


--Judge the number is truly exist or not in the VoiceportMap.
function findVPMapNumExist(switchPath, numPath)
    local isExist = "false"
    local VPMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local replyNumExist, error = mbus.getParameters{ path = VPMapPath, param = "ToUA", filter="(== FromVoicePort "..switchPath..")", datamodel = "second" }
    if replyNumExist[VPMapPath]~=nil and replyNumExist[VPMapPath][1]~=nil then
        for j,k in pairs(replyNumExist[VPMapPath]) do
            if k.param["ToUA"]==numPath then
                isExist = "true"
            end
        end
    end
    return isExist
end

--Judge the number is truly exist or not in the UAMap.
function findVPMapNumExist1(switchPath, numPath)
    local isExist = "false"
    --local UAMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local replyNumExist, error = mbus.getParameters{ path = egressPath1, param = "ToUA", filter="(== FromUA "..switchPath..")", datamodel = "second" }
    if replyNumExist[egressPath1]~=nil and replyNumExist[egressPath1][1]~=nil then
        for j,k in pairs(replyNumExist[egressPath1]) do
            if k.param["ToUA"]==numPath then
                isExist = "true"
            end         
        end         
    end         
    return isExist
end

--Get the priority in the VoiceportMap.
function getVPMapNumPrio(switchPath, linePath)
    local priority = ""
    local VPMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local reply, error = mbus.getParameters{ path = VPMapPath, param = "Priority", filter="(and (== FromVoicePort "..switchPath..") (== ToUA " .. linePath .. "))", datamodel = "second" }
    if reply[VPMapPath]~=nil and reply[VPMapPath][1]~=nil then
        priority = reply[VPMapPath][1].param["Priority"]
    end
    return priority
end

function getVPMapNumPrio1(fromPath,toPath)    		 		
    local priority = ""
    local VPMapPath = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"	
    local reply, error = mbus.getParameters{ path = VPMapPath, param = "Priority", filter="(and(== FromUA " .. fromPath .. ") (== ToUA " .. toPath .. "))", datamodel = "second" }
    if reply[VPMapPath]~=nil and reply[VPMapPath][1]~=nil then
        priority = reply[VPMapPath][1].param["Priority"]
    end
    return priority
end

--Judge the line number is LanManaged or not.
function isNumLanManaged(linePath)
    local isLanManaged = "false"
    local reply, error = mbus.getParameters{ path = linePath, param = "X_TELECOMITALIA_IT_LANManaged", datamodel = "second" }
    if reply[linePath]~=nil and reply[linePath][1]~=nil then
        if reply[linePath][1].param["X_TELECOMITALIA_IT_LANManaged"]=="true" then
            isLanManaged = "true"
        end
    end
    return isLanManaged
end

--Get the X_TELECOMITALIA_IT_SwitchToPSTNIn and X_TELECOMITALIA_IT_SwitchToPSTNOut from DECT interface.
function getDECTPSTNInAndOut()
    local DECTPath = "Device.Services.VoiceService.1.PhyInterface.3"
    local DECTPSTNIn, DECTPSTNOut
    local reply, error = mbus.getParameters{path=DECTPath, param={"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
    if reply[DECTPath]~=nil and reply[DECTPath][1]~=nil then
        DECTPSTNIn = reply[DECTPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]
        DECTPSTNOut = reply[DECTPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]
    end
    return DECTPSTNIn, DECTPSTNOut
end

--- Voip stato ---

function getFXSDECTSIP(phyPath)
    local sipUri,dirNum	
    --local phyPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"		 		
    local replyType, error = mbus.getParameters{ path = phyPath , datamodel = "second" }  
    for i=1,#replyType[phyPath] do
    	local replyType1, error1 = mbus.getParameters{ path = phyPath.."."..i, param= {"PhyReferenceList","DirectoryNumber" }, datamodel = "second" }	
        local replyType2, error2 = mbus.getParameters{ path = phyPath.."."..i..".SIP", param="URI" , datamodel = "second" }	       	
	if replyType1[phyPath.."."..i][1].param["PhyReferenceList"] ~= nil then
		sipUri = replyType2[phyPath.."."..i..".SIP"][1].param["URI"]
                dirNum = replyType1[phyPath.."."..i][1].param["DirectoryNumber"] 		
	end
    end	
    if sipUri ==nil then
	sipUri = ""
    end	
    if dirNum ==nil then
	dirNum = ""
    end	 	    
    return sipUri,dirNum
end

function getFXSDECTInterno()
    local phyPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line.1"	 		
    local replyType, error = mbus.getParameters{ path = phyPath, param="DirectoryNumber" , datamodel = "second" }    
    return replyType[phyPath][1].param["DirectoryNumber"]
end

local infoCount = 0
function connectionInfo()
	infoCount = 1
	local phyIntf_IP = getIPConnectionInfo()
	infoCount = 0
	return phyIntf_IP
end	


--- New IP Phone
function getIPConnectionInfo()
    
    local totalPhone
    local phyIntf_IP = {}
    local phyPath = "Device.Services.VoiceService.3.VoiceProfile."
    local replyType, error = mbus.getParameters{ path = "Device.Services.VoiceService.3", param="VoiceProfileNumberOfEntries" , datamodel = "second" }   
	local replyType1, error = mbus.getParameters{ path = "Device.Services.VoiceService.1.VoiceProfile.1", param="X_TELECOMITALIA_IT_VoicePortMapNumberOfEntries" , datamodel = "second" }   
    totalPhone = replyType["Device.Services.VoiceService.3"][1].param["VoiceProfileNumberOfEntries"] 
	totalPhone1 = replyType1["Device.Services.VoiceService.1.VoiceProfile.1"][1].param["X_TELECOMITALIA_IT_VoicePortMapNumberOfEntries"] 	
	totalPhone = tonumber(totalPhone) - tonumber(totalPhone1)
    local count=1	
    if( totalPhone ~= nil ) then	
		--Hardcoded as 1 and 10 to avoid displaying FXS/DECT
		--for i=2,tonumber(totalPhone) do
		--Hardcoded due to swapping of FXS and Telefono IP
    		--for i=1,tonumber(totalPhone) do
	    for i= 2, 11 do
	    local path1 = phyPath..i..".Line.1"
	    local path2 = phyPath..i..".Line.1.SIP"
	    
	    local replyType1, error1 = mbus.getParameters{ path = path1 , param={"Enable","DirectoryNumber","X_TELECOMITALIA_IT_LineName","X_TELECOMITALIA_IT_PhyAssignment"} , datamodel = "second" }
	    local replyType2, error2 = mbus.getParameters{ path = path2, param="URI" , datamodel = "second" }		
	    if(replyType1[path1][1].param["X_TELECOMITALIA_IT_PhyAssignment"] ~= "Not Assigned") then			
	    	phyIntf_IP[count] = {}		
            	phyIntf_IP[count].enable = replyType1[path1][1].param["Enable"]	
            	phyIntf_IP[count].directory = replyType1[path1][1].param["DirectoryNumber"]
		phyIntf_IP[count].name = replyType1[path1][1].param["X_TELECOMITALIA_IT_LineName"]
            	phyIntf_IP[count].uri = replyType2[path2][1].param["URI"]
		phyIntf_IP[count].proInstance = i	
		phyIntf_IP[count].path = phyPath..i
		if infoCount == 0 then
			phyIntf_IP[count].AllInOutCallNum1 = getAllInOutCallNum1(i)
		end
		count = count+1
	    end	

        end	
    end			    
    return phyIntf_IP
end

function getTelefonoIPInfo()
    local telefonoIPName,username
    local replyType, error = mbus.getParameters{ path = "Device.Services.VoiceService.3.VoiceProfile", param="Enable" , datamodel = "second" }   
    username = #replyType["Device.Services.VoiceService.3.VoiceProfile"] +1
    telefonoIPName = "Telefono IP "..#replyType["Device.Services.VoiceService.3.VoiceProfile"]+1    
    return telefonoIPName,username 
end

function getIpProfiles(path)    	
    local replyType, error = mbus.getParameters{ path = path , datamodel = "second" }      
    return #replyType[path]
end

function getRegister(path)    
    local replyType, error = mbus.getParameters{ path = path, param="UserAgentDomain" , datamodel = "second" }          
    return replyType[path][1].param["UserAgentDomain"]
end

function getUsername(path)
    local replyType, error = mbus.getParameters{ path = path, param="DirectoryNumber" , datamodel = "second" }         
    return replyType[path][1].param["DirectoryNumber"]
end

function checkIPConfBtn()
    local replyType, error = mbus.getParameters{ path = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage" ,param="VoIPDetailEnable" , datamodel = "second" }      
    return replyType["Device.UserInterface.X_TELECOMITALIA_IT_WebPage"][1].param["VoIPDetailEnable"]
end

function getFXSDECTSIP1(phyPath)
    local dirNum ={}
    local replyType, error = mbus.getParameters{ path = phyPath , datamodel = "second" }  
    for i=1,#replyType[phyPath] do
		dirNum[i]={}
    	local replyType1, error1 = mbus.getParameters{ path = phyPath.."."..i, param= {"PhyReferenceList","DirectoryNumber" }, datamodel = "second" }	
       	if replyType1[phyPath.."."..i][1].param["PhyReferenceList"] ~= nil then
		  dirNum[i].val = replyType1[phyPath.."."..i][1].param["DirectoryNumber"] 		
		end
		if dirNum[i].val ==nil then
		 dirNum[i].val = ""
		end	 
    end	
   return dirNum
end

--To userAgent Domain
function getUserAgent(getPath)
    local reply, error = mbus.getParameters{ path = getPath, param = "UserAgentDomain", datamodel = "second" }
    if reply[getPath]~=nil and reply[getPath][1]~=nil and reply[getPath][1].param["UserAgentDomain"]~=nil  then
       return reply[getPath][1].param["UserAgentDomain"]           
    end
end

--To get the Associated Number
function  getAllInOutCallNum1(count)  
    local lineInNumberAll,lineOutNumberAll,linePriorityAll,lineNumber,linePriority, linePath, linePreassigned
    local phyIntfPath = "Device.Services.VoiceService.3.VoiceProfile."..count..".Line.1"
    local inRow = {}
    local replyIngress, error = mbus.getParameters{ path = ingressPath1, param = {"ToUA", "FromUA"}, filter="(== ToUA "..phyIntfPath..")", datamodel = "second" }

    if replyIngress[ingressPath1][1]~=nil and replyIngress[ingressPath1][1].param~=nil then
        for j,k in pairs(replyIngress[ingressPath1]) do
            linePath = k.param["FromUA"]           
            if linePath~=nil then
                lineNumber = getCallNum(linePath)  
		inRow[j] =  lineNumber        
            end            
        end    
    end
    local inSize = #inRow

    local replyEgress, error = mbus.getParameters{ path = egressPath1, param = {"FromUA", "ToUA","Priority"}, filter="(== FromUA "..phyIntfPath..")", datamodel = "second" }    
    if replyEgress[egressPath1][1]~=nil and replyEgress[egressPath1][1].param~=nil then
        for j,k in pairs(replyEgress[egressPath1]) do
            linePath = k.param["ToUA"]
	    linePriority = 	 k.param["Priority"] 	
            if linePath~=nil then
                lineNumber = getCallNum(linePath)                
            else
                lineNumber = "-"
            end	      
	
	    local inFlag = "false"
	    for g=1,#inRow do 
		--if ( (lineNumber == inRow[g]) and (inFlag == "false") )then
		if lineNumber == inRow[g]then
			inFlag = "true"			
			table.remove(inRow,g)
			break
		end
	    end		
	    
            if lineNumber~="-" then
                if lineOutNumberAll==nil then
                    lineOutNumberAll = lineNumber
		    linePriorityAll = linePriority  	
		    if inFlag == "true" then
			lineInNumberAll = lineNumber			
		    else
			lineInNumberAll = "&nbsp;&nbsp;"
		    end			                      
                else
                    lineOutNumberAll = tostring(lineOutNumberAll) .. "<br/>" .. tostring(lineNumber) 
		    linePriorityAll = tostring(linePriorityAll) .. "<br/>" .. tostring(linePriority)
		    if inFlag == "true" then
			lineInNumberAll = tostring(lineInNumberAll) .. "<br/>" .. tostring(lineNumber) 
		    else
			lineInNumberAll = tostring(lineInNumberAll) .. "<br/>".."&nbsp;&nbsp;" 
		    end	 	                   
			
                end
            else
		lineInNumberAll = "-"
                lineOutNumberAll = "-"
		linePriorityAll = "-"
            end
        end
    else 
	lineInNumberAll = "-"
        lineOutNumberAll = "-"
	linePriorityAll = "-"	
    end

    if inSize == 0 then
	lineInNumberAll = "-"
    end
 			
    for g=1,#inRow do 
	if lineInNumberAll==nil or lineInNumberAll=="-"  then
		lineInNumberAll = inRow[g]
	else
		lineInNumberAll = tostring(lineInNumberAll) .. "<br/>" .. tostring(inRow[g]) 
	end
	if lineOutNumberAll==nil or lineOutNumberAll=="-"  then
		--lineOutNumberAll = "&nbsp;&nbsp;"
		--linePriorityAll = "&nbsp;&nbsp;"	
	else
		lineOutNumberAll = tostring(lineOutNumberAll) .. "<br/>" .. "&nbsp;&nbsp;" 
		linePriorityAll = tostring(linePriorityAll) .. "<br/>" .. "&nbsp;&nbsp;" 
	end
    end    	
    return lineInNumberAll.."##"..lineOutNumberAll.."##"..linePriorityAll
end
%>
