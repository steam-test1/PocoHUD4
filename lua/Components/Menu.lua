local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoTabs = ROOT.import('Components/Tabs')
local owner = ROOT.import('Menu')()

local PocoMenu = class()
function PocoMenu:init(ws,alternative)
	self._ws = ws
	self.alt = alternative
	if alternative then
		self.pnl = ws:panel():panel({ name = 'bg' })
		self.gui = PocoTabs:new(ws,{name = 'PocoRose',x = 0, y = -1, w = ws:width(), th = 1, h = ws:height()+1, pTab = nil, alt = true})
	else
		self.gui = PocoTabs:new(ws,{name = 'PocoMenu',x = 10, y = 10, w = 900, th = 30, h = ws:height()-20, pTab = nil})

		self.pnl = ws:panel():panel({ name = 'bg' })
		self.pnl:rect{color = cl.Black:with_alpha(0.3),layer = Layers.Bg}
		self.pnl:bitmap({
			layer = Layers.Blur,
			texture = 'guis/textures/test_blur_df',
			w = self.pnl:w(),h = self.pnl:h(),
			render_template = 'VertexColorTexturedBlur3D'
		})
		local __, lbl = _.l({pnl = self.pnl,x = 1010, y = 20, font_size = 17, layer = Layers.TabHeader},
			{'Dbl-right-click to dismiss',cl.Gray},true)
		lbl:set_right(1000)
	end

	PocoMenu.m_id = PocoMenu.m_id or managers.mouse_pointer:get_id()
	managers.mouse_pointer:use_mouse{
		id = PocoMenu.m_id,
		mouse_move = callback(self, self, 'mouse_moved',true),
		mouse_press = callback(self, self, 'mouse_pressed',true),
		mouse_release = callback(self, self, 'mouse_released',true)
	}

	self._lastMove = 0
end

function PocoMenu:_fade(pnl, out, done_cb, seconds)
	local pnl = self.pnl
	pnl:set_visible( true )
	pnl:set_alpha( out and 1 or 0 )
	local t = seconds
	if self.alt and not out then
		managers.mouse_pointer:set_mouse_world_position(pnl:w()/2, pnl:h()/2)
	end
	while alive(pnl) and t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local r = t/seconds
		pnl:set_alpha(out and r or 1-r)
		if self._tabs then
			for i,tabs in pairs(self._tabs) do
				tabs.pnl:set_alpha(out and r or 1-r)
			end
		end
		if self.gui and self.gui.pnl then
			self.gui.pnl:set_alpha(out and r or 1-r)
		end
	end
	if done_cb then
		done_cb()
	end
end


function PocoMenu:fadeIn(cbk)
	if alive(self.pnl) then
		self.pnl:stop()
		self.pnl:animate( callback( self, self, '_fade' ), false, cbk, self.alt and 0.1 or 0.25 )
	end
end
function PocoMenu:fadeOut(cbk)
	if alive(self.pnl) then
		self.pnl:stop()
		self.pnl:animate( callback( self, self, '_fade' ), true, cbk, self.alt and 0.1 or 0.25 )
	end
end



function PocoMenu:add(...)
	self._tabs = self._tabs or {}
	local newTab = self.gui:add(...)
	table.insert(self._tabs,newTab)
	return newTab
end

function PocoMenu:update(...)
end

function PocoMenu:destroy()
	if self.dead then return end
	self.dead = true
	if PocoMenu.m_id then
		managers.mouse_pointer:remove_mouse(PocoMenu.m_id)
	end

	if self.gui then
		self.gui:destroy()
	end
	if self.pnl then
		self._ws:panel():remove(self.pnl)
	end

end

function PocoMenu:mouse_moved(alt, panel, x, y)
	if not ROOT.active then return end
	local ret = function (a,b)
		if alt then
			managers.mouse_pointer:set_pointer_image(b)
		end
		return a, b
	end
	if self.dead then return end
	--if not inGame and alt then return end
	local isNewPos = self._x ~= x or self._y ~= y
	if isNewPos then
		self._close = nil
	else
		return
	end
	self._x = x
	self._y = y
	local _fireMouseOut = function()
		if self.lastHot then
			self.lastHot:fire(PocoEvent.Out,x,y)
			self.lastHot = nil
		end
	end
	local currentTab = self.gui and self.gui.currentTab

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.Move, x,y)
	if hotElem then
		hotElem:fire(PocoEvent.Move,x,y)
	end

	local hotElem = isNewPos and currentTab and currentTab:isHot(PocoEvent.In, x,y)
	if hotElem then
		if hotElem ~= self.lastHot then
			_fireMouseOut()
			self.lastHot = hotElem
			hotElem:fire(PocoEvent.In,x,y)
		end
	elseif isNewPos then
		_fireMouseOut()
	end
	local hotElem = currentTab and currentTab:isHot(PocoEvent.Pressed, x,y)
	if hotElem then
		return ret(true, hotElem.cursor or 'link')
	end
	if self.gui then
		local tabHdr = {self.gui:insideTabHeader(x,y)}
		if isNewPos and tabHdr[1] then
			return ret(true, tabHdr[2]~=0 and 'link' or 'arrow')
		end
	end
	return ret( true, 'arrow' )
end

function PocoMenu:mouse_pressed(alt, panel, button, x, y)
	if not ROOT.active then return end
	if self.dead then return end
	if self.alt then return end
	local tabT = 0.02
	pcall(function()
		local currentTab = self.gui and self.gui.currentTab
		if button == Idstring('mouse wheel down') then
			if currentTab:isHot(PocoEvent.WheelDown, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(1)
			end
		elseif button == Idstring('mouse wheel up') then
			if currentTab:isHot(PocoEvent.WheelUp, x,y, true) then
				return true
			end
			local tabHdr = {self.gui:insideTabHeader(x,y)}
			if tabHdr[1] and now() - self._lastMove > tabT then
				self._lastMove = now()
				tabHdr[1]:move(-1)
			end
		end

		if button == Idstring('0') then
			local focused = ROOT._focused
			if focused and not focused:inside(x,y) then
				focused:fire(PocoEvent.Click,x,y)
				ROOT._focused = nil
			end
			local tabs, tabInd = self.gui:insideTabHeader(x,y)
			if tabs and self.tabIndex ~= tabInd then
				if tabInd == 0 then
					tabs.currentTab:scroll(0,true)
				else
					tabs:goTo(tabInd)
				end
				return true
			end
			return currentTab and currentTab:isHot(PocoEvent.Pressed, x,y, true)
		end
		if button == Idstring('1') then
			return currentTab and currentTab:isHot(PocoEvent.PressedAlt, x,y, true)
		end
	end)
end

function PocoMenu:mouse_released(alt, panel, button, x, y)
	if not ROOT.active then return end
	if self.dead then return end
	if self.alt then return end
	local currentTab = self.gui and self.gui.currentTab
	if button == Idstring('0') then
		return currentTab and currentTab:isHot(PocoEvent.Released, x,y, true)
	end
	if button == Idstring('1') then
		local hot = currentTab and currentTab:isHot(PocoEvent.ReleasedAlt, x,y, true)
		if not hot then
			if self._close then
				owner:hide()
			else
				self._close = true
			end
		end
		return hot
	end
end

export = PocoMenu

PocoHud4.moduleEnd()
