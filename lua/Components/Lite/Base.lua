local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/Base/Thread')
local O = ROOT.import('Options')()
local LiteBase = class(ThreadElem)

function LiteBase:init( ...)
	-- OVERLOADING start
	local owner = ROOT.UI
	self.name = 'LiteBase'
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
	self.__thread = self.pnl:animate(self._threadTick,self)
	-- OVERLOADING end

	self:on('thread',function(dt)
		--[[
		if self.dyingAlpha then
			if self.dyingAlpha == -1 then
				self.dyingAlpha = nil
			else
				self.dyingAlpha = self.dyingAlpha - math.min( (dt or 0) * 4 , 0.1)
				if self.dyingAlpha > 0 then
					self.pnl:set_alpha(self.dyingAlpha)
				else
					self:destroy()
				end
			end
		end
		]]
		local fading = self.__fading
		if fading and alive(self.pnl) then
			local cA, tA = self.__alpha or 0, self.__alphaT or 0
			cA = cA + math.floor((tA - cA) * 10) / 100
			self.__alpha = cA
			self.pnl:set_alpha(cA)
			if fading == 'in' and cA >= 1 then
				self.__fading = nil
			elseif fading == 'out' and cA <= 0 then
				self.__fading = nil
				self:destroy()
			end
		end
	end)
end

function LiteBase:fadeIn(alpha)
	self.__fading = 'in'
	self.__alphaT = alpha or 1
	return self
end

function LiteBase:fadeOut()
	self.__fading = 'out'
	self.__alphaT = 0
	return self
end

export = LiteBase
PocoHud4.moduleEnd()
