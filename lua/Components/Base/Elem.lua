local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local BaseElem = ROOT.import('Components/Base/Base')
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
		if type(conf) == 'function' then
			conf = conf()
		end
		if b == 1 or ( b == 0 and self.config.primaryContextMenu ) then
			self:trigger('hideHint')
			local size = 3+(self.config.fontSize or 18)
			local menuElem = ListBox:new(self:getRoot(),{
				x=x+2,y=y+2,w=200,h=math.min(#conf*(size+5), 400), scroll=true,items=conf,
				layer=100, fontSize=size , bgColor=cl.Black:with_alpha(0.5)
			})
			self:getRoot():setTaunt(menuElem)
			self.menuElem = menuElem
			return true, 'prompt_enter'
		end
	end)
end

export = ContextElem
PocoHud4.moduleEnd()
