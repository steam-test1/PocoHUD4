local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = class()

function Elem:init( owner, ...) -- x,y,w,h[,font,fontSize,contextMenu,bgColor]
	if not owner.registerElem then
		_('No Owner',debug.traceback())
	end
	self.dead = false
	owner:registerElem(self)
	self.owner = owner
	self.config = _.m({x=0,y=0,w=100,h=100,pnl=owner.pnl}, ...)
	self.ppnl = self.config.pnl
	self.pnl = self.ppnl:panel(self.config)
	self.extraPnls = {}
	self.elems = {}
	self.listeners = {}

	if self.config.bgColor then
		self.pnl:rect{color = self.config.bgColor}
	end
	self:_bakeMouseQuery('Press')
	self:_bakeMouseQuery('Release')
	self:_bakeMouseQuery('Click')
	self:_bakeMouseQuery('DblClick')
	self.name = 'BaseElem'
end

function Elem:setAlpha(alpha)
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

function Elem:triggerElems(...)
	for __, elem in ipairs(self.elems) do
		elem:trigger(...)
	end
	return self
end

function Elem:trigger(event, ...)
	event = event:lower()
	if not self.dead and self.listeners[event] then
		local results = {}
		for key,listener in pairs(self.listeners[event]) do
			results = {pcall(listener, ...)}
			if results[1] then
				table.remove(results,1)
				return unpack(results)
			else
				_('[Elem:trigger] listener failed')
			end
		end
	end
end


function Elem:hide()
	self.pnl:set_visible(false)
end

function Elem:show()
	self.pnl:set_visible(true)
end


function Elem:destroy()
	if self.dead then return end
	self.dead = true
	for k,elem in ipairs(self.elems) do
		elem:destroy()
	end
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
