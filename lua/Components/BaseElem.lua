local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local UIHintLabel = ROOT.import('Components/HintLabel')
local PocoUIElem = class()

function PocoUIElem:init(parent,config)
	config = _.m({
		w = 400,h = 20, font = 'fonts/font_medium_mf'
	}, config)
	if config.font == 'large' then
		config.font = 'fonts/font_large_mf'
	elseif config.font == 'alt' then
		config.font = 'fonts/font_eroded'
	end

	self.parent = parent
	self.config = config or {}
	self.ppnl = config.pnl or parent.pnl
	self.pnl = self.ppnl:panel({ name = config.name, x=config.x, y=config.y, w = config.w, h = config.h})
	self.status = 0

	if self.config[PocoEvent.Click] then
		self:_bind(PocoEvent.Out, function(self)
			self._pressed = nil
		end):_bind(PocoEvent.Pressed, function(self,x,y)
			self._pressed = true
		end):_bind(PocoEvent.Released, function(self,x,y)
			if self._pressed then
				self._pressed = nil
				return self:fire(PocoEvent.Click,x,y)
			end
		end)
	end

	if config.hintText then
		UIHintLabel.makeHintPanel(self)
	end
end

function PocoUIElem:postInit()
	for event,eventVal in pairs(PocoEvent) do
		if self.config[eventVal] then
			self.parent:addHotZone(eventVal,self)
		end
	end
	self._bind = function()
		_('Warning:PocoUIElem._bind was called too late')
	end
end

function PocoUIElem:set_y(y)
	self.pnl:set_y(y)
end
function PocoUIElem:set_center_x(x)
	self.pnl:set_center_x(x)
end
function PocoUIElem:set_x(x)
	self.pnl:set_x(x)
end

function PocoUIElem:popup()
	--abastract
end

function PocoUIElem:inside(x,y)
	return alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:_bind(eventVal,cbk)
	if not self.config[eventVal] then
		self.config[eventVal] = cbk
	else
		local _old = self.config[eventVal]
		self.config[eventVal] = function(...)
			local result = _old(...)
			if not result then
				result = cbk(...)
			else
			end
			return result
		end
	end
	return self
end

function PocoUIElem:sound(sound)
	managers.menu_component:post_event(sound)
end

function PocoUIElem:hide()
	self._hide = true
	if alive(self.pnl) then
		self.pnl:set_visible(false)
	end
end

function PocoUIElem:setLabel(text)
	if alive(self.lbl) then
		self.lbl:set_text(text)
	end
end

function PocoUIElem:disable()
	self._disabled = true
end

function PocoUIElem:isHot(event,x,y)
	return not self._disabled and not self._hide and alive(self.pnl) and self.pnl:inside(x,y)
end

function PocoUIElem:fire(event,x,y)
	if not ROOT.active or self.parent.dead or not alive(self.pnl) then return end
	if not self.config[event] and self.popup then
		self:toggle(false)
		return
	end
	local result = {self.config[event](self,x,y)}
	local sound = {
		onPressed = 'prompt_enter'
	}
	if self.config[event] then
		if self.result == false then
			self:sound('menu_error')
			self.result = nil
			return true
		elseif self.mute then
			self.mute = nil
			return true
		end
		if sound[event] then
			self:sound(sound[event])
		end
		return unpack(result)
	end
end

export = PocoUIElem
PocoHud4.moduleEnd()
