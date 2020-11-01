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
                          <td class="errorMessage">
						  <%=translate([==[Turning off Wi-Fi radio interface]==])%>.</td></tr>
            <tr><td class="errorDesc" id="WlanIntfOffMsg">
			<p><%=translate([==[The Wi-Fi at 2.4 GHz is turned off. Wi-Fi will be detected only at 5 GHz networks.]==])%></p>
			<br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" href="#" onclick="doShowList()"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Next]==])%></div></a></td>
							<td  class="verticalAlign" style="padding-left:15px;">
							<a href="#" onclick="closeConfirm()"><div class='midarea6-1 mainButton' name="thb12"><%=translate([==[Cancel]==])%></div></a>
		</td>
		</tr>
                   </table>
        </td></tr></table>
</div>
</div>

