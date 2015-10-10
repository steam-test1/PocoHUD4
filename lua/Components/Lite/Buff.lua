local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local LiteBase = ROOT.import('Components/Lite/Base')
local O = ROOT.import('Options')()
local BuffElem = class(LiteBase)
local buffO = O('buff')

local clGood, clBad = cl.Green, cl.Red

function BuffElem:init(module, config)
	self.module = module
	BuffElem.super.init(self,config)
	self.name = 'BuffElem'


	self:make()
	self.pnl:rect{color=cl.Blue:with_alpha(0.5)}
	self
		:on('thread',_.b(self,'updatePosition'))
		:on('thread',_.b(self,'updateValue'))
end

function BuffElem:make()
	local pnl,cfg = self.pnl, self.config
	local __, lbl = _.l(
		{
			pnl=pnl,fontSize=cfg.fontSize,color=cfg.color or cfg.good and clGood or clBad,
			layer=1, rotation=360
		}, cfg.text or 'Ready'
	)
	self.lbl = lbl
	local texture = cfg.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
	self.pie = _G.CircleBitmapGuiObject:new( pnl, {
		use_bg = false, x=0,y=0,image = texture, radius = cfg.w/2,
		sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 1
	} )
end

function BuffElem:set(newConfig)
	self:fadeIn()
	local st = self.config and self.config.st
	self.config = newConfig
	if st and newConfig.et ~= 1 then
		self.config.st = st
	end
end

function BuffElem:updateValue()
	if not alive(self.pnl) then return end
	local st, et = self.config.st or 0, self.config.et or -1
	local prog = 1
	if et == -1 then
		prog = 1
	elseif et > 0 then
		local tt = et - st
		local dt = now() - st
		prog = dt/tt
	else
		self.config.et = 0
	end
	if prog <= 1 then
		self.lbl:set_text(_.s(self.config.text,prog))
		self.pie:set_current(prog)
	else
		self.config.et = 0
	end
	if et == 0 and not self.removed then
		self.removed = true
		self.module:removeBuff(self.config.key)
	end
end

local friction = 20
function BuffElem:updatePosition(dt)
	if not alive(self.pnl) then return end
	local cX, cY = self.__x or 0, self.__y or 0
	local tX, tY = self.x or 0, self.y or 0
	if (cX ~= tX) or (cY ~= tY) then
		cX = math.round( cX + ( tX - cX ) / friction )
		if math.abs( cX - tX ) <= 1 then
			cX = tX
		end
		cY = math.round( cY + ( tY - cY ) / friction )
		if math.abs( cY - tY ) <= 1 then
			cY = tY
		end
		self.pnl:set_position(cX,cY)
		self.__x = cX
		self.__y = cY
	end
end

export = BuffElem
PocoHud4.moduleEnd()
