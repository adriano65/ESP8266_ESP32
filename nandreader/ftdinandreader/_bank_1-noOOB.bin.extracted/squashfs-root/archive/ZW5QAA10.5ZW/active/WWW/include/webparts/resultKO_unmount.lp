<div id="resultko_unmount" style="display: <%=resultko_unmount_page%>; position:absolute; left:20px; top:50px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
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
                          <td class="errorMessage"><%=translate([==[Removing USB device - Disc Remote Service]==])%></td>
	</tr>
	<tr>
		<td class="errorDesc">
		<p><%=translate([==[Warning: it has been detected activity of reading / writing to the USB device you want to remove]==])%></p>
		 <p class="paddtop10"><%=translate([==[Press]==])%>&quot;<%=translate([==[Next]==])%>&quot;<%=translate([==[to confirm the removal, or press]==])%>&quot;<%=translate([==[Cancel]==])%>&quot;<%=translate([==[to return to previous page]==])%></p>
  <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" onclick='javascript:confirm_unmount();' href="#">
				<div class="midarea6-1 mainButton" name="thb11"><%=translate([==[Next]==])%></div></a>
				</td><td  class="verticalAlign" style="padding-left:15px;">
				<a onclick='javascript:document.location.href="usbConfig.lp";' href="#">
				<div class="midarea6-1 mainButton" name="thb12"><%=translate([==[Cancel]==])%></div></a>
				</td>
				</tr>
	<!-- <tr>
	<td style="padding-left:285px" align='center'>
		
		<input type="button" onclick='javascript:confirm_unmount();' value="<%=translate([==[Next]==])%>&gt;" name="thb11" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="button" onclick='javascript:document.location.href="usbConfig.lp";' value="<%=translate([==[Cancel]==])%>" name="thb12" /><br/>
	</tr> -->
	</table>
	</td></tr>
</table>
</div>
