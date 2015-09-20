local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = ROOT.import('Components/Elem')
local Box = class(Elem)
local scrollAmount = 20

function Box:init( ... ) -- x,y,w,h[,font,fontSize] + [noBorder]
	Box.super.init(self, ...)
	self.name = 'Box'
	if not self.config.noBorder then
		self._border = BoxGuiObject:new(self.pnl, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if self.config.scroll then
		self.outerPnl = self.pnl
		--table.insert(self.extraPnls, self.pnl)
		self.pnl = self.pnl:panel(_.m({},self.config,{x=0, y=0, layer=1}))

		self:on('press',function(btn, x, y)
			if btn == 'mouse wheel down' then
				return true, self:scrollY(-scrollAmount) and 'selection_next' or ''
			end
			if btn == 'mouse wheel up' then
				return true, self:scrollY(scrollAmount) and 'selection_previous' or ''
			end
		end, 999999)
	end
end

function Box:inside(x,y)
	return (self.outerPnl and self.outerPnl:inside(x,y)) and Elem.inside(self,x,y)
end

function Box:fadeElems()
	if self.config.fade then
		local px, py = self.pnl:position()
		local ow, oh = self.outerPnl:size()
		local pad = 50
		for __, elem in ipairs(self.elems) do
			local x,y,w,h = elem.pnl:shape()
			local yy = y + py + h/2
			if yy <= 0  or yy > oh then
				elem:setAlpha(0)
			elseif yy < pad then
				elem:setAlpha(0.5 + (yy / pad)/2)
			elseif yy > oh - pad then
				elem:setAlpha(0.5 + ((oh - yy) / pad)/2)
			else
				elem:setAlpha(1)
			end
		end
	end
end

function Box:scrollY(delta)
	if not self.dead then
		local y = self.pnl:y() + (delta or 0)
		local h = self.pnl:h()
		local nY = math.min(0,math.max( y, - h + 10 + self.outerPnl:h() ))

		self.pnl:set_y( nY )
		self:fadeElems()
		return nY==y
	end
end

function Box:autoSize(padding)
	padding = padding or 20
	local ww,hh = self.config.w, self.config.h
	for __, elem in ipairs(self.elems) do
		local x,y,w,h = elem.pnl:shape()
		ww = math.max(x+w, ww)
		hh = math.max(y+h, hh)
	end
	self.pnl:set_size(ww + padding,hh + padding)
	self:fadeElems()
end

function Box:setScrollHeight(h)
	self.pnl:set_h(h)
end

function Box:destroy()
	if self.outerPnl then
		self.pnl = self.outerPnl
		self.outerPnl = nil
	end
	Box.super.destroy(self)
end

export = Box
PocoHud4.moduleEnd()
