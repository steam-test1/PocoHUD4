local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local BaseElem = ROOT.import('Components/BaseElem')
local Box = ROOT.import('Components/Box')
local Tabs = ROOT.import('Components/Tabs')
local Handle = ROOT.import('Components/Handle')
local Button = ROOT.import('Components/Button')
local ListBox = ROOT.import('Components/ListBox')

local MainLayout = {}
local w, h, m = 800, 600, 10
local cbW = 150

function MainLayout.drawAboutTabs( Tabs )
	local currBox = Tabs:addTab('About')
	local versionObj = {}
	local f,err = io.open(ROOT.currModPath.. 'package.json', 'r')
	local result = false
	if f then
		local t = f:read('*all')
		local o = _.j:decode(t)
		if type(o) == 'table' then
			versionObj = o
		end
		f:close()
	end
	_(_.i( versionObj))
	Button:new(currBox, {x=5,y=5+math.random()*100,text=versionObj.version or 'UNKNOWN'}):on('click',function() _('Clicked 1234') end)
	Button:new(currBox, {x=5,y=800+math.random()*100,text='1234'}):on('click',function() _('Clicked 1234') end)
	currBox:autoSize()
	Tabs:goto('About')
end

function MainLayout.drawOptionTabs( Tabs )

end

function MainLayout.drawRoot( UI )
	local FullScreenElem = BaseElem:new(UI, {x=0,y=0,w=UI.pnl:w(),h=UI.pnl:h()})
	local RootElem = BaseElem:new(FullScreenElem, {x=0,y=0,w=w,h=h})
		:on('DblClick',function(b)
			if b == 1 then
				ROOT:Menu()
			end
		end)
	local RootHandle = Handle:new(RootElem, {color=cl.White,fontSize=20,text='PocoHud4', x=0,w=w,h=25})

	local MainBox = Box:new(RootElem, {x=0,y=30,w=w,h=h - 30 - 50,scroll=false,bgColor=cl.Black:with_alpha(0.2),sides={1,1,1,1}})

	local MainTab = Tabs:new(MainBox, {x=0,y=0, h=MainBox:h(), w = MainBox:w() })

	MainTab:addSection('Info')
	MainLayout.drawAboutTabs(MainTab)

	MainTab:addSection('Config')
	MainLayout.drawOptionTabs(MainTab)

	local BottomBox = Box:new(RootElem, {x=0,y=h-45,w=w,h=45,scroll=false,bgColor=cl.Black:with_alpha(0.2), sides={2,2,1,1}})

	RootElem.pnl:set_world_center(FullScreenElem.pnl:world_center())

	return FullScreenElem
end

export = MainLayout.drawRoot
PocoHud4.moduleEnd()
