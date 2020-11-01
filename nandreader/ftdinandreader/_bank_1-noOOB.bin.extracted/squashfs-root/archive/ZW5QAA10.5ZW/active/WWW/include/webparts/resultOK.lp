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
                          <td class="errorMessage"><%=translate([==[Operation performed]==])%></td></tr>
            <tr><td class="errorDesc">
                <p>&nbsp;<%=translate([==[Successfully finished]==])%></p>
                <p><%=translate([==[To make permanent configuration changes, press the "Continue"]==])%>
                <%=translate([==[Failure to save leads to zero change settings after shutdown or restart your modem]==])%></p>
                <p class="paddtop10"><%=translate([==[Press "Continue" to save the configuration or]==])%>
                <%=translate([==[press "Cancel" and manually turn off the modem to undo the changes made]==])%></p>
            <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="saveResult()" href="#">
							<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Continue]==])%></div></a>
							</td>
							<td  class="verticalAlign" style="padding-left:15px;">
							<a onclick="cancelConfirm()" href="#">
							<div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div></a>
				</td>
				</tr></table>
            </td></tr></table>
</div>
</div>
