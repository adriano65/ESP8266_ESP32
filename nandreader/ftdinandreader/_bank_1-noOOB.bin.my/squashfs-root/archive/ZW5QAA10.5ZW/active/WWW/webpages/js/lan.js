//Compare the two ip address, in order to confirm the highIp is bigger than lowIP.
function isIpLessEqual(lowIP, highIP)
{
	var bValid = true;
	var i;
	if (isValidIPAddress(lowIP) && isValidIPAddress(highIP))
	{
		var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
		var ipArrayLow = lowIP.match(ipPattern);
		var ipArrayHigh = highIP.match(ipPattern);

		// Can't use bit shifting here because int is a signed int and
		// can't contain the most significant 255.
		for (i = 1; i <= 4; i++)
		{
			thisSegmentLow = parseInt(ipArrayLow[i]);
			thisSegmentHigh = parseInt(ipArrayHigh[i]);
			if (thisSegmentHigh > thisSegmentLow)
			{
				break;
			}
			if (thisSegmentHigh < thisSegmentLow)
                        {
				bValid = false;
                        }
		}
	}
	else
	{
		bValid = false;
	}
	return bValid;
}

//To confirm the ip is between the lowIP and highIP.
function isInIPRange(ip, lowIP, highIP)
{
	return isIpLessEqual(lowIP, ip) && isIpLessEqual(ip, highIP);
}
//To confirm the ip1 and ip2 are in the same ip segment.
function isIPMatch(ip1, ip2, ipMask)
{
	var isMatch = true;
	var i;

	if (isValidIPAddress(ip1) && isValidIPAddress(ip2))
	{
		var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
		var ip1Array = ip1.match(ipPattern);
		var ip2Array = ip2.match(ipPattern);
		var ipMaskArray = ipMask.match(ipPattern);

		for (i = 1; i <= 4; i++)
		{
			ip1Segment = parseInt(ip1Array[i]);
			ip2Segment = parseInt(ip2Array[i]);
			ipMaskSegment = parseInt(ipMaskArray[i]);
			ip1Segment = ip1Segment & ipMaskSegment;
			ip2Segment = ip2Segment & ipMaskSegment;
			if (ip1Segment != ip2Segment)
			{
				isMatch = false;
			}
		}
	}
	else
	{
		isMatch = false;
	}

	return isMatch;
}
//To get the array of the start ip.
function GetStartRange_array(IPNr, SubnetMask)
{
	var IP_new = new Array();
	var IP = new Array();
	IP = IPNr.split('.');

	var Subnet = new Array();
	Subnet = SubnetMask.split('.');

	IP_new[0] = ((IP[0]*1) & (Subnet[0]*1));
	IP_new[1] = ((IP[1]*1) & (Subnet[1]*1));
	IP_new[2] = ((IP[2]*1) & (Subnet[2]*1));
	IP_new[3] = ((IP[3]*1) & (Subnet[3]*1)) + 1;

	return IP_new;
}

//To get the array of the end ip.
function GetEndRange_array(IPNr, SubnetMask)
{
	var IP_new = new Array();
	var IP = new Array();
	IP = IPNr.split('.');

	var Subnet = new Array();
	Subnet = SubnetMask.split('.');

	var xIP0 = ((IP[0]*1) & (Subnet[0]*1));
	var xIP1 = ((IP[1]*1) & (Subnet[1]*1));
	var xIP2 = ((IP[2]*1) & (Subnet[2]*1));
	var xIP3 = ((IP[3]*1) & (Subnet[3]*1));

	IP_new[0] = (xIP0 + (~(Subnet[0]*1) & 255) );
	IP_new[1] = (xIP1 + (~(Subnet[1]*1) & 255) );
	IP_new[2] = (xIP2 + (~(Subnet[2]*1) & 255) );
	IP_new[3] = (xIP3 + (~(Subnet[3]*1) & 255) - 1);

	return IP_new;
}
//To get the start ip in the base of the ip and submask.
function GetStartRange(IPNr, SubnetMask)
{
	IP = GetStartRange_array(IPNr, SubnetMask);
	var NewStart = IP[0] + "." + IP[1] + "." + IP[2] + "." + IP[3];

	return NewStart;
}

//To get the end ip in the base of the ip and submask.
function GetEndRange(IPNr, SubnetMask)
{
	IP = GetEndRange_array(IPNr, SubnetMask);
	var NewEnd = IP[0] + "." + IP[1] + "." + IP[2] + "." + IP[3];

	return NewEnd;
}

//Report the error message when the ip/nat/dhcp is wrong.
function showErrorMsg(errorMsgStr)
{
	document.getElementById("lanConfig").style.display="none";
	document.getElementById("resultKO").style.display="block";
	document.getElementById("errorMsg").innerHTML=errorMsgStr;
}

//validation the ip address, in order to confirm the ip address is right.
function isValidIPAddress(IPvalue)
{
  var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
  var ipArray = IPvalue.match(ipPattern);
  if (ipArray == null)
  {
    return "formatWrong";
  }
  else
  {
    for(i=1; i<=4; i++)
    {
      if(parseInt(ipArray[i])>= 255 || parseInt(ipArray[i])<0)
      {
        return "formatWrong";
      }
    }
    if((parseInt(ipArray[1])==0)||(parseInt(ipArray[4])==0))
    {
      return "formatWrong";
    }  
    if(parseInt(ipArray[1])>=224 || parseInt(ipArray[1])==127)
    {
      return "outOfRange";
    }
    if(parseInt(ipArray[1])==169 && parseInt(ipArray[2])==254)
    {
      return "outOfRange";
    }
  }
  return true;
}

//validation the ip address, in order to confirm the ip address is right.
function isValidIPAddress_mask(IPvalue,mask4)
{
  var ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
  var ipArray = IPvalue.match(ipPattern);
  if (ipArray == null)
	{		
		return "formatWrong";
	}
  
  var test_zero_broadcast = (ipArray[4]*1 & (~(mask4*1)));//for the mask is 255.255.255.mask, only need to test ipAddr4
  var test_broadcast =test_zero_broadcast*1|mask4*1;

	if (ipArray == null)
	{		
		return "formatWrong";
	}
	else
	{
		for(i=1; i<=4; i++)
		{
			if(parseInt(ipArray[i])> 255 || parseInt(ipArray[i])<0)
			{				
				return "formatWrong";
			}
		}
		if(test_zero_broadcast==0)
		{			
			return "localAddr";
		}
		if(test_broadcast==255)
		{			
			return "broadcastAddr";
		}
		if(parseInt(ipArray[1])>=224 || parseInt(ipArray[1])==127)
		{
			return "outOfRange";
		}
		if(parseInt(ipArray[1])==169 && parseInt(ipArray[2])==254)
		{			
			return "outOfRange";
		}

	}	
	return true;
}

//To check the pre-assign ip is repeated.
function isReserveIpRepeat(preNum, ipAddr, index)
{
	for(var i=1;i<=preNum;i++)
	{
		var newIp = document.getElementById("newip"+i).value;
		if(ipAddr==newIp && i!=index)
		{
			return true;
		}
	}
	return false;
}

//Return to the ip config pages.
function cancelConfirm()
{
	document.getElementById("lanConfig").style.display="block";
	document.getElementById("confirmConfig").style.display="none";
	document.getElementById("resultKO").style.display="none";
}

//Submit the ip config form.
function submitConfirm()
{	
	document.lanConfig.submit();
}

//Is valid Mac address.
function CheckMac(macStr)
{
	var reg_name=/[a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2}:[a-fA-F\d]{2}/;
	if(!reg_name.test(macStr)){		
		return false;
	}
	return true;
} 

//Add a new row for ip reservation
function addIpReservation()
{
	document.getElementById("reserveIpAdding").style.visibility="visible";
	document.getElementById("reserveIpAdding").style.position="static";
	document.getElementById("addIpReserveBtn").disabled="true";
	document.getElementById("addIpReserveBtn").style.color="#AEAEAE";
	document.getElementById("reserveIpAddingFlag").value="1";
}
