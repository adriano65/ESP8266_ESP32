/* JavaScript for port mapping */

function customPortJudgement(port)
{   
	if((port=="") || isNaN(port) || parseInt(port)==0 || parseInt(port)>65535 || port.match(/[.,\\]/))
    {
        return false;
    }
    return true;
}

//Check the every port for internal or external port which have been split by "-"
function checkSinglePort(portStr)
{
    var portArr = portStr.split("-");
    for(var i=0;i<portArr.length;i++)
    {
        if(!customPortJudgement(portArr[i]))
        {
            return false;
        }
    }

    if(parseInt(portArr[0])>parseInt(portArr[1]))
    {
        return false;
    }
    return true;
}

//Split the port with "-", if it's a correct port, it should return the value of port2-port1
function customPortElemSplit(internalPortStr, externalPortStr)
{   
    var result = true;
    if(internalPortStr.indexOf("-")>-1)
    {
        if((!checkSinglePort(internalPortStr)) || (!checkSinglePort(externalPortStr)))
        {
            return false;
        }
        
        var internalPortArr = internalPortStr.split("-");
        var externalPortArr = externalPortStr.split("-");

        if(internalPortArr.length!=2 || externalPortArr.length!=2)
        {   
            return false;
        }
        
        var internalPortRange = parseInt(internalPortArr[1]) - parseInt(internalPortArr[0])
        var externalPortRange = parseInt(externalPortArr[1]) - parseInt(externalPortArr[0])
        
        if(internalPortRange != externalPortRange)
        {
            return false;
        }
    }
    else
    {
        if(!(customPortJudgement(internalPortStr) && customPortJudgement(externalPortStr)))
        {
            return false;
        }
    }

    return result;
}

//Check the port range for internal and external port range.
function checkPortRange(internalPortStr, externalPortStr)
{
    var internalPortArr = internalPortStr.split(",");
    var externalPortArr = externalPortStr.split(",");   
    for(var i=0;i<internalPortArr.length;i++)
    {           
        if(!customPortElemSplit(internalPortArr[i], externalPortArr[i]))
        {
            return false;
        }
    }
    return true;
}

//Validate the internal and external port with the split "," and "-"
function portValidation(internalPortStr, externalPortStr, split)
{
    if((internalPortStr.indexOf(split)>-1 && externalPortStr.indexOf(split)==-1) || (internalPortStr.indexOf(split)==-1 && externalPortStr.indexOf(split)>-1))
    {   
        return false;
    }
    
    var internalPortArray = internalPortStr.split(split);
    var externalPortArray = externalPortStr.split(split); 
    if(parseInt(internalPortArray.length) != parseInt(externalPortArray.length))
    {   
        return false;   
    }
    return true;

}


function isCustomPortRangeRight(internalPortStr, externalPortStr)
{   
//    alert(internalPortStr);
//    alert(externalPortStr);
    
    //Check the port's validation if it includes ";"
    if(internalPortStr.indexOf(";")>-1 || externalPortStr.indexOf(";")>-1)
    {       
        return false;
    }

    //Check the port's validation if it includes ","
    if(internalPortStr.indexOf(",")>-1 || externalPortStr.indexOf(",")>-1)
    {
        if(!portValidation(internalPortStr, externalPortStr, ","))
        {   
            return false;
        }
    }

    //Check the port's validation if it includes "-"
        if(internalPortStr.indexOf("-")>-1 || externalPortStr.indexOf("-")>-1)
        {
            if(!portValidation(internalPortStr, externalPortStr, "-"))
            {
                return false;
            }
        }

    if(internalPortStr.indexOf(",")>-1)
    {
        if(!checkPortRange(internalPortStr, externalPortStr))
        {   
            return false;
        }

    }else if(internalPortStr.indexOf("-")>-1)
    {
        if(!customPortElemSplit(internalPortStr, externalPortStr))
        {   
            return false;
        }       
    }
    else
    {   
        if(!(customPortJudgement(internalPortStr) && customPortJudgement(externalPortStr)))
        {   
            return false;
        }
    }   
    
    return true;
}

function isValidFullPortRange(internalPortFull, externalPortFull)
{
  if( (internalPortFull.indexOf("TCP")>-1) && (internalPortFull.indexOf("UDP")>-1) && (internalPortFull.indexOf(";")>-1) )
  {
    if( (externalPortFull.indexOf("TCP")<0) || (externalPortFull.indexOf("UDP")<0) || (externalPortFull.indexOf(";")<0) )
      return false;

    var internalPortArray = internalPortFull.split(";");
    var externalPortArray = externalPortFull.split(";");
    var intStr0 = internalPortArray[0].substring(4, internalPortArray[0].length);
    var extStr0 = externalPortArray[0].substring(4, externalPortArray[0].length);
    var intStr1 = internalPortArray[1].substring(4, internalPortArray[1].length);
    var extStr1 = externalPortArray[1].substring(4, externalPortArray[1].length);
    if( (isCustomPortRangeRight(intStr0, extStr0) == false) || (isCustomPortRangeRight(intStr1, extStr1) == false) )
      return false;
    else
      return true;
  }
  else if( (internalPortFull.indexOf("TCP")==0) || (internalPortFull.indexOf("UDP")==0) )
  {
    var intStr = internalPortFull.substring(4, internalPortFull.length);
    var extStr = externalPortFull.substring(4, externalPortFull.length);
    return isCustomPortRangeRight(intStr, extStr);
  }
  else
  {
    return isCustomPortRangeRight(internalPortFull, externalPortFull);
  }
}

function portChange(port)
{
    if(port=="*")
    {
        document.getElementById("customInternalPort").value="*";
        document.getElementById("customExternalPort").value="*";
    }
}

function sajax_init_object() {
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

function ajax_get(url, param, callback)
{   
    var x = sajax_init_object();
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
