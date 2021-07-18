--@i18n
config = setmetatable({}, config)
config.__index = config

local store = {}
local language = {}
avalLangs = {}

function config.setup(i)
	if(i ~= nil)then
		language = i
	end
end

function config.exportData()
	local result = store
	return result
end

function config.getlanguage(i,s)
	table.insert(avalLangs, i)
	store[i] = s
end

function config.setLanguage(i)
	language = i
end

function config.translate(key)
	local result = ""
	if(store == nil) then
		result = "no translation available !"
	else
		result = store[language][key]
		if(result == nil) then
			result = "key not found !"
		end
	end
	
	return result
end