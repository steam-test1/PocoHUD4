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

	local __, lbl = _.l({pnl = tab.pnl, x=10, y= tab.pnl:h() - 25, font_size = 15, color = cl.Silver},L('_tab_juke_shuffle_tip'),true)

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
			local btn = Button:new(oTab,{
				x = 10, y = y, w = 215,h=25,
				text={' '..text,locked and cl.Red or listed and cl.White or cl.Gray},
				align='left',
				hintText = hint
			}):on('play',function()
				if not locked then
					music[inGame and 'play' or 'set'](inGame and track_name or {track_name})
					return true
				end
			end)
			btn:on('click',function(b) if b==0 then
				return btn:trigger('play')
			end end)
			y = y + 27
		end
		oTab:autoSize()
	end

	local oTabs = Tabs:new(tab,{name = 'jukeboxes',x = 10, y = 10, w = 370, tabW = 100, fontSize = 18, h = tab.pnl:height()-25, pTab = tab, noScroll=true})
	-- [1] Heist musics
	_addItems(oTabs:addTab(L('_tab_juke_heist')), true)
	-- [2] Menu musics
	_addItems(oTabs:addTab(L('_tab_juke_menu')), false)
	oTabs:goto(L('_tab_juke_heist'))

	Button:new(tab,{
		x = 380, y = 40, w = 200,h=40,
		text=L('_tab_juke_stop')
	}):on('click',function(b) if b==0 then music.stop() end end)

	Button:new(tab,{
		x = 380, y = 90, w = 200,h=40,
		text=L('_tab_juke_stealth')
	}):on('click',function(b) if b==0 then music.set('setup') end end)

	Button:new(tab,{
		x = 380, y = 140, w = 200,h=40,
		text=L('_tab_juke_control')
	}):on('click',function(b) if b==0 then music.set('control') end end)

	Button:new(tab,{
		x = 380, y = 190, w = 200,h=40,
		text=L('_tab_juke_anticipation')
	}):on('click',function(b) if b==0 then music.set('anticipation') end end)

	Button:new(tab,{
		x = 380, y = 240, w = 200,h=40,
		text=L('_tab_juke_assault')
	}):on('click',function(b) if b==0 then music.set('assault') end end)

	Button:new(tab,{
		x = 380, y = 290, w = 200,h=40,
		text=L('_tab_juke_random')
	}):on('click',function(b) if b==0 then
		-- Pick a random button from a visible tab
		if oTabs.currentTab then
			local elems = oTabs.currentTab.elems
			local foundElems = {}
			for k,elem in ipairs(elems) do
				if elem.name == 'Button' then
					table.insert(foundElems,elem)
				end
			end
			if #foundElems == 0 then
				return true, 'menu_error'
			else
				local foundElem = foundElems[math.random(#foundElems)]
				foundElem:trigger('play')
				return true, 'count_1_finished'
			end
		end
	end end)

	local cBtn = Button:new(tab,{
		x = 380, y = 340, w = 200,h=100,
		text='-', noBorder=true, color=cl.White, hColor=cl.White
	})
	cBtn:on('slowThread',function()
		-- cBtn.lbl:set_text( _.s(
		-- 	ROOT.import('Modules/Music').currentMusic,
		-- 	' < ',
		-- 	Global.music_manager.current_track or managers.music._current_track,
		-- 	' > ',
		-- 	Global.music_manager.current_event )
		-- )
		local currentMusic = ROOT.import('Modules/Music').currentMusic
		_.l(cBtn.lbl,
			currentMusic and {{O('root','showMusicTitlePrefix')..'\n',cl.Tan},{currentMusic}} or {{'UNKNOWN',cl.Silver}}
		)
	end)

	tab:autoSize()
end

-- GLOBALS: Icon, Label
export = function ( Tabs )

	Tabs:addTab('juke',L('_tab_jukebox'), drawJukebox)
end
PocoHud4.moduleEnd()
