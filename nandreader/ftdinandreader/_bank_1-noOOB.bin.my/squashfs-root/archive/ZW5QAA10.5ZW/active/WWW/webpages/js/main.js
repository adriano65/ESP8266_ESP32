//function for Tab bg color change
	function currentTab(link) {
		var content_links = document.getElementById("content").getElementsByTagName("a");
		for (var i = 0; i < content_links.length; ++i) {
			content_links[i].className = (content_links[i] == link) ? "current" : "";
		}
    }
	
//function for left nav bg color change
	
	function LeftNav(id) {
		
		if(id=='home') {
			
			document.getElementById("home").className="Icons";
			document.getElementById("base").className="";
			document.getElementById("advance").className="";
			
		} else if(id=='base') {
			
			document.getElementById("home").className="";
			document.getElementById("base").className="Icons";
			document.getElementById("advance").className="";
			
		} else if(id=='advance') {
			document.getElementById("home").className="";
			document.getElementById("base").className="";
			document.getElementById("advance").className="Icons";
		}
		/*
		var LeftIcons_links = document.getElementById("LeftIcons").getElementsByTagName("a");
		for (var i = 0; i < LeftIcons_links.length; ++i) {
			LeftIcons_links[i].className = (LeftIcons_links[i] == link) ? "Icons" : "";
		}
		*/
    }
	
	
//function for Base id-d2-submenu selection
	
	function submenuclick(link) {
		var d2_links = document.getElementById("d2").getElementsByTagName("a");
		for (var i = 0; i < d2_links.length; ++i) {
			d2_links[i].className = (d2_links[i] == link) ? "submenuselect" : "";
		}
    }
	
//function for Avanzate id-d3-submenu selection
	
	function submenuclick1(link) {
		var d3_links = document.getElementById("d3").getElementsByTagName("a");
		for (var i = 0; i < d3_links.length; ++i) {
			d3_links[i].className = (d3_links[i] == link) ? "submenuselect1" : "";
		}
    }



 //function for show and hide divs of main icons
	function showSubMenu(obj) {

                document.getElementById(obj).style.display = 'block';
			
            }
			
/*	function showPage(obj) {

                document.getElementById('d1text').style.display = 'none';
                document.getElementById('d2text').style.display = 'none';
				document.getElementById('d3text').style.display = 'none';

                document.getElementById(obj).style.display = 'block';

            }
*/			
	function hideonly(obj) {
				document.getElementById(obj).style.display = 'none';

				}

//function for show and hide divs of submenu


function showsubmenuPage(obj) {

                document.getElementById(obj).style.display = 'block';

            }
function showIcons()
{
	window.parent.menu.document.getElementById("stcon").className="";
	window.parent.menu.document.getElementById("serte").className="";
	window.parent.menu.document.getElementById("lanst").className="";
	window.parent.menu.document.getElementById("wifist").className="";
	window.parent.menu.document.getElementById("asst").className="";
	window.parent.menu.document.getElementById("stat").className="";
	window.parent.menu.document.getElementById("loac").className="";
	
}

function showIcons1()
{
	var id = "";
	if( window.parent.menu.document.getElementById("tele") != null )
	window.parent.menu.document.getElementById("tele").className="";
	window.parent.menu.document.getElementById("usbst").className="";
	window.parent.menu.document.getElementById("media").className="";
	id = window.parent.menu.document.getElementById("port");
	if( id != null )	
	window.parent.menu.document.getElementById("port").className="";
	
	id = window.parent.menu.document.getElementById("dns");
	if( id != null )	
	window.parent.menu.document.getElementById("dns").className="";
		
	window.parent.menu.document.getElementById("firewa").className="";
	
	id = window.parent.menu.document.getElementById("urlfi");
	if( id != null )	
	window.parent.menu.document.getElementById("urlfi").className="";
	
	//window.parent.menu.document.getElementById("reac").className="";
	window.parent.menu.document.getElementById("waon").className="";
	window.parent.menu.document.getElementById("stru").className="";

}

function linktoWifiSub()
{	
	window.parent.menu.document.getElementById("wifi2li").style.display="block";
	window.parent.menu.document.getElementById("wifi5li").style.display="block";
	window.parent.menu.document.getElementById("wifi_guestli").style.display="block";
}

function hideWifiSub()
{	
	window.parent.menu.document.getElementById("wifi2li").style.display="none";
	window.parent.menu.document.getElementById("wifi5li").style.display="none";
	window.parent.menu.document.getElementById("wifi_guestli").style.display="none";
}

function linktoTeleSub()
{	
	window.parent.menu.document.getElementById("teleSubli").style.display="block";
}

function hideTeleSub()
{              if(window.parent.menu.document.getElementById("teleSubli")) {
                                window.parent.menu.document.getElementById("teleSubli").style.display="none";
                }
}

