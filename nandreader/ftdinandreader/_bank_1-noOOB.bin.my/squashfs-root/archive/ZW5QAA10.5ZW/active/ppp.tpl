[ env.ini ]
set var=CONF_REGION value="tr(0,World)"
set var=CONF_PROVIDER value="tr(1,Basic)"
set var=CONF_DESCRIPTION value="tr(2,Routed Connection.)"
set var=CONF_SERVICE value="tr(3,Routed PPP)"
set var=CONF_DATE value=""
set var=CONF_DATETIME value=0000-00-00T00:00:00
set var=CONF_TPVERSION value="2.0.0"
set var=HOST_SETUP value="auto"
set var=HOST_LANGUAGE value="en"
set var=ATM_addr value="8.35"
set var=ATM_upl value="pppoe"
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
def var=ATM type=grp desc="tr(4,Specify the details of the Internet connection. All information should be provided by your ISP.)" alias="tr(5,Routed Internet Connection)"
def var=ATM_addr type=combo grp=ATM alias="VPI/VCI" data="0.32,0.33,0.34,0.35,0.36,0.37,0.38,0.100,1.32,1.33,1.100,8.32,8.35,8.36,8.37,8.48,8.81" desc="tr(6,Choose a VPI/VCI from the list)"
def var=ATM_upl type=radioset grp=ATM req=yes alias="tr(7,Connection Type)" data="pppoa,pppoe" dalias="tr(8,'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)')" default="pppoe"
def var=ENABLE_IPV6 type=bool grp=ATM alias="tr(25,IPv6)" data="disabled,enabled" desc="tr(26,Enable IPv6 on this interface)" default=enabled

' PPP Settings
'-------------
def var=PPP type=grp desc="tr(9,Specify the details of your Internet Account. All information should be provided by your ISP.)" alias="tr(10,Internet Account Settings)"
def var=ST_PPP_USER type=string grp=PPP alias="tr(11,User Name)" req=yes desc="tr(12,Enter your Internet connection user name.)"
def var=%ST_PPP_PASSWORD type=passw grp=PPP alias="tr(13,Password)" req=yes desc="tr(14,Enter your Internet connection password.)" max=32
def var=dummy1 type=passwcheck grp=PPP alias="tr(15,Confirm Password)" desc="tr(16,Re-enter your password.)" linkvar=%ST_PPP_PASSWORD max=32
'ST Security
'-----------
def var=ST type=grp desc="tr(17,Specify user name and password to prevent unwanted access to the Technicolor Gateway management interface.)" alias="tr(18,Access Control)"
def var=ST_SYS_USERNAME type=string grp=ST alias="tr(19,User Name)" req=yes desc="tr(20,Enter a user name.)"
def var=%ST_SYS_PASSWORD type=passw grp=ST alias="tr(21,Password)" desc="tr(22,Enter a password.)" max=32
def var=dummy2 type=passwcheck grp=ST alias="tr(23,Confirm Password)" desc="tr(24,Re-enter the password.)" linkvar=%ST_SYS_PASSWORD max=32

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

[ ip.ini ]
config forwarding=enabled redirects=enabled netbroadcasts=disabled ttl=64 fraglimit=64 defragmode=enabled addrcheck=dynamic mssclamping=enabled acceleration=enabled
config checkoptions=enabled natloopback=enabled
ifadd intf=LocalNetwork dest=bridge
ifconfig intf=loop symmetric=enabled
ifconfig intf=LocalNetwork mtu=1500 group=lan linksensing=disabled primary=enabled
ifattach intf=LocalNetwork
ipadd intf=LocalNetwork addr=10.0.0.138/24
ipadd intf=LocalNetwork addr=192.168.1.254/24
ipconfig addr=192.168.1.254 preferred=enabled primary=enabled
rtadd dst=255.255.255.255/32 gateway=127.0.0.1
ifconfig intf=Internet mtu=1500 linksensing=enabled group=wan acceptredir=disabled rpfilter=disabled curhoplimit=64 dadtransmits=1 retranstimer=1000 acceptra=enabled autoconf=enabled

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
t r="2, Routed-verbinding."
t r="3, Router"
t r="4, Geef de details van de Internetverbinding. Alle informatie wordt door uw Internet-provider verstrekt."
t r="5, Routed-Internetverbinding"
t r="6, Kies een VPI/VCI uit de lijst"
t r="7, Routed-Internetverbinding"
t r="8, 'PPP via ATM (PPPoA)','PPP via Ethernet (PPPoE)'"
t r="9, Geef de details van uw Internetaccount. Alle informatie wordt door uw Internet-provider verstrekt."
t r="10, Instellingen Internetaccount"
t r="11, Gebruikersnaam"
t r="12, Voer de gebruikersnaam van uw Internetverbinding in."
t r="13, Wachtwoord"
t r="14, Voer het wachtwoord van uw Internetverbinding in."
t r="15, Bevestig wachtwoord"
t r="16, Voer uw wachtwoord opnieuw in."
t r="17, Geef gebruikersnaam en wachtwoord om ongewenste toegang tot de beheersinterface van de Technicolor Gateway te voorkomen."
t r="18, Toegangscontrole"
t r="19, Gebruikersnaam"
t r="20, Voer een gebruikersnaam in."
t r="21, Wachtwoord"
t r="22, Voer een wachtwoord in."
t r="23, Bevestig wachtwoord"
t r="24, Voer het wachtwoord opnieuw in."
t r="25, IPv6"
t r="26, Schakel IPv6 op deze interface"
langdef lang=de
t r="0, Welt"
t r="1, Standard"
t r="2, Verbindung über Router"
t r="3, Router"
t r="4, Geben Sie Informationen zu der Internetverbindung an. Sie erhalten alle nötigen Informationen bei Ihrem Internetdienstanbieter."
t r="5, Internetverbindung über Router"
t r="6, Wählen Sie einen VPI/VCI aus der Liste aus"
t r="7, Internetverbindung über Router"
t r="8, 'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)'"
t r="9, Geben Sie Informationen zu Ihrem Internetzugangskonto an. Sie erhalten alle nötigen Informationen bei Ihrem Internetdienstanbieter."
t r="10, Einstellungen für das Internetzugangskonto"
t r="11, Benutzername"
t r="12, Geben Sie den Benutzernamen für die Internetverbindung ein."
t r="13, Kennwort"
t r="14, Geben Sie das Kennwort für die Internetverbindung ein."
t r="15, Kennwort bestätigen"
t r="16, Geben Sie das Kennwort erneut ein."
t r="17, Geben Sie einen Benutzernamen und ein Kennwort ein, um unerwünschten Zugriff auf die Technicolor Gateway-Verwaltungsschnittstelle zu vermeiden."
t r="18, Zugangskontrolle"
t r="19, Benutzername"
t r="20, Geben Sie einen Benutzernamen ein."
t r="21, Kennwort"
t r="22, Geben Sie ein Kennwort ein."
t r="23, Kennwort bestätigen"
t r="24, Geben Sie das Kennwort erneut ein."
t r="25, IPv6"
t r="26, Aktivieren von IPv6 auf dieser Schnittstelle"
langdef lang=pt
t r="0, Mundial"
t r="1, Básico"
t r="2, Conexão roteada."
t r="3, Roteador"
t r="4, Especifique os detalhes da conexão com a Internet. Todas as informações devem ser obtidas com o provedor."
t r="5, Conexão com a Internet roteada"
t r="6, Escolha uma VPI/VCI na lista"
t r="7, Conexão com a Internet roteada"
t r="8, 'PPP via ATM (PPPoA)','PPP via Ethernet (PPPoE)'"
t r="9, Especifique os detalhes da sua Conta na Internet. Todas as informações devem ser obtidas com o provedor."
t r="10, Configurações da conta na Internet"
t r="11, Nome de usuário"
t r="12, Digite o nome de usuário para conexão com a Internet"
t r="13, Senha"
t r="14, Digite a senha para conexão com a Internet."
t r="15, Confirmar senha"
t r="16, Digite a senha novamente."
t r="17, Especifique o nome de usuário e a senha para impedir o acesso não desejado à interface de gerenciamento do Technicolor Gateway."
t r="18, Controle de acesso"
t r="19, Nome de usuário"
t r="20, Digite um nome de usuário."
t r="21, Senha"
t r="22, Digite uma senha."
t r="23, Confirmar senha"
t r="24, Digite novamente a senha."
t r="25, IPv6"
t r="26, Ativar o IPv6 nesta interface"
langdef lang=es
t r="0, Mundo"
t r="1, Básico"
t r="2, Conexión enrutada."
t r="3, Enrutador"
t r="4, Especifique los detalles de la conexión a Internet. Toda la información debe proporcionarla su proveedor de servicios de Internet."
t r="5, Conexión enrutada a Internet"
t r="6, Elegir un VPI/VCI de la lista"
t r="7, Conexión enrutada a Internet"
t r="8, 'PPP a través de ATM (PPPoA)','PPP a través de Ethernet (PPPoE)'"
t r="9, Especifique los detalles de su cuenta de Internet. Toda la información debe proporcionarla su proveedor de servicios de Internet."
t r="10, Configuración de la cuenta de Internet"
t r="11, Nombre de usuario"
t r="12, Escriba su nombre de usuario para la conexión a Internet."
t r="13, Contraseña"
t r="14, Escriba su contraseña de conexión a Internet."
t r="15, Confirmar contraseña"
t r="16, Vuelva a escribir su contraseña."
t r="17, Especifique el nombre de usuario y la contraseña para impedir el acceso no autorizado a la interfaz de administración de Technicolor Gateway."
t r="18, Control de acceso"
t r="19, Nombre de usuario"
t r="20, Escriba un nombre de usuario."
t r="21, Contraseña"
t r="22, Escriba una contraseña."
t r="23, Confirmar contraseña"
t r="24, Vuelva a escribir la contraseña."
t r="25, IPv6"
t r="26, Habilitar el IPv6 en esta interfaz"
langdef lang=it
t r="0, Mondiale"
t r="1, Modello base"
t r="2, Connessione Routed."
t r="3, Router"
t r="4, Specificare i dettagli della connessione Internet. Tutte le informazioni devono essere fornite dal proprio ISP."
t r="5, Connessione Internet routed"
t r="6, Scegliere un VPI/VCI dall'elenco"
t r="7, Connessione Internet routed"
t r="8, 'PPP over ATM (PPPoA)','PPP over Ethernet (PPPoE)'"
t r="9, Specificare i dettagli dell'account Internet. Tutte le informazioni devono essere fornite dal proprio ISP."
t r="10, Impostazioni account Internet"
t r="11, Nome utente"
t r="12, Immettere il nome utente della connessione Internet."
t r="13, Password"
t r="14, Immettere la password della connessione Internet."
t r="15, Conferma password"
t r="16, Reimmettere la password."
t r="17, Specificare nome utente e password per impedire accessi non autorizzati all'interfaccia di gestione dello Technicolor Gateway."
t r="18, Controllo di accesso"
t r="19, Nome utente"
t r="20, Immettere un nome utente"
t r="21, Password"
t r="22, Immettere una password."
t r="23, Conferma password"
t r="24, Reimmettere la password."
t r="25, IPv6"
t r="26, Abilitare IPv6 su questa interfaccia"
langdef lang=fr
t r="0, Monde"
t r="1, Basic"
t r="2, Connexion routée."
t r="3, Routeur"
t r="4, Spécifiez les détails de la connexion Internet. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="5, Connexion Internet routée"
t r="6, Choisissez un VPI/VCI dans la liste"
t r="7, Connexion Internet routée"
t r="8, 'PPP sur ATM (PPPoA)','PPP sur Ethernet (PPPoE)'"
t r="9, Spécifiez les détails de votre compte Internet. Toutes les informations doivent être fournies par votre fournisseur de services Internet."
t r="10, Paramètres du compte Internet"
t r="11, Nom d'utilisateur"
t r="12, Entrez le nom d'utilisateur employé pour votre connexion à Internet."
t r="13, Mot de passe"
t r="14, Entrez le mot de passe employé pour votre connexion à Internet."
t r="15, Confirmer le mot de passe"
t r="16, Entrez à nouveau le mot de passe."
t r="17, Spécifiez un nom d'utilisateur et un mot de passe pour empêcher les accès non voulus à l'interface de gestion du Technicolor Gateway."
t r="18, Contrôle d'accès"
t r="19, Nom d'utilisateur"
t r="20, Entrez un nom d'utilisateur."
t r="21, Mot de passe"
t r="22, Entrez un mot de passe."
t r="23, Confirmer le mot de passe"
t r="24, Entrez à nouveau le mot de passe."
t r="25, IPv6"
t r="26, Activer IPv6 sur cette interface"
langdef lang=sv
t r="0, Världen"
t r="1, Grunder"
t r="2, Routed anslutning."
t r="3, Router"
t r="4, Ange information om Internet-anslutningen. Du får all information som behövs av Internet-leverantören."
t r="5, Routed Internet-anslutning"
t r="6, Välj en VPI/VCI i listan"
t r="7, Routed Internet-anslutning"
t r="8, 'PPP över ATM (PPPoA)','PPP över Ethernet (PPPoE)'"
t r="9, Ange information om Internet-kontot. Du får all information som behövs av Internet-leverantören."
t r="10, Inställningar för Internet-konto"
t r="11, Användarnamn"
t r="12, Ange användarnamnet för Internet-anslutningen."
t r="13, Lösenord"
t r="14, Ange lösenordet för Internet-anslutningen."
t r="15, Bekräfta lösenordet"
t r="16, Ange lösenordet igen."
t r="17, Ange användarnamn och lösenord för att förhindra oönskad åtkomst till hanteringsgränssnittet för Technicolor Gateway."
t r="18, Åtkomstkontroll"
t r="19, Användarnamn"
t r="20, Ange ett användarnamn."
t r="21, Lösenord"
t r="22, Ange ett lösenord."
t r="23, Bekräfta lösenordet"
t r="24, Ange lösenordet igen."
t r="25, IPv6"
t r="26, Aktivera IPv6 på detta gränssnitt"

[ endofarch ]
