<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<!-- <link rel="stylesheet" href="css/style.css" type="text/css"/>
<link href="css/menu.css" type="text/css" rel="stylesheet"/>
 -->
<link href="css/master.css" type="text/css" rel="stylesheet"/>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta http-equiv="Content-Language" content="it"/>
</head>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/portmap.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% 
	local translate = translate 
	local POST=cgilua.POST

	local name, ip, protocol, internalPort, externalPort, status
	local flag = cgilua.QUERY["flag"]

	if flag ~= nil then
		name = cgilua.QUERY["nameInfo"]
		ip = cgilua.QUERY["ipInfo"]
		protocol = cgilua.QUERY["protocolInfo"]
		internalPort = cgilua.QUERY["internalPortInfo"]
		externalPort = cgilua.QUERY["externalPortInfo"]	
	end

	if cgilua.servervariable"REQUEST_METHOD" == "POST" then
		--If enable the status on state page or cancel the conflict page after configuration.
	    local tprint = require("tableprint")	
		if POST["flag"]=="stateEnable"or (POST["flag"]=="config" and POST["cancelFlag"]=="1") then
--			cgilua.errorlog("@@@ flag is stateEnable")
			cgilua.redirect("statoPortMapping.lp")
			return
		end

		local name = POST["name"]
		local ip = POST["ip"]
		local protocol = POST["protocol"]
		local internalPort = POST["internalPort"]
		local externalPort = POST["externalPort"]
		local status = "0"
		manualDisabled = "0"
		intfDisabled = "0"
		
		if name ~= nil then
			local result = virtualServerCreate_IGD(name, ip, protocol, internalPort, externalPort, status, manualDisabled, intfDisabled)

			if result~=1 then
				saveall(0, 1)
				--For edit page which enable the state
				if POST["cancelFlag"]=="1" then
					cgilua.redirect("statoPortMapping.lp")
					return
				end
				cgilua.redirect("save_alert.lp", { u="statoPortMapping.lp" })
				return
			else
				cgilua.redirect("resultKO.lp", { page="statoPortMapping.lp" })
				return
			end
		else
			cgilua.redirect("resultKO.lp", { page="statoPortMapping.lp" })
			return
		end
	end

%>
<body>

<div class='contentcontainer'>
<div class='contentitem'>
<form id="customConflict" name="customConflict" action="" method="post">
<input type="hidden" name="flag" id="flag" value="<%=flag%>" />
<input type="hidden" name="name" id="name" value="<%=name%>" />
<input type="hidden" name="ip" id="ip" value="<%=ip%>" />
<input type="hidden" name="protocol" id="protocol" value="<%=protocol%>" />
<input type="hidden" name="internalPort" id="internalPort" value="<%=internalPort%>" />
<input type="hidden" name="externalPort" id="externalPort" value="<%=externalPort%>" />
<input type="hidden" name="cancelFlag" id="cancelFlag" value="" />

<table cellspacing='0' cellpadding='0' width='100%' class="width790 marleft5 martop5">
                  <tr>
                    <td class="verticalAlign padleft35">
                      <div class="width50 fleft"><img src='images/warn__xl.png' alt='Technicolor Gateway'></div>
					  <div class="errInfo"><%=translate([==[Info]==])%></div>
                    </td>
                  </tr>
                  <tr>
                    <td class="verticalAlign">
                      <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage" style="text-align:left">
                        <tr>
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%>.</td></tr>
                             <tr><td class="errorDesc">

                             <p><%=translate([==[Warning: Verify that the IP address and / or internal port configured not been previously assigned to another port mapping rule.]==])%></p>
                             <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" href="javascript:submitFire()">
				<div name="thb13" class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a>
				</td>
				<td class="verticalAlign" style="padding-left:15px;">
				<a onclick="javascript:document.getElementById('cancelFlag').value='1';document.getElementById('customConflict').submit();" href="#">
				<div name="thb12" class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
                   <!-- <tr>
				   <td align='center'>
                        <input type="submit" class="button" value="<%=translate([==[Next]==])%> &gt;" name="thb13" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <input type="button" class="button" onclick="javascript:document.getElementById('cancelFlag').value='1';document.getElementById('customConflict').submit();" value="<%=translate([==[Cancel]==])%>" name="thb12" /></td></tr>


                   </td>
				   </tr> -->
              
            </td></tr>
        </table>
    </td>
</tr>
</table>
</form>
</div>
</div>
<script src="js/antiCSRF.js" type="text/javascript">
</script>
<script type="text/javascript">
function submitFire() {
	document.customConflict.submit();
}

</script>
</body>
</html>
