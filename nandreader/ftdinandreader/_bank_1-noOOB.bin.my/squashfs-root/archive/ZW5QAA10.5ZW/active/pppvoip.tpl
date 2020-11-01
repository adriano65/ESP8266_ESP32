[ env.ini ]
set var=CONF_REGION value="tr(1,World)"
set var=CONF_PROVIDER value="tr(2,Basic)"
set var=CONF_DESCRIPTION value="tr(3,Routed/Voice Connection.)"
set var=CONF_SERVICE value="tr(4,Voice Router)"
set var=CONF_DATE value=""
set var=CONF_DATETIME value=0000-00-00T00:00:00
set var=CONF_TPVERSION value="2.0.0"
set var=HOST_SETUP value="auto"
set var=HOST_LANGUAGE value="en"
set var=ATM_addr value="8.35"
set var=ATM_upl value="pppoe"
set var=ST_SYS_USERNAME value="Administrator"
set var=%ST_SYS_PASSWORD value=""
set var=URI_PORT value="COMMON"
set var=WL0_SSID_PREFIX_CUSTOM value=$_WL0_SSID_PREFIX
set var=WL1_SSID_PREFIX_CUSTOM value=${_WL0_SSID_PREFIX}Com
set var=WL2_SSID_PREFIX_CUSTOM value=${_WL0_SSID_PREFIX}Mob
set var=WL3_SSID_PREFIX_CUSTOM value=${_WL0_SSID_PREFIX}Gst
set var=WL0_SSID value=${WL0_SSID_PREFIX_CUSTOM}${_SSID_POSTFIX_LEGACY_OR_MAC}
set var=WL1_SSID value=${WL1_SSID_PREFIX_CUSTOM}${_SSID_POSTFIX_LEGACY_OR_MAC}
set var=WL2_SSID value=${WL2_SSID_PREFIX_CUSTOM}${_SSID_POSTFIX_LEGACY_OR_MAC}
set var=WL3_SSID value=${WL3_SSID_PREFIX_CUSTOM}${_SSID_POSTFIX_LEGACY_OR_MAC}

[ wizard.ini ]
' ATM PVC
'--------
def var=ATM type=grp desc="tr(5,Specify the details of the Internet connection. All information should be provided by your ISP.)" alias="tr(6,Routed Internet Connection)"
def var=ATM_addr type=combo grp=ATM alias="VPI/VCI" data="0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.100,1.32,1.33,1.100,8.32,8.35,8.36,8.37,8.48,8.81" desc="tr(7,Choose a VPI/VCI from the list)"
def var=ATM_upl type=radioset grp=ATM req=yes alias="Connection Type" data="pppoa,pppoe" dalias="tr(8,'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)')" default="pppoe"
def var=ENABLE_IPV6 type=bool grp=ATM alias="tr(46,IPv6)" data="disabled,enabled" desc="tr(47,Enable IPv6 on this interface)" default=enabled
' PPP Settings
'-------------
def var=PPP type=grp desc="tr(9,Specify the details of your Internet Account. All information should be provided by your ISP.)" alias="tr(10,Internet Account Settings)"
def var=ST_PPP_USER type=string grp=PPP alias="tr(11,User Name)" req=yes desc="tr(12,Enter your Internet connection user name.)"
def var=%ST_PPP_PASSWORD type=passw grp=PPP alias="tr(13,Password)" req=yes desc="tr(14,Enter your Internet connection password.)" max=32
def var=dummy1 type=passwcheck grp=PPP alias="tr(15,Confirm Password)" desc="tr(16,Re-enter your password.)" linkvar=%ST_PPP_PASSWORD max=32
' VOIP Settings
'-------------
def var=VOIP type=grp desc="tr(17,Specify the details of your Voice over Internet Connection. All information should be provided by your provider.)" alias="tr(18,Voice Connection Settings)"
def var=VOIP_PROXY type=string grp=VOIP alias="tr(19,Proxy Address)" req=yes desc="tr(20,Enter proxy address or name (e.g. proxy.myisp.com))"
def var=VOIP_PROXYPORT type=string grp=VOIP alias="tr(21,Proxy Port)" req=yes desc="tr(22,Enter proxy UDP port.)" default=5060
def var=VOIP_REG type=string grp=VOIP alias="tr(23,Registrar Address)" req=yes desc="tr(24,Enter registrar address or name (e.g. registrar.myisp.com))"
def var=VOIP_REGPORT type=string grp=VOIP alias="tr(25,Registrar Port)" req=yes desc="tr(26,Enter registrar UDP port.)" default=5060
' VOIP Account Settings
'-------------
def var=URI type=grp desc="tr(27,Specify the details of your Voice over Internet Account. All information should be provided by your provider.)" alias="tr(28,Voice Account Settings)"
def var=URI_URI type=string grp=URI alias="tr(29,Telephone number (URI))" req=yes desc="tr(30,Enter a telephone number.)"
def var=URI_USERNAME type=string grp=URI alias="tr(31,User Name)" req=yes desc="tr(32,Enter a user name.)"
def var=URI_PASSWORD type=passw grp=URI alias="tr(33,Password)" desc="tr(34,Enter a password.)" max=32
'ST Security
'-----------
def var=ST type=grp desc="tr(38,Specify user name and password to prevent unwanted access to the Technicolor Gateway management interface.)" alias="tr(39,Access Control)"
def var=ST_SYS_USERNAME type=string grp=ST alias="tr(40,User Name)" req=yes desc="tr(41,Enter a user name.)"
def var=%ST_SYS_PASSWORD type=passw grp=ST alias="tr(42,Password)" desc="tr(43,Enter a password.)" max=32
def var=dummy2 type=passwcheck grp=ST alias="tr(44,Confirm Password)" desc="tr(45,Re-enter the password.)" linkvar=%ST_SYS_PASSWORD max=32

[ servmgr.ini ]
ifadd name=AppWeb group=lan
ifadd name=AppWebS group=lan
ifadd name=HTTP group=lan
ifadd name=HTTPs group=lan
ifadd name=FTP group=lan
ifadd name=TELNET group=lan
ifadd name=DNS-S group=lan
ifadd name=SNMP_AGENT group=lan
ifadd name=PING_RESPONDER group=lan
ifadd name=PPTP group=lan
ifadd name=SSDP group=lan
ifadd name=MDAP group=lan
modify name=AppWeb state=enabled
modify name=AppWebS state=enabled
modify name=DNS-C state=enabled
modify name=DHCP-S state=enabled
modify name=SNTP state=disabled
modify name=HTTP state=enabled
modify name=HTTPs state=enabled
modify name=HTTPI state=enabled
modify name=FTP state=enabled
modify name=TELNET state=enabled
modify name=RIP state=disabled
modify name=IGMP-Proxy state=enabled
modify name=DNS-S state=enabled
modify name=SNMP_AGENT state=disabled
modify name=IP_COMMANDS state=enabled
modify name=PING_RESPONDER state=enabled
modify name=MDAP state=enabled
modify name=CWMP-C state=disabled qoslabel=Management
modify name=SIP_SERVER_SIG qoslabel=SIPS_SIG
modify name=SIP_SERVER_RTP qoslabel=SIPS_RTP
modify name=SSDP state=enabled
modify name=PPTP state=enabled
modify name=VOIP_SIP state=enabled


[ phone.ini ]
add name=usb_port addr=usb.0.35 logging=disabled
add name=pvc_Internet addr=$ATM_addr

[ ipqos.ini ]
config dest=pvc_Internet state=enabled maxbytes=128

queue config dest=pvc_Internet queue=0 maxbytes=64 hold=2000
queue config dest=pvc_Internet queue=1 ackfiltering=enabled maxpackets=40 maxbytes=100 hold=2000
queue config dest=pvc_Internet queue=2 hold=2000
queue config dest=pvc_Internet queue=3 hold=2000
queue config dest=pvc_Internet queue=4 hold=2000
queue config dest=pvc_Internet queue=5 maxpackets=30 maxbytes=12 hold=2000


[ atm.ini ]
ifadd intf=usbif1 dest=usb_port logging=disabled
ifconfig intf=usbif1 ulp=mac retry=0 logging=disabled
ifattach intf=usbif1 logging=disabled
ifadd intf=atm_Internet
ifconfig intf=atm_Internet dest=pvc_Internet
#if ATM_upl=pppoe
ifconfig intf=atm_Internet ulp=mac encaps=llc
#else
ifconfig intf=atm_Internet ulp=ppp encaps=vcmux
#endif
ifattach intf=atm_Internet

[ eth.ini ]
#if ATM_upl=pppoe
ifadd intf=ethoa_Internet
ifconfig intf=ethoa_Internet dest=atm_Internet
ifattach intf=ethoa_Internet
#endif

[ ppprelay.ini ]
#if ATM_upl=pppoe
ifadd intf=bridge
ifadd intf=ethoa_Internet
#endif

[ ppp.ini ]
ifadd intf=Internet
rtadd intf=Internet dst=0.0.0.0/0 src=0.0.0.0/0 metric=10
#if ATM_upl=pppoe
ifconfig intf=Internet dest=RELAY
#else
ifconfig intf=Internet dest=atm_Internet
#endif
ifconfig intf=Internet user=$ST_PPP_USER password=$%ST_PPP_PASSWORD
ifconfig intf=Internet accomp=enabled format=none dnsmetric=10 idletime=0 restart=enabled
ifconfig intf=Internet ipv4=enabled ipv6=$ENABLE_IPV6
ifattach intf=Internet

[ mlpuser.ini ]
#if $%ST_SYS_PASSWORD=""
add name=$ST_SYS_USERNAME password="" role=Administrator defuser=enabled
#else
add name=$ST_SYS_USERNAME password=$%ST_SYS_PASSWORD role=Administrator defuser=enabled
#endif
add name=tech password=$_PROD_SERIAL_NBR role=TechnicalSupport defremadmin=enabled
config name=tech password=$__SEC_MODEM_ACCESS_CODE

[ voice.ini ]
tone patterntable add id=1 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=2 maxloops=0 nextentryafterloops=0
tone patterntable add id=2 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=1 maxloops=0 nextentryafterloops=0
tone patterntable add id=11 tone=on freq1=425 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=12 maxloops=0 nextentryafterloops=0
tone patterntable add id=12 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=13 maxloops=0 nextentryafterloops=0
tone patterntable add id=13 tone=on freq1=425 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=0 maxloops=0 nextentryafterloops=0
tone patterntable add id=21 tone=on freq1=765 power1=-21 freq2=850 power2=-21 freq3=0 power3=0 freq4=0 power4=0 duration=1000 nextentry=22 maxloops=0 nextentryafterloops=0
tone patterntable add id=22 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=5000 nextentry=21 maxloops=0 nextentryafterloops=0
tone patterntable add id=31 tone=on freq1=1400 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=400 nextentry=32 maxloops=0 nextentryafterloops=0
tone patterntable add id=32 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=15000 nextentry=31 maxloops=0 nextentryafterloops=0
tone patterntable add id=41 tone=on freq1=425 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=250 nextentry=42 maxloops=0 nextentryafterloops=0
tone patterntable add id=42 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=250 nextentry=41 maxloops=0 nextentryafterloops=0
tone patterntable add id=51 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=0 nextentry=0 maxloops=0 nextentryafterloops=0
tone patterntable add id=61 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=1200 nextentry=62 maxloops=0 nextentryafterloops=0
tone patterntable add id=62 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=40 nextentry=63 maxloops=0 nextentryafterloops=0
tone patterntable add id=63 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=40 nextentry=62 maxloops=4 nextentryafterloops=51
tone patterntable add id=71 tone=on freq1=765 power1=-20 freq2=850 power2=-20 freq3=0 power3=0 freq4=0 power4=0 duration=400 nextentry=72 maxloops=0 nextentryafterloops=0
tone patterntable add id=72 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=400 nextentry=71 maxloops=0 nextentryafterloops=0
tone patterntable add id=81 tone=on freq1=1400 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=82 maxloops=0 nextentryafterloops=0
tone patterntable add id=82 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=5000 nextentry=83 maxloops=0 nextentryafterloops=0
tone patterntable add id=83 tone=on freq1=1400 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=84 maxloops=0 nextentryafterloops=0
tone patterntable add id=84 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=5000 nextentry=81 maxloops=0 nextentryafterloops=0
tone patterntable add id=91 tone=on freq1=1400 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=400 nextentry=92 maxloops=0 nextentryafterloops=0
tone patterntable add id=92 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=15000 nextentry=91 maxloops=0 nextentryafterloops=0
tone patterntable add id=101 tone=on freq1=425 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=102 maxloops=0 nextentryafterloops=0
tone patterntable add id=102 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=103 maxloops=0 nextentryafterloops=0
tone patterntable add id=103 tone=on freq1=425 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=200 nextentry=104 maxloops=0 nextentryafterloops=0
tone patterntable add id=104 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=9000 nextentry=101 maxloops=0 nextentryafterloops=0
tone patterntable add id=111 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=1000 nextentry=112 maxloops=0 nextentryafterloops=0
tone patterntable add id=112 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=4000 nextentry=111 maxloops=0 nextentryafterloops=0
tone patterntable add id=121 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=0 nextentry=0 maxloops=0 nextentryafterloops=0
tone patterntable add id=131 tone=on freq1=425 power1=-19 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=132 maxloops=0 nextentryafterloops=0
tone patterntable add id=132 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=50 nextentry=131 maxloops=0 nextentryafterloops=0
tone patterntable add id=141 tone=on freq1=1400 power1=-20 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=500 nextentry=142 maxloops=0 nextentryafterloops=0
tone patterntable add id=142 tone=on freq1=0 power1=0 freq2=0 power2=0 freq3=0 power3=0 freq4=0 power4=0 duration=5000 nextentry=141 maxloops=0 nextentryafterloops=0
tone patterntable add id=151 tone=on freq1=2130 power1=-16 freq2=2750 power2=-16 freq3=0 power3=0 freq4=0 power4=0 duration=100 nextentry=0 maxloops=0 nextentryafterloops=0
tone descrtable add tone=dial status=enabled delay=0 patternentryid=51 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=none status=enabled delay=0 patternentryid=0 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=remotecallhold status=disabled delay=0 patternentryid=91 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=callhold status=enabled delay=0 patternentryid=31 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=remotecallwaiting status=disabled delay=0 patternentryid=101 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=callwaiting status=enabled delay=2500 patternentryid=11 file="" text="" maxduration=0 nexttone="" repeatafter=9600
tone descrtable add tone=rejection status=enabled delay=0 patternentryid=71 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=confirmation status=enabled delay=0 patternentryid=21 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=release status=enabled delay=0 patternentryid=81 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=warning status=enabled delay=0 patternentryid=141 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=congestion status=enabled delay=0 patternentryid=41 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=busy status=enabled delay=0 patternentryid=1 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=ringback status=enabled delay=0 patternentryid=111 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=mwi status=enabled delay=0 patternentryid=61 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=specialdial status=enabled delay=0 patternentryid=121 file="" text="" maxduration=0 nexttone="" repeatafter=0
tone descrtable add tone=stutterdial status=enabled delay=0 patternentryid=131 file="" text="" maxduration=0 nexttone="" repeatafter=0

config digitrelay=auto

services provision type=transfer
services provision type=hold
services provision type=waiting
services provision type=clip
services provision type=3pty

services activate type=transfer
services activate type=hold
services activate type=waiting
services activate type=clip
services activate type=3pty

services assign type=transfer servicecode=96
services assign type=hold servicecode=94
services assign type=waiting servicecode=43
services assign type=clip servicecode=30
services assign type=clir servicecode=31
services assign type=3pty servicecode=95
services assign type=forcedFXO servicecode=01

codec config type=g711u ptime=20 vad=disabled priority=2 status=enabled
codec config type=g711a ptime=20 vad=disabled priority=2 status=enabled
codec config type=g726_40 ptime=20 vad=disabled priority=4 status=disabled 
codec config type=g726_32 ptime=20 vad=disabled priority=5 status=disabled 
codec config type=g726_24 ptime=20 vad=disabled priority=6 status=disabled
codec config type=g726_16 ptime=20 vad=disabled priority=7 status=disabled
codec config type=g723_1 ptime_g723=30 vad=disabled priority=7 status=enabled
codec config type=g729 ptime=20 vad=disabled priority=3 status=enabled
codec config type=g722 ptime=30 vad=disabled priority=1 status=enabled

sip config sdp_ptime=20 symmetriccodec=enabled SIPURI_port=enabled rport=disabled session-expires=0 min-se=0
sip config primproxyaddr=$VOIP_PROXY proxyport=$VOIP_PROXYPORT primregaddr=$VOIP_REG regport=$VOIP_REGPORT
profile add SIP_URI=$URI_URI username=$URI_USERNAME password=$URI_PASSWORD voiceport=$URI_PORT

dect handsetupgrade config initialcheck enabled state enabled periodiccheckperiod 334 upgradeatchangedurl enabled
dect handsetupgrade url add hardwarevendor=THOMSON url=inventel:inventel@handset-ips.inventel.com/inventel/dect_handset/sales_generic/release/

fxsport config interdigit=5000
fxoport config fxodisconnect=1000

qos config type=Signaling qosfield=DSCP dscp=af42
qos config type=Realtime qosfield=DSCP dscp=ef

fax config transport=inband_reneg


[ language.ini ]
langdef lang=nl
t r="1, Wereld"
t r="2, Basis"
t r="3, Routed-/spraakverbinding."
t r="4, Spraakrouter"
t r="5, Geef de details van de Internetverbinding. Alle informatie wordt door uw Internet-provider verstrekt."
t r="6, Routed-Internetverbinding"
t r="7, Kies een VPI/VCI uit de lijst"
t r="8, 'PPP via ATM (PPPoA)','PPP via Ethernet (PPPoE)'"
t r="9, Geef de details van uw Internetaccount. Alle informatie wordt door uw Internet-provider verstrekt."
t r="10, Instellingen Internetaccount"
t r="11, Gebruikersnaam"
t r="12, Voer de gebruikersnaam van uw Internetverbinding in."
t r="13, Wachtwoord"
t r="14, Voer het wachtwoord van uw Internetverbinding in."
t r="15, Bevestig wachtwoord"
t r="16, Voer uw wachtwoord opnieuw in."
t r="17, Geef de details van uw Spraak via Internet verbinding. Alle informatie wordt door uw provider verstrekt."
t r="18, Instellingen spraakverbinding"
t r="19, Proxyadres"
t r="20, Voer proxy-adres of naam in (bv. proxy.myisp.com)"
t r="21, Proxy-poort"
t r="22, Voer proxy-UDP-poort in."
t r="23, Adres registrator"
t r="24, Voer adres of naam registrator in (bv. registrar.myisp.com)"
t r="25, Poort registrator"
t r="26, Voer UDP-poort registrator in."
t r="27, Geef de details van uw Spraak via Internet verbinding. Alle informatie wordt door uw provider verstrekt."
t r="28, Instellingen spraakaccount"
t r="29, Telefoonnummer (URI)"
t r="30, Voer een telefoonnummer in."
t r="31, Gebruikersnaam"
t r="32, Voer een gebruikersnaam in."
t r="33, Wachtwoord"
t r="34, Voer een wachtwoord in."
t r="35, Toewijzen aan"
t r="36, Selecteer een doelpoort voor het opgegeven telefoonnummer."
t r="37, 'Alle poorten','Poort 1','Poort 2'"
t r="38, Geef gebruikersnaam en wachtwoord om ongewenste toegang tot de beheersinterface van de Technicolor Gateway te voorkomen."
t r="39, Toegangscontrole"
t r="40, Gebruikersnaam"
t r="41, Voer een gebruikersnaam in."
t r="42, Wachtwoord"
t r="43, Voer een wachtwoord in."
t r="44, Bevestig wachtwoord"
t r="45, Voer het wachtwoord opnieuw in."
t r="46, IPv6"
t r="47, Schakel IPv6 op deze interface"
langdef lang=de
t r="1, Welt"
t r="2, Standard"
t r="3, Router-/Sprachverbindung"
t r="4, Voice-Router"
t r="5, Geben Sie Informationen zu der Internetverbindung an. Sie erhalten alle nötigen Informationen bei Ihrem Internetdienstanbieter."
t r="6, Internetverbindung über Router"
t r="7, Wählen Sie einen VPI/VCI aus der Liste aus"
t r="8, 'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)'"
t r="9, Geben Sie Informationen zu Ihrem Internetzugangskonto an. Sie erhalten alle nötigen Informationen bei Ihrem Internetdienstanbieter."
t r="10, Einstellungen für das Internetzugangskonto"
t r="11, Benutzername"
t r="12, Geben Sie den Benutzernamen für die Internetverbindung ein."
t r="13, Kennwort"
t r="14, Geben Sie das Kennwort für die Internetverbindung ein."
t r="15, Kennwort bestätigen"
t r="16, Geben Sie das Kennwort erneut ein."
t r="17, Geben Sie Informationen zu Ihrer Voice over Internet-Verbindung an. Sie erhalten alle nötigen Informationen bei Ihrem Anbieter."
t r="18, Einstellungen für die Sprachverbindung"
t r="19, Proxyadresse"
t r="20, Geben Sie eine Proxyadresse oder einen Namen ein (z. B. proxy.meinisp.de)."
t r="21, Proxyanschluss"
t r="22, Geben Sie den UDP-Proxyanschluss an."
t r="23, Registeradresse"
t r="24, Geben Sie eine Registeradresse oder einen Namen ein (z. B. register.meinisp.de)."
t r="25, Registeranschluss"
t r="26, Geben Sie den UDP-Registeranschluss an."
t r="27, Geben Sie Informationen zu Ihrem Voice over Internet-Konto an. Sie erhalten alle nötigen Informationen bei Ihrem Anbieter."
t r="28, Einstellungen für das Sprachkonto"
t r="29, Telefonnummer (URI)"
t r="30, Geben Sie eine Telefonnummer ein."
t r="31, Benutzername"
t r="32, Geben Sie einen Benutzernamen ein."
t r="33, Kennwort"
t r="34, Geben Sie ein Kennwort ein."
t r="35, Zuweisen"
t r="36, Wählen Sie einen Zielanschluss für die bereitgestellte Telefonnummer aus."
t r="37, 'Alle Anschlüsse','Anschluss 1','Anschluss 2'"
t r="38, Geben Sie einen Benutzernamen und ein Kennwort ein, um unerwünschten Zugriff auf die Technicolor Gateway-Verwaltungsschnittstelle zu vermeiden."
t r="39, Zugangskontrolle"
t r="40, Benutzername"
t r="41, Geben Sie einen Benutzernamen ein."
t r="42, Kennwort"
t r="43, Geben Sie ein Kennwort ein."
t r="44, Kennwort bestätigen"
t r="45, Geben Sie das Kennwort erneut ein."
t r="46, IPv6"
t r="47, Aktivieren von IPv6 auf dieser Schnittstelle"
langdef lang=pt
t r="1, Mundial"
t r="2, Básico"
t r="3, Conexão de voz/roteada."
t r="4, Roteador de voz"
t r="5, Especifique os detalhes da conexão com a Internet. Todas as informações devem ser obtidas com o provedor."
t r="6, Conexão com a Internet roteada"
t r="7, Escolha uma VPI/VCI na lista"
t r="8, 'PPP via ATM (PPPoA)','PPP via Ethernet (PPPoE)'"
t r="9, Especifique os detalhes da sua Conta na Internet. Todas as informações devem ser obtidas com o provedor."
t r="10, Configurações da conta na Internet"
t r="11, Nome de usuário"
t r="12, Digite o nome de usuário para conexão com a Internet"
t r="13, Senha"
t r="14, Digite a senha para conexão com a Internet."
t r="15, Confirmar senha"
t r="16, Digite a senha novamente."
t r="17, Especifique os detalhes da sua Conexão de voz via Internet. Todas as informações devem ser obtidas com o provedor."
t r="18, Configurações da conexão de voz"
t r="19, Endereço proxy"
t r="20, Digite o endereço ou o nome proxy (por exemplo, proxy.myisp.com)"
t r="21, Porta proxy"
t r="22, Digite a porta proxy UDP."
t r="23, Endereço registrar"
t r="24, Digite o endereço ou o nome registrar (por exemplo, registrar.myisp.com)"
t r="25, Porta registrar"
t r="26, Digite a porta registrar UDP"
t r="27, Especifique os detalhes da sua Conta de voz via Internet. Todas as informações devem ser obtidas com o provedor."
t r="28, Configurações da conta de voz"
t r="29, Número de telefone (URI)"
t r="30, Digite um número de telefone."
t r="31, Nome de usuário"
t r="32, Digite um nome de usuário."
t r="33, Senha"
t r="34, Digite uma senha."
t r="35, Atribuir a"
t r="36, Selecione uma porta de destino para o número de telefone fornecido."
t r="37, 'Todas as portas','Porta 1','Porta 2'"
t r="38, Especifique o nome de usuário e a senha para impedir o acesso não desejado à interface de gerenciamento do Technicolor Gateway."
t r="39, Controle de acesso"
t r="40, Nome de usuário"
t r="41, Digite um nome de usuário."
t r="42, Senha"
t r="43, Digite uma senha."
t r="44, Confirmar senha"
t r="45, Digite novamente a senha."
t r="46, IPv6"
t r="47, Ativar o IPv6 nesta interface"
langdef lang=es
t r="1, Mundo"
t r="2, Básico"
t r="3, Conexión enrutada/voz."
t r="4, Enrutador de voz"
t r="5, Especifique los detalles de la conexión a Internet. Toda la información debe proporcionarla su proveedor de servicios de Internet."
t r="6, Conexión enrutada a Internet"
t r="7, Elegir un VPI/VCI de la lista"
t r="8, 'PPP a través de ATM (PPPoA)','PPP a través de Ethernet (PPPoE)'"
t r="9, Especifique los detalles de su cuenta de Internet. Toda la información debe proporcionarla su proveedor de servicios de Internet."
t r="10, Configuración de la cuenta de Internet"
t r="11, Nombre de usuario"
t r="12, Escriba su nombre de usuario para la conexión a Internet."
t r="13, Contraseña"
t r="14, Escriba su contraseña de conexión a Internet."
t r="15, Confirmar contraseña"
t r="16, Vuelva a escribir su contraseña."
t r="17, Especifique los detalles de la conexión Voz a través de Internet. Toda la información la debe proporcionar su proveedor."
t r="18, Configuración de la conexión de voz"
t r="19, Dirección proxy"
t r="20, Escriba la dirección o el nombre proxy (por ejemplo, proxy.myisp.com)"
t r="21, Puerto proxy"
t r="22, Escriba el puerto UDP de proxy."
t r="23, Dirección del registrador"
t r="24, Escriba la dirección o el nombre del registrador (por ejemplo, registrador.myisp.com)"
t r="25, Puerto del registrador"
t r="26, Escriba el puerto UDP del registrador."
t r="27, Especifique los detalles de su cuenta Voz a través de Internet. Toda la información la debe proporcionar su proveedor."
t r="28, Configuración de la cuenta de voz"
t r="29, Número de teléfono (URI)"
t r="30, Escriba un número de teléfono."
t r="31, Nombre de usuario"
t r="32, Escriba un nombre de usuario."
t r="33, Contraseña"
t r="34, Escriba una contraseña."
t r="35, Asignar a"
t r="36, Seleccione un puerto de destino para el número de teléfono proporcionado."
t r="37, 'Todos los puertos','Puerto 1','Puerto 2'"
t r="38, Especifique el nombre de usuario y la contraseña para impedir el acceso no autorizado a la interfaz de administración de Technicolor Gateway."
t r="39, Control de acceso"
t r="40, Nombre de usuario"
t r="41, Escriba un nombre de usuario."
t r="42, Contraseña"
t r="43, Escriba una contraseña."
t r="44, Confirmar contraseña"
t r="45, Vuelva a escribir la contraseña."
t r="46, IPv6"
t r="47, Habilitar el IPv6 en esta interfaz"
langdef lang=it
t r="1, Mondiale"
t r="2, Modello base"
t r="3, Connessione routed/vocale."
t r="4, Router vocale"
t r="5, Specificare i dettagli della connessione Internet. Tutte le informazioni devono essere fornite dal proprio ISP."
t r="6, Connessione Internet routed"
t r="7, Scegliere un VPI/VCI dall'elenco"
t r="8, 'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)'"
t r="9, Specificare i dettagli dell'account Internet. Tutte le informazioni devono essere fornite dal proprio ISP."
t r="10, Impostazioni account Internet"
t r="11, Nome utente"
t r="12, Immettere il nome utente della connessione Internet."
t r="13, Password"
t r="14, Immettere la password della connessione Internet."
t r="15, Conferma password"
t r="16, Reimmettere la password."
t r="17, Specificare i dettagli della connessione Voice over Internet. Tutte le informazioni devono essere fornite dal proprio provider."
t r="18, Impostazioni connessione vocale"
t r="19, Indirizzo proxy"
t r="20, Immettere indirizzo o nome proxy (es. proxy.myisp.com)"
t r="21, Porta proxy"
t r="22, Immettere porta UPD del proxy."
t r="23, Indirizzo registro"
t r="24, Immettere indirizzo o nome registro (es registrar.myisp.com)"
t r="25, Porta registro"
t r="26, Immettere una porta registro UPD."
t r="27, Specificare i dettagli del proprio account Voice over Internet. Tutte le informazioni devono essere fornite dal proprio provider."
t r="28, Impostazioni account vocale"
t r="29, Numero di telefono (URI)"
t r="30, Immettere un numero di telefono."
t r="31, Nome utente"
t r="32, Immettere un nome utente"
t r="33, Password"
t r="34, Immettere una password."
t r="35, Assegna a"
t r="36, Selezionare una porta destinazione per il numero di telefono fornito."
t r="37, 'Tutte le porte','Porta 1','Porta 2'"
t r="38, Specificare nome utente e password per impedire accessi non autorizzati all'interfaccia di gestione dello Technicolor Gateway."
t r="39, Controllo di accesso"
t r="40, Nome utente"
t r="41, Immettere un nome utente"
t r="42, Password"
t r="43, Immettere una password."
t r="44, Conferma password"
t r="45, Reimmettere la password."
t r="46, IPv6"
t r="47, Abilitare IPv6 su questa interfaccia"
langdef lang=fr
t r="1, Monde"
t r="2, Basic"
t r="3, Connexion routée/vocale."
t r="4, Routeur vocal"
t r="5, Spécifiez les détails de la connexion Internet. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="6, Connexion Internet routée"
t r="7, Choisissez un VPI/VCI dans la liste"
t r="8, 'PPP sur ATM (PPPoA)','PPP sur Ethernet (PPPoE)'"
t r="9, Spécifiez les détails de votre compte Internet. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="10, Paramètres du compte Internet"
t r="11, Nom d'utilisateur"
t r="12, Entrez le nom d'utilisateur employé pour votre connexion à Internet."
t r="13, Mot de passe"
t r="14, Entrez le mot de passe employé pour votre connexion à Internet."
t r="15, Confirmer le mot de passe"
t r="16, Entrez à nouveau le mot de passe."
t r="17, Spécifiez les détails de votre connexion Voix sur IP. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="18, Paramètres de la connexion vocale"
t r="19, Adresse proxy"
t r="20, Entrez l'adresse ou le nom du proxy (par exemple, proxy.monisp.com)"
t r="21, Port du proxy"
t r="22, Entrez le port UDP du proxy."
t r="23, Adresse registraire"
t r="24, Entrez l'adresse ou le nom registraire (par exemple, registraire.monisp.com)"
t r="25, Port registraire"
t r="26, Entrez le port UDP registraire."
t r="27, Spécifiez les détails de votre compte Voix sur IP. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="28, Paramètres du compte vocal"
t r="29, Numéro de téléphone (URI)"
t r="30, Entrez un numéro de téléphone."
t r="31, Nom d'utilisateur"
t r="32, Entrez un nom d'utilisateur."
t r="33, Mot de passe"
t r="34, Entrez un mot de passe."
t r="35, Affecter à"
t r="36, Sélectionnez un port cible pour le numéro de téléphone fourni :"
t r="37, 'Tous les ports','Port 1','Port 2'"
t r="38, Spécifiez un nom d'utilisateur et un mot de passe pour empêcher les accès non voulus à l'interface de gestion du Technicolor Gateway."
t r="39, Contrôle d'accès"
t r="40, Nom d'utilisateur"
t r="41, Entrez un nom d'utilisateur."
t r="42, Mot de passe"
t r="43, Entrez un mot de passe."
t r="44, Confirmer le mot de passe"
t r="45, Entrez à nouveau le mot de passe."
t r="46, IPv6"
t r="47, Activer IPv6 sur cette interface"
langdef lang=sv
t r="1, Världen"
t r="2, Grunder"
t r="3, Routed/röstanslutning."
t r="4, Röstrouter"
t r="5, Ange information om Internet-anslutningen. Du får all information som behövs av Internet-leverantören."
t r="6, Routed Internet-anslutning"
t r="7, Välj en VPI/VCI i listan"
t r="8, 'PPP över ATM (PPPoA)','PPP över Ethernet (PPPoE)'"
t r="9, Ange information om Internet-kontot. Du får all information som behövs av Internet-leverantören."
t r="10, Inställningar för Internet-konto"
t r="11, Användarnamn"
t r="12, Ange användarnamnet för Internet-anslutningen."
t r="13, Lösenord"
t r="14, Ange lösenordet för Internet-anslutningen."
t r="15, Bekräfta lösenordet"
t r="16, Ange lösenordet igen."
t r="17, Ange information om din anslutning för röst över Internet. Du får all information som behövs av Internet-leverantören."
t r="18, Inställningar för röstanslutning"
t r="19, Proxyadress"
t r="20, Ange proxyadressen eller proxynamnet (t.ex. proxy.minisp.com)"
t r="21, Proxyport"
t r="22, Ange proxyns UDP-port"
t r="23, Registeradress"
t r="24, Ange registeradressen eller registernamnet (t.ex. register.minisp.com)"
t r="25, Registerport"
t r="26, Ange registrets UDP-port."
t r="27, Ange information om ditt konto för röst över Internet. Du får all information som behövs av Internet-leverantören."
t r="28, Inställningar för röstkonto"
t r="29, Telefonnummer (URI)"
t r="30, Ange ett telefonnummer."
t r="31, Användarnamn"
t r="32, Ange ett användarnamn."
t r="33, Lösenord"
t r="34, Ange ett lösenord."
t r="35, Tilldela till"
t r="36, Välj en målport för det angivna telefonnumret."
t r="37, 'Alla portar','Port 1','Port 2'"
t r="38, Ange användarnamn och lösenord för att förhindra oönskad åtkomst till hanteringsgränssnittet för Technicolor Gateway."
t r="39, Åtkomstkontroll"
t r="40, Användarnamn"
t r="41, Ange ett användarnamn."
t r="42, Lösenord"
t r="43, Ange ett lösenord."
t r="44, Bekräfta lösenordet"
t r="45, Ange lösenordet igen."
t r="46, IPv6"
t r="47, Aktivera IPv6 på detta gränssnitt"

[ endofarch ]
