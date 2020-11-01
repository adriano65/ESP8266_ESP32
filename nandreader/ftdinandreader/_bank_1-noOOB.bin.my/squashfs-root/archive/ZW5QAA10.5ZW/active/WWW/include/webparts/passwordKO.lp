<% cgilua.lp.include("lp/device.lp") %>
<%
local is_remote = isRemoteAccess()
%>
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
                          <td class="errorMessage"><%=translate([==[Operation failure]==])%>.</td></tr>
            <tr><td class="errorDesc">
<%if is_remote then%>
			<p><%=translate ([==[Error. Username or password incorrect!]==])%></p>
<%else%>
			<p><%=translate ([==[Caution: The password is incorrect!]==])%></p>
<%end%>
		<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
									<a  style="text-align:center;" onclick='javascript: passwordko_onclick();' href="#"><div class="midarea6-1 mainButton" name="thb7"><%=translate ([==[Continue]==])%></div></a>
                     						   </td></tr>
                   </table>
        </td></tr></table>
</div>
</div>

