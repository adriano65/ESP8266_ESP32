// JavaScript Document


function FP_preloadImgs() {//v1.0
 var d=document,a=arguments; if(!d.FP_imgs) d.FP_imgs=new Array();
 for(var i=0; i<a.length; i++) { d.FP_imgs[i]=new Image; d.FP_imgs[i].src=a[i]; }
}

function FP_swapImg() {//v1.0
 var doc=document,args=arguments,elm,n; doc.$imgSwaps=new Array(); for(n=2; n<args.length;
 n+=2) { elm=FP_getObjectByID(args[n]); if(elm) { doc.$imgSwaps[doc.$imgSwaps.length]=elm;
 elm.$src=elm.src; elm.src=args[n+1]; } }
}

function FP_getObjectByID(id,o) {//v1.0
 var c,el,els,f,m,n; if(!o)o=document; if(o.getElementById) el=o.getElementById(id);
 else if(o.layers) c=o.layers; else if(o.all) el=o.all[id]; if(el) return el;
 if(o.id==id || o.name==id) return o; if(o.childNodes) c=o.childNodes; if(c)
 for(n=0; n<c.length; n++) { el=FP_getObjectByID(id,c[n]); if(el) return el; }
 f=o.forms; if(f) for(n=0; n<f.length; n++) { els=f[n].elements;
 for(m=0; m<els.length; m++){ el=FP_getObjectByID(id,els[n]); if(el) return el; } }
 return null;
}

function coolRedirect(url, topflag, msg)
{
   var TARG_ID = "COOL_REDIRECT";
   var DEF_MSG = "Reindirizzamento...";

   if( ! msg )
   {
      msg = DEF_MSG;
   }

   if( ! url )
   {
      throw new Error('Lei non ha incluso il parametro "url"');
   }


   var e = document.getElementById(TARG_ID);

   if( ! e )
   {
      throw new Error('"COOL_REDIRECT" elemento id non trovato');
   }

   var cTicks = parseInt(e.innerHTML);

   var timer = setInterval(function()
   {
      if( cTicks )
      {
         e.innerHTML = --cTicks;
      }
      else
      {
         clearInterval(timer);
         document.body.innerHTML = msg;
         if (topflag)
           top.location.href=url; 
         else
         location.href = url;
      }

   }, 1000);
}

function coolRedirectReset(url, msg)
{
   var TARG_ID = "COOL_REDIRECT";
   var DEF_MSG = "Reindirizzamento...";

   if( ! msg )
   {
      msg = DEF_MSG;
   }

   if( ! url )
   {
      throw new Error('Lei non ha incluso il parametro "url"');
   }


   var e = document.getElementById(TARG_ID);

   if( ! e )
   {
      throw new Error('"COOL_REDIRECT" elemento id non trovato');
   }

   var cTicks = parseInt(e.innerHTML);

   var timer = setInterval(function()
   {
      if( cTicks )
      {
         e.innerHTML = --cTicks;
      }
      else
      {
         clearInterval(timer);
         document.body.innerHTML = msg;
         window.parent.location = url;
      }

   }, 1000);
}

//validation the ip address, in order to confirm the ip address is right.
function isValidIPAddress(IPvalue)
{
	var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
	var ipArray = IPvalue.match(ipPattern);
	if (ipArray == null)
		return false;
	else
	{
        for(i=1; i<=4; i++)
        {
		   if(parseInt(ipArray[i])> 255 || parseInt(ipArray[i])<0)
            return false;
        }
		if(parseInt(ipArray[1])>=224 || parseInt(ipArray[1])==127)
			return false;
		if(parseInt(ipArray[1])==169 && parseInt(ipArray[2])==254)
			return false;
		if(parseInt(ipArray[4])==0 || parseInt(ipArray[4])==255)
			return false;
	}	
	return true;
}


function ip2long(ip_address) 
{
    var parts = ip_address.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
      return parts
            ? parts[1] * 16777216 + parts[2] * 65536 + parts[3] * 256 + parts[4] * 1
                : false;
}

function inRange(ip, startip, endip)
{
    if ((ip2long(ip)>=ip2long(startip)) && (ip2long(ip)<=ip2long(endip))) 
       return true;
    else
       return false;
}

function ajax_init_object() {
        var A;
        try {
                A=new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
                        try {
                                A=new ActiveXObject("Microsoft.XMLHTTP");
                        } catch (oc) {
                                A=null;
                        }
        }
        if(!A && typeof XMLHttpRequest != "undefined")
                        A = new XMLHttpRequest();
        return A;
}

function sajax_get(url, param, callback)
{
        var x = ajax_init_object();
        if (param) {
                url = url + '?' + param;
        }
        x.open('GET', url, true);
        x.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        x.setRequestHeader("Connection", "close");
        x.send("");
        x.onreadystatechange = function() {
                if (x.readyState == 4)
                callback(x);
        };
        delete x;
}
