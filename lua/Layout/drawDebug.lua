local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local BaseElem = ROOT.import('Components/BaseElem')
local Box = ROOT.import('Components/Box')
local Handle = ROOT.import('Components/Handle')
local Button = ROOT.import('Components/Button')
local ListBox = ROOT.import('Components/ListBox')

local function drawFunc (UI)
	local RootElem = BaseElem:new(UI, {x=100,y=100+math.random(0,100),w=600,h=250})

	local TopBox = Box:new(RootElem, {x=0,y=30,w=600,h=200,scroll=true,bgColor=cl.Black:with_alpha(0.5)})
	TopBox:on('DblClick',function(b)
		if b == 1 then
			ROOT:Menu()
		end
	end)
	--ListBox:new(TopBox,{x=100,y=10,scroll=true,items={{'123',function() _(123) end}, {'456',function() _(456) end}},noBorder=true})
	local cd = ROOT.currModPath --debug.getinfo(6, "S").source
	Handle:new(RootElem, {text='Handle', x=20,w=100,h=30})

	local testBtn = Button:new(TopBox, {text=cd, x=200,w=300}):on('click',function() _.c('Test',now()) return true end)
	Handle:new(testBtn, {text='Handle', x=20,w=50,h=30})

	local files = {}
	local fileHandle = io.popen('dir /b /a-d')
	--[=[]=] for dir in fileHandle:lines() do
		table.insert(files,{dir,function() _('Clicked',dir) end})
	end --]=]
	Button:new(TopBox, {
		x=10,y=210,w=60,h=20,text='OpenContext',fontSize=20,hColor=cl.Red,
		contextMenu=files
	})

	--[[
	Button:new(TopBox, {
		x=10,y=1410,w=60,h=70,text='OpenContext',fontSize=20,hColor=cl.Blue,
		contextMenu=files
	})
]]
	TopBox:autoSize()

	do return TopBox end

	local a = Button:new(TopBox, {
		x=30,y=150,w=60,h=60,text='OpenContext',fontSize=20,hColor=cl.Red,
		contextMenu={{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456x',function() _(456) end}
		}
	})

	local sBox = Box:new(TopBox, {
		x=230,y=150,w=100,h=100,fontSize=20,hColor=cl.Red, scroll=1
	})

	local btn = Button:new(sBox, {x=20,y=80,w=100,h=100,text='TEST',color=cl.Red,
		contextMenu={{'123',function() _(123) end}}
		}):on('click',function(b)
		if b == 0 then
			_('Btn1~')
			return true
		end
	end)

	sBox:autoSize()

	Button:new(TopBox, {x=20,y=320,w=100,h=100,text='TEST',color=cl.Blue}):on('click',function()
		_('Btn2~')
		return true
	end)
	Button:new(TopBox, {x=20,y=520,w=100,h=100,text='TEST 3333',color=cl.White}):on('click',function()
		_('Btn3~')
		return true
	end)

	TopBox:autoSize()
	return TopBox
end

export = drawFunc;
PocoHud4.moduleEnd()
