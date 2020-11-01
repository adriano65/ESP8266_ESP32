--------------------------------------------------------------------------------
-- Default values
--------------------------------------------------------------------------------

cgilua.addscripthandler ("lua", cgilua.doscript)
cgilua.addscripthandler ("lp",  cgilua.handlelp)
cgilua.addscripthandler ("llp", cgilua.handlellp)

--Add the handler to support accessing url without suffix for xml dumping of TI_WLS.
cgilua.addscripthandler ("requestdata", cgilua.handlelp)
cgilua.addscripthandler ("sipgwconfig", cgilua.handlelp)
cgilua.addscripthandler ("sipgwcalllog", cgilua.handlelp)
--Add the error rediret page to handle the session expire.
cgilua.seterrorpage("loginMask.lp", function() return {url = cgilua.script_file} end)
--------------------------------------------------------------------------------
-- Dynamic caching strategy
-- Set the dynamic stategy used for caching lua pages/scripts
-- Possibilities:
-- false -> normal
--   - Caches the compiled page/script in a table using the filename/path
--     as the key. This is sufficient if the webui is not updated while
--     the webserver is running. (Default)
-- true -> modification
--   - Same as above but with each request the file modification time is
--     checked to see if the file has been updated. Use this if the webui can
--     be updated on the fly.
--------------------------------------------------------------------------------
cgilua.lp.setdynamiccachingstrategy(false)
