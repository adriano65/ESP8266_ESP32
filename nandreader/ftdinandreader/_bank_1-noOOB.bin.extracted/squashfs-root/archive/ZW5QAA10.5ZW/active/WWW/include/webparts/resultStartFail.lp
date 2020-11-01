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
                          <td class="errorMessage"><%=translate([==[You are about to make changes]==])%>.</td></tr>
                             <tr><td class="errorDesc">
                            <p><%=translate([==[Warning: the security level of the password may not be appropriate.]==])%></p>
                   <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" style='color:black' onclick="submitConfirm()" href="#">
							<div class="midarea6-1 mainButton"><%=translate([==[Next]==])%></div></a></td>
				   <td  class="verticalAlign" style="padding-left:15px;">
				   <a style='color:black' onclick="cancelConfirm()">
				<div class="midarea6-1 mainButton"><%=translate([==[Cancel]==])%></div></a>
                   </td></tr>
              </table>
            </td></tr>
        </table>
   </div>
</div>