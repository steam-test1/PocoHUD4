local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local BaseElem = ROOT.import('Components/BaseElem')
local Box = ROOT.import('Components/Box')
local Tabs = ROOT.import('Components/Tabs')
local Handle = ROOT.import('Components/Handle')
local Button = ROOT.import('Components/Button')
local ListBox = ROOT.import('Components/ListBox')

local Value = ROOT.import('Components/Value')

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

local MainLayout = {}
local w, h, m = 800, 600, 10
local cbW = 150
local UNKNOWN = 'UNKNOWN'

function MainLayout.drawAboutTabs( Tabs )
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

	Button:new(currBox, {x=5,y=5,w=200,h=50,text=versionText,fontSize=20})
		:on('click',openCbk('http://steamcommunity.com/groups/pocomods') )
	Button:new(currBox, {x=210,y=5,w=100,h=50,text='@Zenyr',fontSize=20,color=cl.OrangeRed,hColor=cl.Orange})
		:on('click',openCbk('https://twitter.com/zenyr') )

	Button:new(currBox, {x=5,y=00+math.random()*100,text='1234'}):on('click',function() _('Clicked 1234') end)
	currBox:autoSize()
	Tabs:goto('About')
end

function MainLayout.drawOptionTabs( Tabs )
	local prioritize = function(a, b)
		return tostring(a) > tostring(b)
	end
	local m = 10
	local objs = {}
	for category, objects in _.p(O.scheme, prioritize) do
		local box = Tabs:addTab(L('_tab_'..category))
		local x, y = m, m
		if objects[1] then
			local mergedText, lbl = _.l(
				_.m({	align = 'left', fontSize=20}, { pnl = box.pnl, x = x, y=y}),
				L(objects[1]), true
			)
			y = math.round( y + lbl:h() )
			-- Button:new(box, {x=5,y=5,w=500,h=50,text=L(objects[1]),fontSize=20})

		end

		local _y, m, half = y+5, 5
		local x,y = function()
			return half and 300 or 5
		end, function(h)
			_y = _y + h + m
			return _y - h - m
		end
		local fontSize = 16
		local c = 0
		local _sy,_ty = _y
		for name,values in _.p(objects,function(a,b)
			local t1, t2 = O:_type(category,a),O:_type(category,b)
			local s1, s2 = O:_sort(category,a) or 99,O:_sort(category,b) or 99
			if a == 'enable' then
				return true
			elseif b == 'enable' then
				return  false
			elseif s1 ~= s2 and type(s1) == type(s2) then
				return s1 < s2
			elseif t1 == 'bool' and t2 ~= 'bool' then
				return true
			elseif t1 ~= 'bool' and t2 == 'bool' then
				return false
			end
			return tostring(a) < tostring(b)
		end) do
			if type(name) ~= 'number' then
				c = c + 1
				if not half and c > table.size(objects) / 2 then
					half = true
					_ty = _y
					_y = _sy
				end
				local type = O:_type(category,name)
				local value = O:get(category,name,true)
				local hint = O:_hint(category,name)
				if hint:find('EN,') then
					_(_.i( L(hint), {depth=2}))
				end
				hint = hint and L(hint)
				local tName = L('_opt_'..name)

				if type == 'bool' then
					objs[#objs+1] = {ROOT.import('Components/ValueBoolean'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName , value = value ,
						hintText = hint
					}),category,name}
				elseif type == 'num' then
					local range = O:_range(category,name) or {}
					local vanity = O:_vanity(category,name)
					if vanity then
						vanity = L(vanity):split(',')
					end
					local step = O:_step(category,name)
					objs[#objs+1] = {ROOT.import('Components/ValueNumber'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name, step = step,
						fontSize = fontSize, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'color' then
					objs[#objs+1] = {ROOT.import('Components/ValueColor'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'key' then
					objs[#objs+1] = {ROOT.import('Components/ValueKey'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value,
						hintText = hint
					}),category,name}
				else
					objs[#objs+1] = {Value:new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName , value = value ,
						hintText = hint
					}),category,name}
				end
				--[==[


				elseif type == 'num' then
					local range = O:_range(category,name) or {}
					local vanity = O:_vanity(category,name)
					if vanity then
						vanity = PocoHud3Class.L(vanity):split(',')
					end
					local step = O:_step(category,name)

					objs[#objs+1] = {PocoUINumValue:new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name, step = step,
						fontSize = fontSize, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'string' then
					local selection = O:_vanity(category,name)

					objs[#objs+1] = {PocoUIStringValue:new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value, selection = selection,
						hintText = hint
					}),category,name}
				else
					PocoUIButton:new(box,{
						hintText = L('_msg_not_implemented'),
						x = x()+10, y = y(30), w=290, h=30,
						text=_.s(name,type,value)
					})
				end ]==]
			end
		end
		box:autoSize()
	end
end

function MainLayout.drawRoot( UI )
	local FullScreenElem = BaseElem:new(UI, {x=0,y=0,w=UI.pnl:w(),h=UI.pnl:h()})
	local RootElem = BaseElem:new(FullScreenElem, {x=0,y=0,w=w,h=h})
	local RootHandle = Handle:new(RootElem, {color=cl.White,fontSize=20,text='PocoHud4', x=0,w=w,h=25})
	RootHandle.pnl:bitmap{
		name = 'blur',
		texture = 'guis/textures/test_blur_df',
		render_template = 'VertexColorTexturedBlur3D',
		layer = -1, w=w, h=25
	}
	Button:new(RootHandle, {color=cl.Red, hColor=cl.OrangeRed,text='X',x=w-25,w=25,h=25,y=0,noBorder=1})
		:on('click',function(b) if b==0 then ROOT:Menu() end end)
		:on('move',function() return true, false, 'link' end)

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
