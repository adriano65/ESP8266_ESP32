local wsd = require("wsd")
dofile("TI-creds.lua")

local entry_cfg = {
	{  
		path = 'System',
		set = { system = { WANMode='ADSL' } } 
	}, 
	{  
		path = 'ENV', key='Name', 
		set = { IS_NOT_DSL_DEVICE = { Value='0' } } 
	},
}

local exit_cfg = {
 
}

-- [ Main code ] ---------------------------------------------------------------

local argv = argv
--Enable logging by removing comments on next line
wsd.log()
return wsd.entry_exit(argv, entry_cfg, exit_cfg)
