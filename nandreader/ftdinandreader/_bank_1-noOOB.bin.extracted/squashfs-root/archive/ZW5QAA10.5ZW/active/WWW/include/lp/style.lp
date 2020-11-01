<%
function writeBlockTitleWifiConfig(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'>&nbsp;</td>
  <td width='250%' valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2" style="font-weight:bold;padding-left:70px"><%=name%></td></tr></table><br> 
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
<%
end 
function writePageHeader(name, image)
%>
  <table cellspacing='0' cellpadding='0' width='100%'>
  <tr>
   <!--  <td class='icon' valign='top' width='100px'><img src='images/<%=image%>' alt='<%=name%>'></td> 
    <td class='data' valign='top'> -->
	<td>
      <table cellspacing='0' cellpadding='0' width='100%'>
        <tr><td class='midarea2' style='font-weight:bold;vertical-align:left'><%=name%></td></tr> 
        <tr><td>
<%
end

function writePageHeader_new()
%>
  <table cellspacing='0' cellpadding='0' width='100%'>
  <tr>
     <td valign='top'>
      
<%
end

function writeItemTitle(name)
%>
  <!-- <br> -->
  <table cellspacing='0' cellpadding='0' width='100%'>
  <tr><td class='midarea2 tableTitle martop15-1' style='font-weight:bold;width:300px'><%=name%></td></tr>
  <tr><td width='40' valign='top'></td><td valign='top'>
  <table width='100%' class='datatable' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
<%
end

function writeBlockTitle(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'>&nbsp;</td>
  <td width='250%' valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2" style="font-weight:bold;" width='250px'><%=name%></td></tr></table><br> 
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
<%
end

   
function writeBlockTitle_Guest(name)
%>
  <!-- <br> -->
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'>&nbsp;</td>
  <td width='250%' valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle" style="font-weight:bold;padding-left:30px" width='250px'><%=name%></td></tr></table>
  <table width='99%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <!-- <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr> -->
<%
end
function writeBlockTitle_Wifi(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'>&nbsp;</td>
  <td width='100%' valign='top'>
  <table cellspacing='0' cellpadding='0' border="0">
  <tr><td class="midarea2 tableTitle" style="font-weight:bold;padding-left:30px"><%=name%></td></tr></table><br> 
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 

<%
end
function writeBlockNoTitle()
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'><br>
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
  <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
<%
end

function writeBlockNoTitle1()
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'><br>
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'>
  <tr><td></td><td width='30px'></td><td width='220px'></td><td width='50px'></td></tr>
<%
end

function writeBlockRow(name, value)
%>
  <tr class="midarea4"><td width='330'><%=name%>:</td><td colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow2(name, value)
%>
  <tr><td class="midarea4-2"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRow3(name, value)
%>
  <tr><td class="midarea4-5"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow4(name, value)
%>
  <tr><td class="midarea4-6"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow5(name, value)
%>
  <tr><td class="wifiMidarea4-2" style="vertical-align:middle;padding-top:0px;"><%=name%>:</td><td class="midarea4-8" colspan='2' style="vertical-align:middle;padding-top:0px"><div class="wordWrap width425"><%=value%></div></td></tr>
<%
end
function writeBlockRow1(name, value)
%>
  <tr class="midarea4-1"><td width='330'><%=name%>:</td><td colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow_stat(name, value)
%>
  <tr class="midarea4" style="width:750px" ><td width='330'><%=name%>:</td><td colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow_stat1(name, value)
%>
  <tr style="width:750px" ><td class="midarea4-2"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRow_stat2(name, value)
%>
  <tr style="width:750px" ><td class="midarea4-5"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRow_TIS(name, value)
%>
  <tr><td class="midarea4" width='330'><%=name%>:</td><td class="midarea4" colspan='3'><%=value%></td></tr>
<%
end
function writeBlockRowCtrl(name, value)
%>
  <tr class='midarea4'><td width='330'><%=name%>:</td><td colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRowCtrl_new(name, value)
%>
  <tr class='midarea2'><td style='vertical-align:middle;height:100px' height='100' width='330'><%=name%>:</td><td style='vertical-align:bottom' colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRowCtrl_newAccess(name, value)
%>
  <tr><td style='vertical-align:middle;height:100px;' class="midarea4-2" height='100' ><%=name%>:</td><td style='vertical-align:middle' colspan='3' class="midarea4-3"><%=value%></td></tr>
<%
end
function writeBlockRowCtrl_GuestAccess(name, value)
%>
  <tr><td style='vertical-align:top;height:100px;' class="midarea4-2" height='100' ><%=name%>:</td><td style='vertical-align:top;padding-top:26px;' colspan='3' class="midarea4-3"><%=value%></td></tr>
<%
end
function writeBlockRowCtrl_newConfig(name, value)
%>
  <tr><td style='vertical-align:middle;padding-top:0px;' class="wifiMidarea4-2"  ><%=name%>:</td><td style='vertical-align:middle;padding-top:0px;' colspan='3'><%=value%></td></tr>
<%
end
function writeBlockSubTitle(name)
%>
  <tr><td colspan='4'><span class='Table_Title'><%=name%></span></td></tr>
<%
end 

function writeBlockSubTitle_restore(name)
%>
  <tr><td style="padding-left:30px;" colspan='4'><span class='Table_Title'><%=name%></span></td></tr>
<%
end 

function writeBlockSubTitle_statisticsAG(name)
%>

  <tr><td colspan='4' style="padding-left:40px;"><span class='Table_Title'><%=name%></span></td></tr>
<%
end

function writeTableBlockTitle(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <span class='midarea2'style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockTitle_statisticsAG(name)
%>
<br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><!-- <td width='40' valign='top'></td> --><td valign='top'>
  <span class='midarea2'style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockTitle_tool(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <span class='midarea11'style='font-weight:bold;vertical-align:left;padding-left:0px'><%=name%></span><br>
  <table class='edittable' style='padding-left:40px' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockTitle_Audevices(name)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='80' valign='top'></td><td valign='top'>
  <span class='midarea2_telmain' style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockTitle_Audevices(name,size)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='<%=size%>' valign='top'></td><td valign='top'>
  <span class='midarea2_telmain tableTitle'style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end
function writeTableBlockTitle_Authdevices(name,size)
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='<%=size%>' valign='top'></td><td valign='top'>
  <span class='midarea2_telmain'style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0' style="padding-left: 0px;">
<%
end
function writeTableBlockTitleWithoutPic(name)
%>
  <!-- <br> -->
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top' style="text-align:center;">
  <span class='midarea2 tableTitle' style='font-weight: bold; padding-left: 0px;'><%=name%></span><br>
  <table class='edittable fontSize valueSpace' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockNoTitle()
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockNoTitle_new()
%>
  <br>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockHeader(cnt, ...)
  local headers = {...}
%>
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr>
<% for k, v in pairs(headers) do %>
    <th class="tableHd"><%=v%></th>
<% end %>
  </tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
<%
end

function writeTableBlockHeader_BR(cnt, ...) 
  local headers = {...} 
%> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='0' alt=''><br></td></tr> 
  <tr> 
<% for k, v in pairs(headers) do %> 
    <td class="midarea2 tableTitle"><%=v%></td>
<% end %> 
  </tr>  
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='0' alt=''><br></td></tr> 
<% 
end

function writeWiFiTableBlockHeader(cnt, ...)
  local headers = {...}
%>
  <!-- <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>  -->
  <tr>
<% for k, v in pairs(headers) do %>
    <td class="tableHd"><%=v%></td>
<% end %>
  </tr> 
  <!-- <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> -->
<%
end

function writeTableBlockHeader_Header(cnt, ...)
  local headers = {...}
%>
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr>
<% for k, v in pairs(headers) do %>
    <th colspan='<%=cnt%>' style="padding-left:40px;"><%=v%></th>
<% end %>
  </tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
<%
end

function writeTableBlockRow(cnt, rowStyle, ...)
  local tdValues = {...}
%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr class="edittable">
<% for k, v in pairs(tdValues) do %>
    <td style="vertical-align:middle" class="<%=rowStyle%> midvertical"><%=v%></td>
<% end %>
  </tr>
  <tr><td class="<%=rowStyle%>" colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<%
end

function writeTableBlockRow_BR(cnt, rowStyle, ...)
  local tdValues = {...}
%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='0' alt=''><br></td></tr>
  <tr>
<% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> midarea2"><%=v%></td>
<% end %>
  </tr>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='0' alt=''><br></td></tr>
<%
end

function writeWiFiTableBlockRow(cnt, rowStyle, ...)
  local tdValues = {...}
%>
  <tr>
<% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%>"><%=v%></td>
<% end %>
  </tr>
<%
end

function writeTableBlockRow_Guest(cnt, rowStyle, ...)
  local tdValues = {...}
%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr >
<% for k, v in pairs(tdValues) do %>
   <td style="vertical-align:middle; padding-left: 0px;" class="<%=rowStyle%> midvertical"><%=v%></td>
<% end %>
  </tr>
  <tr><td style="padding-left: 0px;" class="<%=rowStyle%>" colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<%
end

function writeTableBlockRow_statisticsAG(cnt, rowStyle, ...)
	local tdValues = {...}
%>
  <tr class="edittable">
  <% for k, v in pairs(tdValues) do %>
    <td colspan='<%=cnt%>' style="vertical-align:middle;padding-left:40px;" class="<%=rowStyle%> midvertical"><%=v%></td>
<% end %>
  </tr>
<%
end

function writeTableBlockRowCtrl(cnt, rowStyle, value)

%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr>
    <td colspan='<%=cnt%>' class="<%=rowStyle%>"><%=value%></td>
  </tr>
  <tr><td class="<%=rowStyle%>" colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<%
end

function writeTableBlockRowCtrl_wifihidden(cnt, rowStyle, value)

%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr style='padding-left:40px'>
    <td colspan='<%=cnt%>' class="<%=rowStyle%>"><%=value%></td>
  </tr>
  <tr><td class="<%=rowStyle%>" colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<%
end
function writeSectionRow(name, value)
%>
 <tr><td class="sectionArea-1 padleft40"><%=name%>:</td><td class="sectionArea-2" colspan='3'><%=value%></td></tr>
<%
end
function writeSectionRowHeader(name)
%>
 <tr><td class="midarea2 tableTitle"><%=name%>:</td></tr>
<%
end
function writeBlockNoTitle_restoreWithoutHeader()
%>
  <table class='servizitable fontSize martop5' width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'>   

<%
end

function writeTableRowNoTitle()
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'></td><td valign='top'>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeBlockTitle_restoreHeader(name)
%>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle"><%=name%></td></tr></table>	

<%
end

function writeBlockRowTitle(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle"><%=name%></td></tr></table>
  <table cellspacing='0' cellpadding='0' class='servizitable fontSize' style='line-height:150%;'> 
<%
end

function writeBlockRow_Desc(name, value)
%>
  <tr><td class="sectionArea-1 padleft40 "><%=name%>:</td><td class="sectionArea-2 verticalAlign" colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRow_Sub(name, value)
%>
  <tr><td class="sectionArea-1 padleft40 "><%=name%>:</td><td colspan='3' class="sectionArea-2 verticalAlign"><%=value%></td></tr>
<%
end

function writeTableContHeader(cnt, ...)
  local headers = {...}
%>
  <tr>
<% for k, v in pairs(headers) do %>
    <td class="tableTitle"><%=v%></td>
<% end %>
  </tr> 
 
<%
end

function writeTableRowTitle_statisticsAG(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="padtop10 width770"><tr><!-- <td width='40' valign='top'></td> --><td valign='top'>
  <span class="midarea2 tableTitle"><%=name%></span><br>
  <table class='edittable fontSize marleft36 valueSpace width770' width='100%' cellspacing='0' cellpadding='0' border='0'>
  
  <%
end

function writeTableRow_statisticsAG(cnt, rowStyle, ...)
	local tdValues = {...}
%>
  <tr>
  <% for k, v in pairs(tdValues) do %>
    <td colspan='<%=cnt%>' class="<%=rowStyle%> alignMid rowvertical"><%=v%></td>
<% end %>
  </tr>
   
<%
end


function writeTableRowHeader_Header(cnt, ...)
  local headers = {...}
%>
  <tr>
<% for k, v in pairs(headers) do %>
    <td  class="tableHd" colspan='<%=cnt%>'><%=v%></td>
<% end %>
  </tr> 
<%
end

function writeBlockRowNoTitle()
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td valign='top'>
  <table class='edittable fontSize marleft36 width750' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableRowTitle_port(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="width750 padtop10 marLeft26"><tr><td valign='top'>
  <span class="tableTitle"><%=name%></span>
  <table class='edittable fontSize valueSpace martop5' width='100%' cellspacing='0' cellpadding='0' border='0'>
  
  <%
end

function writePageRowHeader(name, image)
%>
  <table cellspacing='0' cellpadding='0' class='edittable fontSize  width750'>
  <tr>
	<td>
      <table cellspacing='0' cellpadding='0' width='100%'>
        <tr><td class='midarea2 tableTitle padLeft26'><%=name%></td></tr> 
        <tr><td>
<%
end


function writeTableBlockRowHeader(cnt, ...)
  local headers = {...}
%>
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td></tr> 
  <tr>
<% for k, v in pairs(headers) do %>
    <th  class="tableHd"><%=v%></th>
<% end %>
  </tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''></td></tr>
<%
end

function writeBlockRowTitle_Guest(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="padtop10 fontSize"><tr>
  <td valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle" style="font-weight:bold;padding-left:30px"><%=name%></td></tr></table><br> 
  <table width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
   <%
end

function writeBlockRow_Guest(name, value)
%>
  <tr><td class="midarea4-2 padleft40" ><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRow_Guest1(name, value)
%>
  <tr><td class="midarea4-2"><%=name%>:</td><td class="midarea4-3" colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRowCtrl_GuestControl(name, value)
%>
  <tr><td style='vertical-align:top;height:100px;' class="midarea4-2" height='100' ><%=name%>:</td><td style='vertical-align:top;padding-top:10px;' colspan='3' class="midarea4-3"><%=value%></td></tr>
<%
end

function writeBlockPageHeader(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%'>
  <tr>

	<td>
      <table cellspacing='0' cellpadding='0' width='100%'>
        <tr><td class='midarea2 tableTitle'><%=name%></td></tr> 
        <tr><td>
<%
end

function writeBlockRowCtrl_Config(name, value)
%>
  <tr><td style='vertical-align:middle;padding-top:0px;' class="wifiMidarea4-2"  ><%=name%>:</td><td style='vertical-align:middle;padding-top:0px;' colspan='3' ><%=value%></td><td>&nbsp;</td></tr>
<%
end

function writeBlockRow_GuestStatus(name, value)
%>
  <tr><td class="wifiMidarea4-2"><%=name%>:</td><td class="midarea4-8" colspan='3'><%=value%></td></tr>
<%
end

function writeTableRowTitle_modemConfig(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="padtop10 width750"><tr><!-- <td width='40' valign='top'></td> --><td valign='top'>
  <span class="midarea2 tableTitle"><%=name%></span><br>
  <table class='edittable fontSize marleft36 valueSpace' style="width:715px;" width='100%' cellspacing='0' cellpadding='0' border='0'>
  
  <%
end

function writeBlockRow_WifiGuest(name, value)
%>
  <tr><td class="wifiMidarea4-2" style="padding-top:0px"><%=name%>:</td><td class="midarea4-8" colspan='3' style="padding-top:0px"><%=value%></td></tr>
<%
end

function writeTableBlockTitle_Wifidevices(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="martop15"><tr><td valign='top'>
  <span class='midarea2 tableTitle' style="padding-left:32px"><%=name%></span><br>
  <table class='edittable fontSize marleft32 valueSpace width750' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeBlockRow_WifiGuestValue(name, value)
%>
  <tr><td class="wifiMidareaCont" style="padding-top:0px;padding-left:0px;"><%=name%>:</td><td class="midarea4-8" colspan='3' style="padding-top:0px;padding-left:0px;"><%=value%></td></tr>
<%
end

function writeBlockTitle_GuestConnect(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='40' valign='top'>&nbsp;</td>
  <td width='250%' valign='top'>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle" style="padding-left:30px;height:20px"><%=name%></td></tr></table>
  <table width='99%' cellspacing='0' cellpadding='0' style='line-height:150%;'> 
<%
end

function writeBlockRowCtrl_Access(name, value)
%>
  <tr><td style='vertical-align:middle;padding-top:0px;' class="wifiMidarea4-2"  ><div style='width:280px'><%=name%>:</div></td><td style='vertical-align:middle;padding-top:0px;' colspan='3'><%=value%></td></tr>
<%
end

function writeBlockRowCntrl_Access(name, value)
%>
  <tr><td style='vertical-align:middle;padding-top:0px;' class="wifiMidarea4-2"  ><div style='width:280px'><%=name%>.</div></td><td style='vertical-align:middle;padding-top:0px;' colspan='3'><%=value%></td></tr>
<%
end
function writeTableBlockTitle_Authdevices(name,size)
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td width='<%=size%>' valign='top'></td><td valign='top'>
  <span class='midarea2_telmain tableTitle' style='font-weight:bold;vertical-align:left'><%=name%></span><br>
  <table class='edittable' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeBlockRowCtrl_AccessControl(name, value)
%>
  <tr><td style='vertical-align:top;height:50px;' class="midarea4-2" ><%=name%>:</td><td style='vertical-align:top;padding-top:10px;' colspan='3' class="midarea4-3"><%=value%></td></tr>
<%
end

function writeWifiBlockHeader(cnt, ...)
  local headers = {...}
%>
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr>
<% for k, v in pairs(headers) do %>
    <th class="tableHd" style="width:250px;"><%=v%></th>
<% end %>
  </tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''><br></td></tr>
<%
end

function writeTableRow_wifihidden(cnt, rowStyle, value)

%>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
  <tr style='padding-left:40px'>
    <td colspan='<%=cnt%>' class="<%=rowStyle%>" style='padding-left:0px'><%=value%></td>
  </tr>
  <tr><td class="<%=rowStyle%>" colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''><br></td></tr>
<%
end

function writeTableBlockRowHeader_Call(cnt, ...)
  local headers = {...}
%>
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='3' alt=''></td></tr> 
  <tr>
<% for k, v in pairs(headers) do %>
    <th  class="tableHd" style="width:180px"><%=v%></th>
<% end %>
  </tr> 
  <tr><td colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='1' alt=''></td></tr>
<%
end

function writeTableRow_statisticsCall(cnt, rowStyle, ...)
	local tdValues = {...}
%>
  <tr>
  <% for k, v in pairs(tdValues) do %>
    <td colspan='<%=cnt%>' class="<%=rowStyle%> alignMid rowvertical fontSize" style="width:180px"><%=v%></td>
<% end %>
  </tr>
   
<%
end

function writeTableRowTitle_PortMap(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%' class="padtop10" style="width:700px;"><tr><td valign='top'>
  <span class="midarea2 tableTitle"><%=name%></span><br>
  <table class='edittable fontSize marleft36 valueSpace' width='100%' cellspacing='0' cellpadding='0' border='0' style="width:700px;">
  
  <%
end

function writeTableRowHeader_PortMap(...)
  local headers = {...}
%>
  <tr>
<% for k, v in pairs(headers) do %>
    <td  class="tableHd width110 wordWrap"><div class="width110 wordWrap"><%=v%></div></td>
<% end %>
  </tr> 
<%
end

function writeTableRow_PortMap(rowStyle, ...)
	local tdValues = {...}
%>
  <tr>
  <% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> alignMid rowvertical width110 wordWrap"><div class="width110 wordWrap"><%=v%></div></td>
<% end %>
  </tr>
   
<%
end

function writeBlockRowNoTitle_Access()
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td valign='top'>
  <table class='edittable fontSize marleft36 width770' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableRow_callstatistics(rowStyle, ...)
	local tdValues = {...}
%>
  <tr>
  <% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> alignMid rowvertical fontSize" style="width:180px"><%=v%></td>
<% end %>
  </tr>
   
<%
end

function writePortTableRow(cnt, rowStyle, ...)
  local tdValues = {...}
%>
  <tr>
<% for k, v in pairs(tdValues) do %>
    <td style="vertical-align:middle" class="<%=rowStyle%> midvertical padcell"><%=v%></td>
<% end %>
  </tr>
<%
end

function writeTableRow_Guest(name, value)
%>
  <tr><td class="midarea4-3" style="width:130px;padding-left:30px;"><%=name%>:</td><td class="midarea4-3 txtLeft" style="width:200px;"><%=value%></td></tr>
<%
end

function writeTableBlockRow_restore(cnt, rowStyle, ...)
  local tdValues = {...}
%>
   <tr>
<% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> restoreTd"><%=v%></td>
<% end %>
  </tr>
  <tr><td class='<%=rowStyle%>' colspan='<%=cnt%>'><img src='images/spacer.gif' border='0' width='1' height='0' alt=''><br></td></tr>
   
  
<%
end

function writeTableBlockHeader_restore(cnt, ...) 
  local headers = {...} 
%> 

  <tr> 
<% for k, v in pairs(headers) do %> 
    <td class="restoreTd tableTitle"><%=v%></td>
<% end %> 
  </tr>  

<% 
end

function writeBlockNoTitle_restoreHeader()
%>
  <table class='servizitable fontSize martop5 marleft40' width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'>   

<%
end

function writeTableBlockRowRestore_BR(cnt, rowStyle, ...)
  local tdValues = {...}
%>

  <tr>
<% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> midarea2" style="width:85px;"><%=v%></td>
<% end %>
  </tr>
<%
end

function writeTableBlockHeaderRestore_BR(cnt, ...) 
  local headers = {...} 
%> 

  <tr> 
<% for k, v in pairs(headers) do %> 
    <td class="midarea2 tableTitle" style="width:85px;"><%=v%></td>
<% end %> 
  </tr>  

<% 
end
function writeTableBlockRowRestore_new(cnt, rowStyle, ...)
  local tdValues = {...}
%>

  <tr>
<% for k, v in pairs(tdValues) do %>
    <td class="<%=rowStyle%> midarea2" style="width:135px;"><%=v%></td>
<% end %>
  </tr>
<%
end

function writeTableBlockHeaderRestore_new(cnt, ...) 
  local headers = {...} 
%> 

  <tr> 
<% for k, v in pairs(headers) do %> 
    <td class="midarea2 tableTitle" style="width:135px;"><%=v%></td>
<% end %> 
  </tr>  

<% 
end

function writeBlockNoTitle_restoreContent()
%>
  <table class='servizitable fontSize martop5 marleft40'  cellspacing='0' cellpadding='0' style='line-height:150%;width:720px;'>   

<%
end

function writeBlockNoTitle_restoreContentTable()
%>
  <table class='fontSize martop5 marleft40'  cellspacing='0' cellpadding='0' style='line-height:150%;width:720px;'>   

<%
end

function writeBlock_RestoreWithoutHeader()
%>
  <table class='servizitable fontSize martop5' width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;width:540px;'>   

<%
end

function writeBlockTitle_WaitInfoHeader(name)
%>
  <table cellspacing='0' cellpadding='0'>
  <tr><td class="midarea2 tableTitle" style="height:20px"><%=name%></td></tr></table>	

<%
end

function writeSectionRow_WaitInfoHeader(name)
%>
 <tr><td class="midarea2 tableTitle" style="height:20px"><%=name%>:</td></tr>
<%
end

function writeBlockNoTitle_conWithoutHeader()
%>
  <table class='fontSize' width='100%' cellspacing='0' cellpadding='0' style='line-height:150%;'>   

<%
end

function writeTableWifiWithoutPic(name)
%>
  <table cellspacing='0' cellpadding='0' width='100%'><tr><td valign='top' style="text-align:center;">
  <span class='midarea2 tableTitle '><%=name%></span><br>
  <table class='edittable fontSize width700 valueSpace marleft40' width='100%' cellspacing='0' cellpadding='0' border='0'>
<%
end

function writeTableBlockHeader_WiFi(cnt, ...)
  local headers = {...}
%>
  <tr>
<% for k, v in pairs(headers) do %>
    <td class="tableHd width150"><%=v%></td>
<% end %>
  </tr> 
<%
end

function endBlock_restore()
  cgilua.print([[</table>]])

end

function endBlock()
  cgilua.print([[</table></td></tr></table>]])
end

function endPage()
  cgilua.print([[</td></tr></table></td></tr></table>]])
end
%>

