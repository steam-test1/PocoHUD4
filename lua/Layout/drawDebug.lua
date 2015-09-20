local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local Elem = ROOT.import('Compo/Elem')
local Box = ROOT.import('Compo/Box')
local Box = ROOT.import('Compo/Box')
local Button = ROOT.import('Compo/Button')
local ListBox = ROOT.import('Compo/ListBox')

local function drawFunc (UI)
	local TopBox = Box:new(UI, {x=100,y=100+math.random(0,100),w=600,h=200,scroll=true,bgColor=cl.Black:with_alpha(0.5)})


	--ListBox:new(TopBox,{x=100,y=10,scroll=true,items={{'123',function() _(123) end}, {'456',function() _(456) end}},noBorder=true})

	local a = Button:new(TopBox, {
		x=30,y=150,w=60,h=60,text='OpenContext',fontSize=20,
		contextMenu={{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end},
			{'123',function() _(123) end}, {'456',function() _(456) end}
		}
	})

	local btn = Button:new(TopBox, {x=20,y=20,w=100,h=100,text='TEST',color=cl.Red}):on('click',function(b)
		if b == 0 then
			_('Btn1~')
			return true
		end
	end)
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
