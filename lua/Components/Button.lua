local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIButton = class(ROOT.import('Components/BaseElem'))

function PocoUIButton:init(parent,config,inherited)
	self.super.init(self,parent,config,true)

	local spnl = self.pnl:panel{}
	BoxGuiObject:new(spnl, {sides = {1,1,1,1}})
	spnl:rect{color=cl.Black,alpha=0.5,layer=-1}
	spnl:set_visible(false)
	local __, lbl = _.l({
		pnl = self.pnl,x=0, y=0, w = config.w, h = config.h, font = config.font, font_size = config.fontSize or 20, color = config.fontColor or cl.White,
		align = config.align or 'center', vertical = config.vAlign or 'center'
	},config.text,config.autoSize)

	self:_bind(PocoEvent.In, function(self,x,y)
		spnl:set_visible(true)
		self:sound('slider_grab')
	end):_bind(PocoEvent.Out, function(self,x,y)
		spnl:set_visible(false)
	end)

	self.lbl = lbl
	if not inherited then
		self:postInit(self)
	end
end

export = PocoUIButton

PocoHud4.moduleEnd()
