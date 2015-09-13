local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')
local PocoUIChooseValue = ROOT.import('Components/ChooseValue')
local Hook = ROOT.import('Hook')
--GLOBALS: utf8

local PocoUIStringValue = class(PocoUIValue)
function PocoUIStringValue:init(parent,config,inherited)
	config.noArrow = not config.selection
	self.super.init(self,parent,config,true)
	self:_initLayout()
	self:val(config.value or '')
	self.box = self.pnl:rect{color = cl.White:with_alpha(0.3), visible = false}
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		if self.arrowLeft and self.arrowLeft:inside(x,y) then
			return
		elseif self.arrowRight and self.arrowRight:inside(x,y) then
			return
		elseif not self._editing then
			self:startEdit()
			self:selectAll()
		else
			if now() - (self._lastClick or 0) < 0.3 then
				self:selectAll()
			elseif self.valLbl:inside(x,y) then
				self:_setCaret(x)
			else
				self:endEdit()
			end
		end
		self._lastClick = now()
	end):_bind(PocoEvent.WheelUp,self.next):_bind(PocoEvent.WheelDown,self.prev):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:sound('menu_error')
			self:endEdit()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIStringValue:selection()
	return self.config.selection or {}
end

function PocoUIStringValue:prev()
	PocoUIChooseValue.go(self,-1)
	self._lastClick = now()
end

function PocoUIStringValue:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()] or self:val()
	end
end


function PocoUIStringValue:next()
	PocoUIChooseValue.go(self,1)
	self._lastClick = now()
end

function PocoUIStringValue:_initLayout()
	if not self.config.valX and self.config.text:gsub(' ','') == '' then
		self.config.valX = self.config.w / 2
	end
end

function PocoUIStringValue:val(set)
	if set then
		set = utf8.sub(set,1,self.config.max or 15)
	end
	local result =  PocoUIValue.val(self,set)
	self:repaint()
	if set then
		local text = self:selection()[result]
		if text then
			_.l(self.valLbl,text,true)
			self.valLbl:set_center_x(self.config.valX or 12*self.config.w/16)
			self.valLbl:set_x(math.floor(self.valLbl:x()))
		end
	end
	return result
end

function PocoUIStringValue:startEdit()
	self._editing = true
	self.box:set_visible(true)
	ROOT.ws:connect_keyboard(Input:keyboard())
	ROOT._focused = self
	self.pnl:enter_text(callback(self, self, 'enter_text'))
	self.pnl:key_press(callback(self, self, 'key_press'))
	self.pnl:key_release(callback(self, self, 'key_release'))
	local l = utf8.len(self:val())
	self.valLbl:set_selection(l,l)
	self._rename_caret = self.pnl:rect({
		name = 'caret',
		layer = -1,
		x = 10,
		y = 10,
		w = 2,
		h = 2,
		color = cl.Red
	})
	self:repaint()
	self._rename_caret:animate(self.blink)
	self.beforeVal = self:val()
end

function PocoUIStringValue:selectAll()
	self:_select(0, utf8.len(self:val()))
	self._start = 0
	self._shift = nil
	self:repaint()
end

function PocoUIStringValue:_select(tS,tE)
	local s,e = self.valLbl:selection()
	local l = utf8.len(self:val())
	if tS and tE then
		s, e = math.max(0,tS),math.min(tE,l)
		if s == e then
			self._start = s
		end
		self.valLbl:set_selection(s,e)
	else
		return s,e
	end
end
function PocoUIStringValue:select(delta,shift)
	local s, e = self:_select()
	if shift then -- start Shift
		self._start = s
		self._shift = true
	elseif shift == false then
		self._shift = nil
	elseif self._shift then -- grow selection
		local ss = self._start
		if delta > 0 then
			if ss == s then
				self:_select(ss,e+delta)
			else
				self:_select(s+delta,ss)
			end
		elseif delta < 0 then
			if ss == e then
				self:_select(s+delta,ss)
			else
				self:_select(ss,e+delta)
			end
		end
	else -- simpleMove
		self:_select(s+delta,s+delta)
	end

end

function PocoUIStringValue:_setCaret(worldX)
	local lbl = self.valLbl
	local l = utf8.len(self:val())
	if l == 0 then
		self:select(0,0)
	end
	local c, x, y, w, h = -1
	repeat
		c = c + 1
		self:_select(c,c)
		x, y, w, h = self.valLbl:selection_rect()
	until x>=worldX or c > l
	self:_select(c-1,c-1)
	self:repaint()
end

function PocoUIStringValue:endEdit(cancel)
	self._editing = nil
	ROOT._focused = nil
	ROOT._lastFocusT = now()
	self.box:set_visible(false)
	ROOT.ws:disconnect_keyboard()
	self:_select(0,0)
	self.pnl:enter_text(nil)
	self.pnl:key_press(nil)
	self.pnl:key_release(nil)
	self.pnl:remove(self._rename_caret)
	self._rename_caret = nil
	if cancel then
		self:val(self.beforeVal)
	end
	self.beforeVal = nil
end

function PocoUIStringValue:repaint()
	ROOT._lastFocusT = now()
	if self.box then
		local x,y,w,h = self.valLbl:shape()
		x, y, w, h = x-5, y-5, w+10, math.max(h+10,self.config.h+10)
		self.box:set_shape(x,y,w,h)
	end
	if self._rename_caret then
		local x, y, w, h = self.valLbl:selection_rect()
		if x == 0 then
			x,y = self.valLbl:world_position()
		end
		w = math.max(w,3)
		h = math.max(h,20)
		self._rename_caret:set_world_shape(x,y,w,h)
	end
end

function PocoUIStringValue.blink(o)
	while alive(o) do
		o:set_color(cl.White:with_alpha(0.1))
		wait(0.2)
		o:set_color(cl.White:with_alpha(0.5))
		wait(0.3)
	end
end
function PocoUIStringValue:enter_text(o, s)
	if self._editing then
		self.valLbl:replace_text(s)
		self:val(self.valLbl:text())
	end
end

function PocoUIStringValue:key_release(o, k)
	if k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,false)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = false
	end
end

function PocoUIStringValue:key_press(o, k)
	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:disable_input(0.2)
	end
	local lbl = self.valLbl
	local n = utf8.len(lbl:text())
	local s, e = lbl:selection()
	if k == Idstring('delete') then
		if s == e and s > 0 then
			lbl:set_selection(s, e+1)
		end
		self:enter_text('')
	elseif k == Idstring('backspace') then
		if s == e and s > 0 then
			lbl:set_selection(s - 1, e)
		end
		self:enter_text('')
	elseif k == Idstring('left') then
		self:select(-1)
		--[[
		if s < e then
			lbl:set_selection(s, s)
		elseif s > 0 then
			lbl:set_selection(s - 1, s - 1)
		end]]

	elseif k == Idstring('right') then
		self:select(1)
		--[[
		if s < e then
			lbl:set_selection(e, e)
		elseif s < n then
			lbl:set_selection(s + 1, s + 1)
		end]]
	elseif k == Idstring('end') then
		lbl:set_selection(n, n)
	elseif k == Idstring('home') then
		lbl:set_selection(0, 0)
	elseif k == Idstring('enter') or k == Idstring('tab') then
		self:endEdit()
	elseif k == Idstring('esc') then
		self:endEdit(true)
		return
	elseif k == Idstring('left shift') or k == Idstring('right shift') then
		self:select(0,true)
	elseif k == Idstring('left ctrl') or k == Idstring('right ctrl') then
		self._key_ctrl_pressed = true
	elseif self._key_ctrl_pressed == true then
		return
	end
	self:repaint()
end
export = PocoUIStringValue

PocoHud4.moduleEnd()
