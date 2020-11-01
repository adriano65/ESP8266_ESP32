<%
local status = "Ready"
local info, error = mbus.getParameters{path = "VFS.MetaDataService", param = "ProfilingStatus"}
if info["VFS.MetaDataService"][1].param["ProfilingStatus"]~="Ready" then
    status = "Profiling"
end
cgilua.print(status)
%>
