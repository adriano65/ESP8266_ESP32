local wsd = require("wsd")
dofile("TI-creds.lua")

-- [ Mode entry configuration ] ------------------------------------------------

local entry_cfg = {
--  { path = 'DeviceConfig',
--   set = { deviceconfig = {FactoryDefaults='1'} } },
      
}

-- [ Mode exit configuration ] -------------------------------------------------

local exit_cfg = {
}

-- [ Main code ] ---------------------------------------------------------------

local argv = argv
--Enable logging by removing comments on next line
wsd.log()
return wsd.entry_exit(argv, entry_cfg, exit_cfg)
