<% cgilua.lp.include("lp/device.lp") %>
<%
local is_remote = isRemoteAccess()
%>
<div class='contentcontainer'>
<div class='contentitem'>
<table cellspacing='0' cellpadding='0' width="100%">
<tr><td width="5%">&nbsp;</td>
    <td class='icon' style='vertical-align:top' width='100px' style="vertical-align:top"><img src='images/usrs__xl.png' alt='Technicolor Gateway'></td>
    <td class='data' style='vertical-align:top'>
        <table cellspacing='0' cellpadding='0' width="100%">
        <tr><td>
            <table cellspacing='0' cellpadding='0' width='100%'><tr><td style='vertical-align:top' class="midareainfo" style="vertical-align:top">
            Info</td></tr></table>   
            <table width='100%' cellspacing='0' cellpadding='0' class="PageMessage">
            <tr><td class="trScura"><%=translate([==[Operation failure]==])%>.</td></tr>
            <tr><td class="tdBiancaC"><br/>
<%if is_remote then%>
			<p><%=translate ([==[Error. Username or password incorrect!]==])%></p>
<%else%>
			<p><%=translate ([==[Caution: The password is incorrect!]==])%></p>
<%end%>
		<br/></td></tr></table><br/>
                   
                   <tr>
                   <td style="padding-left:285px" align='center'>
						<a onclick='javascript: passwordko_onclick();'>
							<div class="midarea6-1 mainButton" name="thb7"><%=translate ([==[Continue]==])%></div>
						</a>
					</td>
                         <!-- <input type="button" onclick='javascript: passwordko_onclick();' value="<%=translate ([==[Continue]==])%>" name="thb7" /><br/></td></tr> -->
                   
        </td></tr></table>
    </td>
</tr>
</table>
</div>
</div>


