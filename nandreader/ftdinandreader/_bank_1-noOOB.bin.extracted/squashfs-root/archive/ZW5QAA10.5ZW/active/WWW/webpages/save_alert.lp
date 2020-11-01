<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Modem Telecom Italia</title>
<link rel="stylesheet" href="css/master.css" type="text/css">
<script language="javascript" type="text/javascript" src="js/script.js"></script>
<script language="javascript" src="js/xp_progress.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Language" content="it">
</head>
<body>
<div class='contentcontainer'>
<div class='contentitem'>
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
                          <td class="errorMessage"><%=translate([==[Saving]==])%>.</td></tr>
            <tr><td class="errorDesc"><p><%=translate([==[Please wait]==])%>...</p><p><%=translate([==[Saving settings in progress]==])%>!<br>
		<%=translate([==[When you finish the page will be redirected automatically]==])%>!
		</p>

		<div align="center" class="padtop10">
<script type="text/javascript">
<%
local round = "1"

if cgilua.QUERY["u"]~=nil and cgilua.QUERY["u"]~="" then
  local param = cgilua.urlcode.escape(cgilua.QUERY["u"])
  if cgilua.QUERY["uparam"]~=nil and cgilua.QUERY["uparam"]~="" then
    param = param .. "?u=" .. cgilua.QUERY["uparam"]
  end
%>
var bar1= createBar(300,15,'white',1,'black','#53669e',85,7,<%=round%>,'javascript:location.href="<%=cgilua.urlcode.unescape(param)%>";');
<% else %>
var bar1= createBar(300,15,'white',1,'black','#53669e',85,7,<%=round%>,'javascript:window.history.back();');
<% end %>
</script>
		</div>
		<br/></td></tr></table><br/>
		</td></tr>
		</table>
        </td></tr></table>
    </td>
</tr>
</table>
</div>
</div>

</body>
</html>


