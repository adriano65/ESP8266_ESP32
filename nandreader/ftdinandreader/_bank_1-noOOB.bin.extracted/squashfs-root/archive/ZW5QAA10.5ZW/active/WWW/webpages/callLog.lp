<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Modem Telecom Italia</title>
	<link rel="stylesheet" href="css/master.css" type="text/css" />
</head>
<%
cgilua.lp.include("lp/mbus_util.lp")
cgilua.lp.include("lp/common.lp")
cgilua.lp.include("lp/style.lp")

local translate = translate
local POST=cgilua.POST

if cgilua.servervariable"REQUEST_METHOD" == "POST" then	
	cgilua.redirect("callLog.lp")
	return
end

-- variable declaration for call log 
-- local callLogList = getList("SIPServer.CallLog.MergedList.Entry")

-- CPE_P00105429 START

function convertDuration(nSeconds)
        local baseTime = os.time{year=1970, month=1, day=1, hour=0, min=0, sec=0}
        local tt = os.date("*t", baseTime+nSeconds)
        local hour = tt["hour"]
        local min = tt["min"]
        local sec = tt["sec"]
        if hour <= 9 then
                hour = "0" .. tt["hour"]
        end
        if min <=9 then
                min = "0" .. tt["min"]
        end
        if sec <=9 then
                sec = "0" .. tt["sec"]
        end
        time = hour .. ":" .. min .. ":" .. sec
        return time
end

-- CPE_P00105429 END

-- CPE_P00105427 START

function formatStartTime(datetime)
        local year = string.sub(datetime, 1,4)
        local month = string.sub(datetime, 6,7)
        local date = string.sub(datetime, 9,10)
        local hour = string.sub(datetime, 12,13)
        local min = string.sub(datetime, 15,16)
        local sec = string.sub(datetime, 18,19)
        output = hour .. ":" .. min .. ":" .. sec .. " - " .. date .. ":" .. month .. ":" .. year
        return output
end

-- CPE_P00105427 END

local call = {}
local startIndex = 120

local lastIndex = 1
local reply, error = mbus.getParameters{path = "SIPServer.CallLog.MergedList.Entry"} 
local numberOfEntries = #reply["SIPServer.CallLog.MergedList.Entry"]
	startIndex =tonumber(numberOfEntries)
	if(startIndex>120)then
		lastIndex = tonumber(numberOfEntries) - 119
	else
		lastIndex = 1
	end
	for i=startIndex,lastIndex,-1 do
	call[i] = {}	
	call[i].callingNumber = reply["SIPServer.CallLog.MergedList.Entry"][i].param["CallingNumber"]
	call[i].CalledNumber = reply["SIPServer.CallLog.MergedList.Entry"][i].param["CalledNumber"]
	call[i].StartTime = formatStartTime(reply["SIPServer.CallLog.MergedList.Entry"][i].param["StartTime"])
	call[i].Direction = reply["SIPServer.CallLog.MergedList.Entry"][i].param["Direction"]
    call[i].Duration = convertDuration(reply["SIPServer.CallLog.MergedList.Entry"][i].param["Duration"])
    if call[i].Duration == "00:00:00" then
         call[i].Duration = translate([==[Not answered]==])    
	end
	end 
%>
<body>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb"> 
				<li><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a></li><li>|</li><li><a href="voipStato.lp"><%=translate([==[Telephony]==])%></a></li><li>|</li><li><a href="callLog.lp"><%=translate([==[Call Statistics]==])%></a></li>
			</ul>
		</div>	

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="callLog.lp" class="current">
				<div class="tab">
				<span class="tabIcon_sttel"></span>  
				<span class="contTabTxt"><%=translate([==[Telephony services]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>

<div class='contentcontainer'>
<div class='contentitem'>

<% 
writeTableRowTitle_statisticsAG(translate([==[Call Statistics]==]))
writeTableBlockRowHeader_Call(5, translate([==[External number]==]), translate([==[Extension]==]), translate([==[Direction]==]), translate([==[Time]==]),translate([==[Duration]==]))
    local rowStyle = "oddrow"
    local rowNum = 0 
 for i=startIndex,lastIndex,-1 do
  --call[i]={}
        rowNum = rowNum + 1
        if rowNum%2==1 then
          rowStyle = "oddrow"
        else
          rowStyle = "evenrow"
        end  
		if call[i].callingNumber == "Anonymous" then
			call[i].callingNumber = "UNKNOWN"
		end
  	if call[i].Direction == "Incoming" then
		writeTableRow_callstatistics(rowStyle, call[i].callingNumber,call[i].CalledNumber,translate([==[entry]==]),call[i].StartTime,call[i].Duration)
	else
		writeTableRow_callstatistics(rowStyle, call[i].CalledNumber,call[i].callingNumber,translate([==[exit]==]),call[i].StartTime,call[i].Duration)
	end
 end
endBlock()
%>
</td>
</form>
</table>

<% endPage() %>

</div>
</td></tr></table>
</div>
</div>
</div>



<script src="js/antiCSRF.js" type="text/javascript"></script>

</body>
</html>
