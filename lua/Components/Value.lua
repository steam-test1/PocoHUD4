local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local O = ROOT.import('Config')()

local PocoUIElem = ROOT.import('Components/BaseElem')

local PocoUIValue = class(PocoUIElem)
function PocoUIValue:init(parent,config,inherited)
	PocoUIElem.init(self,parent,config,true)

	local bg = self.pnl:rect{color = cl.White:with_alpha(0.1),layer=-1}
	bg:set_visible(false)
	self:_bind(PocoEvent.In, function(self,x,y)
		bg:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		bg:set_visible(false)
	end)

	local __, lbl = _.l({
			pnl = self.pnl,x=5, y=0, w = config.w, h = config.h, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.lbl = lbl
	self.lbl:set_center_y(config.h/2)
	local __, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font_size = config.fontSize or 24,
			color = config.fontColor or cl.White },config.text,true)
	self.valLbl = lbl
	self.valLbl:set_center_y(config.h/2)

	if not config.noArrow then
		self.arrowLeft = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				0,
				5,
				15,
				20
			},
			color = cl.White,
			x = 0,
			y = 0,
			blend_mode = 'add'
		})
		self.arrowRight = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {
				10,
				5,
				20,
				20
			},
			color = cl.White,
			x = 20,
			y = 1,
			blend_mode = 'add',
			--rotation = 180,
		})
		self.arrowRight:set_right(config.w)
		self.arrowLeft:set_left(config.w/2)

		self.arrowLeft:set_center_y(config.h/2)
		self.arrowRight:set_center_y(config.h/2)

		local shift = function()
			return ROOT._kbd:down(42) or ROOT._kbd:down(54)
		end

		self:_bind(PocoEvent.Pressed,function(self,x,y)
			if self.arrowRight:inside(x,y) then
				self:next()
			elseif self.arrowLeft:inside(x,y) then
				self:prev()
			else
				self.mute = true
			end
		end):_bind(PocoEvent.Move,function(self,x,y)
			if self.arrowRight:inside(x,y) or self.arrowLeft:inside(x,y) then
				self.cursor = 'link'
			elseif shift() then
				self.cursor = 'grab'
			else
				self.cursor = 'arrow'
			end
		end):_bind(PocoEvent.WheelUp,function()
			if shift() then
				self:sound('slider_increase')
				return true, self:next()
			end
		end):_bind(PocoEvent.WheelDown,function(...)
			if shift() then
				self:sound('slider_decrease')
				return true, self:prev()
			end
		end)
	end


	-- Always inherited though
end

function PocoUIValue:next()
	self.result = false
end

function PocoUIValue:prev()
	self.result = false
end

function PocoUIValue:isValid(val)
	return true
end

function PocoUIValue:isDefault(val)
	if val == nil then
		val = self:val()
	end
	return O:isDefault(self.config.category,self.config.name,val)
end

function PocoUIValue:_markDefault(set)
	if self.config.category then
		local isChanged = O:isChanged(self.config.category,self.config.name,set)
		_.l(self.lbl,{self.config.text,self:isDefault(set) and cl.White or (isChanged and cl.LightSkyBlue or cl.DarkKhaki)})
	end
end

function PocoUIValue:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			_.l(self.valLbl,set,true)
			self.valLbl:set_center_x(self.config.valX or 12*self.config.w/16)
			self.valLbl:set_x(math.floor(self.valLbl:x()))
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

export = PocoUIValue

PocoHud4.moduleEnd()
