local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local BaseElem = ROOT.import('Components/Base/Base')
local LabelElem = class(BaseElem)

function LabelElem:init(...)
	LabelElem.super.init(self, ...)
	local mergedText, lbl = _.l(
		_.m({	align = 'center', vertical = 'center'}, self.config, { pnl = self.pnl, x = 0, y = 0}),
		self.config.text or '', false
	)
	self.lbl = lbl
end

export = LabelElem
PocoHud4.moduleEnd()
