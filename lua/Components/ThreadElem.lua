local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = ROOT.import('Components/Elem', ENV)
local ThreadElem = class(Elem)

local t = 0
function ThreadElem:init(...)
	ThreadElem.super.init(self, ...)
	self.name = 'ThreadElem'
	self.thread = self.pnl:animate(self._threadTick,self)
end

function ThreadElem._threadTick(pnl, self)
	while not (self.dying or self.dead) do
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
