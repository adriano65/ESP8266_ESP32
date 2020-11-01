local ipairs, loadstring, mbus = ipairs, loadstring, mbus
local pairs, pcall, print, string, type = pairs, pcall, print, string, type

local dbgtrc = 1

module('wsd')

--------------------------------------------------------------------------------

function printtype(prefix, t, k)
   local p = prefix
   if k then
      p = p..k..' = '
   end
   if type(t) == 'number' or type(t) == 'string' then
      print(p..t)
   elseif type(t) == 'table' then
      print(p..'{')
      for k,v in pairs(t) do
         printtype(prefix..'  ', v, k)
      end
      print(prefix..'}')
   elseif type(t) == 'nil' then
      print(prefix..'nil')
   else
      print(prefix..'euh?')
   end
end

--------------------------------------------------------------------------------

local function loc_invoke(cmd, type, path, allok) 
   local ok, res, err = false, nil, nil
   local msg = nil

   -- tracing
   if dbgtrc then
      print('*** '..type..'('..path..')')
   end
   -- execute MBus client command
   ok, res, err = pcall(mbus.invoke, cmd)
   -- handle results and errors
   if not ok or err then
      allok = false
      if not ok then
         msg = res
         res = nil
      else 
         msg = 'can not '..type..'('..path..')'
      end
      if dbgtrc then
         print('E - '..msg)
         if res then printtype('    ', res, 'res') end
         if err then printtype('    ', err, 'err') end
      end
   end
   return allok, msg
end

--------------------------------------------------------------------------------

local function loc_process_cfg_cmd(cmdtype, cmdpath, key, name, params) 
   local allok, msg = true, nil
   local fltr, flgs = nil, nil

   -- delete command has no parameters (array instead of hashtable)
   if cmdtype == 'del' then
      name,params = params,nil
   end
   -- process key parameter
   if key then
      if cmdtype == 'add' then
         params[key] = name
      else
         fltr = '(== '..key..' '..name..')'
      end
   end
   -- process dynamic parameter values
   if type(params) == 'table' then
      for k,v in pairs(params) do
         if type(v) == 'function' then
            allok, params[k] = pcall(v, name)
            if not allok then
               return nil, 'could not get value for: '..k
            end
         end
      end
   end
   -- execute MBus client command
   local ccmd = {
      cmd = cmdtype, path = cmdpath, param = params, filter = fltr,
      flags = 'KEYPATH'
   }
   allok, msg = loc_invoke(ccmd, cmdtype, cmdpath..'.'..name, allok)
   return allok, msg
end

--------------------------------------------------------------------------------

local function loc_process_cfg_block(cfg, exit_on_error) 
   local allok, msg = true, nil
   local res, err = nil, nil

   for _,cmdtype in ipairs{'sync','add','del','set'} do
      if cfg[cmdtype] then
         if cmdtype == 'sync' then
            -- if syncing perform a synchronized get for objects
            local ccmd = {
               cmd = 'get', path = cfg.path, flags = { 'KEYPATH', 'SYNC' },
               gettype = 'object'
            }
            allok, msg = loc_invoke(ccmd, cmdtype, cfg.path, allok)
            if not allok and exit_on_error then
               return nil, msg
            end
         else
            for name,params in pairs(cfg[cmdtype]) do
               allok, msg = loc_process_cfg_cmd(cmdtype, cfg.path, cfg.key,
                                                name, params)
               -- try error recovery
               if not allok then
                  if cmdtype == 'add' then
                     -- 1. failed add, try delete and add again
                     loc_process_cfg_cmd('del', cfg.path, cfg.key, nil, name)
                     allok, msg = loc_process_cfg_cmd(cmdtype, cfg.path,
                                                      cfg.key, name, params)
                  end
               end
               -- handle error
               if not allok and exit_on_error then
                  return nil, msg
               end
            end
         end
      end
   end
   if allok then
      return 'All ok'
   else
      return nil, 'an error occurred'
   end
end

--------------------------------------------------------------------------------

local function loc_process_cfg(cfg, exit_on_error)
   local allok = true
   local pok, ok, msg = true, true, ''

   for _,block in ipairs(cfg) do
      pok, ok, msg = pcall(mbus.modify,
                           function ()
                              return loc_process_cfg_block(block, exit_on_error)
                           end)
      if not pok or not ok then
         allok = false
         if not pok then
            msg = ok
         end
         if dbgtrc and msg then
            print('E - '..msg)
         end
         if exit_on_error then
            return nil, msg
         end
      end
   end
   if allok then
         return 'All ok'
   else
      return nil, 'an error occurred'
   end
end

--------------------------------------------------------------------------------

function entry_exit(argv, entry_cfg, exit_cfg)
   local cfg, exit_on_error = nil, false

   if argv[1] == 'Entry' then
      cfg, exit_on_error  = entry_cfg, true
   elseif argv[1] == 'Exit' then
      cfg, exit_on_error = exit_cfg, false
   else
      return 'No action specified'
   end
   if cfg then
      return loc_process_cfg(cfg, exit_on_error)
   end
   return 'All Ok'              -- no error
end
