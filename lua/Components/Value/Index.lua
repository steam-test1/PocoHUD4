local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/ThreadElem')
local O = ROOT.import('Options')()
local Value = class(ThreadElem)

function Value:init(...)
	Value.super.init(self, ...)

	local bg = self.pnl:rect{color = cl.White:with_alpha(0.1),layer=-1}
	bg:set_visible(false)


	self:on('enter', function()
		bg:set_visible(true)
		return false, 'slider_grab'
	end):on('move', function()
		return false, false, 'link'
	end):on('leave', function()
		bg:set_visible(false)
	end)
	local config = self.config

	local __, lbl = _.l({
			pnl = self.pnl,x=5, y=0, w = config.w, h = config.h, fontSize = config.fontSize} ,config.text,true)
	self.lbl = lbl
	self.lbl:set_center_y(config.h/2)

	__, lbl = _.l({
			pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, fontSize = config.fontSize,
			color = config.fontColor or cl.White },config.text,true)
	self.valLbl = lbl
	self.valLbl:set_center_y(config.h/2)

	if not config.noArrow then
		self.arrowLeft = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect = {0,5,15,20},
			color = cl.White,
			x = 0,
			y = 0,
			blend_mode = 'add'
		})
		self.arrowRight = self.pnl:bitmap({
			texture = 'guis/textures/menu_icons',
			texture_rect={10,5,20,20},
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

		self:on('press',function(btn,x,y)
			if btn == 0 then
				if self.arrowRight:inside(x,y) then
					return self:next()
				elseif self.arrowLeft:inside(x,y) then
					return self:prev()
				end
			elseif btn == 'mouse wheel up' and shift() then
				return self:prev()
			elseif btn == 'mouse wheel down' and shift() then
				return self:next()
			end
		end):on('move',function(x,y)
			if self.arrowRight:inside(x,y) or self.arrowLeft:inside(x,y) then
				return true, 'link'
			elseif shift() then
				return true, 'grab'
			end
		end)
	end
end

function Value:next()
	return false
end

function Value:prev()
	return false
end

function Value:isValid(val)
	return true
end

function Value:isDefault(val)
	if val == nil then
		val = self:val()
	end
	return O:isDefault(self.config.category,self.config.name,val)
end

function Value:_markDefault(set)
	if self.config.category then
		local isChanged = O:isChanged(self.config.category,self.config.name,set)
		_.l(self.lbl,{self.config.text,self:isDefault(set) and cl.White or (isChanged and cl.LightSkyBlue or cl.DarkKhaki)})
	end
end

function Value:val(set)
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

export = Value
PocoHud4.moduleEnd()
