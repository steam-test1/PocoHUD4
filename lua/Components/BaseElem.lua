local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = class()

function Elem:init( owner, ...) -- x,y,w,h[,font,fontSize,contextMenu,bgColor]
	if not owner.registerElem then
		_('>>>No Owner',debug.traceback(),'\n','<<<No Owner',self.name)
	end
	self.dead = false
	owner:registerElem(self)
	self.owner = owner
	self.config = _.m({x=0,y=0,w=100,h=100,pnl=owner.pnl,color=tweak_data.screen_colors.button_stage_3,layer=1}, ...)
	self.ppnl = self.config.pnl
	self.pnl = self.ppnl:panel(self.config)
	self.extraPnls = {}
	self.elems = {}
	self.listeners = {}

	if self.config.bgColor then
		self.bgRect = self.pnl:rect{color = self.config.bgColor, layer=0}
	end
	self:_bakeMouseQuery('Press')
	self:_bakeMouseQuery('Release')
	self:_bakeMouseQuery('Click')
	self:_bakeMouseQuery('DblClick')
	self.name = 'BaseElem'

	if self.config.hintText then
		self:installHint()
	end
end

function Elem:sound(snd)
	managers.menu_component:post_event(snd)
end

function Elem:installHint()
	local config = self.config
	local hintPnl
	local rootPnl = self:getRoot().pnl

	local _reposition = function(x,y)
		if hintPnl then
			x = math.max(0,math.min(rootPnl:w()-hintPnl:w(),x+10))
			y = math.max(rootPnl:world_y(),math.min((rootPnl:h() or 0)-20-hintPnl:h(),y))
			hintPnl:set_world_position(x,y+20)
		end
	end
	local _buildOne = function(x,y)
		hintPnl = rootPnl:panel{
			x = 0, y = 0, w = 800, h = 200, layer=2000
		}
		local __, hintLbl = _.l({
			pnl = hintPnl,x=5, y=5, font = config.hintFont, font_size = config.hintFontSize or 18, color = config.hintFontColor or cl.White,
			align = config.align, vertical = config.vAlign, layer = 2, rotation = 360
		},config.hintText or '',true)
		hintPnl:set_size(hintLbl:size())
		hintPnl:grow(10,10)
		hintPnl:rect{ color = cl.Black:with_alpha(0.7), layer = 1, rotation = 360}
		_reposition(x,y)
	end
	self:on('enter', function(x,y)
		if not hintPnl then
			_buildOne(x,y)
		end
	end):on('leave', function(x,y)
		if hintPnl then
			if alive(hintPnl) then
				rootPnl:remove(hintPnl)
			end
			hintPnl = nil
		end
	end):on('move', function(x,y)
		_reposition(x,y)
	end)

end
function Elem:size()
	if not self.dead then
		return self.pnl:size()
	end
	return 0, 0
end

function Elem:set_size(w,h)
	if not self.dead then
		if type(w) == 'number' then
			self.pnl:set_w(w)
		end
		if type(h) == 'number' then
			self.pnl:set_h(h)
		end
	end
end

function Elem:set_position(x,y)
	if not self.dead then
		if type(x) == 'number' then
			self.pnl:set_x(x)
		end
		if type(y) == 'number' then
			self.pnl:set_y(y)
		end
	end
end

function Elem:set_y(y)
	if self.outerPnl then
		self.outerPnl:set_y(y)
	else
		self.pnl:set_y(y)
	end
	return self
end

function Elem:set_center_x(y)
	if self.outerPnl then
		self.outerPnl:set_center_x(y)
	else
		self.pnl:set_center_x(y)
	end
	return self
end

function Elem:set_x(y)
	if self.outerPnl then
		self.outerPnl:set_x(y)
	else
		self.pnl:set_x(y)
	end
	return self
end

function Elem:set_alpha(alpha)
	local la = self._lastAlpha
	if la ~= alpha then
		self.pnl:set_alpha(alpha)
		if alpha == 0 and la ~= 0 then
			self:hide()
		elseif alpha ~= 0 and la == 0 then
			self:show()
		end
		self._lastAlpha = alpha
	end
end

function Elem:setCursor(cursor)
	local __
	__, self._cursorListener = self:on('move', function()
		return false, false, cursor
	end)
	return self
end

function Elem:clearCursor()
	if self._cursorListener then
		self:off('enter',self._cursorListener)
	end
	return self
end

function Elem:on(event, fn, key)
	if not self then error('[Elem:on] !self') end
	if not event then error('[Elem:on] !event') end
	event = event:lower()
	key = key or ('%x'):format(math.random(0,0xffffff))
	self.listeners[event] = self.listeners[event] or {}
	self.listeners[event][key] = fn
	return self, key
end

function Elem:off(event, key)
	event = event:lower()
	if self.listeners[event] and self.listeners[event][key] then
		table.remove(self.listeners[event], key)
	end
	return self
end

function Elem:getDeepName()
	local entity, failSafe, name = self, 20, ''
	while entity.owner do
		name = self.name .. ' ' .. name
		entity = entity.owner
		failSafe = failSafe - 1
		if failSafe <= 0 then
			return
		end
	end
	return entity
end

function Elem:disable()
	self._maxAlpha = 0.5
	self.pnl:set_alpha(self._maxAlpha)
	self.disabled = true
	return self
end
function Elem:enable()
	self._maxAlpha = 1
	self.pnl:set_alpha(self._maxAlpha)
	self.disabled = false
	return self
end

function Elem:triggerElems( event, ...)
	for __, elem in ipairs(self.elems or {}) do
		elem:trigger(event, ...)
		if event == 'leave' then
			elem.isInside = nil
		end
	end
	return self
end

function Elem:trigger(event, ...)
	event = event:lower()
	if event == 'click' and now() - (self._pressed or 0) > 0.1 then
		return -- drag out to cancel click
	end
	if not self.dead and self.listeners[event] then
		local results = {}
		for key,listener in pairs(self.listeners[event]) do
			results = {pcall(listener, ...)}
			if results[1] then
				table.remove(results,1)
				if results[1] then
					return unpack(results)
				end
			else
				_('[Elem:trigger] listener failed')
			end
		end
	end
end

function Elem:h()
	return not self.dead and self.pnl:h() or 0
end

function Elem:w()
	return not self.dead and self.pnl:w() or 0
end

function Elem:hide()
	if self.outerPnl then
		self.outerPnl:set_visible(false)
	end
	self.pnl:set_visible(false)
	return self
end

function Elem:show()
	if self.outerPnl then
		self.outerPnl:set_visible(true)
	end
	self.pnl:set_visible(true)
	return self
end

function Elem:clear()
	for k,elem in ipairs(self.elems) do
		elem:destroy()
	end
	self.elems = {}
end

function Elem:destroy()
	if self.dead then return end
	self:trigger('leave',0,0)
	self.dead = true
	self:clear()
	self.owner = nil
	self.elems = nil
	self.extraPnls = nil
	if alive(self.ppnl) and alive(self.pnl) then
		self.ppnl:remove(self.pnl)
	end
end

function Elem:getRoot()
	local entity, failSafe = self, 20
	while entity.owner do
		entity = entity.owner
		failSafe = failSafe - 1
		if failSafe <= 0 then
			return
		end
	end
	return entity
end

function Elem:inside(x,y)
	local isAvailable = not (self.dead or self.disabled) and self.pnl:visible()
	local result = isAvailable and self.pnl:inside(x,y)
	if isAvailable and not result then
		for __, pnl in pairs(self.extraPnls) do
			if alive(pnl) and pnl:visible() and pnl:inside(x,y) then
				result = true
				break
			end
		end
	end
	return result
end

function Elem:queryMouseMove( x, y )
	local isInside = self:inside( x, y )
	local stop, sound, cursor
	local process = function(_stop, _sound, _cursor)
		stop, sound, cursor = _stop, _sound or sound, _cursor or cursor
	end
	if isInside then
		if not self.isInside then
			process( self:trigger('enter', x, y ) )
		end
		for __, elem in ipairs(self.elems or {}) do
			if not (stop or elem.disabled or elem.dead) then
				process( elem:queryMouseMove( x, y ) )
			end
		end
		if not stop then
			process( self:trigger('move', x, y ) )
		end
	else
		if self.isInside then
			process( self:trigger('leave', x, y ) )
			self:triggerElems('leave',x,y)
		end
	end
	self.isInside = isInside
	return stop, sound, cursor or (isInside and 'arrow')
end

function Elem:_bakeMouseQuery( typeName, button, ... )
	self['queryMouse'..typeName] = function ( self, button, ... ) -- button, x, y
		local isInside = self:inside( ... )
		local stop, sound
		local process = function(_stop, _sound)
			stop, sound = _stop, _sound or sound
		end
		if isInside then
			if typeName == 'Press' then
				self._pressed = button
			elseif typeName == 'Release' then
				if self._pressed == button then
					self._pressed = now()
				else
					self._pressed = nil
				end
			end
			for k,elem in ipairs(self.elems or {}) do
				if not (stop or elem.disabled or elem.dead) then
					process( elem['queryMouse'..typeName]( elem, button, ... ) )
				end
			end
			if not stop then
				process( self:trigger(typeName, button, ... ) )
			end
		end
		return stop, sound or (stop and 'menu_enter' )
	end
end

local _UI = ROOT.import('Components/UI')
Elem.registerElem = _UI.registerElem
Elem.remove = _UI.remove
Elem.bringToFront = _UI.bringToFront

export = Elem
PocoHud4.moduleEnd()
