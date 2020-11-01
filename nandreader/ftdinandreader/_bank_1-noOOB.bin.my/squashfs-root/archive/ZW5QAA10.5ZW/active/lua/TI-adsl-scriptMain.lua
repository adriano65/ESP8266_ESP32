local wsd = require("wsd")
dofile("TI-creds.lua")
-- [ Main code ] ---------------------------------------------------------------

local argv = 'ADSL'
--Enable logging by removing comments on next line
wsd.log()
return sensing_changed(argv)




