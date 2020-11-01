function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
 return null;
}
var forms=document.getElementsByTagName("form");
var rn = readCookie('xAuth_SESSION_ID');
for (var i=0; i<forms.length; i++)
{
  var temp = document.createElement("INPUT");
  temp.type = "hidden";
  temp.name = "rn";
  temp.value = rn;
  forms[i].insertBefore(temp, forms[i].firstChild);
}
