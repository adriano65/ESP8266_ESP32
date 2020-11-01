<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Modem Telecom Italia</title>
         <link href="css/master.css" type="text/css" rel="stylesheet"/>
         <% cgilua.lp.include("lp/language.lp") %>
<%
local translate = translate
%>
</head>
<body>

<div class="contentContainer">
	 
		<div class="breadCrumbContainer">
			<ul class="brdCrumb">
				<li><a href="standard.lp"><%=translate([==[Basic Settings]==])%></a></li><li>|</li><li><a href="loginMgm.lp"><%=translate([==[Local Access]==])%></a></li>
			</ul>
		</div>	

<div class="contentTab" id="content">
		<ol id="tocTab">
			<li><a href="loginMgm.lp" class="current">
				<div class="tab">
				<span class="tabIconLocalAccess"></span>  
				<span class="contTabTxt transform"><%=translate([==[Local Access]==])%></span>
				</div><div class="clrBth"></div></a>
			</li>
		</ol>
</div>

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
                          <td class="errorMessage"><%=translate([==[Operation failed]==])%>.</td></tr>
                             <tr><td class="errorDesc"><p><%=translate([==[Warning: The password you entered is not valid. Make sure the passwords are to respect the minimum and maximum allowed, which contain at least one character of each of the following sets: [0-9], [a - z], [A - Z], or does not contain special characters or symbols not allowed]==])%></p>
							<br/>
        </td></tr></table>
        </td></tr>
		<tr><td>
         <table  cellspacing='0' cellpadding='0' class="fontSize padtop10 width790">
          <tr><td class="width340">&nbsp;</td>
            <td class="verticalAlign">
				   <!-- <a onclick="back()" href="#"> -->
				   <a href="loginMgm.lp">
				<div name="thb11" class="midarea6-1 mainButton"><%=translate([==[Continue]==])%></div></a>
            </td></tr>
        </table>
    </td>
</tr>
</table>
</div>
</div>
</body>
</html>
		