<%
local reply, error = mbus.getParameters{path = "ENV._BOARD_NAME", param = {"Value"}, flags="KEYPATH" }
cgilua.print(tostring(reply["ENV._BOARD_NAME"][1].param["Value"]))
%>
