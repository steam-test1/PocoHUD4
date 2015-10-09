local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
ROOT.import('Layout/Main/Const', ENV)
local Hook = ROOT.import('Hook')

local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

-- GLOBALS: Steam
local openCbk = function( url , ...)
	return function(b)
		if b ~= 0 then return end
		if shift() then
			os.execute('start '..url)
		else
			Steam:overlay_activate('url', url)
		end
		managers.menu:post_event(not shift() and 'camera_monitor_engage' or 'trip_mine_sensor_alarm')
	end
end

local UNKNOWN = 'UNKNOWN'

export = function ( Tabs )
	local currBox = Tabs:addTab('About')
	local vO = {}
	local f,err = io.open(ROOT.currModPath.. 'package.json', 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = _.j:decode(t)
		if type(o) == 'table' then
			vO = o
		end
		f:close()
	end
	local vD = vO.versionDetail or {}
	local rev, desc = vD.gitRev or UNKNOWN, vD.gitDescribe or UNKNOWN
	local versionText = { {vO.description,cl.White}, '\n', {desc, cl.Green}, ' (r', rev, ')'	}

	ENV.Button:new(currBox, {x=5,y=5,w=200,h=50,text=versionText,fontSize=20})
		:on('click',openCbk('http://steamcommunity.com/groups/pocomods') )
	ENV.Button:new(currBox, {x=210,y=5,w=100,h=50,text='@Zenyr',fontSize=20,color=cl.OrangeRed,hColor=cl.Orange})
		:on('click',openCbk('https://twitter.com/zenyr') )

	ENV.Button:new(currBox, {x=5,y=100+math.random()*100,h=200,text=_.s(
		_.f(123.456789,2),'\n',
		_.f(123.0010,5),'\n',
		_.f(123.05000,1),'\n',
		''
	) }):on('click',function() _('Clicked 1234') end)
	currBox:autoSize()
	Tabs:goto('About')
end
PocoHud4.moduleEnd()
