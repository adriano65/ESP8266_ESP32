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
                          <td class="errorMessage"><%=translate([==[Remove USB sharing service]==])%>.</td></tr>
            <tr> <td class="errorDesc">
            <div id="errorMsg">
                <p><%=translate([==[Warning: it was detected activity of reading / writing to the USB device you want to remove.]==])%></p>
            </div>
               <p class="paddtop10"><%=translate([==[Click "Next" to confirm or click "Cancel" to return to previous page]==])%>.</p>
            <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick="confirm_unmount_submit()" href="#"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Next]==])%></div></a></td>
						<td  class="verticalAlign" style="padding-left:15px;">
						<a onclick="cancelForm()" href="#"><div class='midarea6-1 mainButton' name="thb12"><%=translate([==[Cancel]==])%></div></a>	
           </td></tr>
        </table>
        </td></tr></table>
    </div>
</div>
