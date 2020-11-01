<%
cgilua.lp.include("lp/device.lp")
cgilua.lp.include("lp/common.lp")
local print = cgilua.print

local pppLed = "ledoff.gif"
local dslLed = "ledoff.gif"
local wifiLed = "ledoff.gif"	
local dectLed = "ledoff.gif"
local lineOneLed = "ledoff.gif"
local lineTwoLed = "ledoff.gif"

local led, err = mbus.getParameters{ path = "LEDS.LED", param = {"Name", "State", "Color"}, filter = "(!= Color None)" }
for i, v in pairs(led["LEDS.LED"]) do
	if v.param["Name"] == "Internet" then
		pppLed = getLedLightPic(v.param["State"], v.param["Color"])
  	elseif v.param["Name"] == "Wifi" then
		wifiLed = getLedLightPic(v.param["State"], v.param["Color"])
  	elseif v.param["Name"] == "ADSL" then
		dslLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "DECT" then
        dectLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "Line1" then
        lineOneLed = getLedLightPic(v.param["State"], v.param["Color"])
    elseif v.param["Name"] == "Line2" then
        lineTwoLed = getLedLightPic(v.param["State"], v.param["Color"])
	end
end

local TI_info = getTIInfo()
local serviceLed="ledlight.gif"
if TI_info.static == "off" then
	serviceLed="ledoff.gif"
elseif TI_info.static == "green_blink" then
	serviceLed="ledblinking.gif"
elseif TI_info.static == "red_fixed" then
	serviceLed="ledlightred.gif"
elseif TI_info.static == "red_blink" then
	serviceLed="ledblinkingred.gif"
end

local result = dslLed .. "##" .. pppLed .. "##" .. wifiLed .. "##" .. serviceLed .. "##" .. dectLed .. "##" .. lineOneLed .. "##" .. lineTwoLed
print(result)
%>
