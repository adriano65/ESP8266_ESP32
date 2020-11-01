<%
--[[
In this header file, two Lua functions are provided for language configuration in Lua pages:

- getLanguages()
  @return the OSI code of current active language
	  and
    a table which contains the descriptions of all the available language packs, such as:
	  { {code="en", Language="English"}, {code="es", Language="Español"}, {code="fr", Language="Français"}, {code="de", Language="Deutsch"} }

- setLanguage(code)
  @description: set the language specified by the OSI code as active language
  @param code: the OSI code of selected language
  
These two functions have different internal implementations based on the variable isSDK.
When isSDK is false, GUI uses the translation engine in gateway software. Configuration is based on MBUS.
When isSDK is true, GUI uses the translation engine in SDK. Configuration is based on Lua language API functions described as below.

a) language.get()
   @return the OSI code of current active language

b) language.set(code)
   @description: set the language specified by the OSI code as active language
   @param code: the OSI code of selected language

c) language.list()
   @return the count of available language packs in websdk/lng/
	  and
      a language description string which contains the OSI code and language name of every language pack, such as:
	  "es,Español,fr,Français,de,Deutsch,pt,Português"
]]

--[[
In SDK package, the variable isSDK is set to true by default.
If you set it to false and still run Lua pages in SDK, you'll be able to configure the language packs in the gateway through MBUS. However, the translate() function won't work because it invokes SDK's translation engine.
If you want to run Lua pages in the gateway, isSDK should be set to false.
]]
local isSDK = false


if isSDK==true then
--Run translation in SDK. Not reboot persistent.

function getLanguages()
    local results = {}
    local num, lng_list = language.list()
    local langSelect_code = language.get()
    local has_en = 0

    if num==0 then
        table.insert( results, {["Code"]="en", ["Language"]="English"} )
    else
        local t = {}       
        local start=1
        for i=1, #lng_list do
            local pos = string.find(lng_list, ",", start)
            if pos==nil then
                t[i] = string.sub(lng_list, start)
                break
            end
            t[i] = string.sub(lng_list, start, pos-1)
            start = pos+1
        end
        for i=1, #t, 2 do
            table.insert( results, {["Code"]=t[i], ["Language"]=t[i+1]} )
            if (t[i]=="en") then has_en = 1 end
        end

        -- If there's no English language pack, add default English language
        if (has_en==0) then
            table.insert( results, {["Code"]="en", ["Language"]="English"} )
        end

        -- Gurantee the language list is sorted by alphametic
        table.sort(results, function(x, y) return string.lower(x["Code"]) < string.lower(y["Code"]) end)
    end

    return langSelect_code, results
end

function setLanguage(code)
    if (code==nil) then return end
    code = tostring(code)
    if (#code~=2) then return end
    language.set(code)
end


else
-- Run translation on target, invoke MBUS.

function getLanguages()
    local results = {}
    local langSelect_code = "en"
    local langset, error = mbus.getParameters { path = "Language", param = "SelectedLanguage"}
    local langSelect_path = langset["Language"][1].param.SelectedLanguage
    if (langSelect_path~=nil) and (langSelect_path~="") then
        local reply, error = mbus.getParameters { path = langSelect_path, param = "Code"}
        if (reply[langSelect_path][1].path~=nil) and (reply[langSelect_path][1].param~=nil) then
            langSelect_code = reply[langSelect_path][1].param["Code"]
        end
    end

    local atomic, atomic_err = mbus.getParameters { path = "Language.Pack", param = {"Code", "Language"}}

    -- Gurantee the language list is sorted by alphametic
    table.sort(atomic["Language.Pack"], function(x, y) return string.lower(x.param["Code"]) < string.lower(y.param["Code"]) end)

    for k,v in pairs(atomic["Language.Pack"]) do
        local item = {}
        for ki, vi in pairs(v.param) do
            item[ki] = vi
        end
        table.insert(results, item)
    end

    return langSelect_code, results
end

function setLanguage(code)
    if (code==nil) then return end
    code = tostring(code)
    if (#code~=2) then return end
    
    local atomic, atomic_err = mbus.getParameters { path = "Language.Pack", param = "Code", filter = "(==Code "..code..")" }
    local selan_path = atomic["Language.Pack"][1].path
    
    if selan_path~=nil then
        local reply, error = mbus.modify(
            function()
                mbus.setParameters{ path = "Language", param = {SelectedLanguage=selan_path} }
            end)
    end
end

end
%>
