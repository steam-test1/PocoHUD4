local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = ROOT.import('Compo/Elem', ENV)
local Box = class(Elem)

function Box:init(owner,...) -- x,y,w,h[,font,fontSize]
	self:baseInit(owner, ...)
	self.name = 'Box'
	self.outerPnl = self.pnl
	table.insert(self.extraPnls, self.pnl)
	self.pnl = self.pnl:panel(_.m(self.config,{x=0,y=0}))
	self._border = BoxGuiObject:new(self.outerPnl, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self:on('press',function(btn, x, y)
		if btn == 'mouse wheel down' then
			self:scrollY(-10)
			return true, 'selection_next'
		end
		if btn == 'mouse wheel up' then
			self:scrollY(10)
			return true, 'selection_previous'
		end
	end, 999999)

end

function Box:inside(x,y)
	return self.outerPnl:inside(x,y) and Elem.inside(self,x,y)
end

function Box:scrollY(delta)
	if not self.dead then
		local y = self.pnl:y() + (delta or 0)
		local h = self.pnl:h()

		self.pnl:set_y(math.min(0,math.max( y, - h + 10 + self.outerPnl:h() )))
	end
end
function Box:setScrollHeight(h)
	self.pnl:set_h(h)
end

function Box:destroy()
	self.pnl = self.outerPnl
	self.outerPnl = nil
	self:baseDestroy()
end

export = Box
PocoHud4.moduleEnd()
