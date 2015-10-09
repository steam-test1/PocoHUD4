local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
ROOT.import('Layout/Main/Const', ENV)
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

local MainLayout = {
	drawAboutTabs = ROOT.import('Layout/Main/About'),
	drawOptionTabs = ROOT.import('Layout/Main/Options'),
	drawStatsTabs = ROOT.import('Layout/Main/Stats'),
	drawJukebox = ROOT.import('Layout/Main/Jukebox')
}

local w, h, m = 800, 600, 10
local cbW = 150
local UNKNOWN = 'UNKNOWN'

function MainLayout.drawRoot( UI )
	local FullScreenElem = ENV.BaseElem:new(UI, {x=0,y=0,w=UI.pnl:w(),h=UI.pnl:h()})
	local RootElem = ENV.BaseElem:new(FullScreenElem, {x=0,y=0,w=w,h=h})
	local RootHandle = ENV.Handle:new(RootElem, {color=cl.White,fontSize=20,text={'PocoHud4',{_.s(' (',ROOT._INSTANCE,')'), cl.Yellow}}, x=0,w=w,h=25})
	RootHandle.pnl:bitmap{
		name = 'blur',
		texture = 'guis/textures/test_blur_df',
		render_template = 'VertexColorTexturedBlur3D',
		layer = -1, w=w, h=25
	}
	ENV.Button:new(RootHandle, {color=cl.Red, hColor=cl.OrangeRed,text='X',x=w-25,w=25,h=25,y=0,noBorder=1})
		:on('press',function(b) if b==0 then ROOT:Menu() end end)
		:on('move',function() return true, false, 'link' end)

	local MainBox = ENV.Box:new(RootElem, {x=0,y=30,w=w,h=h - 30 - 50,scroll=false,sides={1,1,1,1}})
	MainBox.pnl:gradient{
		layer = -1,
		gradient_points = {
			0,
			cl.Black:with_alpha(0.1),
			1,
			cl.Black:with_alpha(0.5)
		},
		orientation = 'vertical',
		h = MainBox.pnl:h()
	}
	local MainTab = ENV.Tabs:new(MainBox, {x=0,y=0, h=MainBox:h(), w = MainBox:w() })

	local BottomBox = ENV.Box:new(RootElem, {x=0,y=h-45,w=w,h=45,scroll=false,bgColor=cl.Black:with_alpha(0.2), sides={2,2,1,1}})

	MainTab:addSection('Info')
	MainLayout.drawAboutTabs(MainTab)


	MainTab:addSection('Config')
	MainLayout.drawOptionTabs(MainTab, BottomBox)

	MainTab:addSection('Stats')
	MainLayout.drawStatsTabs(MainTab)

	MainTab:addSection('Tools')
	MainLayout.drawJukebox(MainTab)

	RootElem.pnl:set_world_center(FullScreenElem.pnl:world_center())

	return FullScreenElem
end

export = MainLayout.drawRoot
PocoHud4.moduleEnd()
