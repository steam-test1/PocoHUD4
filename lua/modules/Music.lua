local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/base')
local MusicModule = class(ModuleBase)

-- GLOBALS: Global
function MusicModule:postInit()
	self:installHooks()
end

function MusicModule:getTrackName(name)
	local isHeistMusic = false
	for __, data in ipairs(tweak_data.music.track_list) do
		if name == data.track then
			isHeistMusic = true
			break
		end
	end
	return managers.localization:text((isHeistMusic and 'menu_jukebox_' or 'menu_jukebox_screen_')..(name or '??'))
end


function MusicModule:installHooks()
	local ignore = {
		music_heist_setup = 1,
		music_heist_anticipation = 1,
		music_heist_assault = 1,
		music_heist_control = 1
	}
	Hook(getmetatable(Global.music_manager.source))
	:footer('set_switch', function(__, tSelf,switch,track)
		if switch == 'music_randomizer' then
			self.currentMusic = self:getTrackName(track)
		end
	end)
	Hook(managers.music)
	:footer('post_event', function(__, tSelf,track)
		if not ignore[track] then
			self.currentMusic = self:getTrackName(track)
		end
	end)
end

function MusicModule:preDestroy()

end

export = MusicModule:new()

PocoHud4.moduleEnd()
