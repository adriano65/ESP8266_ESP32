<div style="position:absolute; left:20px; top:50px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
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
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%></td>
		</tr>
		<tr>
          <td class="errorDesc">
			<p><%=translate([==[Rule already configured on another IP/port internal]==])%>.<br/>
			<%=translate([==[The rule was created in "Not Active"]==])%>.</p>
			<p class="paddtop10"><%=translate([==[Press]==])%> &quot;<%=translate([==[Next]==])%>&quot; <%=translate([==[to confirm or press]==])%>&quot;<%=translate([==[Cancel]==])%>&quot; <%=translate([==[to return to previous page]==])%></p>
			<br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="cancelConfirm()" href="#">
				<div name="thb13" class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a>
				</td>
				<td  class="verticalAlign" style="padding-left:15px;">
				  <a onclick="cancelConfirm()" href="#">
				<div name="thb12" class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
				</td>
				</tr>
				</table>
				</td>
				</tr>
		</table>
</div>
