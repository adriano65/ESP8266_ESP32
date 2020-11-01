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
                 <tr><td class="errorDesc" id="pinKOMsg">
			<p><%=translate([==[Warning: The PIN entered is invalid]==])%>.</p>
			<p><%=translate([==[Verify that the pin inserted in the length]==])%><br/><%=translate([==[permitted and which contains only characters allowed]==])%> (0 - 9).</p>
       		<p class="paddtop10"><%=translate([==[Press "Continue" to return to previous page]==])%></p>
		<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				 <a onclick="closeConfirm()"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Continue]==])%></div></a>
                     						   </td></tr>
                   </table>
        </td></tr></table>
</div>
</div>

