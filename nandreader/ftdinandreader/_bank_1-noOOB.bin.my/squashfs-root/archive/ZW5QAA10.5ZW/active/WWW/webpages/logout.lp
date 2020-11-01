<%
local url = cgilua.urlcode.escape(tostring(cgilua.QUERY["u"]))
if url=="nil" then
  cgilua.redirect("home.lp")
else
  if url=="index_auth.lp" then
    cgilua.logout()
  end
  url = cgilua.urlcode.escape(url)
%>
<script language="javascript" type="text/javascript">
//<![CDATA[
window.parent.location.href = "<%=cgilua.urlcode.unescape(url)%>";
//]]>
</script>
<%
end
%>
