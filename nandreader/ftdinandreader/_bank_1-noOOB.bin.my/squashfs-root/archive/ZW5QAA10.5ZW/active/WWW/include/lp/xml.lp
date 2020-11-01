<%
--Set the session variable for xml file
local xmlStr=""
local fxoNumber = ""
--The param of the node name for single object query(the default value is Device).
local configurationData="Device"

--Set the value of session variable "configurationData"
local function setConfigurationData(value)
	if value ~= nil then
		configurationData = value
	end
end

--Get the value of session variable "configurationData"
local function getConfigurationData()
	return configurationData 
end

--Judge whether the table is null
function table_is_empty(t)
        return _G.next( t ) == nil
end

--Generate the tag start
--like <name> 
--or <name id="num">
function generateTagStart(name, num)
	local tagName=string.gsub(name, " ", "")
	local tagStart="\<" .. tagName .. "\>"
	if num ~= nil then
		tagStart="\<" .. tagName .." id=\""..num.."\"\>"	
	end
	return tagStart
end

--Generate the tag end
--like </name> 
function generateTagEnd(name)
	local tagName=string.gsub(name, " ", "")
	local tagEnd="\</" .. tagName .. "\>"
	return tagEnd
end

--To create the tag for params by path
--like <path><param>value</param></path> 
--or <path id="1"><param>value</param></path>
function getTag(tagName, paramVal, num)
	local tagStart=generateTagStart(tagName, num)
	local tagEnd=generateTagEnd(tagName)
	local tagVal = "\<" .. tagName .."/\>"
--[[
    paramVal = string.gsub(paramVal, "<", "&lt;")
    paramVal = string.gsub(paramVal, ">", "&gt;")
    paramVal = string.gsub(paramVal, "\"", "&quot;")
]]
	if paramVal~="" and paramVal~=nil then
		tagVal = tagStart .. paramVal .. tagEnd
	end
	return tagVal
end

--To get the mutil instance path by mbus
function getMutilPath_T(pathStr)
	local stack = {}
	local data, error = mbus.getParameters{path=pathStr, datamodel="second"}
	for i,v in pairs(data[pathStr]) do
		table.insert(stack, v.path)
	end
	return stack
end

--To intergrate the groups of the path and params
function setMutilObjects_T(path_T, param_T)
	local set = {}
	while #path_T>0 do
		local pathTop = table.remove(path_T)
		table.insert(set, {path=pathTop, param=param_T})
	end
	
	return set
end

--get all the multi instance groups 
function getMutilObjects_T(set)
	local path = set["path"]
	local param = set["param"]
	local pathStack={}	
	local pathStr=""
	for s in string.gmatch(path, "[^.]+") do
		if s~="{i}" then
			if #pathStack>0 then
				for i,v in pairs(pathStack) do
					pathStack[i] = pathStack[i] ..".".. s					
				end
			else	
				table.insert(pathStack, s)
			end
		else
			local multiStack={}
			local tmpStack={}
			while #pathStack>0 do
				local pathTop = table.remove(pathStack)
				multiStack = getMutilPath_T(pathTop) 				
				for i,v in pairs(multiStack) do
					table.insert(tmpStack, v)
				end
			end
			pathStack = tmpStack
		end
	end
	local objects_T = setMutilObjects_T(pathStack, param)
	return objects_T
end

--get param tag by the data of mbus
function getParamsTagByData(path, params_T, data_T, lastIndex)
	local g, f, pathObjName = string.find(path, "%.([^.]+)$")
	local paramArray = {}	
	for i,elem_T in pairs(data_T[path]) do
		local flag = true
		if lastIndex~=nil then
			if path.."."..tostring(lastIndex) ~= elem_T["path"] then
				flag = false
			end
		end
		if flag == true and table_is_empty(elem_T["param"])==false then
			local paramStr = "" 
			for j,paramName in pairs(params_T) do
				if elem_T.param[paramName] ~= nil then
					local paramVal = elem_T.param[paramName]
                    --add special sign such as "& < >" solution
                    paramVal = string.gsub(paramVal, "&", "&amp;")
                    paramVal = string.gsub(paramVal, "<", "&lt;")
                    paramVal = string.gsub(paramVal, ">", "&gt;")
                    paramVal = string.gsub(paramVal, "\"", "&quot;")
					if pathObjName == paramName then
						paramName = paramName .. "_ReplaceWord"
					end
					local paramTmp = getTag(paramName, tostring(paramVal))		
					paramStr = paramStr .. paramTmp
				end
			end
			table.insert(paramArray, paramStr)
		end		
	end	
	return paramArray
end

--Get the path start position of the xml, from left to right like aaa.bbb.1
--Find the start position like <path> or <path id="num">
--then find another start position like <pathChild> or <pathChild id="num">
function getPathPositionStart(pathStack)
	local pathPosition=1
	local index = 1
	local resultIdx=index
	while index <= #pathStack do
		local path = pathStack[index]		
		local tagStart = generateTagStart(path)
		
		--if it is multi object, the next child node is number
		if pathStack[index+1]~=nil and tonumber(pathStack[index+1])~=nil then
			index = index + 1 
			local nodeNum = pathStack[index]
			tagStart = generateTagStart(path, nodeNum)
		end
		resultIdx = index 
	
		local posStart = string.find(xmlStr, tagStart, pathPosition)
		if posStart==nil or posStart<pathPosition then
			resultIdx = resultIdx - 1
			if tonumber(pathStack[index])~=nil then
				resultIdx = resultIdx - 1
			end
			break 
		end
		pathPosition = posStart
		index = index + 1 
	end
	if pathPosition==1 then		
		pathPosition=nil	
	end
	return resultIdx, pathPosition
end

--Get the path end position of the xml
--To find the pattern like "</path>" after the start position 
function getPathPositionEnd(path, pathStartPos)
	local pathTagEnd = generateTagEnd(path)
	local pathPosition = string.find(xmlStr,pathTagEnd,pathStartPos)		
	return pathPosition
end

--To find whether the path exist in the xml file 
--If unexist, return nil
function findPath(pathTagStart, pathStartPos)	

	local result = string.find(xmlStr,pathTagStart,pathStartPos)

	return result
end

--Generate the xml 
function generateXml(pathStack, pathStr)
	local index, pathStartPos = getPathPositionStart(pathStack)
	local total = #pathStack
	while total>=index do
		if xmlStr~="" and total==index  then
			break
		end
		local parentPath = table.remove(pathStack)
		if parentPath==nil then
			break
		end
		total = total -1
		local nodeNum	
		if tonumber(parentPath)~=nil then
			nodeNum = parentPath
			parentPath = table.remove(pathStack)
			total = total -1
		end
		local nextTagStart = generateTagStart(parentPath, nodeNum)		
		local nextTagEnd = generateTagEnd(parentPath)
		pathStr = nextTagStart .. pathStr .. nextTagEnd
	end
	if xmlStr=="" then
		xmlStr = pathStr
		return
	end
	local path = table.remove(pathStack)
    --TI needs ManageableDevice even it is empty.
    if path==nil then
        path = "Device"
    end
	if tonumber(path)~=nil then		
		path = table.remove(pathStack)	
	end
	local pathEndPos = getPathPositionEnd(path, pathStartPos)
	if path == "Device" and pathStack[2]~="UPnP" then		
		local pathEndPosNext = pathEndPos + 1
		while pathEndPosNext ~= nil do
			pathEndPosNext = getPathPositionEnd(path, pathEndPosNext)
			if pathEndPosNext ~= nil then
				pathEndPos = pathEndPosNext
				pathEndPosNext = pathEndPosNext + 1
			end		
		end
	end
	xmlStr = string.sub(xmlStr, 1, pathEndPos-1) .. pathStr .. string.sub(xmlStr, pathEndPos, string.len(xmlStr))	
end

--Filter the object by the special path from url param.
function filterConfigurationData(pathStr)
	local result = false
	local lastIndex 
	local configurationDataStr = getConfigurationData()
	local isChildObj = string.find(pathStr, tostring(configurationDataStr))
	
	if isChildObj ~= nil then
		result = true
	else
		local i, f, ext = string.find(configurationDataStr, "%.([^.]+)$")
		if type(tonumber(ext)) == "number" then		
			if pathStr.."."..ext == configurationDataStr then
				lastIndex = ext
			end	
		end
	end
	return result, lastIndex
end

--Get data by the mbus of the object to generate the xml file
--The obj_T includes path and params as obj_T = {path=***,params={"***"...}}
function getXmlByData(obj_T)
	local paramArray = {}
	local pathStack={}
	local pathDetail = obj_T["path"]
	local params_T = obj_T["param"]
	local isSingleObjQuery, lastIndex = filterConfigurationData(pathDetail) 
	if isSingleObjQuery==false and lastIndex==nil then	
		return
	end

	local data, error = mbus.getParameters{path=pathDetail, datamodel="second"}
    --TI needs ManageableDevice even it is empty.
    if string.match(tostring(pathDetail), "ManageableDevice")~=nil and data[pathDetail][1]==nil then
        table.insert(pathStack, "ManagementServer")
        local pathStr = ""
        generateXml(pathStack, pathStr)
    end
	if data[pathDetail][1]~=nil then
		--process params as <param>val</param>
		paramArray = getParamsTagByData(pathDetail, params_T, data, lastIndex)
		if table_is_empty(paramArray)==false then
			--process path		
			for pathElem in string.gmatch(pathDetail, "[^.]+") do
				table.insert(pathStack, pathElem)
			end		
			local pathElement = table.remove(pathStack)
			local pathStr = ""
			for i,paramStr in pairs(paramArray) do
				local paramTag = getTag(pathElement, paramStr)
				if data[pathDetail][1].path~=pathDetail then --multi instance
					if lastIndex==nil then
						paramTag = getTag(pathElement, paramStr, i)
					else
						paramTag = getTag(pathElement, paramStr, lastIndex)
					end
				end
				pathStr = pathStr .. paramTag
			end	
			generateXml(pathStack, pathStr)
		end
	end	
end

--Iterator Multi instance
function iteratorMultiObj(multiObj_T)	
	for i,obj_T in pairs(multiObj_T) do
		getXmlByData(obj_T)
	end	
end

--Iterator every object, including multi instance and single instance.
function iteratorObjects(obj_T)
	local path = obj_T["path"]
	local isMultiObj = string.find(path, "{i}")
	if isMultiObj ~= nil then
		local multiObj_T = getMutilObjects_T(obj_T)
		table.sort(multiObj_T, function(x, y) return string.lower(x["path"]) < string.lower(y["path"]) end)
		iteratorMultiObj(multiObj_T)
	else
		getXmlByData(obj_T)
	end
end

--Create the xml for the object groups
function createXmlByObjects(objs)
  	for i,obj_T in pairs(objs) do
		iteratorObjects(obj_T)
	end	
end

local function parseargs(s)
	local arg = {}
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
		arg[w]=a
	end)
	if arg["id"]~=nil then
		return arg["name"]..".{"..arg["id"].."}"
	end
	return arg["name"]
end
		
local function collect(s)
	
	local ni,c,label,xarg, empty
	local i, j = 1, 1
	local type=""
	local stack={}
	local top = {}
	local param={}
	local path={}
	
	while true do
		ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
		if not ni then break end
	 
		if label == "xs:element" then

			if empty == "/" then	-- empty element tag

				local arg=parseargs(xarg)					
				table.insert(param,arg)

			elseif c == "" then	 -- start tag
				local arg=parseargs(xarg)	
				table.insert(top,arg)

				local lastPath=""
				if #path>0 then
					lastPath=path[#path].."."
				end
				table.insert(path,lastPath..arg)

			else	-- end tag		

				if type=="param" then
					
					local toclose = table.remove(top)					
					table.insert(param, toclose)		
					type=""
				else
					if #param>0 then
						local pathInfo = path[#path]
						local lastMutilIdx = string.find(pathInfo,".{i}",string.len(pathInfo)-4)
						if lastMutilIdx~=nil then
							pathInfo = string.sub(pathInfo,1,string.len(pathInfo)-4)
						end
												
						table.insert(stack,{path=pathInfo,param=param})
						param={}
					end
				end
				table.remove(path)
			end
 		elseif label == "xs:simpleType" then
			type="param"	
		elseif label == "xs:complexType" then
			if #param>0 and c~="/" then
				local pathInfo = path[#path-1]
				local lastMutilIdx = string.find(pathInfo,".{i}",string.len(pathInfo)-4)
				if lastMutilIdx~=nil then
					pathInfo = string.sub(pathInfo,1,string.len(pathInfo)-4)
				end
				table.insert(stack,{path=pathInfo,param=param})
				param={}
			end
		end
		i = j+1
	end
	--table.sort(stack, function(x, y) return string.lower(x["path"]) < string.lower(y["path"]) end)
	return stack
end

--Read the template of xml
function readXmlTemplate(type)
	local open=io.open
	local src
	local schemaPath=cgilua.servervariable"SERVER_ROOT".."include/lp/TIWLS_schema.xml"
	if type=="widget" then
		schemaPath=cgilua.servervariable"SERVER_ROOT".."include/lp/TIWLS_widget_schema.xml"
	end
	if type=="Backup" then
		schemaPath=cgilua.servervariable"SERVER_ROOT".."include/lp/TIWLS_backup_schema.xml"
	end
    
	-- read the whole contents of the xml file
	local fh = open (schemaPath)
	if fh~=nil then
		src = fh:read("*a")		
		--cgilua.print(src)
		--cgilua.print("<br>xml file is read<br>")
	end
	fh:close()	
	return src
end

--To get the device log from the file of "/var/localsyslog"
function getDeviceLog()
	local confUrl = getConfigurationData()
	if confUrl=="Device" or confUrl=="Device.DeviceInfo" then
		
		local reply, error = mbus.modify(
		function()
                	local reply1, error1 = mbus.setParameters{ path = "TI_STORE.TiUserIntf", param = { SaveDeviceLog="1"}}
		end)		
		local open=io.open
		local filePath = "/var/localsyslog"
		local deviceLog = ""
		local fh = open (filePath)
		if fh~=nil then
			deviceLog = fh:read("*a")		
		end
		fh:close()
		deviceLog = "<DeviceLog>" .. deviceLog .. "</DeviceLog>"
		local pathEndPos = getPathPositionEnd("DeviceInfo")
		xmlStr = string.sub(xmlStr, 1, pathEndPos-1) .. deviceLog .. string.sub(xmlStr, pathEndPos, string.len(xmlStr))
	end
end

--To get the wan type as "Phibra", "ADSL", "VDSL"
function getWanType()
	local wanType = "ADSL"
	local wanTypePath = "Device.UserInterface.X_TELECOMITALIA_IT_WebPage"

	local data, error = mbus.getParameters{path=wanTypePath, param="Profile", datamodel="second"}
	if data[wanTypePath][1]~=nil then
		if data[wanTypePath][1].param["Profile"]~="" and data[wanTypePath][1].param["Profile"]~=nil then
			wanType = data[wanTypePath][1].param["Profile"]
		end
	end
	return wanType
end

--Write xml to /tmp/AGconfig.xml.
function writeToXmlFile(type)
	--If it doesn't exist in the datamodel of IGD, it should be reported error as invalid output.
	if xmlStr=="" then
		httperror(510, "Invalid output")		
	end
	local open=io.open
	local xmlPath="/tmp/AGConfig.xml"
	if type=="widget" then
		xmlPath="/tmp/Widget.xml"
	end
	local fh = open (xmlPath, "w")
	if fh~=nil then
		--getDeviceLog()		
		local xmlStart="\<?xml version=\"1.0\" encoding=\"UTF-8\"?\>"	
		xmlStr = string.gsub(xmlStr, "_ReplaceWord", "")
		local wanType = getWanType()
		local rootTagWithWanType="<Device xmlns=\"http://www.telecomitalia.it/agconfig_agplus-m5\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.telecomitalia.it/agconfig_agplus-m5\" elementFormDefault=\"qualified\" id=\"NewDataSet\">"
		xmlStr = rootTagWithWanType .. string.sub(xmlStr, 9, string.len(xmlStr))
		fh:write(xmlStart .. tostring(xmlStr))
	end
	fh:close()	
end

--get the atomic web type.
function getAtomWebType()
    local webTypePath = "WLAN.Intf.wl_ssid1_local0.Security"
    local reply, error = mbus.getParameters{ path = webTypePath, param = {"Mode"},flags="KEYPATH"}
    local webType = reply[webTypePath][1].param["Mode"]
    if webType=="WEP" then
        return true
    end
    return false
end

--Get the atomic webkey.
function getAtomWebkey()
    local webkeyPath = "WLAN.Intf.wl_ssid1_local0.Security.WEP"
    local reply, error = mbus.getParameters{ path = webkeyPath, param = {"WEPKey"},flags="KEYPATH"}
    local webkey = reply[webkeyPath][1].param["WEPKey"]
    return webkey
end

--Get FXO number from ENV.
function getFXONumber()
    local fxoNumber = ""
    local reply, error = mbus.getParameters{ path = "ENV", param = { "Name", "Value" }, filter = "(== Name ".. "IsFXONum" ..")" }
    if reply["ENV"]~=nil and reply["ENV"][1]~=nil then
        fxoNumber = reply["ENV"][1].param["Value"]
    end
    return fxoNumber
end

--Write xml to /tmp/AGconfig.xml for backup and restore.
function writeToXmlFileForBR(type)
    --If it doesn't exist in the datamodel of IGD, it should be reported error as invalid output.
    if xmlStr=="" then
        httperror(510, "Invalid output")    
    end 
    --If the wepkey is WEP, get the atomic path of WLAN.Intf.wl_ssid1_local0.Security.WEPKey and backup it.
    local isWebType = getAtomWebType()
    if isWebType==true then
        local webKey = getAtomWebkey()
        local xmlStrWithWebkey = string.sub(xmlStr, 1, -10)
        local webkeyTag = "<WEPKeyInAtomic>" .. tostring(webKey) .. "</WEPKeyInAtomic>"
        xmlStr = xmlStrWithWebkey .. webkeyTag .. "</Device>"
    end

    --Get the ENV of FXO Number value.
    local fxoNumber = getFXONumber()
    
    local xmlStrWithENV = string.sub(xmlStr, 1, -10)
    local ENVTag = "<FXONumber>" .. tostring(fxoNumber) .. "</FXONumber>"
    xmlStr = xmlStrWithENV .. ENVTag .. "</Device>"

    local open=io.open
    local xmlPath="/tmp/AGConfig.xml"
    if type=="widget" then
        xmlPath="/tmp/Widget.xml"
    end 
    local fh = open (xmlPath, "w")

    if fh~=nil then
        --getDeviceLog()        
        local xmlStart="\<?xml version=\"1.0\" encoding=\"UTF-8\"?\>"   
        xmlStr = string.gsub(xmlStr, "_ReplaceWord", "") 
        local wanType = getWanType()
        local rootTagWithWanType="<Device xmlns=\"http://www.telecomitalia.it/agconfig_agplus-m5\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.telecomitalia.it/agconfig_agplus-m5\" elementFormDefault=\"qualified\" id=\"NewDataSet\">"
        xmlStr = rootTagWithWanType .. string.sub(xmlStr, 9, string.len(xmlStr))
        fh:write(xmlStart .. tostring(xmlStr))
    end 
    fh:close()  
end

--Start to create xml .
function xmlCreate(objNode) 
	local xmlObjNode = objNode
	local type = nil
	if objNode == "WidgetAssurance" then
		xmlObjNode = "Device"
		type = "widget"
	end
	local src = readXmlTemplate(type)
	local objs = collect(src)
	setConfigurationData(xmlObjNode)
	createXmlByObjects(objs)
	writeToXmlFile(type)	
end

--Start to create xml for Backup and Restored.
function xmlCreateBR(objNode) 
    local xmlObjNode = "Device"
    local type = "Backup"
    local src = readXmlTemplate(type)
    local objs = collect(src)
    setConfigurationData(xmlObjNode)
    createXmlByObjects(objs)

    --Fix for CQ CPE_P00121582
    --Instead calling writeToXmlFileforBR() writeToXmlFile() is called
    writeToXmlFile(type)
end

--Fix For CQ CPE_P00120870 Starts
--Encrypt the xml file to kry file
--mode:0 DECRYPT, 1 -- ENCRYPT
function xmlEncryptAndDecrypt(mode)
    local inputFile="/tmp/AGConfig.xml"
    local outputFile = "/tmp/AGConfig.kry"
    if mode == 0 then
        inputFile="/tmp/AGConfig.kry"
        outputFile="/tmp/AGConfig.xml"
    end
    local key = "a0dd1da4242d32424fdffaa0ed0e0f12"
    local iv  = "00000000000000000000000000000000"
    local error = xml_encryption(inputFile, outputFile, key, iv, mode)
    return error
end
--Fix For CQ CPE_P00120870 Ends

--Encrypt the xml file to kry file 
--mode:0 DECRYPT, 1 -- ENCRYPT
function widgetXmlEncryptAndDecrypt(mode)
    local inputFile="/tmp/Widget.xml" 
    local outputFile="/tmp/Widget.kry"
    if mode == 0 then
        inputFile="/tmp/Widget.kry"
        outputFile="/tmp/Widget.xml"
    end 
    local key = "a0dd1da4242d32424fdffaa0ed0e0f12"
    local iv  = "00000000000000000000000000000000"
    local error = xml_encryption(inputFile, outputFile, key, iv, mode)
    return error
end
%>
