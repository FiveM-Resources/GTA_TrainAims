TargetSpawned = {}

function canRequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

--> Permet de ne pas use de native pour check la distance entre 2 vecteur :
square = math.sqrt
function getDistance(a, b) 
    local x, y, z = a.x-b.x, a.y-b.y, a.z-b.z
    return square(x*x+y*y+z*z)
end

function ShowNotification(text)
    SetNotificationTextEntry( "STRING" )
    AddTextComponentString( text )
    DrawNotification( false, false )
end

function Ninja_Core__DisplayHelpAlert(msg)
	BeginTextCommandDisplayHelp("STRING");  
    AddTextComponentSubstringPlayerName(msg);  
    EndTextCommandDisplayHelp(0, 0, 1, -1);
end

function DrawHudText(label,color,posX,posY,sX,sY)
    SetTextFont(7)
    SetTextProportional(7)
    SetTextScale(sX, sY)
    local colorR,colorG,colorB,colorA = table.unpack(color)
    SetTextColour(colorR,colorG,colorB, colorA)
	SetTextDropshadow(1, 0, 0, 0, colorA)
    SetTextEdge(1, 0, 0, 0, colorA)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(label)
	DrawText(posX,posY)	
end

function IsActive()
	return not IsPlayerDead(PlayerId()) and not IsPlayerSwitchInProgress() and not GetIsLoadingScreenActive()
end

function getRandomNumber()
	for i = 1, #TargetPosition do
		math.randomseed(GetGameTimer())
		math.random(); math.random(); math.random();
		
		local number =  math.random(1, #TargetPosition)
		local q = TargetPosition[number]

		return q
	end
end
targetPos = getRandomNumber()

function getRandomNumberColors()
	for i = 1, #RandomColorsTargetTouchText do
		math.randomseed(GetGameTimer())
		math.random(); math.random(); math.random();
		
		local number =  math.random(1, #RandomColorsTargetTouchText)
		local q = RandomColorsTargetTouchText[number]

		return q
	end
end
colorTextTouch = getRandomNumberColors()

function getRandomNumberText()
	for i = 1, #RandomTextTargetTouch do
		math.randomseed(GetGameTimer())
		math.random(); math.random(); math.random();
		
		local number =  math.random(1, #RandomTextTargetTouch)
		local q = RandomTextTargetTouch[number]

		return q
	end
end
textTouch = getRandomNumberText()

myObj = nil
targetNetId = nil

function CreateTarget() --> Here we create the target.
    targetPos = getRandomNumber()

    myObj = CreateObject(Config.HashTarget, targetPos.x, targetPos.y, targetPos.z-1, true)
    SetEntityHeading(myObj, targetPos.h)
    SetEntityRotation(myObj, targetPos.rX, targetPos.rY, targetPos.rZ)
    TargetSpawned[#TargetSpawned+1] = ObjToNet(myObj)

    local ObjNetID = ObjToNet(myObj)
    targetNetId = ObjNetID
    local PlayerPedNetID = PedToNet(GetPlayerPed(-1))

    if not NetworkGetEntityIsNetworked(myObj) then
        NetworkRegisterEntityAsNetworked(myObj)
    end

    if NetworkDoesNetworkIdExist(targetNetId) then
        if (NetworkGetEntityIsNetworked(myObj)) then
            while targetPos.rX <= 0.0 do
                Wait(0)
                targetPos.rX = targetPos.rX + 1.7
                TriggerEvent('GTA:RotateEntity', targetNetId, targetPos.rX, targetPos.rY, targetPos.rZ, 0)
                TriggerServerEvent('GTA:RequestRotateEntity', targetNetId, targetPos.rX, targetPos.rY, targetPos.rZ, PlayerPedNetID)
            end
        end
    end
end

function isEntityTouch(entity)
    if HasEntityBeenDamagedByWeapon(entity, 0, 2) then
        return true
    else
        return false
    end
end

RegisterNetEvent('GTA:RotateEntity')
AddEventHandler('GTA:RotateEntity', function(ObjNetID, rX, rY, rZ, PlayerPedNetID)
    local Obj = NetToObj(ObjNetID)
    local PlayerNetID = PedToNet(GetPlayerPed(-1))
    if PlayerNetID ~= PlayerPedNetID then
        SetEntityRotation(Obj, rX, rY, rZ, 0, true)
    end
end)

RegisterNetEvent('GTA:DeleteAllTarget')
AddEventHandler('GTA:DeleteAllTarget', function()
    for k, v in pairs(TargetSpawned) do 
        DeleteObject(NetToObj(v))
        TargetSpawned[k] = nil
    end
end)


function BulletCoords()
    local result, coord = GetPedLastWeaponImpactCoord(PlayerPedId(), Citizen.ReturnResultAnyway())
    return coord
end

__RoundNumber = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

function ShowStats(scaleform, textOne, textTwo)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieFunctionParameterString(textOne)
    PushScaleformMovieFunctionParameterString(textTwo)
    PopScaleformMovieFunctionVoid()
    return scaleform
end

function DrawText3DMarker(x,y,z,text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    
    if onScreen then
        SetTextScale(0.2 + 0.03, 0.3 + 0.03)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(colorTextTouch.R, colorTextTouch.G, colorTextTouch.B, colorTextTouch.A)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end