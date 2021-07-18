local _barWidth = 0.155
local _barHeight = 0.035

local _barProgressWidth = _barWidth / 2.65
local _barProgressHeight = _barHeight / 3.25

local _barTexture = 'all_black_bg'
local _barTextureDict = 'timerbars'

Player = { }
Player.__index = Player

Player.Loaded = false

Player.TimePlayed = 0

Player.InPassiveMode = false
Player.Kills = 0
Player.Deaths = 0
Player.SkinModel = nil
Player.Moderator = nil

Player.Killstreak = 0
Player.Deathstreak = 0

Player.VehicleHandle = nil
Player.Vehicle = nil

Player.PatreonTier = nil

Player.Cash = 0
Player.Experience = 0
Player.Rank = 1
Player.Prestige = 0

Player.MoneyWasted = 0
Player.Headshots = 0
Player.VehicleKills = 0
Player.MaxKillstreak = 0
Player.LongestKillDistance = 0
Player.MissionsDone = 0
Player.EventsWon = 0

Player.WeaponStats = { }

Player.Garages = { }
Player.Vehicles = { }

Player.DrugBusiness = { }

Player.CrewLeader = nil
Player.CrewMembers = { }

Player.Records = { }

Player.Settings = { }

Gui = { }
Gui.__index = Gui

function Gui.GetPlayerName(serverId, color, lowercase)
	if Player.ServerId() == serverId then
		if lowercase then
			return 'you'
		else
			return 'You'
		end
	else
		if not color then
			if Player.CrewMembers[serverId] then
				color = '~b~'
			elseif serverId == World.BeastPlayer or serverId == World.HotPropertyPlayer or serverId == World.KingOfTheCastlePlayer or MissionManager.IsPlayerOnMission(serverId) then
				color = '~r~'
			else
				color = '~w~'
			end
		end

		local playerName = PlayerData.IsExists(serverId) and PlayerData.GetName(serverId) or GetPlayerName(GetPlayerFromServerId(serverId))
		return color..'<C>'..playerName..'</C>~w~'
	end
end

function Gui.CreateMenu(id, title)
	WarMenu.CreateMenu(id, title)
	WarMenu.SetMenuMaxOptionCountOnScreen(id, Settings.maxMenuOptionCount)
end

function Gui.OpenMenu(id)
	if not WarMenu.IsAnyMenuOpened() and Player.IsActive() then
		WarMenu.OpenMenu(id)
	end
end

function Gui.ToolTip(text, width, flipHorizontal)
	if Player.Settings.disableTips then
		return
	end

	WarMenu.ToolTip(text, width, flipHorizontal)
end

function Gui.GetTextInputResultAsync(maxInputLength, defaultText)
	DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', defaultText or '', '', '', '', maxInputLength)

	while true do
		Citizen.Wait(0)
		DisableAllControlActions(0)

		local status = UpdateOnscreenKeyboard()
		if status == 2 then
			return nil
		elseif status == 1 then
			return GetOnscreenKeyboardResult()
		end
	end
end

function Gui.AddText(text)
	local str = tostring(text)
	local strLen = string.len(str)
	local maxStrLength = 99

	for i = 1, strLen, maxStrLength + 1 do
		if i > strLen then
			return
		end

		AddTextComponentString(string.sub(str, i, i + maxStrLength))
	end
end

function Gui.DisplayHelpText(text)
	BeginTextCommandDisplayHelp('STRING')
	Gui.AddText(text)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function Gui.DisplayNotification(text, pic, title, subtitle, icon)
	BeginTextCommandThefeedPost('STRING')
	Gui.AddText(text)

	if pic then
		EndTextCommandThefeedPostMessagetext(pic, pic, false, icon or 4, title or '', subtitle or '')
	else
		EndTextCommandThefeedPostTicker(true, true)
	end
end

function Gui.DisplayPersonalNotification(text, pic, title, subtitle, icon, backgroundColor)
	BeginTextCommandThefeedPost('STRING')
	Gui.AddText(text)
	ThefeedNextPostBackgroundColor(backgroundColor or 200)

	if pic then
		EndTextCommandThefeedPostMessagetext(pic, pic, false, icon or 4, title or '', subtitle or '')
	else
		EndTextCommandThefeedPostTicker(true, true)
	end
end

function Gui.DrawRect(position, width, height, color)
	DrawRect(position.x, position.y, width, height, color.r, color.g, color.b, color.a or 255)
end

function Gui.SetTextParams(font, color, scale, shadow, outline, center)
	SetTextFont(font)
	SetTextColour(color.r, color.g, color.b, color.a or 255)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow()
	end

	if outline then
		SetTextOutline()
	end

	if center then
		SetTextCentre(true)
	end
end

function Gui.DrawText(text, position, width)
	BeginTextCommandDisplayText('STRING')
	Gui.AddText(text)

	if width then
		SetTextRightJustify(true)
		SetTextWrap(position.x - width, position.x)
	end

	EndTextCommandDisplayText(position.x, position.y)
end

function Gui.DrawTextEntry(entry, position, ...)
	BeginTextCommandDisplayText(entry)

	local params = { ... }
	for _, param in ipairs(params) do
		local paramType = type(param)
		if paramType == 'string' then
			AddTextComponentString(param)
		elseif paramType == 'number' then
			if math.is_integer(param) then
				AddTextComponentInteger(param)
			else
				AddTextComponentFloat(param, 2)
			end
		end
	end

	EndTextCommandDisplayText(position.x, position.y)
end

function Gui.DrawNumeric(number, position)
	Gui.DrawTextEntry('NUMBER', position, number)
end

function Gui.DisplayObjectiveText(text)
	BeginTextCommandPrint('STRING')
	Gui.AddText('<C>'..text..'</C>')
	EndTextCommandPrint(1, true)
end

function Gui.DrawMarker(type, position, color, radius, height, bobUpAndDown)
	if not radius then
		radius = Settings.placeMarker.radius
	end

	if IsSphereVisible(position.x, position.y, position.z, radius) then
		DrawMarker(type, position.x, position.y, position.z - 1, 0, 0, 0, 0, 0, 0, radius * 2, radius * 2, height or radius * 2, color.r, color.g, color.b, color.a or Settings.placeMarker.opacity, bobUpAndDown, true, nil, false)
	end
end

function Gui.DrawPlaceMarker(position, color, radius, height)
	Gui.DrawMarker(1, position, color, radius, height)
end

function Gui.StartEvent(name, message)
	PlaySoundFrontend(-1, 'MP_5_SECOND_TIMER', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)

	Citizen.CreateThread(function()
		local scaleform = Scaleform.NewAsync('MIDSIZED_MESSAGE')
		scaleform:call('SHOW_SHARD_MIDSIZED_MESSAGE', name..' has started', message)
		scaleform:renderFullscreenTimed(10000)
	end)

	FlashMinimapDisplay()
end

function Gui.StartMission(name, message)
	PlaySoundFrontend(-1, 'EVENT_START_TEXT', 'GTAO_FM_EVENTS_SOUNDSET', true)

	Citizen.CreateThread(function()
		local scaleform = Scaleform.NewAsync('MIDSIZED_MESSAGE')
		scaleform:call('SHOW_SHARD_MIDSIZED_MESSAGE', name, message or '')
		scaleform:renderFullscreenTimed(10000)

		Gui.DisplayHelpText('Other players have been alerted to your activity. They can come after you to earn reward.')
	end)

	FlashMinimapDisplay()
end

function Gui.FinishMission(name, success, reason)
	if success then
		PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', true)
	else
		PlaySoundFrontend(-1, 'ScreenFlash', 'MissionFailedSounds', true)
	end

	if not reason then
		return
	end

	if Player.IsActive() then
		local status = success and 'COMPLETED' or 'FAILED'
		local scaleform = Scaleform.NewAsync('MIDSIZED_MESSAGE')
		scaleform:call('SHOW_SHARD_MIDSIZED_MESSAGE', string.upper(name)..' '..status, reason)
		scaleform:renderFullscreenTimed(7000)
	else
		local message = name
		if success then
			message = message..' Completed\n'
		else
			message = message..' Failed\n'
		end
		message = message..reason

		Gui.DisplayPersonalNotification(message)
	end
end

Prompt = { }
Prompt.__index = Prompt

local _isDisplaying = false

function Prompt.ShowAsync(message, type)
	if _isDisplaying then
		return
	end

	BeginTextCommandBusyString('STRING')
	Gui.AddText(message or 'Transaction pending')
	EndTextCommandBusyString(type or 4)

	_isDisplaying = true
	while _isDisplaying do
		Citizen.Wait(0)
	end
end

function Prompt.IsDisplaying()
	return _isDisplaying
end

function Prompt.Hide()
	_isDisplaying = false
	RemoveLoadingPrompt()
end


SafeZone = { }
SafeZone.__index = SafeZone

function SafeZone.Size()
	return GetSafeZoneSize()
end

function SafeZone.Left()
	return (1.0 - SafeZone.Size()) * 0.5
end

function SafeZone.Right()
	return 1.0 - SafeZone.Left()
end

SafeZone.Top = SafeZone.Left
SafeZone.Bottom = SafeZone.Right

function string.from_ms(ms, highAccuracy)
	local roundMs = ms / 1000

	local minutes = math.floor(roundMs / 60)
	local seconds = math.floor(roundMs % 60)

	local result = string.format('%02.f', minutes)..':'..string.format('%02.f', math.floor(seconds))
	if highAccuracy then
		result = result..'.'..string.format('%02.f', math.floor((ms - (minutes * 60000) - (seconds * 1000)) / 10))
	end

	return result
end

function string.to_speed(speed)
	if ShouldUseMetricMeasurements() then
		return string.format('%d KM/H', math.floor(speed * 3.6))
	else
		return string.format('%d MP/H', math.floor(speed * 2.236936))
	end
end


Timer = { }
Timer.__index = Timer

function Timer.New(startTime)
	local self = { }
	setmetatable(self, Timer)

	self._startTime = GetGameTimer()
	if startTime then
		self._startTime = self._startTime + startTime
	end

	return self
end

function Timer:elapsed()
	return GetGameTimer() - self._startTime
end

function Timer:restart()
	local elapsedTime = self:elapsed()
	self._startTime = GetGameTimer()
	return elapsedTime
end

function Gui.DrawBar(title, text, barPosition, color, isPlayerText, isMonospace)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	HideHudComponentThisFrame(6) -- VEHICLE_NAME
	HideHudComponentThisFrame(7) -- AREA_NAME
	HideHudComponentThisFrame(8) -- VEHICLE_CLASS
	HideHudComponentThisFrame(9) -- STREET_NAME

	local x = SafeZone.Right() - _barWidth / 2

	local y = SafeZone.Bottom() - (barPosition - 2) * _barHeight
	if Prompt.IsDisplaying() or not Player.Settings.disableTips then
		y = y - 0.05
	end

	local color = color or Color.WHITE
	local font = isPlayerText and 4 or 0
	local scale = isPlayerText and 0.5 or 0.3
	local margin = isPlayerText and 0.015 or 0.007

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	Gui.SetTextParams(font, color, scale, isPlayerText, false, false)
	Gui.DrawText(title, { x = SafeZone.Right() - _barWidth / 2, y = y - margin }, SafeZone.Size() - _barWidth / 2)
	Gui.SetTextParams(isMonospace and 5 or 0, color, 0.5, false, false, false)
	Gui.DrawText(text, { x = SafeZone.Right() - 0.00285, y = y - 0.0175 }, _barWidth / 2)
end

function Gui.DrawBarBestScore(title, text, barPosition, color, isPlayerText, isMonospace)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	HideHudComponentThisFrame(6) -- VEHICLE_NAME
	HideHudComponentThisFrame(7) -- AREA_NAME
	HideHudComponentThisFrame(8) -- VEHICLE_CLASS
	HideHudComponentThisFrame(9) -- STREET_NAME

	local x = SafeZone.Right() - _barWidth / 2

	local y = SafeZone.Bottom() - (barPosition + 0.5) * _barHeight

	local color = color or Color.WHITE
	local font = isPlayerText and 4 or 0
	local scale = isPlayerText and 0.5 or 0.3
	local margin = isPlayerText and 0.015 or 0.007

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	Gui.SetTextParams(font, color, scale, isPlayerText, false, false)
	Gui.DrawText(title, { x = SafeZone.Right() - _barWidth / 2, y = y - margin }, SafeZone.Size() - _barWidth / 2)
	Gui.SetTextParams(isMonospace and 5 or 0, color, 0.5, false, false, false)
	Gui.DrawText(text, { x = SafeZone.Right() - 0.00285, y = y - 0.0175 }, _barWidth / 2)
end

function Gui.DrawBarScore(title, text, barPosition, color, isPlayerText, isMonospace)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	HideHudComponentThisFrame(6) -- VEHICLE_NAME
	HideHudComponentThisFrame(7) -- AREA_NAME
	HideHudComponentThisFrame(8) -- VEHICLE_CLASS
	HideHudComponentThisFrame(9) -- STREET_NAME

	local x = SafeZone.Right() - _barWidth / 2

	local y = SafeZone.Bottom() - (barPosition - 2) * _barHeight
	if Prompt.IsDisplaying() or not Player.Settings.disableTips then
		y = y - 0.05
	end

	local color = color or Color.WHITE
	local font = isPlayerText and 4 or 0
	local scale = isPlayerText and 0.5 or 0.3
	local margin = isPlayerText and 0.015 or 0.007

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	Gui.SetTextParams(font, color, scale, isPlayerText, false, false)
	Gui.DrawText(title, { x = SafeZone.Right() - _barWidth / 2, y = y - margin }, SafeZone.Size() - _barWidth / 2)
	Gui.SetTextParams(isMonospace and 5 or 0, color, 0.5, false, false, false)
	Gui.DrawText(text, { x = SafeZone.Right() - 0.00285, y = y - 0.0175 }, _barWidth / 2)
end

function Gui.DrawTimerBar(text, ms, barPosition, isPlayerText, color, highAccuracy)
	if ms < 0 then
		return
	end

	if not color then
		color = ms <= 10000 and Color.RED or Color.WHITE
	end

	Gui.DrawBar(text, string.from_ms(ms, highAccuracy), barPosition, color, isPlayerText, true)
end

function Gui.DrawProgressBar(title, progress, barPosition, color)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	local x = SafeZone.Right() - _barWidth / 2

	local y = SafeZone.Bottom() - (barPosition - 2) * _barHeight
	if Prompt.IsDisplaying() or not Player.Settings.disableTips then
		y = y - 0.05
	end

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	Gui.SetTextParams(0, Color.WHITE, 0.3, false, false, false)
	Gui.DrawText(title, { x = SafeZone.Right() - _barWidth / 2, y = y - 0.011 }, SafeZone.Size() - _barWidth / 2)

	local color = color or { r = 255, g = 255, b = 255 }
	local progressX = x + _barWidth / 2 - _barProgressWidth / 2 - 0.00285 * 2
	DrawRect(progressX, y, _barProgressWidth, _barProgressHeight, color.r, color.g, color.b, 96)

	local progress = math.max(0.0, math.min(1.0, progress))
	local progressWidth = _barProgressWidth * progress
	DrawRect(progressX - (_barProgressWidth - progressWidth) / 2, y, progressWidth, _barProgressHeight, color.r, color.g, color.b, 255)
end

Color = { }
Color.__index = Color

Color.BLIP_WHITE = 0
Color.BLIP_RED = 1
Color.BLIP_GREEN = 2
Color.BLIP_BLUE = 3
Color.BLIP_YELLOW = 5
Color.BLIP_ORANGE = 17
Color.BLIP_PURPLE = 19
Color.BLIP_GREY = 20
Color.BLIP_BROWN = 21
Color.BLIP_PINK = 23
Color.BLIP_LIME = 24
Color.BLIP_LIGHT_BLUE = 26
Color.BLIP_LIGHT_RED = 35
Color.BLIP_LIGHT_GREY = 45
Color.BLIP_DARK_GREEN = 52
Color.BLIP_DARK_BLUE = 54

local _blipColors = {
	{ r = 254, g = 254, b = 254, a = 255 },
	{ r = 224, g = 50, b = 50, a = 255 },
	{ r = 114, g = 204, b = 114, a = 255 },
	{ r = 93, g = 182, b = 229, a = 255 },
	{ r = 240, g = 240, b = 240, a = 255 },
	{ r = 240, g = 200, b = 80, a = 255 },
	{ r = 194, g = 80, b = 80, a = 255 },
	{ r = 156, g = 110, b = 175, a = 255 },
	{ r = 255, g = 123, b = 196, a = 255 },
	{ r = 247, g = 159, b = 123, a = 255 },
	{ r = 178, g = 144, b = 132, a = 255 },
	{ r = 141, g = 206, b = 167, a = 255 },
	{ r = 113, g = 169, b = 175, a = 255 },
	{ r = 211, g = 209, b = 231, a = 255 },
	{ r = 144, g = 127, b = 153, a = 255 },
	{ r = 106, g = 196, b = 191, a = 255 },
	{ r = 214, g = 196, b = 153, a = 255 },
	{ r = 234, g = 142, b = 80, a = 255 },
	{ r = 152, g = 203, b = 234, a = 255 },
	{ r = 178, g = 98, b = 135, a = 255 },
	{ r = 144, g = 142, b = 122, a = 255 },
	{ r = 166, g = 117, b = 94, a = 255 },
	{ r = 175, g = 168, b = 168, a = 255 },
	{ r = 232, g = 142, b = 155, a = 255 },
	{ r = 187, g = 214, b = 91, a = 255 },
	{ r = 12, g = 123, b = 86, a = 255 },
	{ r = 123, g = 196, b = 255, a = 255 },
	{ r = 171, g = 60, b = 230, a = 255 },
	{ r = 206, g = 169, b = 13, a = 255 },
	{ r = 71, g = 99, b = 173, a = 255 },
	{ r = 42, g = 166, b = 185, a = 255 },
	{ r = 186, g = 157, b = 125, a = 255 },
	{ r = 201, g = 225, b = 255, a = 255 },
	{ r = 240, g = 240, b = 150, a = 255 },
	[46] = { r = 240, g = 240, b = 240, a = 255 }, -- Lazy bitch
	[53] = { r = 66, g = 109, b = 66, a = 255 }, -- Lazy bitch
	[55] = { r = 57, g = 100, b = 121, a = 255 }, -- Lazy bitch
}

local _colorPalette = {
	{ r = 8, g = 8, b = 8 },
	{ r = 15, g = 15, b = 15 },
	{ r = 28, g = 30, b = 33 },
	{ r = 41, g = 44, b = 46 },
	{ r = 90, g = 94, b = 102 },
	{ r = 119, g = 124, b = 135 },
	{ r = 81, g = 84, b = 89 },
	{ r = 50, g = 59, b = 71 },
	{ r = 51, g = 51, b = 51 },
	{ r = 31, g = 34, b = 38 },
	{ r = 35, g = 41, b = 46 },
	{ r = 18, g = 17, b = 16 },
	{ r = 5, g = 5, b = 5 },
	{ r = 18, g = 18, b = 18 },
	{ r = 47, g = 50, b = 51 },
	{ r = 8, g = 8, b = 8 },
	{ r = 18, g = 18, b = 18 },
	{ r = 32, g = 34, b = 36 },
	{ r = 87, g = 89, b = 97 },
	{ r = 35, g = 41, b = 46 },
	{ r = 50, g = 59, b = 71 },
	{ r = 15, g = 16, b = 18 },
	{ r = 33, g = 33, b = 33 },
	{ r = 91, g = 93, b = 94 },
	{ r = 136, g = 138, b = 153 },
	{ r = 105, g = 113, b = 135 },
	{ r = 59, g = 70, b = 84 },
	{ r = 105, g = 0, b = 0 },
	{ r = 138, g = 11, b = 0 },
	{ r = 107, g = 0, b = 0 },
	{ r = 97, g = 16, b = 9 },
	{ r = 74, g = 10, b = 10 },
	{ r = 71, g = 14, b = 14 },
	{ r = 56, g = 12, b = 0 },
	{ r = 38, g = 3, b = 11 },
	{ r = 99, g = 0, b = 18 },
	{ r = 128, g = 40, b = 0 },
	{ r = 110, g = 79, b = 45 },
	{ r = 189, g = 72, b = 0 },
	{ r = 120, g = 0, b = 0 },
	{ r = 54, g = 0, b = 0 },
	{ r = 171, g = 63, b = 0 },
	{ r = 222, g = 126, b = 0 },
	{ r = 82, g = 0, b = 0 },
	{ r = 140, g = 4, b = 4 },
	{ r = 74, g = 16, b = 0 },
	{ r = 89, g = 37, b = 37 },
	{ r = 117, g = 66, b = 49 },
	{ r = 33, g = 8, b = 4 },
	{ r = 0, g = 18, b = 7 },
	{ r = 0, g = 26, b = 11 },
	{ r = 0, g = 33, b = 30 },
	{ r = 31, g = 38, b = 30 },
	{ r = 0, g = 56, b = 5 },
	{ r = 11, g = 65, b = 69 },
	{ r = 65, g = 133, b = 3 },
	{ r = 15, g = 31, b = 21 },
	{ r = 2, g = 54, b = 19 },
	{ r = 22, g = 36, b = 25 },
	{ r = 42, g = 54, b = 37 },
	{ r = 69, g = 92, b = 86 },
	{ r = 0, g = 13, b = 20 },
	{ r = 0, g = 16, b = 41 },
	{ r = 28, g = 47, b = 79 },
	{ r = 0, g = 27, b = 87 },
	{ r = 59, g = 78, b = 120 },
	{ r = 39, g = 45, b = 59 },
	{ r = 149, g = 178, b = 219 },
	{ r = 62, g = 98, b = 122 },
	{ r = 28, g = 49, b = 64 },
	{ r = 0, g = 85, b = 196 },
	{ r = 26, g = 24, b = 46 },
	{ r = 22, g = 22, b = 41 },
	{ r = 14, g = 49, b = 109 },
	{ r = 57, g = 90, b = 131 },
	{ r = 9, g = 20, b = 46 },
	{ r = 15, g = 16, b = 33 },
	{ r = 21, g = 42, b = 82 },
	{ r = 50, g = 70, b = 84 },
	{ r = 21, g = 37, b = 99 },
	{ r = 34, g = 59, b = 161 },
	{ r = 31, g = 31, b = 161 },
	{ r = 3, g = 14, b = 46 },
	{ r = 15, g = 30, b = 115 },
	{ r = 0, g = 28, b = 50 },
	{ r = 42, g = 55, b = 84 },
	{ r = 48, g = 60, b = 94 },
	{ r = 59, g = 103, b = 150 },
	{ r = 245, g = 137, b = 15 },
	{ r = 217, g = 166, b = 0 },
	{ r = 74, g = 52, b = 27 },
	{ r = 162, g = 168, b = 39 },
	{ r = 86, g = 143, b = 0 },
	{ r = 87, g = 81, b = 75 },
	{ r = 41, g = 27, b = 6 },
	{ r = 38, g = 33, b = 23 },
	{ r = 18, g = 13, b = 7 },
	{ r = 51, g = 33, b = 17 },
	{ r = 61, g = 48, b = 35 },
	{ r = 94, g = 83, b = 67 },
	{ r = 55, g = 56, b = 43 },
	{ r = 34, g = 25, b = 24 },
	{ r = 87, g = 80, b = 54 },
	{ r = 36, g = 19, b = 9 },
	{ r = 59, g = 23, b = 0 },
	{ r = 110, g = 98, b = 70 },
	{ r = 153, g = 141, b = 115 },
	{ r = 207, g = 192, b = 165 },
	{ r = 31, g = 23, b = 9 },
	{ r = 61, g = 49, b = 29 },
	{ r = 102, g = 88, b = 71 },
	{ r = 240, g = 240, b = 240 },
	{ r = 179, g = 185, b = 201 },
	{ r = 97, g = 95, b = 85 },
	{ r = 36, g = 30, b = 26 },
	{ r = 23, g = 20, b = 19 },
	{ r = 59, g = 55, b = 47 },
	{ r = 59, g = 64, b = 69 },
	{ r = 26, g = 30, b = 33 },
	{ r = 94, g = 100, b = 107 },
	{ r = 0, g = 0, b = 0 },
	{ r = 176, g = 176, b = 176 },
	{ r = 153, g = 153, b = 153 },
	{ r = 181, g = 101, b = 25 },
	{ r = 196, g = 92, b = 51 },
	{ r = 71, g = 120, b = 60 },
	{ r = 186, g = 132, b = 37 },
	{ r = 42, g = 119, b = 161 },
	{ r = 36, g = 48, b = 34 },
	{ r = 107, g = 95, b = 84 },
	{ r = 201, g = 110, b = 52 },
	{ r = 217, g = 217, b = 217 },
	{ r = 240, g = 240, b = 240 },
	{ r = 63, g = 66, b = 40 },
	{ r = 255, g = 255, b = 255 },
	{ r = 176, g = 18, b = 89 },
	{ r = 246, g = 151, b = 153 },
	{ r = 143, g = 47, b = 85 },
	{ r = 194, g = 102, b = 16 },
	{ r = 105, g = 189, b = 69 },
	{ r = 0, g = 174, b = 239 },
	{ r = 0, g = 1, b = 8 },
	{ r = 5, g = 0, b = 8 },
	{ r = 8, g = 0, b = 0 },
	{ r = 86, g = 87, b = 81 },
	{ r = 50, g = 6, b = 66 },
	{ r = 5, g = 0, b = 8 },
	{ r = 8, g = 8, b = 8 },
	{ r = 50, g = 6, b = 66 },
	{ r = 5, g = 0, b = 8 },
	{ r = 107, g = 11, b = 0 },
	{ r = 18, g = 23, b = 16 },
	{ r = 50, g = 51, b = 37 },
	{ r = 59, g = 53, b = 45 },
	{ r = 112, g = 102, b = 86 },
	{ r = 43, g = 48, b = 43 },
	{ r = 65, g = 67, b = 71 },
	{ r = 102, g = 144, b = 181 },
	{ r = 71, g = 57, b = 27 },
	{ r = 71, g = 57, b = 27 },
	{ r = 255, g = 216, b = 89 },
}

local function blipToHudColor(blipColor)
	return _blipColors[blipColor + 1]
end

function Color.GetRandomRgb()
	return table.random(_colorPalette)
end

function Color.UnpackRgb(color)
	return table.unpack({ color.r, color.g, color.b })
end

Color.WHITE = blipToHudColor(Color.BLIP_WHITE)
Color.RED = blipToHudColor(Color.BLIP_RED)
Color.GREEN = blipToHudColor(Color.BLIP_GREEN)
Color.BLUE = blipToHudColor(Color.BLIP_BLUE)
Color.YELLOW = blipToHudColor(Color.BLIP_YELLOW)
Color.ORANGE = blipToHudColor(Color.BLIP_ORANGE)
Color.PURPLE = blipToHudColor(Color.BLIP_PURPLE)
Color.GREY = blipToHudColor(Color.BLIP_GREY)
Color.BROWN = blipToHudColor(Color.BLIP_BROWN)
Color.PINK = blipToHudColor(Color.BLIP_PINK)
Color.LIME = blipToHudColor(Color.BLIP_LIME)
Color.LIGHT_BLUE = blipToHudColor(Color.BLIP_LIGHT_BLUE)
Color.LIGHT_GREY = blipToHudColor(Color.BLIP_LIGHT_GREY)
Color.DARK_GREEN = blipToHudColor(Color.BLIP_DARK_GREEN)
Color.DARK_BLUE = blipToHudColor(Color.BLIP_DARK_BLUE)