<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/> -->
<link rel="stylesheet" href="css/master.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/script.js"></script>
    <script language="JavaScript" type="text/javascript">
   if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
		window.parent.menu.document.getElementById("tele").className="submenuselect1";
		window.parent.menu.document.getElementById("teleSub").style.display="block";	
	}
	
	if(window.parent.menu.document.getElementById("usbst")!=null && 
		window.parent.menu.document.getElementById("usbst") != "undefinded") {
		window.parent.menu.document.getElementById("usbst").className="";
	}

	if(window.parent.menu.document.getElementById("media")!=null && 
		window.parent.menu.document.getElementById("media") != "undefinded") {
		window.parent.menu.document.getElementById("media").className="";
	}

	if(window.parent.menu.document.getElementById("ipv6")!=null && 
		window.parent.menu.document.getElementById("ipv6") != "undefinded") {
		window.parent.menu.document.getElementById("ipv6").className="";
		if(window.parent.menu.document.getElementById("ipv6list")) {
			window.parent.menu.document.getElementById("ipv6firewall").className="";
			window.parent.menu.document.getElementById("ipv6list").style.display="none";
		}
	}

	if(window.parent.menu.document.getElementById("port")!=null && 
		window.parent.menu.document.getElementById("port") != "undefinded") {
		window.parent.menu.document.getElementById("port").className="";
	}

	if(window.parent.menu.document.getElementById("dns")!=null && 
		window.parent.menu.document.getElementById("dns") != "undefinded") {
		window.parent.menu.document.getElementById("dns").className="";
	}
	if(window.parent.menu.document.getElementById("firewa")!=null && 
		window.parent.menu.document.getElementById("firewa") != "undefinded") {
		window.parent.menu.document.getElementById("firewa").className="";
	}
	if(window.parent.menu.document.getElementById("urlfi")!=null && 
		window.parent.menu.document.getElementById("urlfi") != "undefinded") {
		window.parent.menu.document.getElementById("urlfi").className="";
	}

	if(window.parent.menu.document.getElementById("waon")!=null && 
		window.parent.menu.document.getElementById("waon") != "undefinded") {
		window.parent.menu.document.getElementById("waon").className="";
	}
	if(window.parent.menu.document.getElementById("stru")!=null && 
		window.parent.menu.document.getElementById("stru") != "undefinded") {
		window.parent.menu.document.getElementById("stru").className="";
	}	
  </script>

<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/form.lp")%>
<% cgilua.lp.include("lp/voip.lp")%>

<%
local tprint = require("tableprint")


local translate = translate
local QUERY = cgilua.QUERY
local POST=cgilua.POST

local isRemote = isRemoteAccess()
if cgilua.servervariable"REQUEST_METHOD" == "POST" then
    local rowIndex = POST["rowIndex"]
	local assoNum = POST["assoNum"]
    local rowIPIndex = POST["rowIPIndex"]
	local rowDelIPIndex = POST["rowDelIPIndex"]
	local delIPFlag = POST["delIPFlag"]
	
    local pageStr
	
    if rowIndex ~= nil then
		if assoNum ~= nil and assoNum ~= "-" and assoNum ~="" then
			pageStr = "voipConfig.lp?pathId="..(tonumber(rowIndex)).."&assoNum="..(tostring(assoNum))
		else
			pageStr = "voipConfig.lp?pathId="..(tonumber(rowIndex)).."&assoNum=-"
		end
		cgilua.redirect(tostring(pageStr))
	end	
	
	if delIPFlag == "true" then
		
		local linePath = "Device.Services.VoiceService.3.VoiceProfile."..rowDelIPIndex..".Line.1"
		
		local deleteUAmapPath = "Device.Services.VoiceService.2.X_TELECOMITALIA_IT_UAMapping"
		local reply, error = mbus.modify(
		function()
			local reply1, error1 = mbus.deleteObjects{path = deleteUAmapPath, filter="(== ToUA " .. linePath .. ")", datamodel = "second"}                    
        end, {datamodel="second"})
		
		local deleteVoiceportmapPath = "Device.Services.VoiceService.3.X_TELECOMITALIA_IT_UAMapping"
        local replyv1, errorv1 = mbus.modify(
        function()        
            local reply2, error2 = mbus.deleteObjects{path = deleteVoiceportmapPath, filter="(== FromUA " .. linePath .. ")", datamodel = "second"}
        end, {datamodel="second"})
		
		-- Fix for CPE_P00104073 : Reset the VoiceProfile Line Instance values to factory default values
		-- Sample default values taken for Voice Profile 2 after Factory reset
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.Enable: Enabled
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.DirectoryNumber: **02
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.SIP.AuthUserName: **02
  		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.SIP.AuthPassword: 02
  		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.SIP.URI: **02@192.168.1.1
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.X_TELECOMITALIA_IT_PhyAssignment: Not Assigned
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.X_TELECOMITALIA_IT_LineName: Telefono IP 1
		-- Device.Services.VoiceService.3.VoiceProfile.2.Line.1.X_TELECOMITALIA_IT_MACAddress: 
		
		-- Use Mbus Modify Parameters api
		--if rowDelIPIndex ~= "10" then
		--Changed this condition to have rowDelIPIndex as 11
		
		if tonumber(rowDelIPIndex) < 10 then
			directoryNumber = "**0"..rowDelIPIndex..""
			authUserName = "**0"..rowDelIPIndex..""
			authPassword = "0"..rowDelIPIndex..""
			--local sipURI = "**0"..rowDelIPIndex.."@192.168.1.1"
		elseif rowDelIPIndex == "11" then
			directoryNumber = "**01"
			authUserName = "**01"
			authPassword = "01"
		else
			directoryNumber = "**"..rowDelIPIndex..""
			authUserName = "**"..rowDelIPIndex..""
			authPassword = ""..rowDelIPIndex..""
		end
		
		--commented for CPE_P00121126
		--local lineInstanceCount = rowDelIPIndex - 1
		local lineInstanceCount = rowDelIPIndex
		local lineName
		if(lineInstanceCount=="11")then
			lineName = "Telefono IP 1"
		else
			lineName = "Telefono IP "..lineInstanceCount..""
		end
		local linePhyAlignment="Not Assigned"
		local macAddress=""
		
		-- Change the Factory Default values for Line Parameters
		local reply, error = mbus.modify(
			function()
				local reply, error = mbus.setParameters{path=linePath, param={Enable="Enabled",DirectoryNumber=directoryNumber}, datamodel = "second"}
				end, {datamodel="second"})

		-- Change the Factory Default values for Line Path SIP Parameters
		local linePathSIP = ""..linePath..".SIP"
		local reply, error = mbus.modify(
			function()
				local reply, error = mbus.setParameters{path=linePathSIP, param={AuthUserName=authUserName,AuthPassword=authPassword}, datamodel = "second"}
				end, {datamodel="second"})

		-- Change the LineName and PhyAssignment value to the Factory Default values
		local sipServerPath = "SIPServer.InternalUA."..rowDelIPIndex..""
		local reply, error = mbus.modify(
			function()
				local reply1, error1 = mbus.setParameters{path=sipServerPath,param={MacAddress=macAddress,Linename=lineName,PhyAssignment=linePhyAlignment},flags="KEYPATH"}
			end)
	else
		if rowIPIndex ~= nil then
			pageStr = "ipConfig.lp?pathId="..(tonumber(rowIPIndex))
			cgilua.redirect(tostring(pageStr))
		end	
    end	    
end

local userAgent = getUserAgent("Device.Services.VoiceService.3.VoiceProfile.1.SIP")
if(userAgent ~= nil)then
	userAgent = "<Numero interno>@" .. userAgent
end
--local sipUri,dirNum = getFXSDECTSIP("Device.Services.VoiceService.1.VoiceProfile.1.Line")

%>
</head>

<body>
<script type="text/javascript">

if(window.parent.menu.document.getElementById("tele")!=null && 
		window.parent.menu.document.getElementById("tele") != "undefinded") {
	window.parent.menu.document.getElementById("tele").className="submenuselect1";
	window.parent.menu.document.getElementById("teleSubli").style.display="block";
	window.parent.menu.document.getElementById("teleSub").className="";
}


//<![CDATA[
function submitConf(pathId, rowIndex, assoNum)
{
    document.getElementById("rowIndex").value=rowIndex;
	document.getElementById("assoNum").value=assoNum;
    document.getElementById("configTelephony").submit();
}

function submitIPConf(pathId, rowIndex) {    
    document.getElementById("rowIPIndex").value=rowIndex;
    document.getElementById("configIP").submit();
}

function submitDeleteIP() {    
				
    document.getElementById("configIP").submit();
}

function showIPWarn(pathId, rowIndex) {
	document.getElementById("delIPFlag").value="true";
	document.getElementById("rowDelIPIndex").value=rowIndex;
    document.getElementById("voipStato").style.display = "none";
	document.getElementById("ipDelete").style.display = "block";    	    
}

function closeIPConfirm() {
	document.getElementById("delIPFlag").value="false";
	document.getElementById("rowDelIPIndex").value="";
    document.getElementById("voipStato").style.display = "block";
	document.getElementById("ipDelete").style.display = "none";    	    
}

function invokeIpPage_Check(pageName) {
<%
--Check for IP Phone configuration
local phyIntf_IPCheck = connectionInfo()
if(#phyIntf_IPCheck<10)then
%>
	window.location.href=pageName;
<%
else
%>
	document.getElementById("voipStato").style.display = "none";
	document.getElementById("newMax").style.display="block";  
<%
end
%>
}
function invokeIpPage(pageName) {
	window.location.href=pageName;
}
//]]>
</script>

<div class="contentContainer">

<div id="voipStato" style="display:block">

		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li> <li><a href="voipStato.lp"><%=translate([==[Telephony]==])%></a></li> 
			</ul>
		</div>

<!-- <table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp">Avanzate</a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="voipStato.lp"><%=translate([==[Telephony services]==])%></a></td> -->

<div class="contentTab" id="content">
			<ol id="tocTab">
				<li><a href="voipStato.lp" class="current">
		<div class="tab">
			<span class="tabIcon_sttel"></span>  
			<span class="contTabTxt transform"><%=translate([==[Telephony services]==])%></span>
		</div>
		<div class="clrBth"></div></a></li>
		<% if isRemote==false then%> 
			<li><a class="margin15" href="telephonyNumber.lp">
		
		<div class="tab">
			<span class="contTabTxt transform"><%=translate([==[Telephone numbers]==])%></span></div></a></li>
		<% end %> 
			</ol>
		</div>


<!-- <%if isRemote==false then%>
<td align="right"><a href="telephonyNumber.lp">Numeri telefonici</a></td>
<%end%>
</tr>
</table> -->

<div class='contentcontainer' id='configNum'>

<div class='contentitem'>

<table border="0" width="100%">
<form id="configTelephony" name="configTelephony" action="" method="post">
<input type="hidden" id="pathId" name="pathId" value=""/>
<input type="hidden" id="assoNum" name="assoNum" value=""/>
<input type="hidden" id="rowIndex" name="rowIndex" value=""/>
<tr>
   <!--  <td class='icon' style='vertical-align:top' width='100px'><img src='images/tel___xl.gif' alt=''></td> -->
<td class="padLeft37 verticalAlign">
        <table cellspacing='0' cellpadding='0' width="100%">
        <!-- <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony services]==])%></span></td>
        </tr> -->
        <tr><td>
            <br><!-- Begin of showing Telephone Service-->
            <table cellspacing='0' cellpadding='0' width='100%' class="fontSize">
			<tr>
			<td width='0' class="verticalAlign">
			</td>
			<td class="verticalAlign">
            <span class='midarea2_telmain tableTitle'><%=translate([==[Telephone service State]==])%></span><br>
            <table width='100%' class="edittable valueSpace width770 fontSize" cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                <tr><td align='left' class="width85 tableHeader"><div class="wordWrap width85"><%=translate([==[connection]==])%></div></td>
		
		      <td align='left' class="width70 tableHeader">
			  <div class="wordWrap width48"><%=translate([==[Extension ]==])%><%=translate([==[Number]==])%></div></td>		      	
                    <!--<td align='left' class="width110 tableHeader">
					<div class="wordWrap width60"><%=translate([==[Number of ]==])%><br/><%=translate([==[input]==])%></div></td>-->
                    <td align='left' class="width110 tableHeader">
					<div class="wordWrap width60"><div class="wordWrap width60">
				<%=translate([==[Associated Number]==])%></div></td>
		    <!--<td align='left' class="tableHeader width65"><div class="wordWrap width65"><%=translate([==[Priority]==])%></div></td> 	-->
                    <td align='left' class="tableHeader width85"><div class="wordWrap width85">POS/FAX</div></td>                    
                    <td align='left' class="tableHeader wdth120px"><div class="wordWrap width130"><%=translate([==[Associated with fixed ]==])%><br/><%=translate([==[line]==])%></div></td>

                    <td align='left' class="width70 tableHeader txtAlignCenter"><%if isRemote==false then%><div class="wordWrap"><%=translate([==[Configure]==])%></div><%end%></td>

                </tr>
                <tr><td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
                
                <%
                local rowStyle = "oddrow_firewall"
                local rowNum = 0
                local phoneType, phyInterfaceEnable
		local profilePath = "Device.Services.VoiceService.3.VoiceProfile."
		local FXSIndex = 1
				local phyIntf_T = getConnectionInfo()		
                for i=1, #phyIntf_T do
                    rowNum = rowNum + 1
                    if rowNum%2==1 then
                        rowStyle = "oddrow_firewall"
                    else
                        rowStyle = "evenrow_firewall"
                    end
                    local v = phyIntf_T[i]	                   
					if (v ~= nil) then
					if(v.name ~= nil)then
						 phoneType = v.name
					end
					
                    if phoneType=="FXS" then
                        phoneType = "FXS" .. tostring(i)
                    end
                    if phoneType~="FXO" then
						if(v.enable ~= nil)then
							phyInterfaceEnable = v.enable							 
						end
                        --if false, just show "Interface off"
                        if phyInterfaceEnable~="true" then
                %>
                 <tr><td class="<%=rowStyle%>"><%=phoneType%></td><td class="<%=rowStyle%>" align="left" colspan='6'><%=translate([==[Interface off]==])%></td></tr>
                <%
                        else
                            if phoneType~="DECT" then								
                                local incomingCallNum, outgoingCallNum, priority = "-", "-", "-"
                                local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)
                                -- local replySwitch, error = mbus.getParameters{ path = switchPath, param = {"X_TELECOMITALIA_IT_SwitchToPSTNIn", "X_TELECOMITALIA_IT_SwitchToPSTNOut"}, datamodel = "second"}
                                --if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNIn"]=="true" then
                                    --incomingCallNum = translate([==[Fixed Line]==])
                                --end
                               -- if replySwitch[switchPath][1].param["X_TELECOMITALIA_IT_SwitchToPSTNOut"]=="true" then
                                    --outgoingCallNum = translate([==[Fixed Line]==])
                                --end
								local posFAX
                                if(v.posConfig ~= nil)then
									posFAX = v.posConfig
								end
                               local PSTNIn
								if(v.switchToPSTNIn ~= nil)then
									 PSTNIn = v.switchToPSTNIn
								end
                                local PSTNOut
								if(v.switchToPSTNOut ~= nil)then
									PSTNOut = v.switchToPSTNOut
								end
                                local posFAXValue = translate([==[Unsynchronized]==])
                                local PSTNInValue = translate([==[Unsynchronized]==])
                                local PSTNOutValue = translate([==[Unsynchronized]==])
                                if posFAX~="false" and posFAX~=nil then
                                    posFAXValue = translate([==[Actived]==])
                                end
                                if PSTNIn~="false" and PSTNIn~=nil then
                                    PSTNInValue = translate([==[Actived]==])
                                end
                                if PSTNOut~="false" and PSTNOut~=nil then
                                    PSTNOutValue = translate([==[Actived]==])
                                end
                                local fixedLineInfo = tostring(translate([==[ingress:]==])) .. tostring(PSTNInValue) .. "<br/>" .. tostring(translate([==[egress:]==])) .. tostring(PSTNOutValue)
								if(v.path ~= nil)then
									v.path=v.path
								end
                                local pathId = string.sub(v.path, -1)
				
				-- For CPE_P00106895 - Start
				--[[
				incomingCallNum = getAllInCallNum1(profilePath)
				outgoingCallNum = getAllOutCallNum1(profilePath)
				priority = getAllOutPriority(profilePath)	
				]]
				
				local inOutCall = getAllInOutCallNum1(FXSIndex)
				if(FXSIndex<12)then
					FXSIndex = FXSIndex+11
				end
				if inOutCall ~= nil and inOutCall ~= "" then
					local inOutCallArray = split(inOutCall,"##")					
					incomingCallNum = inOutCallArray[1]
					if(incomingCallNum == "" or incomingCallNum == nil)then
						incomingCallNum = "-"						
					end
					outgoingCallNum = inOutCallArray[2]
					priority	= inOutCallArray[3]
				end
				-- For CPE_P00106895 - End
                %>
                
                <tr>
                <td class="<%=rowStyle%> fontSize width85"><div class="wordWrap"><%=phoneType%><input type="hidden" id="phoneType<%=rowNum%>" name="phoneType<%=rowNum%>" value="<%=phoneType%>" /></div></td>
		   
	         <td class="<%=rowStyle%> wordWrap width70"><div class="wordWrap"><%=v.val%></div></td>     	

                <td class="<%=rowStyle%> width110 fontSize"><div class="wordWrap fontSize"><%=incomingCallNum%></div></td>
                <!--<td class="<%=rowStyle%> width110 fontSize"><div class="wordWrap fontSize"><%=outgoingCallNum%></div></td>-->

		  <!--<td class="<%=rowStyle%> width65" ><div class="wordWrap"><%=priority%></div></td>-->

                <td class="<%=rowStyle%>"><div class="wordWrap"><%=posFAXValue%></div></td>
                <td class="<%=rowStyle%> wdth120px"><div class="wordWrap"><%=fixedLineInfo%></div></td>

                <td class="<%=rowStyle%> txtAlignCenter">
				<%if isRemote==false then%>
				<a onclick='submitConf("<%=pathId%>", "<%=i%>", "<%=incomingCallNum%>")' class="linkPointer">
					<img src='images/rename_usb.png' alt=''/></a>
				<%end%>
                </td>

                </tr>
                    <%      end
                            if phoneType=="DECT" then
								local index = 13
								local dectNumber
                                for j=1,5 do

                                    rowNum = rowNum + 1
                                    if rowNum%2==1 then
                                        rowStyle = "evenrow_firewall"
                                    else
                                        rowStyle = "oddrow_firewall"
                                    end

                                    local incomingCallNum, outgoingCallNum, priority = "-", "-","-"
                                    phoneType = "DECT" .. tostring(j)
									if(v.path ~= nil)then
										v.path=v.path
									end
                                    local DECTPath = v.path .. ".X_TELECOMITALIA_IT_DECTHandset." .. j
                                    local pathId = string.sub(DECTPath, -1)

				    -- For CPE_P00106895 - Start
				    --[[	
                                    incomingCallNum = getAllInCallNum1(profilePath)
                                    outgoingCallNum = getAllOutCallNum1(profilePath)
				    priority = getAllOutPriority(profilePath)
                                    ]]

				    local inOutCall = getAllInOutCallNum1(index)
					index=index+1
				    if inOutCall ~= nil and inOutCall ~= "" then
					local inOutCallArray = split(inOutCall,"##")					
					incomingCallNum = inOutCallArray[1]
					outgoingCallNum = inOutCallArray[2]
					priority	= inOutCallArray[3]
				    end
                                    -- For CPE_P00106895 - end				    
 	
                                    local DECTPSTNInValue = translate([==[Unsynchronized]==])
                                    local DECTPSTNOutValue = translate([==[Unsynchronized]==])
                                    local DECTPSTNIn, DECTPSTNOut = getDECTPSTNInAndOut()
                                    if DECTPSTNIn~="false" then
                                        DECTPSTNInValue = translate([==[Actived]==])
                                    end
                                    if DECTPSTNOut~="false" then
                                        DECTPSTNOutValue = translate([==[Actived]==])
                                    end
									local posFAXValue = translate([==[Non]==]) .. "<br/>" .. translate([==[applicabile]==])	
                                    local fixedLineInfo = tostring(translate([==[ingress:]==])) .. tostring(DECTPSTNInValue) .. "<br/>" .. tostring(translate([==[egress:]==])) .. tostring(DECTPSTNOutValue)
                    %>
                <tr>
                <td class="<%=rowStyle%>"><%=phoneType%><input type="hidden" id="phoneType<%=i+j-1%>" name="phoneType<%=i+j-1%>" value="<%=phoneType%>" /></td>
                <%
                                    local DECTAssociato = getDECTHandsetAssociato(DECTPath)
                                    if DECTAssociato~="true" then
                %>
                <td class="<%=rowStyle%>" colspan='5'><%=translate([==[Terminal is not associated]==])%></td>
                <%
                                    else
				    dectNumber = phyIntf_T[(2+j)]
                %>

	         <td class="<%=rowStyle%> width70"><%if dectNumber.val ~=  nil then%><%=dectNumber.val%><%else%>-<%end%></td>


                <td class="<%=rowStyle%> wordWrap width110"><%=incomingCallNum%></td>
                <!--<td class="<%=rowStyle%> wordWrap width110"><%=outgoingCallNum%></td>-->
                <!--<td class="<%=rowStyle%> wordWrap width65"><%=priority%></td>-->

		<td class="<%=rowStyle%>  wordWrap width65"><div class="wordWrap width65"><%=posFAXValue%></div></td>

                <td class="<%=rowStyle%> wdth120px"><div class="wordWrap wdth120px"><%=fixedLineInfo%></div></td>
		
                <td class="<%=rowStyle%> txtAlignCenter">				
				<%if isRemote==false then%>
			<a onclick='submitConf("<%=pathId%>", "<%=(i+j-1)%>", "<%=incomingCallNum%>")' class="linkPointer">
			<img src='images/rename_usb.png' alt=''/></a>
				<%end%>
                </td>
		
                <%
                                    end
                %>
                </tr>
                <%
                                end
                            end
                        end
                    end
                end
				end
                %>
                <br>
            </table>
            </td></tr></table>
        </td></tr></table>
    </td>
</tr>
</form>
</table>
<br/><br/>

<%
   local phyIntf_IP = getIPConnectionInfo()
   if #phyIntf_IP > 0 then
%>
<!-- IP Phone -->
<table border="0" width="100%" cellspacing='0' cellpadding='0'>
<form id="configIP" name="configIP" action="" method="post">
<input type="hidden" id="pathIPId" name="pathIPId" value=""/>
<input type="hidden" id="rowIPIndex" name="rowIPIndex" value=""/>
<input type="hidden" id="rowDelIPIndex" name="rowDelIPIndex" value=""/>
<input type="hidden" id="delIPFlag" name="delIPFlag" value="false"/>
<input type="hidden" id="configFlag" name="configFlag" value="false"/>
<tr>

    <td class="verticalAlign">
        <table cellspacing='0' cellpadding='0' width="100%">        
        <tr>
		<td>
<!-- Begin of showing Telephone Service-->
            <table cellspacing='0' cellpadding='0' width='100%' border="0">
			<tr>
			
			<td class="verticalAlign fontSize padLeft37">
            <table width='100%' class='edittable valueSpace fontSize' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr>
				<td colspan='6'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td>
				</tr>
                <tr>
				<td class="tableHeader width65 " align='left'><div class="wordWrap width65"><%=translate([==[IP Phone]==])%></div></td>
				
				<td class="tableHeader width65" align='left' >
				<div class="wordWrap width48"><%=translate([==[Extension ]==])%><%=translate([==[Number]==])%></div></td>		      	
                <td class="tableHeader width70" align='left' >
				<div class="wordWrap width60"><%=translate([==[Associated Number]==])%></div></td>
                <!--<td class="tableHeader width70" align='left' >
				<div class="wordWrap width60"><%=translate([==[Number of ]==])%><br/><%=translate([==[outgoing]==])%></div></td>
				<td class="tableHeader width55" align='left' ><div class="wordWrap width55"><%=translate([==[Priority]==])%></div></td>-->
                <td class="tableHeader width78" align='left' ><div class="wordWrap width78">POS/FAX</div></td>                    
              <!--  <td class="tableHeader wdth120px" align='left' >
				<div class="wordWrap width98"><%=translate([==[Associated with fixed ]==])%><br/><%=translate([==[line]==])%></div></td>
		
                <td class="tableHeader width65" align='left'><%if isRemote==false then%><div class="wordWrap width65"><%=translate([==[Configure]==])%></div><%end%></td>-->
		
				<td class="tableHeader width55"><div class="wordWrap width55"><%=translate([==[Status]==])%></div></td>	
				<td class="tableHeader width55 txtAlignCenter"><div class="wordWrap width55"><%=translate([==[Delete]==])%></div></td>	
                </tr>
                <tr><td colspan='6' class='black'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
                <%
                local rowIPStyle = "oddrow_firewall"
                local rowIPNum = 0
                local phoneIPType, phyIPInterfaceEnable

                for i=1, #phyIntf_IP do
                    rowIPNum = rowIPNum + 1
                    if rowIPNum%2==1 then
                        rowIPStyle = "oddrow_firewall"
                    else
                        rowIPStyle = "evenrow_firewall"
                    end
                    local v = phyIntf_IP[i]
						
                    phoneIPType = v.name
                    if phoneIPType == nil then
                        phoneIPType = v.directory
                    end
                    
                    phyIPInterfaceEnable = v.enable

                    local incomingCallNum, outgoingCallNum, priority = "-", "-", "-"
                    local switchPath = "Device.Services.VoiceService.1.PhyInterface."..tostring(i)
                    
                    local posFAXValue = translate([==[Non]==]) .. "<br/>" .. translate([==[applicabile]==])
                    
                    local fixedLineInfo = translate([==[Non]==]) .. "<br/>" .. translate([==[applicabile]==])
		    local ipStato = translate([==[Unsynchronized]==])
		    if(phyIPInterfaceEnable == "Enabled" ) then	
				ipStato = translate([==[Actived]==])
		    end	

                    local pathIPId = string.sub(v.path, -1)
		    local proInstance = v.proInstance
			
		    -- For CPE_P00106895 - Start
 		    --[[
		    incomingCallNum = getAllInCallNum1(v.path..".Line.1")
		    outgoingCallNum = getAllOutCallNum1(v.path..".Line.1")
		    priority = getAllOutPriority(v.path..".Line.1")		
		    ]]

		    local inOutCall = v.AllInOutCallNum1
		    if inOutCall ~= nil and inOutCall ~= "" then
			local inOutCallArray = split(inOutCall,"##")
			incomingCallNum = inOutCallArray[1]
			outgoingCallNum = inOutCallArray[2]
			priority	= inOutCallArray[3]
		     end
		     -- For CPE_P00106895 - End

                %>
              
                <tr>
				<td class='<%=rowIPStyle%>' colspan='6'>
				<img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br>
				</td>
				</tr>
                <tr>
                <td class="<%=rowIPStyle%> wordWrap fontSize width45"><div class="wordWrap width45"><%=phoneIPType%>
				<input type="hidden" id="phoneIPType<%=rowIPNum%>" name="phoneIPType<%=rowIPNum%>" value="<%=phoneIPType%>" />				  </div></td>
				<td class="<%=rowIPStyle%> wordWrap width65" ><div class="wordWrap width65"><%=v.directory%></div></td>     	

                <td class="<%=rowIPStyle%> wordWrap width70" ><div class="wordWrap width70 fontSize"><%=incomingCallNum%></div></td>
                <!--<td class="<%=rowIPStyle%> wordWrap width70"><div class="wordWrap width70 fontSize"><%=outgoingCallNum%></div></td>

				<td class="<%=rowIPStyle%> wordWrap width55" ><div class="wordWrap width55"><%=priority%></div></td>-->
				
                <td class="<%=rowIPStyle%> wordWrap width78"><div class="wordWrap width78" ><%=posFAXValue%></div></td>
               <!-- <td class="<%=rowIPStyle%> wordWrap wdth120px"><div class="wordWrap wdth120px" ><%=fixedLineInfo%></div></td>
				
                <td class="<%=rowIPStyle%> wordWrap txtAlignCenter width65">
				<%if isRemote==false then%>
				<a onclick='submitIPConf("<%=pathIPId%>", "<%=proInstance%>")' class="linkPointer">
					<img src='images/rename_usb.png' alt=''/>					
				</a>
				<%end%>
                </td>-->
				
			<td class="<%=rowIPStyle%> width55"><div class="wordWrap width55" ><%=ipStato%></div></td>
			<td class="<%=rowIPStyle%> txtAlignCenter width55">
			<a onclick='showIPWarn("<%=pathIPId%>", "<%=proInstance%>")' class="linkPointer ">
				<img src='images/delete_usb.png' alt=''/>
			</a>
			</td>
            </tr>
                    
                </tr>
                <%                   
                end
                %>
                <br>
            </table>
			<div class="fontSize padleft4 padngtop5px"><%=translate([==[Attention: To change the settings of IP phones act from Home Phone installed on your smartphone]==])%></div>
            </td></tr></table>
        </td></tr></table>
    </td>
</tr>
</form>
</table>
<br/><br/>

<%  end %>

		<!--  Vignesh: Fix for CPE_P00104074 -->
			<%
			local ipConf = checkIPConfBtn()
				if(ipConf=="true") then		
			%>
			<table cellspacing='0' cellpadding='0' width="100%">    
				<tr>
				<td width="40">&nbsp;</td><td>	
			<a onclick='invokeIpPage_Check("newIp.lp")'>
				<div class="midarea7-1 mainButton"><%=translate([==[Configure new terminal]==])%></div></a>
			</td></tr></table>
			<% end %>	

</div>
</div>

</div>

<div id="ipDelete" style="display:none">
	<%
	cgilua.lp.include("webparts/confirmIPDelete.lp")
	%>
</div>
<div id="newMax" style="display:none">
<%cgilua.lp.include("webparts/newIpMax.lp")%>
</div>

</div>




<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>

