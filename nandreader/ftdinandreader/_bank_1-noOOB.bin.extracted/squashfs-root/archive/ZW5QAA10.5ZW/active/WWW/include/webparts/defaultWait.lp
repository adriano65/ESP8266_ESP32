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
                          <td class="errorMessage"><%=translate([==[Restore initial]==])%></td></tr>
              <tr><td class="errorDesc">
                <p><%=translate([==[Warning: pressing the "Next" modem configuration will be modified and reset with the initial value]==])%>. <%=translate([==[All changes made will be lost]==])%>!</p>
                <p class="paddtop10"><%=translate([==[Click "Next" to confirm or click "Cancel" to return to previous page]==])%>.</p>
              <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="submitConfirm()" href="#">
						<div class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a>
						</td>
						<td  class="verticalAlign" style="padding-left:15px;">
						<a onclick="cancelConfirm()" href="#">
						<div class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
				</td>
				</tr>
				</table>
           </td></tr></table>