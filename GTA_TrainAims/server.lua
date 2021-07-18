RegisterNetEvent('GTA:RequestRotateEntity')
AddEventHandler('GTA:RequestRotateEntity', function(ObjNetID, rX, rY, rZ, PlayerPedNetID)
    TriggerClientEvent('GTA:RotateEntity', -1, ObjNetID, rX, rY, rZ, PlayerPedNetID) -- Triggers the event for every client (-1)
end)

RegisterNetEvent('GTA:RequestDeleteAllTarget')
AddEventHandler('GTA:RequestDeleteAllTarget', function()
    TriggerClientEvent('GTA:DeleteAllTarget', -1)
end)

RegisterServerEvent("GTA_Target:RequestPlayerTrain")
AddEventHandler("GTA_Target:RequestPlayerTrain", function(canTrain)
    TriggerClientEvent("GTA_Target:PlayerCanTrain", -1, canTrain)
end)

RegisterServerEvent("GTA_Target:RequestTimingHUD")
AddEventHandler("GTA_Target:RequestTimingHUD", function()
    TriggerClientEvent("GTA_Target:ShowToAllTimeRemaining", -1)
end)

RegisterServerEvent("GTA_Target:RequestTimerDone")
AddEventHandler("GTA_Target:RequestTimerDone", function(isTimerDown)
    TriggerClientEvent("GTA_Target:TimerDone", -1, isTimerDown)
end)

RegisterServerEvent("GTA_Target:RequestScorePlayer")
AddEventHandler("GTA_Target:RequestScorePlayer", function(player)
    TriggerClientEvent("GTA_Target:ShowPlayerScore", -1, player)
end)

RegisterServerEvent("GTA_Target:RequestAddTargetTouch")
AddEventHandler("GTA_Target:RequestAddTargetTouch", function(newTargetTouch)
    newTargetTouch = newTargetTouch + 1
    TriggerClientEvent("GTA_Target:SetNewTargetTouch", -1, newTargetTouch)
end)

RegisterServerEvent("GTA_Target:RequestResetTargetTouch")
AddEventHandler("GTA_Target:RequestResetTargetTouch", function(newTargetTouch)
    newTargetTouch = 0
    TriggerClientEvent("GTA_Target:SetNewTargetTouch", -1, newTargetTouch)
end)

RegisterServerEvent("GTA_Target:RequestShowStatsTarget")
AddEventHandler("GTA_Target:RequestShowStatsTarget", function(canSee)
    TriggerClientEvent("GTA_Target:SetShowStatsTarget", -1, canSee)
end)








--JSON STUFF : 
local resource_name = GetCurrentResourceName()

function GetFile(filename)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or '{}')
    return file_data
end


function GetItem(filename, itemname)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or "{}")
    return file_data[itemname]
end


function AddItem(filename, itemname, itemcontent)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or '{}')
    file_data[itemname] = itemcontent
    SaveResourceFile(resource_name, "data/" .. filename .. ".json", json.encode(file_data, { indent = true }), -1)
end

function GetPlayerIdentifierFromType(type, source)
	local identifiers = {}
	local identifierCount = GetNumPlayerIdentifiers(source)

	for a = 0, identifierCount do
		table.insert(identifiers, GetPlayerIdentifier(source, a))
	end

	for b = 1, #identifiers do
		if string.find(identifiers[b], type, 1) then
			return identifiers[b]
		end
	end
	return nil
end


RegisterNetEvent("GTA_TrainAims_IsDataExist")
AddEventHandler("GTA_TrainAims_IsDataExist", function()
    local source = source
	local playerIDName = GetPlayerName(source) --> Get Player Name based on the FiveM Player Name.

    TriggerEvent("json:getItem", "dataScore", playerIDName, function(cb)
        --Check if the data doesn't exist then we create new one
        if(cb == nil) then 
            TriggerClientEvent("GTA_TrainAims_CreateNewDataUsers",source)
            return
        else
            TriggerClientEvent("GTA_TrainAims_StartGame",source)
        end
    end)
end)

RegisterNetEvent("GTA_TrainAims_GetAllData")
AddEventHandler("GTA_TrainAims_GetAllData", function()
    local source = source
	local playerIDName = GetPlayerName(source) --> Get Player Name based on the FiveM Player Name.

    TriggerEvent("json:getItem", "dataScore", playerIDName, function(cb)
        if(cb ~= nil) then 
            TriggerClientEvent("GTA_TrainAims_RefreshData",source, cb.bestScore)
        end
    end)
end)

RegisterNetEvent("GTA_TrainAims_CreateNewData")
AddEventHandler("GTA_TrainAims_CreateNewData", function(newScore)
    local source = source
	local playerIDName = GetPlayerName(source) --> Get Player Name based on the FiveM Player Name.

    TriggerEvent("json:getItem", "dataScore", playerIDName, function(cb)
        -->We update the new score :
        TriggerEvent("json:addItem", "dataScore", playerIDName, {bestScore = newScore})
    end)
end)

RegisterNetEvent("GTA_TrainAims_UpdateScore")
AddEventHandler("GTA_TrainAims_UpdateScore", function(newScore)
    local source = source
	local playerIDName = GetPlayerName(source) --> Get Player Name based on the FiveM Player Name.

    TriggerEvent("json:getItem", "dataScore", playerIDName, function(cb)

        --We just update the new data if the new score are up to the old one : 
        if(newScore <= cb.bestScore) then 
            return
        end

        -->We update the new score :
        TriggerEvent("json:replaceItem", "dataScore", playerIDName, {bestScore = newScore })
    end)
end)



function DeleteItem(filename, itemname)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or '{}')
    if file_data[itemname] ~= nil then
        file_data[itemname] = nil
        SaveResourceFile(resource_name, "data/" .. filename .. ".json", json.encode(file_data, { indent = true }), -1)
    else
        print("^1[ERROR][" .. resource_name .. "]^7 Attempted to delete a non-existing item.")
        return
    end
end


function ReplaceItem(filename, itemname, itemcontent)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or '{}')
    if file_data[itemname] ~= nil then
        file_data[itemname] = itemcontent
        SaveResourceFile(resource_name, "data/" .. filename .. ".json", json.encode(file_data, { indent = true }), -1)
    else
        print("^1[ERROR][" .. resource_name .. "]^7 Attempted to replace a non-existing item.")
        return
    end
end

function DeleteData(filename, itemname, dataname)
    local loaded_data = LoadResourceFile(resource_name, "data/" .. filename .. ".json")
    local file_data = json.decode(loaded_data or '{}')
    if file_data[itemname][dataname] ~= nil then
        file_data[itemname][dataname] = nil
        SaveResourceFile(resource_name, "data/" .. filename .. ".json", json.encode(file_data, { indent = true }), -1)
    else
        print("^1[ERROR][" .. resource_name .. "]^7 Attempted to delete a non-existing data (^3" .. dataname .. "^7) within ^3" .. itemname .. "^7 in file ^3" .. filename .. ".json^7")
    end
end



RegisterNetEvent("json:getFile", function(file, cb)
    cb(GetFile(file))
end)

RegisterNetEvent("json:getItem", function(file, item, cb)
    cb(GetItem(file, item))
end)

RegisterNetEvent("json:addItem", function(file, item, content)
    AddItem(file, item, content)
end)

RegisterNetEvent("json:deleteItem", function(file, item)
    DeleteItem(file, item)
end)

RegisterNetEvent("json:replaceItem", function(file, item, content)
    ReplaceItem(file, item, content)
end)

RegisterNetEvent("json:deleteData", function(file, item, data)
    deleteData(file, item, data)
end)