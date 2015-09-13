-- Menu manager
local ENV = PocoHud4.moduleBegin()
-- GLOBALS: Menu
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local L = ROOT.import('Localizer')()
local Internet = ROOT.import('Util/Internet')

local PocoUIButton = ROOT.import('Components/Button')
local PocoUIBoolean = ROOT.import('Components/Boolean')
local PocoUIColorValue = ROOT.import('Components/ColorValue')
local PocoUIKeyValue = ROOT.import('Components/KeyValue')
local PocoUINumValue = ROOT.import('Components/NumValue')
local PocoUIStringValue = ROOT.import('Components/StringValue')

local FONTLARGE = 'fonts/font_large_mf'
local PocoTabs = ROOT.import('Components/Tabs')


export = function (self, tab, REV, TAG)
	PocoUIButton:new(tab,{
		onClick = function(self)
			Internet._open('http://steamcommunity.com/groups/pocomods')
		end,
		x = 10, y = 10, w = 200,h=100,
		text={{'PocoHud4 r'},{REV,cl.Gray},{' by ',cl.White},{'Zenyr',cl.MediumTurquoise},{'\n'..TAG,cl.Silver}},
		hintText = {{L('_about_group_btn'),cl.LightSkyBlue},'\n',L('_about_hold_shift')}
	})

	local oTabs = PocoTabs:new(ROOT.ws,{name = 'abouts',x = 220, y = 10, w = tab.pnl:width()-230, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
	local oTab = oTabs:add(L('_about_recent_updates'))


	local __, rssLbl = _.l({color=cl.LightSteelBlue, alpha=0.9, font_size=25, pnl = oTab.pnl, x = 10, y = 10},L('_about_loading_rss'),true)
	local _strip = function(s)
		return s:gsub('&lt;','<'):gsub('&gt;','>'):gsub('<br>','\n'):gsub(string.char(13),''):gsub('<.->',''):gsub('&amp;','&'):gsub('&amp;','&')
	end
	local _onRSS = function (success, body, _rss)
		if not Internet then return end
		if success then
			local rss = _rss or {}
			if body then
				for title,desc,date,link in body:gmatch('<item>.-<title>(.-)</title>.-<description>(.-)</description>.-<pubDate>(.-)</pubDate>.-<guid.->(.-)</guid>') do
					local diffH = math.round((_.t()-_.t(1)) / 360)/10
					-- Based on http://stackoverflow.com/a/4600967
					local days,day,month,year,hour,min,sec=date:match('(.-), (.-) (.-) (.-) (.-):(.-):(.-) ')
					local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
					month=MON[month]
					local d = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})+diffH*3600
					local diffS = - _.t(false,d)
					if diffS < 3600*24 then
						local h = math.max(0,math.floor(diffS/3600))
						date = _.s( h==1 and L('_word_an') or h,h>1 and L('_word_hrs') or L('_word_hr'),L('_word_ago'))
					else
						local d = math.floor(diffS/3600/24)
						date = _.s( d==1 and L('_word_a') or d,d>1 and L('_word_days') or L('_word_day'),L('_word_ago'))
					end
					rss[#rss+1] = {_strip(title),_strip(desc),date,link}

				end
			end
			Internet._rss = rss
			if not alive(rssLbl) then return end
			_.l(rssLbl,' ',true)
			local y = 10
			for ind,obj in pairs(rss) do
				local title = '   '..obj[1]
				local bef,name,rev,rest=title:match('^(.-)(PocoHud[34] r)(%d-)( .-)$')
				if rev then
					title = {{bef,cl.CornFlowerBlue},{name..rev,tonumber(rev) > REV and cl.PapayaWhip or cl.DodgerBlue},{rest,cl.CornFlowerBlue}}
				else
					title = {title,cl.DeepSkyBlue}
				end
				local pos,line = 1,1
				local hintText = obj[2]:gsub( "(%s+)()(%S+)()",function( sp, b, word, e )
					if line < 8 then
						if e-pos > 60 then
							pos = b
							line = line + 1
							return "\n"..word
						end
					else
						return ''
					end
				end) .. '...'
				PocoUIButton:new(oTab,{
					onClick = function(self)
						Internet._open(obj[4])
					end,
					x = 10, y = y, w = 500, h=50,
					fontSize = 20,align = 'left',
					text=title,
					hintText = L('{'..hintText..'} \n {_about_hold_shift|DarkSeaGreen}')
				})
				local __, lbl = _.l({ color=cl.Tan, alpha=0.9, font_size=18, pnl = oTab.pnl, x = 120, y = y+25, w = 350, h=20, vertical = 'center',align='right'},obj[3])

				y = y + 60
				oTab:set_h(y)
				--_.l(lbl,obj[1]..'\n'..obj[2],true)
			end
		end
	end
	if Internet._rss then
		_onRSS(true,nil,Internet._rss)
	else
		Internet._get(nil,'http://steamcommunity.com/groups/pocomods/rss', _onRSS)
	end
	local oTab = oTabs:add(L('_about_trans_volunteers'))
	local y = 10
	local w = oTab.pnl:width()-20
	local __, lbl = _.l({ color=cl.LightSteelBlue, alpha=0.9, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_presented'),true)
	y = y + 20
	lbl:set_w(w)
	__, lbl = _.l({ color=cl.White, font_size=25, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_names'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)

	__, lbl = _.l({ color=cl.LightSteelBlue, alpha=0.9, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_special_thanks'),true)
	y = y + 20
	lbl:set_w(w)

	__, lbl = _.l({ color=cl.Silver, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_special_thanks_list'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)

	__, lbl = _.l({ color=cl.LightSteelBlue, font_size=20, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_volunteers'),true)
	y = y + lbl:h()
	lbl:set_w(w)
	oTab:set_h(y)

	__, lbl = _.l({ color=cl.Silver, font_size=18, pnl = oTab.pnl, x = 10, y = y, align='center'},L('_about_trans_fullList'),true)
	y = y + lbl:h()+20
	lbl:set_w(w)
	oTab:set_h(y)

	PocoUIButton:new(tab,{
		onClick = function(self)
			Internet._open('https://twitter.com/zenyr')
		end,
		x = 10, y = 120, w = 200,h=40,
		text={'@zenyr',cl.OrangeRed},
		hintText = L('{Not in English but feel free to ask in English,\nas long as it is not a technical problem!|DarkSeaGreen|0.5} {:)|DarkKhaki}\n{_about_hold_shift}')
	})

	PocoUIButton:new(tab,{
		onClick = function(self)
			Internet._open('http://msdn.microsoft.com/en-us/library/ie/aa358803(v=vs.85).aspx')
		end,
		x = 10, y = 170, w = 200,h=40,
		text={L('_about_colors'), cl.Silver},-- no moar fun tho
		hintText = {L('_about_colors_hint'),'\n',L('_about_hold_shift')}
	})

end

PocoHud4.moduleEnd()
