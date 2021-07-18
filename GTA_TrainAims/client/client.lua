local ishudStart, isCountDownBegin, isTrainBegin = false, false, false
local timerOpti = 1000
config.setLanguage(tostring(Config.language))
local timeTrains = 0

local isPlayerCanTrain = true
RegisterNetEvent("GTA_Target:PlayerCanTrain")
AddEventHandler("GTA_Target:PlayerCanTrain", function(canTrain)
    isPlayerCanTrain = canTrain
end)

local isTimerEnd = false
RegisterNetEvent("GTA_Target:TimerDone")
AddEventHandler("GTA_Target:TimerDone", function(timerShowed)
    isTimerEnd = timerShowed
end)

local targetTouchCount = 0
RegisterNetEvent("GTA_Target:SetNewTargetTouch")
AddEventHandler("GTA_Target:SetNewTargetTouch", function(addTargetTouch)
    targetTouchCount = addTargetTouch
end)

RegisterNetEvent("GTA_Target:ShowToAllTimeRemaining")
AddEventHandler("GTA_Target:ShowToAllTimeRemaining", function()
    local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
    local distBeginAims = GetDistanceBetweenCoords(plyCoords, Config.StartPos.x, Config.StartPos.y, Config.StartPos.z, true)

    local setTimer = Timer.New()
    timeTrains = Config.CountTimer

    Citizen.CreateThread(function()
        if distBeginAims <= 3.0 then
            while timeTrains > 0 do
                Citizen.Wait(0)
                timeTrains = Config.CountTimer - setTimer:elapsed()
                countimer = timeTrains
                Gui.DrawTimerBar(config.translate("time"), timeTrains, 1)
            end
    
            TriggerServerEvent("GTA_Target:RequestShowStatsTarget", true)
            TriggerServerEvent("GTA_Target:RequestTimerDone", true)
        end
    end)
end)


RegisterNetEvent("GTA_Target:ShowPlayerScore")
AddEventHandler("GTA_Target:ShowPlayerScore", function(targetPlayer)
    local PlayerNetID = PedToNet(GetPlayerPed(-1))
    local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
    local distBeginAims = GetDistanceBetweenCoords(plyCoords, Config.StartPos.x, Config.StartPos.y, Config.StartPos.z, true)

    Citizen.CreateThread(function()
        if distBeginAims <= 3.0 then
            if PlayerNetID ~= targetPlayer then
                while timeTrains > 0 do
                    Citizen.Wait(0)
                    Gui.DrawBarScore(config.translate("targetPlayerScore"), tonumber(__RoundNumber(targetTouchCount)), 3)
                end
            end
        end
    end)
end)

local pScore = 0
RegisterNetEvent("GTA_TrainAims_RefreshData")
AddEventHandler("GTA_TrainAims_RefreshData", function(bestScore)
    pScore = bestScore
end)


local showStatsPlayerTarget = false
RegisterNetEvent("GTA_Target:SetShowStatsTarget")
AddEventHandler("GTA_Target:SetShowStatsTarget", function(canSee)
    showStatsPlayerTarget = canSee
end)

RegisterNetEvent("GTA_TrainAims_CreateNewDataUsers")
AddEventHandler("GTA_TrainAims_CreateNewDataUsers", function()
    TriggerServerEvent("GTA_TrainAims_CreateNewData", 0)
    TriggerServerEvent("GTA_TrainAims_GetAllData")
    BeginTrainAim()
end)

RegisterNetEvent("GTA_TrainAims_StartGame")
AddEventHandler("GTA_TrainAims_StartGame", function()
    TriggerServerEvent("GTA_TrainAims_GetAllData")
    BeginTrainAim()
end)

    
function BeginTrainAim()
    TriggerServerEvent("GTA_Target:RequestPlayerTrain", false)
    isCountDownBegin = true
    isTrainBegin = true
    DisplayRadar(false)

    while not ishudStart do
        Citizen.Wait(0)
        local time = 0
        
        function setcountdown(x)
          time = GetGameTimer() + x*1000
        end
        
        function getcountdown()
          return math.floor((time-GetGameTimer())/1000)
        end
        
        setcountdown(4)

        while getcountdown() > 0 do
            Citizen.Wait(1)
            DrawHudText(getcountdown(), {Config.TextColorR, Config.TextColorG, Config.TextColorB, Config.TextColorA},0.5,0.4,4.0,4.0)
            ishudStart = true
            isCountDownBegin = false
        end
    end

    TriggerServerEvent("GTA_Target:RequestTimingHUD")
    TriggerServerEvent("GTA_Target:RequestScorePlayer", PedToNet(GetPlayerPed(-1)))

    CreateTarget()
end

function TargetTouch(pos)
    local textTouch = getRandomNumberText()
    local PlayerPedNetID = PedToNet(GetPlayerPed(-1))

    Citizen.CreateThread(function()
        TriggerServerEvent("GTA_Target:RequestAddTargetTouch", targetTouchCount)
    end)

    --Here if the TargetTouchText is enabled then we show a random text once the target touch :
    if Config.enableTargetTouchText == true then 
        colorTextTouch = getRandomNumberColors()
        local time = 0
            
        function setcountdown(x)
            time = GetGameTimer() + x*1000
        end
        
        function getcountdown()
            return math.floor((time-GetGameTimer())/1600)
        end
        
        setcountdown(2)
        
        Citizen.CreateThread(function()
            while getcountdown() > 0 do
                Wait(0)
                DrawText3DMarker(pos.x, pos.y, pos.z, textTouch.touch)
            end
        end)
    end

    while targetPos.rX >= -85.0 do
        Wait(0)
        targetPos.rX = targetPos.rX - 1.7

        TriggerEvent('GTA:RotateEntity', targetNetId, targetPos.rX, targetPos.rY, targetPos.rZ, 0)
        TriggerServerEvent('GTA:RequestRotateEntity', targetNetId, targetPos.rX, targetPos.rY, targetPos.rZ, PlayerPedNetID)
    end

    targetPos.rX = -90.0

    CreateTarget()
    return
end

function StopTrainAim()
    isTrainBegin = false
    targetPos.rX = -90.0
    
    DisplayRadar(true)
    SetPedInfiniteAmmoClip(GetPlayerPed(-1), false)

    TriggerServerEvent("GTA_TrainAims_GetAllData")
    TriggerServerEvent("GTA:RequestDeleteAllTarget")

    PlaySoundFrontend(-1, "MP_AWARD","HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    Citizen.Wait(5 * 1000)


    TriggerServerEvent("GTA_Target:RequestShowStatsTarget", false)
    TriggerServerEvent("GTA_Target:RequestResetTargetTouch", targetTouchCount)
    ishudStart = false
    
    TriggerServerEvent("GTA:RequestDeleteAllTarget")
    TriggerServerEvent("GTA_Target:RequestTimerDone", false)
    TriggerServerEvent("GTA_Target:RequestPlayerTrain", true)
end

Citizen.CreateThread(function()
    while true do
        timerOpti = 1000
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local distBeginAims = GetDistanceBetweenCoords(plyCoords, Config.StartPos.x, Config.StartPos.y, Config.StartPos.z, true)

        if distBeginAims <= 3.0 then
            timerOpti = 0

            if showStatsPlayerTarget == true then
                -------------------------------> Here we control the text skill related to the "targetTouchCount".
                if targetTouchCount < 10 then  
                    scaleform = ShowStats("mp_big_message_freemode", config.translate("time_end").. "\n" .." ~w~SKILL : ~r~"..config.translate("bad_shoot").."  \n ~g~"..config.translate("bestScore").." : ~w~ ".. pScore .. "~y~\n " ..config.translate("targetPlayerScore").. "~w~ : "..targetTouchCount)
                elseif targetTouchCount < 30 then
                    scaleform = ShowStats("mp_big_message_freemode", config.translate("time_end").. "\n" .." ~w~SKILL : ~o~"..config.translate("good_shoot").."  \n ~g~"..config.translate("bestScore").. " : ~w~ "..pScore .. "~y~\n " ..config.translate("targetPlayerScore").. "~w~ : "..targetTouchCount)
                elseif targetTouchCount >= 30 then
                    scaleform = ShowStats("mp_big_message_freemode", config.translate("time_end").. "\n" .." ~w~SKILL : ~g~"..config.translate("perfect_shoot").." \n ~g~"..config.translate("bestScore").. " : ~w~ ".. pScore .. "~y~\n " ..config.translate("targetPlayerScore").. "~w~ : "..targetTouchCount)
                end
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            end

            if ishudStart == false then 
                if isPlayerCanTrain == true then

                    if GetLastInputMethod(0) then
                        Ninja_Core__DisplayHelpAlert("~INPUT_PICKUP~"..config.translate("pour").. "~g~" ..config.translate("interact"))
                    else
                        Ninja_Core__DisplayHelpAlert("~INPUT_CELLPHONE_EXTRA_OPTION~"..config.translate("pour").. "~g~" ..config.translate("interact"))
                    end

                    if (IsControlJustReleased(0, 38) or IsControlJustReleased(0, 214)) then 
                        TriggerServerEvent("GTA_TrainAims_IsDataExist")
                    end
                    
                    if isCountDownBegin == true then
                        PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", false)
                        Wait(1000)
                        PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", false)
                        Wait(1000)
                        PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", false)
                        ishudStart = false
                    end
                end
            end

            if isTrainBegin == true then 
                if myObj ~= nil then 
                    local playerPed = GetPlayerPed(-1)
                    local is, pos = GetPedLastWeaponImpactCoord(playerPed)
                    
                    if timeTrains > 900 then
                        if isEntityTouch(myObj) then
                            ClearEntityLastWeaponDamage(myObj)
                            PlaySoundFrontend(-1, "LOOSE_MATCH", "HUD_MINI_GAME_SOUNDSET", false)
                            TargetTouch(pos)
                        end
                    end
                end
            end
        end
        Citizen.Wait(timerOpti)
	end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(timerOpti)
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local distBeginAims = GetDistanceBetweenCoords(plyCoords, Config.StartPos.x, Config.StartPos.y, Config.StartPos.z, true)
        
        if distBeginAims <= 3.0 then
            if isTrainBegin == true then
                if isTimerEnd == true then
                    TriggerServerEvent("GTA_TrainAims_UpdateScore", targetTouchCount)
                    StopTrainAim()
                end

                if Config.infinitAmmo == true then 
                    SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
                else
                    SetPedInfiniteAmmoClip(GetPlayerPed(-1), false)
                end

                --> ALLOW PLAYER TO NOT HAVE COPS
                if (GetPlayerWantedLevel(PlayerId()) > 0) then
                    SetPlayerWantedLevel(PlayerId(), 0, false)
                    SetPlayerWantedLevelNow(PlayerId(), false)
                end

                
                Gui.DrawBarBestScore("~g~"..config.translate("bestScore"), tonumber(__RoundNumber(pScore)), 3)

                if targetTouchCount < 10 then
                    Gui.DrawBarScore(config.translate("score"), tonumber(__RoundNumber(targetTouchCount)), 3)
                elseif targetTouchCount < 30 then
                    Gui.DrawBarScore(config.translate("score"),"~o~" ..tonumber(__RoundNumber(targetTouchCount)), 3)
                elseif targetTouchCount >= 30 then
                    Gui.DrawBarScore(config.translate("score"),"~g~" ..tonumber(__RoundNumber(targetTouchCount)), 3)
                end
            end
        end
    end
end)

--[[
--> CallBack Main from NUI : used to show the wanted announce.
RegisterNUICallback("main", function(data)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "enableui",
        activate = false
    })
end)

--> CallBack Error from NUI : used to exit the nui + show the data error.
RegisterNUICallback("error", function(data)
    print("NUI WANTED ERROR : ", data.error)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "enableui",
        activate = false
    })
end)

--> CallBack Exit from NUI : used to exit the nui without error.
RegisterNUICallback("exit", function(data)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "enableui",
        activate = false
    })
end)
]]