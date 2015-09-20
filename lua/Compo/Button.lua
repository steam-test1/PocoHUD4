local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Compo/ThreadElem')
local Button = class(ThreadElem)

function Button:init(...) -- x,y,w,h[,font,fontSize] + [noBorder]
	Button.super.init(self,...)
	self.name = 'Button'
	local conf = self.config
	self.bgRect = self.pnl:rect{color=conf.bgColor or cl.Black, alpha=0.3}
	if conf.noBorder then
		self:on('enter',function() self.bgRect:set_alpha(0.5) end)
		:on('leave',function() self.bgRect:set_alpha(0.3) end)
	else
		self._border = BoxGuiObject:new(self.pnl, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._border:set_visible(false)
		self:on('enter',function() self._border:set_visible(true) end)
		:on('leave',function() self._border:set_visible(false) end)
	end
	local mergedText, lbl = _.l(
		_.m({	align = 'center', vertical = 'center'}, conf, { pnl = self.pnl, x = 0, y = 0}),
		conf.text, false
	)
end

function Button:destroy()
	if self.outerPnl then
		self.pnl = self.outerPnl
		self.outerPnl = nil
	end
	Button.super.destroy(self)
end

export = Button
PocoHud4.moduleEnd()
