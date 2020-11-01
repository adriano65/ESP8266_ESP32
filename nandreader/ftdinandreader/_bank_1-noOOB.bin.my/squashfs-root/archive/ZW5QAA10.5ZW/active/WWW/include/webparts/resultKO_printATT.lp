<div id="resultko_printATT" style="display: <%=resultko_printATT_page%>; position:absolute; left:20px; top:50px; width:670px; height:690px; z-index:1; overflow: auto; "><!--questo e' il layer scrollabile che include la tabella ed evita la scrollbar orizzontale nell'iframe-->
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
                          <td class="errorMessage"><%=translate([==[Attivazione servizio Print Server]==])%></td>
	</tr>
	<tr>
		<td class="errorDesc">
		<p>Attenzione: è stata rilevata una attività di lettura/scrittura in corso su una o più unità USB.</p>
		<p>L'attivazione del servizio di print server sarà resa effettiva solo al termine di tale attività.</p>
		<p class="paddtop10">Premere &quot;Avanti >&quot; per tornare alla pagina precedente</p>
		<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
	<a href="#" onclick="javascript:confirm_printATT();"><div class='midarea6-1 mainButton' name="thb11"><%=translate([==[Next]==])%></div></a>
		<!-- <input type="button" onclick='javascript:confirm_printATT();' value="<%=translate([==[Next]==])%>&gt;" name="thb11" /> -->
	</td></tr>
	</table>
	</td></tr>
</table>
</div>
