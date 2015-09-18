local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = class()

function Elem:init(owner,...) -- x,y,w,h[,font,fontSize]
	owner:registerElem(self)
	self.owner = owner
	self.config = _.m({x=0,y=0,w=100,h=100},...)
	self.ppnl = owner.pnl
	self.pnl = self.ppnl:panel(self.config)
	self.pnl:rect{color = cl.Blue:with_alpha(0.5)}
	self.elems = {}
	self.listeners = {}
	self:_bakeMouseQuery('Press')
	self:_bakeMouseQuery('Release')
	self:_bakeMouseQuery('Click')
	self:_bakeMouseQuery('DblClick')
end

function Elem:on(event, fn, key)
	event = event:lower()
	key = key or ('%x'):format(math.random(0,0xffffff))
	self.listeners[event] = self.listeners[event] or {}
	self.listeners[event][key] = fn
	return key
end

function Elem:trigger(event, ...)
	event = event:lower()
	if not self.dead and self.listeners[event] then
		local results = {}
		for key,listener in pairs(self.listeners[event]) do
			results = {listener(self, ...)}
			if results[1] then
				return unpack(results)
			end
		end
	end
end

function Elem:destroy()
	self.dead = true
	for k,elem in ipairs(self.elems) do
		elem:destroy()
	end
	self.owner = nil
	self.elems = nil
	self.ppnl:remove(self.pnl)
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

function Elem:queryMouseMoved( x, y )
	local isInside = self.pnl:inside( x, y )
	local stop, sound, cursor
	if isInside then
		if not self.isInside then
			stop, sound, cursor = self:trigger('enter', x, y )
		end
		for __, v in ipairs(self.elems or {}) do
			if not stop then
				stop, sound, cursor = self:queryMouseMoved( x, y )
			end
		end
		if not stop then
			stop, sound, cursor = self:trigger('move', x, y )
		end
	else
		if self.isInside then
			stop, sound, cursor = self:trigger('leave', x, y )
		end
	end
	self.isInside = isInside
	return stop, sound, cursor
end

function Elem:_bakeMouseQuery( typeName, button, ... )
	self['queryMouse'..typeName] = function ( self, button, ... ) -- button, x, y
		local isInside = self.pnl:inside( ... )
		local stop, sound
		if isInside then
			for k,itm in ipairs(self.elems or {}) do
				if not stop then
					stop, sound = itm['queryMouse'..typeName]( itm, button, ... )
				end
			end
			if not stop then
				stop, sound = self:trigger(typeName, button, ... )
			end
		end
		return stop, sound
	end
end

export = Elem
PocoHud4.moduleEnd()
