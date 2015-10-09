local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
ROOT.import('Layout/Main/Const', ENV)
local Hook = ROOT.import('Hook')

local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

export = function ( Tabs, BottomBox )
	local prioritize = function(a, b)
		return tostring(a) > tostring(b)
	end
	local m = 10
	local objs = {}
	-- buttons

	ENV.Button:new(BottomBox,{
		onClick = function()
			dofile('../../PocoHud4_reload.lua')
		end,
		x = 10, y = 10, w = 400, h=30, fontSize = 20,
		text={L('_btn_apply_and_reload'),cl.SteelBlue},
		hintText = L('_desc_apply_and_reload')
	})

	ENV.Button:new(BottomBox,{
		onClick = function()
			for __,obj in pairs(objs) do
				obj[1]:val(O:get(obj[2],obj[3],true))
			end
		end,
		x = 410, y = 10, w = 200, h=30, fontSize = 18,
		text={L('_btn_discard'),cl.Gray},
		hintText = L('_desc_discard')
	})
	ENV.Button:new(BottomBox,{
		onClick = function()
			managers.menu:show_default_option_dialog({
				text =  L('_desc_reset')..'\n'..L('_desc_reset_ask'),
				callback = function()
					for __,obj in pairs(objs) do
						obj[1]:val(O:_default(obj[2],obj[3]))
					end
				end
			})
		end,
		x = 610, y = 10, w = 180, h=30, fontSize = 18,
		text={L('_btn_reset'),cl.Gray},
		hintText = L('_desc_reset')
	})

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
					objs[#objs+1] = {ROOT.import('Components/Value/Boolean'):new(box,{
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
					objs[#objs+1] = {ROOT.import('Components/Value/Number'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name, step = step,
						fontSize = fontSize, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'color' then
					objs[#objs+1] = {ROOT.import('Components/Value/Color'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'key' then
					objs[#objs+1] = {ROOT.import('Components/Value/Key'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'string' then
					local selection = O:_vanity(category,name)

					objs[#objs+1] = {ROOT.import('Components/Value/String'):new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName, value = value, selection = selection,
						hintText = hint
					}),category,name}
				else
					objs[#objs+1] = {ENV.Value:new(box,{
						x = x()+10, y = y(30), w=290, h=30, category = category, name = name,
						fontSize = fontSize, text=tName , value = value ,
						hintText = hint
					}),category,name}
				end
				--[==[


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
PocoHud4.moduleEnd()
