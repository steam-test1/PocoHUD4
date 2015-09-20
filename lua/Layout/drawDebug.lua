local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local Elem = ROOT.import('Components/Elem')
local Box = ROOT.import('Components/Box')
local Button = ROOT.import('Components/Button')
local ListBox = ROOT.import('Components/ListBox')

local function drawFunc (UI)
	local TopBox = Box:new(UI, {x=100,y=100+math.random(0,100),w=600,h=200,scroll=true,bgColor=cl.Black:with_alpha(0.5)})
	TopBox:on('DblClick',function(b)
		if b == 1 then
			ROOT:Menu()
		end
	end)
	--ListBox:new(TopBox,{x=100,y=10,scroll=true,items={{'123',function() _(123) end}, {'456',function() _(456) end}},noBorder=true})
	local cd = currModFolder
	Button:new(TopBox, {text=cd, x=200,w=400})

	local files = {}
	--[=[]=] for dir in io.popen([[dir /b /ad]]):lines() do
		table.insert(files,{dir,function() _('Clicked',dir) end})
	end --]=]
	Button:new(TopBox, {
		x=10,y=10,w=60,h=60,text='OpenContext',fontSize=20,hColor=cl.Red,
		contextMenu=files
	})

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
