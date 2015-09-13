local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')

local PocoUIBoolean = class(PocoUIValue)
function PocoUIBoolean:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self.tick = self.pnl:bitmap({
		name = 'tick',
		texture = 'guis/textures/menu_tickbox',
		texture_rect = {
			0,
			0,
			24,
			24
		},
		w = 24,
		h = 24,
		color = cl.White
	})
	self.tick:set_center_y(config.h/2)

	self.lbl:set_x(self.lbl:x()+20)
	self.valLbl:set_visible(false)
	self:val(config.value or false)
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self:val(not self:val())
		self:sound('box_'..(self:val() and 'tick' or 'untick'))
		self.mute = true
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIBoolean:val(set)
	if set ~= nil then
		if not self.value or self:isValid(set) then
			self.value = set
			if self.tick then
				if not set then
					self.tick:set_texture_rect(0,0,24,24)
				else
					self.tick:set_texture_rect(24,0,24,24)
				end
			end
			self:_markDefault(set)
			return set
		else
			return false
		end
	else
		return self.value
	end
end

export = PocoUIBoolean

PocoHud4.moduleEnd()
