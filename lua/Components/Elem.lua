local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local BaseElem = ROOT.import('Components/BaseElem', ENV)
local ContextElem = class(BaseElem)

function ContextElem:init(...)
	ContextElem.super.init(self, ...)
	if self.config.contextMenu then
		self:_bindMenu(self.config.contextMenu)
	end
end

function ContextElem:_bindMenu(conf)
	local ListBox = ROOT.import('Components/ListBox')
	self:on('click',function(b,x,y)
		if b == 1 then
			local menuElem = ListBox:new(self:getRoot(),{
				x=x+2,y=y+2,w=150,h=math.min(#conf*20, 300), scroll=true,items=conf,
				layer=100, fontSize=self.config.fontSize, bgColor=cl.Black:with_alpha(0.8)
			})
			self:getRoot():setTaunt(menuElem)
			self.menuElem = menuElem
			return true, 'prompt_enter'
		end
	end)
end

export = ContextElem
PocoHud4.moduleEnd()
