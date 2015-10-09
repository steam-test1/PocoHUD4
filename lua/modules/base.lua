local ENV = PocoHud4.moduleBegin()
local ModuleBase = class()

function ModuleBase:init()
	self.category = 'UNKNOWN'
	self.id = 'Base'
	self.C = {}
	self.aliveThunk = function() return not self.dead end

	self.O = ROOT.import('Options')()
	self.L = ROOT.import('Localizer')()

	self:postInit()
end

function ModuleBase:postInit()
	-- Abstract
end

function ModuleBase:preDestroy()
	-- Abstract
end

function ModuleBase:destroy()
	self.dying = true
	self:preDestroy()
	self.dead = true
end

export = ModuleBase

PocoHud4.moduleEnd()
