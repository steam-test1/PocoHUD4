local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
ROOT.import('Layout/Main/Const', ENV)
local Hook = ROOT.import('Hook')
local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

-- GLOBALS: Global, Button, Tabs

local function drawJukebox(tab)
	-- revised old code I made. also thx to PierreDjays for basic idea.
	local music
	music = {
		play = function(num)
			music.stop()
			Global.music_manager.source:set_switch( 'music_randomizer', num )
			music.set(managers.music._last or 'setup')
		end,
		set = function(mode)
			managers.music._last = type(mode)~='table' and mode
			managers.music._skip_play = nil
			managers.music:post_event( type(mode)=='table' and mode[1] or 'music_heist_'..mode )
		end,
		stop = function()
			managers.music:stop()
		end
	}
	Button:new(tab,{
		x = 380, y = 40, w = 200,h=40,
		text=L('_tab_juke_stop')
	}):on('click',function(b) if b==0 then music.stop() end end)

	Button:new(tab,{
		x = 380, y = 90, w = 200,h=40,
		text=L('_tab_juke_stealth')
	}):on('click',function(b) if b==0 then music.set('setup') end end)

	Button:new(tab,{
		onClick = function(self)
			music.set('control')
		end,
		x = 380, y = 140, w = 200,h=40,
		text=L('_tab_juke_control')
	}):on('click',function(b) if b==0 then music.set('control') end end)

	Button:new(tab,{
		onClick = function(self)
			music.set('anticipation')
		end,
		x = 380, y = 190, w = 200,h=40,
		text=L('_tab_juke_anticipation')
	}):on('click',function(b) if b==0 then music.set('anticipation') end end)

	Button:new(tab,{
		onClick = function(self)
			music.set('assault')
		end,
		x = 380, y = 240, w = 200,h=40,
		text=L('_tab_juke_assault')
	}):on('click',function(b) if b==0 then music.set('assault') end end)

	local __, lbl = _.l({pnl = tab.pnl, x=10, y= tab.pnl:h() - 25, font_size = 20, color = cl.Gray},L('_tab_juke_shuffle_tip'),true)


	local _addItems = function(oTab,inGame)
		local y = 10;
		local track_list,track_locked
		if inGame then
			track_list,track_locked = managers.music:jukebox_music_tracks()
		else
			track_list,track_locked = managers.music:jukebox_menu_tracks()
		end
		for __, track_name in pairs(track_list or {}) do
			local text = managers.localization:text((inGame and 'menu_jukebox_' or 'menu_jukebox_screen_')..track_name)
			local listed = inGame and managers.music:playlist_contains(track_name) or managers.music:playlist_menu_contains(track_name)
			local locked = track_locked[track_name]
			local hint = locked and managers.localization:text('menu_jukebox_locked_' .. locked) or nil
			Button:new(oTab,{
				x = 10, y = y, w = 200,h=30,
				text={' '..text,locked and cl.Red or listed and cl.White or cl.Gray},
				align='left',
				hintText = hint
			}):on('click',function(b) if b==0 then
				if not locked then
					music[inGame and 'play' or 'set'](inGame and track_name or {track_name})
				end
			end end)
			y = y + 35
		end
		oTab:autoSize()
	end

	local oTabs = Tabs:new(tab,{name = 'jukeboxes',x = 10, y = 10, w = 370, tabW = 100, fontSize = 18, h = tab.pnl:height()-30, pTab = tab})
	-- [1] Heist musics
	_addItems(oTabs:addTab(L('_tab_juke_heist')), true)
	-- [2] Menu musics
	_addItems(oTabs:addTab(L('_tab_juke_menu')), false)



end

-- GLOBALS: Icon, Label
export = function ( Tabs )

	Tabs:addTab('juke',L('_tab_jukebox'), drawJukebox)
end
PocoHud4.moduleEnd()
