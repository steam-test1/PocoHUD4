local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/base')
local BuffModule = class(ModuleBase)


function BuffModule:postInit()
	self.C = self.O('buff')
	if self.C.enable then
		self:installHooks()
	else
		_(_.i(self.C))
	end
end

function BuffModule:installHooks()
	_('INSTALL HOOKS~')
end

function BuffModule:preDestroy()

end

export = BuffModule:new()

PocoHud4.moduleEnd()
