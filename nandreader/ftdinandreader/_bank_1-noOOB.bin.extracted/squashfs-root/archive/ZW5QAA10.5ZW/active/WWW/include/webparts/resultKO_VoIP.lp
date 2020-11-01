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
            <div id="errorMsg">
                <p><%=translate([==[Warning: Reached the maximum number of active DECT terminals. For others it is encouraged to combine necessary to delete any of the items]==])%></p>
            </div>
                <p class="paddtop10"><%=translate([==[Press "Continue" to return to previous page]==])%></p>
            <br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
			<a onclick='cancelConfirm()' href="#">
				<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Continue]==])%></div>
			</a>
        </td></tr>
        <!-- <tr>
        <td align='center'>
            <input type="button" class="button" onclick='cancelConfirm()' value="<%=translate([==[Continue]==])%>" name="thb11" />
        </td></tr> -->
        
       </table>
	</td></tr></table>
 </div>
</div>

