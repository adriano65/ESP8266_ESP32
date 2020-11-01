<%
local QUERY = cgilua.QUERY
local print = cgilua.print
local fromUAId = QUERY["fromUAId"]
local toUAId = QUERY["toUAId"]
if QUERY["typeAndPriority"] == "1" then
    local fromUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. QUERY["selectIndex"]
    local toUAPath = "Device.Services.VoiceService.1.VoiceProfile.1.Line." .. QUERY["selectIndex"]
    local toVoicePortPath, fromVoicePortPath
    local pathIdVal = QUERY["pathId"]
    if tonumber(pathIdVal)<3 then
        toVoicePortPath = "Device.Services.VoiceService.1.PhyInterface." .. QUERY["pathId"]
        fromVoicePortPath = "Device.Services.VoiceService.1.PhyInterface." .. QUERY["pathId"]
    else
        toVoicePortPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. (tonumber(QUERY["pathId"])-2)
        fromVoicePortPath = "Device.Services.VoiceService.1.PhyInterface.3.X_TELECOMITALIA_IT_DECTHandset." .. (tonumber(QUERY["pathId"])-2)
    end
    local priorityVP = QUERY["priority"]
    local UAMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap"
    local VoicePortMap_path = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap"
    local uaMapPathId, voicePortMapPathId
    if fromUAId~=nil then
        local reply, error = mbus.modify(
        function()
            local reply1, error1 = mbus.addObjects{ path = UAMap_path, param = { FromUA = fromUAPath, ToVoicePort = toVoicePortPath }, datamodel = "second" }
            --get the object path id for deleting.
            uaMapPathId = string.gsub(reply1[UAMap_path][1].path, UAMap_path..".", "")
            if error1~=nil or reply1[UAMap_path][1]==nil then
                result=1
        cgilua.errorlog("error1 is not nil:")
            end
        end, {datamodel="second"})
    print(uaMapPathId)
    end
    if toUAId~=nil then
        local reply, error = mbus.modify(
        function()
            local reply2, error2
            if priorityVP=="" then
                reply2, error2 = mbus.addObjects{ path = VoicePortMap_path, param = { ToUA = toUAPath, FromVoicePort = fromVoicePortPath }, datamodel = "second" }
            else
                reply2, error2 = mbus.addObjects{ path = VoicePortMap_path, param = { ToUA = toUAPath, FromVoicePort = fromVoicePortPath, Priority = tostring(priorityVP) }, datamodel = "second" }
            end
            --get the object path id for deleting.
            voicePortMapPathId = string.gsub(reply2[VoicePortMap_path][1].path, VoicePortMap_path..".", "")
            if error2~=nil or reply2[VoicePortMap_path][1]==nil then
                result=1
        cgilua.errorlog("error1 is not nil:")
            end
        end, {datamodel="second"})
    print(voicePortMapPathId)
    end
end

if QUERY["deleteDirectNumFlag"] == "1" then
    local uaMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_UAMap." .. tostring(QUERY["uaMapPathId"])
    local voicePortMapPath = "Device.Services.VoiceService.1.VoiceProfile.1.X_TELECOMITALIA_IT_VoicePortMap." .. tostring(QUERY["voicePortMapPathId"])
    if fromUAId~=nil then
        local reply, error = mbus.modify(
            function()
                if uaMapPath~=nil then
                    local reply1, error1 = mbus.deleteObjects{path = uaMapPath, datamodel = "second"}
                end
            end, {datamodel="second"})
        print("")
    end
    if toUAId~=nil then
        local reply, error = mbus.modify(
            function()
                if voicePortMapPath~=nil then
                    local reply2, error2 = mbus.deleteObjects{path = voicePortMapPath, datamodel = "second"}
                end
            end, {datamodel="second"})
        print("")
    end
end
%>

