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
                            <%=translate([==[You are about to make changes]==])%>.
                            </td>
                          </tr>
                        <tr>
                          <td class="errorDesc">
                            <div id="ipChanging">
                              <p>
                                <%=translate([==[Warning: Changing the IP address of the modem can cause loss of connection.]==])%>
                                
                                <p>
                                  <%=translate([==[In addition, the new configuration requires reconfiguration of the DHCP and Port Mapping.]==])%>
                                  </p>
                              </div>
                            
                            <div id="natDisabled" style="display:none;">
                              <p>
                                <%=translate([==[Warning: If you change the settings of NAT may not be able to surf the net from devices on the LAN.]==])%>
                                </p>
                              </div>
                            
                            <div id="dhcpDisabled" style="display:none">
                              <p>
                                <%=translate([==[Warning: If you change the configuration, it is necessary to provide the customer LAN terminals of a fixed address. The connection to the router can be lost.]==])%>
                                </p>
                              </div>
                            
                            <p class="paddtop10">
                              <%=translate([==[Click]==])%>
                                &quot;
                                <%=translate([==[Next]==])%>
                                  &quot; 
                                  <%=translate([==[to confirm the changes]==])%>
                                    
                                    <%=translate([==[and wait about 120 seconds]==])%>
                                      , 
                                      <%=translate([==[or]==])%>
                                        <br/>
                                        <%=translate([==[Click]==])%>
                                          &quot;
                                          <%=translate([==[Cancel]==])%>
                                            &quot; 
                                            <%=translate([==[to return to previous page]==])%>
                                            </p>
                <br/>
                 </td></tr></table>
                   </td></tr>
                   <tr><td>
                      <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
                         <tr><td class="verticalAlign fright">
                            <a class="fright" href="#" onclick='submitConfirm()'>
                                              <div class='midarea6-1 mainButton' name="thb13">
                                                <%=translate([==[Next]==])%>
                                                </div>
                                              </a>
                                            </td>
                                            <td  class="verticalAlign" style="padding-left:15px;">
                                              <a href="#" onclick='cancelConfirm()'>
                                                <div class='midarea6-1 mainButton' name="thb12">
                                                  <%=translate([==[Cancel]==])%>
                                                  </div>
                                                </a>
                                              </td>
                                          </tr>
                                      </table>
                                    </td>                                 
                                  </tr>
  </table>
               
          </div>
         </div>
         
         
         
         
