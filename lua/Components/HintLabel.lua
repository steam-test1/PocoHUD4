local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIHintLabel = class(ROOT.import('Components/BaseElem'))

function PocoUIHintLabel:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text or 'Err: No text given',config.autoSize)
	self.lbl = lbl

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIHintLabel:makeHintPanel()
	local config = self.config
	local hintPnl

	local _reposition = function(x,y)
		if hintPnl then
			x = math.max(0,math.min(self.ppnl:world_x()+self.ppnl:w()-hintPnl:w(),x+10))
			y = math.max(self.ppnl:world_y(),math.min((self.ppnl:h() or 0)-20-hintPnl:h(),y))
			hintPnl:set_world_position(x,y+20)
		end
	end
	local _buildOne = function(x,y)
		hintPnl = self.ppnl:panel{
			x = 0, y = 0, w = 800, h = 200
		}
		local __, hintLbl = _.l({
			pnl = hintPnl,x=5, y=5, font = config.hintFont, font_size = config.hintFontSize or 18, color = config.hintFontColor or cl.White,
			align = config.align, vertical = config.vAlign, layer = 2, rotation = 360
		},config.hintText or '',true)
		hintPnl:set_size(hintLbl:size())
		hintPnl:grow(10,10)
		hintPnl:rect{ color = cl.Black:with_alpha(0.7), layer = 1, rotation = 360}
		_reposition(x,y)
	end
	self:_bind(PocoEvent.In, function(self,x,y)
		if not hintPnl then
			_buildOne(x,y)
		end
	end):_bind(PocoEvent.Out, function(self,x,y)
		if hintPnl then
			if alive(hintPnl) then
				self.ppnl:remove(hintPnl)
			end
			hintPnl = nil
		end
	end):_bind(PocoEvent.Move, function(self,x,y)
		_reposition(x,y)
	end)

end
export = PocoUIHintLabel

PocoHud4.moduleEnd()
