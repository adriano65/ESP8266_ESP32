<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<title>Modem Telecom Italia</title>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="css/style.css" type="text/css"/>
<link rel="stylesheet" href="css/menu.css" type="text/css" />
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<script language="javascript" type="text/javascript" src="js/portmap.js"></script>
<% cgilua.lp.include("lp/language.lp") %>
<% cgilua.lp.include("lp/common.lp") %>
<% cgilua.lp.include("lp/mbus_util.lp") %>
<% cgilua.lp.include("lp/util.lp") %>
<% cgilua.lp.include("lp/form.lp") %>
<% cgilua.lp.include("lp/ppp.lp") %>
<% cgilua.lp.include("lp/device.lp") %>
<% cgilua.lp.include("lp/portmap.lp") %>
<% cgilua.lp.include("lp/style.lp") %>
<% cgilua.lp.include("lp/voip.lp") %>

<%
local translate = translate
local POST=cgilua.POST
local QUERY=cgilua.QUERY
local pathId = QUERY["pathId"]
local linePathInId = QUERY["linePathInId"]
local linePathOutId = QUERY["linePathOutId"]
local lineNumVal = QUERY["lineNum"]

local wrongPriority = translate([==[Warning: the input priority is incorrect. Use only the allowed characters (0-9)]==])
%>
</head>

<body>
<script type="text/javascript">
//<![CDATA[
function showErrorMsg(errorMsgStr)
{
    document.getElementById("conf_all_num").style.display="none";
    document.getElementById("resultKO").style.display="block";
    document.getElementById("errorMsg").innerHTML=errorMsgStr;
}

function submitAdd(pathIdVal)
{
    var selectNumber = document.getElementById("selectNumber").value;
    if(selectNumber=="")
    {
        document.getElementById("conf_all_num").style.display="none";
        document.getElementById("resultKoConfNum").style.display="block";
        return false;
    }

    <%if linePathInId==nil then%>
        var priorityStr = document.getElementById('Priority').value;
        if(priorityStr!="")
        {
            if(!priorityExam(priorityStr))
            {
                showErrorMsg('<%=wrongPriority%>');
                return false;
            }
        }
    <%end%>

    document.getElementById("typeAndPriority").value="1";

    var urlStr = "/tele_ajax.lp";
    <%if linePathInId~=nil then%>
        var fromUAId = document.getElementById("linePathInId").value;
        var params="pathId="+pathIdVal+"&typeAndPriority=1&fromUAId="+fromUAId+"&selectIndex="+selectNumber;
    <%end%>
    <%if linePathOutId~=nil then%>
        var toUAId = document.getElementById("linePathOutId").value;
        var params="pathId="+pathIdVal+"&typeAndPriority=1&toUAId="+toUAId+"&priority="+priorityStr+"&selectIndex="+selectNumber;
    <%end%>

    ajax_get(urlStr, params, ajaxCallback);

    var num = parseInt(document.getElementById("num").value) + 1;
    document.getElementById("num").value = num;
}

function cancelDelete(num, MapPathId)
{
    var urlStr = "/tele_ajax.lp";
    <%if linePathInId~=nil then%>
        var fromUAId = document.getElementById("linePathInId").value;
        var params="lineNum"+num+"&deleteDirectNumFlag=1&uaMapPathId="+MapPathId+"&fromUAId="+fromUAId;
    <%end%>
    <%if linePathOutId~=nil then%>
        var toUAId = document.getElementById("linePathOutId").value;
        var params="lineNum"+num+"&deleteDirectNumFlag=1&voicePortMapPathId="+MapPathId+"&toUAId="+toUAId;
    <%end%>
    ajax_get(urlStr, params, ajaxCallback);
    document.getElementById("port"+num).innerHTML = "";
    document.getElementById("port"+num).style.display= "none";
}

function cancelConfirm()
{
    document.getElementById("conf_all_num").style.display = "";
    document.getElementById("confirm").style.display = "none";
    document.getElementById("resultKoConfNum").style.display="none";
    document.getElementById("resultKO").style.display="none";

}

function ajaxCallback(ajax_obj)
{
    var rsps = ajax_obj.responseText.replace(/\s/g,"");
    if(rsps!="")
    {
        var selObj =  document.getElementById("selectNumber");
        var selectNumber = selObj.options[selObj.selectedIndex].innerHTML;
        var num = document.getElementById("num").value;
        var arr = rsps.split("#");
        document.getElementById("port"+num).innerHTML = selectNumber + "<input type='button' value='<%=translate([==[Clear]==])%>' onclick='cancelDelete("+num+", "+arr[0]+")' />";
    }

}

function priorityExam(str)
{
    //exam the input box value is number or not.
    //var filter=/^\s*[.,0-9]{0,10240}\s*$/;
    var filter=/^\d/g;
    if ((str.indexOf(' ') != -1) || (!str.match(filter)) || (str > 65535))
    {
        return false;
    }
    return true;
}

//]]>
</script>

<table cellspacing='0' cellpadding='0' width="100%" class="NavBar">
<tr><td align="left"><a href="advance.lp"><%=translate([==[Advanced Settings]==])%></a>&nbsp;&nbsp;>&nbsp;&nbsp;<a href="telephonyStato.lp"><%=translate([==[Telephony services]==])%></a></td><td align="right"><a href="telephonyNumber.lp">NumberInfo</a></td></tr>
</table>

<div class='contentcontainer'>
<hr>
<div class='contentitem' id="conf_all_num">

<table border="0" width="100%">
<form id="modConfigFlag" name="modConfigFlag" action="" method="post">
<input type="hidden" id="configFlag" name="configFlag" value="0"/>
<tr>
    <td class='icon' style='vertical-align:top' width='100px'><img src='images/tel___xl.gif' alt=''></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr>
            <td align='left'><span class='itemtitle'><%=translate([==[Telephony services]==])%></span></td>
        </tr>
        <tr><td>
            <br><!-- Begin of add Telephone number-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td><td style='vertical-align:top'>
            <input type="hidden" id="typeAndPriority" name="typeAndPriority" value="0"/>
            <input type="hidden" id="pathId" name="pathId" value="<%=QUERY['pathId']%>"/>
            <input type="hidden" id="linePathInId" name="linePathInId" value="<%=QUERY['linePathInId']%>"/>
            <input type="hidden" id="linePathOutId" name="linePathOutId" value="<%=QUERY['linePathOutId']%>"/>
            <input type="hidden" id="rowIndex" name="rowIndex" value=""/>
            <span class='blocktitle'><%=translate([==[Telephone service config]==])%></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr>
                <%
                local rowStyle = "oddrow"
                %>
                <td class="<%=rowStyle%>">
                    <select id="selectNumber" name="selectNumber" style="font-family:Tahoma;width:200px;overflow:hidden">
                    <option value="">&lt;<%=translate([==[Choose]==])%> &gt;</option>
                    <%
                    local lineNumPortName
                    if tonumber(pathId)<3 then
                        lineNumPortName = "Device.Services.VoiceService.1.PhyInterface." .. tostring(pathId)
                    else
                        lineNumPortName = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. tostring(tonumber(pathId)-2)
                    end
                    if linePathInId~=nil then
                        local preassInNum = getPreassignedInNum(lineNumPortName)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for i,v in pairs(replyAll[allNumberPath]) do
                            if v.path~=lineNumVal and v.param["DirectoryNumber"]~=preassInNum then
                                cgilua.print("<option title='"..tostring(v.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(v.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(v.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    end
                    if linePathOutId~=nil then
                        local preassOutNum = getPreassignedOutNum(lineNumPortName)
                        local allNumberPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line"
                        local replyAll, error = mbus.getParameters{ path = allNumberPath, param = "DirectoryNumber", filter="(== X_TELECOMITALIA_IT_LANManaged " .. "false" .. ")", datamodel = "second" }
                        for i,v in pairs(replyAll[allNumberPath]) do
                            if v.path~=lineNumVal and v.param["DirectoryNumber"]~=preassOutNum then
                                cgilua.print("<option title='"..tostring(v.param["DirectoryNumber"]).."' value='"..tostring(string.gsub(v.path, "Device.Services.VoiceService.1.VoiceProfile.1.Line.", "")).."'>"..tostring(v.param["DirectoryNumber"]).."</option>")
                            end
                        end
                    end
                    %>
                    </select>
                </td>
                <%
                if linePathOutId~=nil then
                %>
                <td><%=translate([==[Priority]==])%>:<input type="text" id="Priority" name="Priority" size="10" style="font-weight: 700" /></td>
                <%end%>
                </tr>
                <tr><td align='center'>
                    <input type="button" class="button" onclick='submitAdd("<%=pathId%>")' value="<%=translate([==[Apply]==])%>" name="thb1" />&nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="button" class="button" onclick='javascript:document.location.href="telephonyStato.lp";' value="<%=translate([==[Back]==])%>" name="thb7" /></td>
                </tr>
            </table>
            </td></tr></table><!-- End of add Telephone number-->
            </form>
            <br><!-- Begin of showing Telephone numbers-->
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' style='vertical-align:top'><img src='images/bull__md.gif' alt=''></td><td style='vertical-align:top'>
            <input type="hidden" id="num" name="num" value="0">
            <input type="hidden" id="pathId" name="pathId" value="<%=QUERY['pathId']%>"/>
            <span class='blocktitle'><%=translate([==[Delete telephone]==])%></span><br>
            <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style="line-height:150%;">
                <tr>
                <td>
                <%
                for i=1,100 do
                %>
                <div id="port<%=i%>"></div>
                <%
                end
                %>
                </td>
                </tr>
            </table>
            </td></tr></table><!-- End of showing Telephone numbers-->
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
<div id="resultKoConfNum" style="display:none">
<%cgilua.lp.include("webparts/resultKO_noconfnum.lp")%>
</div>
<div id="resultKO" style="display:none">
<%cgilua.lp.include("webparts/resultKO_URL.lp")%>
</div>
<div id="confirm" style="display:none">
<%cgilua.lp.include("webparts/confirmBack.lp")%>
</div>
<script src="js/antiCSRF.js" type="text/javascript"></script>
</body>
</html>
