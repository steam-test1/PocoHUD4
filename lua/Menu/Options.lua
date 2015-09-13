-- Menu manager
local ENV = PocoHud4.moduleBegin()
-- GLOBALS: Menu
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local L = ROOT.import('Localizer')()
local O = ROOT.import('Config')()

local PocoUIButton = ROOT.import('Components/Button')
local PocoUIBoolean = ROOT.import('Components/Boolean')
local PocoUIColorValue = ROOT.import('Components/ColorValue')
local PocoUIKeyValue = ROOT.import('Components/KeyValue')
local PocoUINumValue = ROOT.import('Components/NumValue')
local PocoUIStringValue = ROOT.import('Components/StringValue')

local FONTLARGE = 'fonts/font_large_mf'
local PocoTabs = ROOT.import('Components/Tabs')


export = function (self, gui, tab)
	local objs = {}
	PocoUIButton:new(tab,{
		onClick = function()
			if ROOT then
				O:default()
				for __,obj in pairs(objs) do
					if not obj[1]:isDefault() then
						O:set(obj[2],obj[3],obj[1]:val())
					end
				end
				O:save()
			  ROOT.unload()
			  rawset(_G,'PocoHud4',nil)
			end
		end,
		x = 20, y = 10, w = 400, h=50,
		fontSize = 30,font = FONTLARGE,
		text={L('_btn_apply_and_reload'),cl.SteelBlue},
		hintText = L('_desc_apply_and_reload')
	})

	PocoUIButton:new(tab,{
		onClick = function()
			for __,obj in pairs(objs) do
				obj[1]:val(O:get(obj[2],obj[3],true))
			end
		end,
		x = 450, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_discard'),cl.Gray},
		hintText = L('_desc_discard')
	})
	PocoUIButton:new(tab,{
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
		x = 660, y = 10, w = 200, h=50,
		fontSize = 25,font = FONTLARGE,
		text={L('_btn_reset'),cl.Gray},
		hintText = L('_desc_reset')
	})

	local oTabs = PocoTabs:new(ROOT.ws,{name = 'Options',x = 10, y = 70, w = tab.pnl:width()-20, th = 30, fontSize = 18, h = tab.pnl:height()-80, pTab = tab})
	for category, objects in _.p(O.scheme) do
		local _y, m, half = 10, 5
		local x,y = function()
			return half and 440 or 10
		end, function(h)
			_y = _y + h + m
			return _y - h - m
		end

		local oTab = oTabs:add(L('_tab_'..category))
		if objects[1] then
			local txts = L:parse(objects[1])
			local __, lbl = _.l({color=cl.LightSteelBlue, alpha=0.9, font_size=20, pnl = oTab.pnl, x = x(), y = y(0)},txts,true)
			y(lbl:h())
			--[[oTab.pnl:bitmap({
				texture = 'guis/textures/pd2/shared_lines',	wrap_mode = 'wrap',
				color = cl.White, x = 5, y = y(3), w = oTab.pnl:w()-10, h = 3, alpha = 0.3 })]]
		end

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
					objs[#objs+1] = {PocoUIBoolean:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName , value = value ,
						hintText = hint
					}),category,name}
				elseif type == 'color' then
					objs[#objs+1] = {PocoUIColorValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'key' then
					objs[#objs+1] = {PocoUIKeyValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value,
						hintText = hint
					}),category,name}
				elseif type == 'num' then
					local range = O:_range(category,name) or {}
					local vanity = O:_vanity(category,name)
					if vanity then
						vanity = L(vanity):split(',')
					end
					local step = O:_step(category,name)

					objs[#objs+1] = {PocoUINumValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name, step = step,
						fontSize = 20, text=tName, value = value, min = range[1], max = range[2], vanity = vanity,
						hintText = hint
					}),category,name}
				elseif type == 'string' then
					local selection = O:_vanity(category,name)

					objs[#objs+1] = {PocoUIStringValue:new(oTab,{
						x = x()+10, y = y(30), w=390, h=30, category = category, name = name,
						fontSize = 20, text=tName, value = value, selection = selection,
						hintText = hint
					}),category,name}
				else
					PocoUIButton:new(oTab,{
						hintText = L('_msg_not_implemented'),
						x = x()+10, y = y(30), w=390, h=30,
						text=_.s(name,type,value)
					})
				end
			end
		end
		oTab:set_h(math.max(_y,_ty)+40)
	end
end

PocoHud4.moduleEnd()
