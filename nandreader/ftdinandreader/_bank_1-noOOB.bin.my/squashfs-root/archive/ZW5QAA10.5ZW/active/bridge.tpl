[ env.ini ]
set var=CONF_REGION value="tr(0,World)"
set var=CONF_PROVIDER value="tr(1,Basic)"
set var=CONF_DESCRIPTION value="tr(2,Bridged Connection.)"
set var=CONF_SERVICE value="tr(3,Bridge)"
set var=CONF_DATE value=""
set var=CONF_DATETIME value=0000-00-00T00:00:00
set var=CONF_TPVERSION value="2.0.0"
set var=HOST_SETUP value="auto"
set var=HOST_LANGUAGE value="en"
set var=ATM_addr value="8.35"
set var=ST_V4_DHCP_SRV value="enabled"
set var=ST_V6_DHCP_SRV value="enabled"
set var=ST_SYS_USERNAME value="Administrator"
set var=%ST_SYS_PASSWORD value=""
set var=CWMPUSER value=${_OUI}-${_PROD_SERIAL_NBR}
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
def var=ATM type=grp desc="tr(4,Specify the details of the Internet connection. All information should be provided by your ISP.)" alias="tr(5,Bridged Internet Connection)"
def var=ATM_addr type=combo grp=ATM alias="VPI/VCI" data="0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.100,1.32,1.33,1.100,8.32,8.35,8.36,8.37,8.48,8.81" desc="tr(6,Choose a VPI/VCI from the list)"
' LAN=Settings
'-------------
def var=LAN type=grp desc="tr(7,Specify the Local Area Network settings.)" alias="tr(8,LAN Settings)"
def var=ST_V4_DHCP_SRV type=bool grp=LAN alias="tr(9,DHCPv4 Server)" data="disabled,enabled" desc="tr(10,Start the DHCPv4 server on the Technicolor Gateway)" default=enabled
def var=ST_V6_DHCP_SRV type=bool grp=LAN alias="tr(19,Stateless DHCPv6 Server)" data="disabled,enabled" desc="tr(20,Start the stateless DHCPv6 server on the Technicolor Gateway)" default=enabled

'ST Security
'-----------
def var=ST type=grp desc="tr(11,Specify user name and password to prevent unwanted access to the Technicolor Gateway management interface.)" alias="tr(12,Access Control)"
def var=ST_SYS_USERNAME type=string grp=ST alias="tr(13,User Name)" req=yes desc="tr(14,Enter a user name.)"
def var=%ST_SYS_PASSWORD type=passw grp=ST alias="tr(15,Password)" desc="tr(16,Enter a password.)" max=32
def var=dummy2 type=passwcheck grp=ST alias="tr(17,Confirm Password)" desc="tr(18,Re-enter the password.)" linkvar=%ST_SYS_PASSWORD max=32

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
ifconfig intf=atm_Internet ulp=mac encaps=llc
ifattach intf=atm_Internet

[ bridge.ini ]
ifadd intf=ethport2 dest=ethif2 logging=disabled
ifadd intf=ethport3 dest=ethif3 logging=disabled
ifadd intf=ethport4 dest=ethif4 logging=disabled
ifadd intf=usbport dest=usbif1 logging=disabled
ifadd intf=virt dest ethif6 logging=disabled
ifadd intf=WLAN dest=wlif1 logging=disabled
ifconfig intf=ethport2 logging=disabled
ifconfig intf=ethport3 logging=disabled
ifconfig intf=ethport4 logging=disabled
ifconfig intf=usbport retry=0 logging=disabled
ifconfig intf=virt logging=disabled
ifconfig intf=WLAN logging=disabled
ifattach intf=ethport2 logging=disabled
ifattach intf=ethport3 logging=disabled
ifattach intf=ethport4 logging=disabled
ifattach intf=usbport logging=disabled
ifattach intf=virt logging=disabled
ifattach intf=WLAN logging=disabled
ifadd intf=Internet dest=atm_Internet
ifattach intf=Internet
config age=300 filter=none

[ eth.ini ]

[ ppprelay.ini ]

[ ppp.ini ]

[ dnss.ini ]
config domain=lan timeout=15 suppress=0 trace=disabled WANDownSpoofing=disabled WDSpoofedIP=198.18.1.1
host add name=speedtouch addr=0.0.0.0 ttl=1200
host add name=dsldevice addr=0.0.0.0 ttl=1200

[ dsd.ini ]
config state=disabled

[ servmgr.ini ]
mapadd name=HTTPI intf=LocalNetwork port=www-http
mapadd name=HTTPI intf=LocalNetwork port=1080
mapadd name=HTTPI intf=LocalNetwork port=httpproxy
ifadd name=AppWeb group=lan
ifadd name=AppWebS group=lan
ifadd name=HTTP group=lan
ifadd name=HTTPs group=lan
ifadd name=FTP group=lan
ifadd name=TELNET group=lan
ifadd name=DNS-S group=lan
ifadd name=DNS-S-TCP group=lan
ifadd name=SNMP_AGENT group=lan
ifadd name=PING_RESPONDER group=lan
ifadd name=PPTP group=lan
ifadd name=SSDP group=lan
ifadd name=MDAP group=lan
modify name=AppWeb state=enabled
modify name=AppWebS state=enabled
modify name=DNS-C state=enabled qoslabel=Management
modify name=DHCP-S state=$ST_V4_DHCP_SRV
modify name=DHCPv6-S state=$ST_V6_DHCP_SRV
modify name=SNTP state=disabled
modify name=HTTP state=enabled
modify name=HTTPs state=enabled
modify name=HTTPI state=enabled
modify name=FTP state=enabled
modify name=TELNET state=enabled
modify name=RIP state=disabled
modify name=IGMP-Proxy state=enabled qoslabel=Management
modify name=DNS-S state=enabled qoslabel=Management
modify name=DNS-S-TCP state=enabled qoslabel=Management
modify name=SNMP_AGENT state=disabled
modify name=IP_COMMANDS state=enabled
modify name=PING_RESPONDER state=enabled
modify name=MDAP state=enabled
modify name=CWMP-C state=disabled qoslabel=Management
modify name=SSDP state=enabled
modify name=PPTP state=enabled


[ mlpuser.ini ]
#if $%ST_SYS_PASSWORD=""
add name=$ST_SYS_USERNAME password="" role=Administrator defuser=enabled
#else
add name=$ST_SYS_USERNAME password=$%ST_SYS_PASSWORD role=Administrator defuser=enabled
#endif
add name=tech password=$_PROD_SERIAL_NBR role=TechnicalSupport defremadmin=enabled
config name=tech password=$__SEC_MODEM_ACCESS_CODE

[ language.ini ]
langdef lang=nl
t r="0, Wereld"
t r="1, Basis"
t r="2, Bridged-verbinding."
t r="3, Bridge"
t r="4, Geef de details van de Internetverbinding. Alle informatie wordt door uw Internet-provider verstrekt."
t r="5, Bridged-Internetverbinding"
t r="6, Kies een VPI/VCI uit de lijst"
t r="7, Geef de instellingen voor het lokale netwerk (LAN)."
t r="8, LAN-instellingen"
t r="9, DHCPv4-server"
t r="10, Start de DHCPv4-server op de Technicolor Gateway"
t r="11, Geef gebruikersnaam en wachtwoord om ongewenste toegang tot de beheersinterface van de Technicolor Gateway te voorkomen."
t r="12, Toegangscontrole"
t r="13, Gebruikersnaam"
t r="14, Voer een gebruikersnaam in."
t r="15, Wachtwoord"
t r="16, Voer een wachtwoord in."
t r="17, Bevestig wachtwoord"
t r="18, Voer het wachtwoord opnieuw in."
t r="19, Stateless DHCPv6-Server"
t r="20, Start de staatloze DHCPv6-server op de Technicolor Gateway"
langdef lang=de
t r="0, Welt"
t r="1, Standard"
t r="2, Bridge-Verbindung."
t r="3, Bridge"
t r="4, Geben Sie Informationen zu der Internetverbindung an. Sie erhalten alle nötigen Informationen bei Ihrem Internetdienstanbieter."
t r="5, Bridge-Internetverbindung"
t r="6, Wählen Sie einen VPI/VCI aus der Liste aus"
t r="7, Legen Sie die Einstellungen für das LAN (Local Area Network) fest."
t r="8, LAN-Einstellungen"
t r="9, DHCPv4-Server"
t r="10, Starten Sie den DHCPv4-Server des Technicolor Gateway"
t r="11, Geben Sie einen Benutzernamen und ein Kennwort ein, um unerwünschten Zugriff auf die Technicolor Gateway-Verwaltungsschnittstelle zu vermeiden."
t r="12, Zugangskontrolle"
t r="13, Benutzername"
t r="14, Geben Sie einen Benutzernamen ein."
t r="15, Kennwort"
t r="16, Geben Sie ein Kennwort ein."
t r="17, Kennwort bestätigen"
t r="18, Geben Sie das Kennwort erneut ein."
t r="19, Stateless DHCPv6 Server"
t r="20, Starten Sie den staatenlosen DHCPv6-Server des Technicolor Gateway"
langdef lang=pt
t r="0, Mundial"
t r="1, Básico"
t r="2, Conexão com ponte."
t r="3, Com ponte"
t r="4, Especifique os detalhes da conexão com a Internet. Todas as informações devem ser obtidas com o provedor."
t r="5, Conexão com a Internet com ponte"
t r="6, Escolha uma VPI/VCI na lista"
t r="7, Especifique as configurações da Rede local."
t r="8, Configurações da LAN"
t r="9, Servidor DHCPv4"
t r="10, Iniciar servidor DHCPv4 no Technicolor Gateway"
t r="11, Especifique o nome de usuário e a senha para impedir o acesso não desejado à interface de gerenciamento do Technicolor Gateway."
t r="12, Controle de acesso"
t r="13, Nome de usuário"
t r="14, Digite um nome de usuário."
t r="15, Senha"
t r="16, Digite uma senha."
t r="17, Confirmar senha"
t r="18, Digite novamente a senha."
t r="19, Servidor DHCPv6 apátridas"
t r="20, Iniciar servidor DHCPv6 apátridas no Technicolor Gateway"
langdef lang=es
t r="0, Mundo"
t r="1, Básico"
t r="2, Conexión con puente."
t r="3, Puente"
t r="4, Especifique los detalles de la conexión a Internet. Toda la información debe proporcionarla su proveedor de servicios de Internet."
t r="5, Conexión a Internet con puente"
t r="6, Elegir un VPI/VCI de la lista"
t r="7, Especifique la configuración de la red de área local."
t r="8, Configuración de la LAN"
t r="9, Servidor DHCPv4"
t r="10, Iniciar el servidor DHCPv4 en Technicolor Gateway"
t r="11, Especifique el nombre de usuario y la contraseña para impedir el acceso no autorizado a la interfaz de administración de Technicolor Gateway."
t r="12, Control de acceso"
t r="13, Nombre de usuario"
t r="14, Escriba un nombre de usuario."
t r="15, Contraseña"
t r="16, Escriba una contraseña."
t r="17, Confirmar contraseña"
t r="18, Vuelva a escribir la contraseña."
t r="19, Apátridas servidor DHCPv6"
t r="20, Iniciar el servidor sin estado DHCPv6 en Technicolor Gateway"
langdef lang=it
t r="0, Mondiale"
t r="1, Modello base"
t r="2, Connessione Bridged."
t r="3, Bridge"
t r="4, Specificare i dettagli della connessione Internet. Tutte le informazioni devono essere fornite dal proprio ISP."
t r="5, Connessione Internet Bridged"
t r="6, Scegliere un VPI/VCI dall'elenco"
t r="7, Specificare le impostazione per la LAN (Local Area Network)."
t r="8, Impostazioni LAN"
t r="9, Server DHCPv4"
t r="10, Avvia il server DHCPv4 sullo Technicolor Gateway"
t r="11, Specificare nome utente e password per impedire accessi non autorizzati all'interfaccia di gestione dello Technicolor Gateway."
t r="12, Controllo di accesso"
t r="13, Nome utente"
t r="14, Immettere un nome utente"
t r="15, Password"
t r="16, Immettere una password."
t r="17, Conferma password"
t r="18, Reimmettere la password."
t r="19, Apolide Server DHCPv6"
t r="20, Avvia il apolidi server DHCPv6 sullo Technicolor Gateway"
langdef lang=fr
t r="0, Monde"
t r="1, Basic"
t r="2, Connexion dérivée."
t r="3, Pont"
t r="4, Spécifiez les détails de la connexion Internet. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="5, Connexion Internet dérivée."
t r="6, Choisissez un VPI/VCI dans la liste"
t r="7, Spécifiez les paramètres LAN (réseau local)."
t r="8, Paramètres LAN"
t r="9, Serveur DHCPv4"
t r="10, Démarrez le serveur DHCPv4 sur le Technicolor Gateway"
t r="11, Spécifiez un nom d'utilisateur et un mot de passe pour empêcher les accès non voulus à l'interface de gestion du Technicolor Gateway."
t r="12, Contrôle d'accès"
t r="13, Nom d'utilisateur"
t r="14, Entrez un nom d'utilisateur."
t r="15, Mot de passe"
t r="16, Entrez un mot de passe."
t r="17, Confirmer le mot de passe"
t r="18, Entrez à nouveau le mot de passe."
t r="19, Apatrides serveur DHCPv6"
t r="20, Démarrez le serveur DHCPv6 apatrides sur le Technicolor Gateway"
langdef lang=sv
t r="0, Världen"
t r="1, Grunder"
t r="2, Bridged-anslutning."
t r="3, Bridge"
t r="4, Ange information om Internet-anslutningen. Du får all information som behövs av Internet-leverantören."
t r="5, Bridged Internet-anslutning"
t r="6, Välj en VPI/VCI i listan"
t r="7, Ange inställningar för LAN (Local Area Network)"
t r="8, LAN-inställningar"
t r="9, DHCPv4-server"
t r="10, Starta DHCPv4-servern på Technicolor Gateway"
t r="11, Ange användarnamn och lösenord för att förhindra oönskad åtkomst till hanteringsgränssnittet för Technicolor Gateway."
t r="12, Åtkomstkontroll"
t r="13, Användarnamn"
t r="14, Ange ett användarnamn."
t r="15, Lösenord"
t r="16, Ange ett lösenord."
t r="17, Bekräfta lösenordet"
t r="18, Ange lösenordet igen."
t r="19, Statslösa DHCPv6-server"
t r="20, Starta statslösa DHCPv6-server på Technicolor Gateway"

[ endofarch ]
