local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Button = ROOT.import('Components/Button', ENV)
local ListboxItem = class(Button)

function ListboxItem:init( ... ) -- x,y,w,h[,font,fontSize] + items
	ListboxItem.super.init(self, ...)
	self.name = 'ListboxItem'
end

function ListboxItem:destroy()
	if self.outerPnl then
		self.pnl = self.outerPnl
		self.outerPnl = nil
	end
	ListboxItem.super.destroy(self)
end

export = ListboxItem
PocoHud4.moduleEnd()
