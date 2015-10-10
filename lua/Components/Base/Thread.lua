local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = ROOT.import('Components/Base/Elem', ENV)
local ThreadElem = class(Elem)

local t = 0
local slowThreadThreshold = 20
function ThreadElem:init(...)
	ThreadElem.super.init(self, ...)
	self.name = 'ThreadElem'
	self.thread = self.pnl:animate(self._threadTick,self)
end

function ThreadElem._threadTick(pnl, self)
	local n = 0
	while not (self.dying or self.dead) do
		n = n + 1
		if n > slowThreadThreshold then
			n = 0
			self:trigger('slowThread')
		end
		self:trigger('thread')
		coroutine.yield()
	end
end

function ThreadElem:destroy()
	self.dying = true
	self.thread = nil
	ThreadElem.super.destroy(self)
end

export = ThreadElem
PocoHud4.moduleEnd()
