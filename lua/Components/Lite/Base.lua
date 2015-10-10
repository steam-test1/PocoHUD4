local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/Base/Thread')
local O = ROOT.import('Options')()
local LiteBase = class(ThreadElem)

function LiteBase:init(owner, ...)
	self.name = 'ThreadElem'
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

	self.thread = self.pnl:animate(self._threadTick,self)
end

export = LiteBase
PocoHud4.moduleEnd()
