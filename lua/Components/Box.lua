local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Elem = ROOT.import('Components/Elem')
local Button = ROOT.import('Components/Button')
local Box = class(Elem)
local scrollAmount = 20

function Box:init( ... ) -- x,y,w,h[,font,fontSize] + [noBorder]
	Box.super.init(self, ...)
	self.name = 'Box'
	self.pnl:bitmap({
		name = 'blur',
		texture = 'guis/textures/test_blur_df',
		render_template = 'VertexColorTexturedBlur3D',
		layer = -1, w=self.config.w, h=self.config.h
	})

	if not self.config.noBorder then
		if self._border then
			self._border:close()
		end
		self._border = BoxGuiObject:new(self.pnl, {
			sides = {
				1,
				1,
				2,
				2
			}
		})
	end

	if self.config.scroll then
		self.outerPnl = self.pnl
		self.scrollBar = Button:new(self, {x=self.config.w - 15, y=5,w=10,h=self.config.h-10,
			noBorder=true,bgColor=cl.White})
		self:on('move',_.b(self,'checkGripMove'))
			:on('press',_.b(self,'checkGripPress'))
			:on('release',_.b(self,'checkGripRelease'))
			:on('leave',_.b(self,'gripLeave'))
		table.insert(self.extraPnls, self.outerPnl)
		self.pnl = self.pnl:panel(_.m({},self.config,{x=0, y=0, w=self.config.w-20, layer=1}))
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

function Box:checkGripPress(b, x, y)
	if b == 0 and self.scrollBar and self.scrollBar:inside(x,y) then
		self.grabbed = true
		self.grabY = y
	end
end

function Box:checkGripMove(x, y)
	if self.grabbed then
		local dY = (self.grabY or 0 ) - y
		dY = dY * self.pnl:h() / self.config.h
		self:scrollY( dY )
		self.grabY = y
		return true, false, 'grab'
	end
	if self.scrollBar and self.scrollBar:inside(x,y) then
		return true, false, 'hand'
	end
end

function Box:checkGripRelease(b, x, y)
	if self.scrollBar then
		self:gripLeave()
	end
end
function Box:gripLeave()
	if self.grabbed then
		self.grabbed = nil
		self.grabY = nil
	end
end

function Box:inside(x,y)
	return (self.outerPnl and self.outerPnl:inside(x,y) or true) and Elem.inside(self,x,y)
end

function Box:updateElems()
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
	if self.scrollBar then
		local sBtn = self.scrollBar
		local iY, iH, oH, h = self.pnl:y(), self.pnl:h(), self.outerPnl:h(), self.config.h - 10
		local sH = math.min(h, h * oH / iH)
		local y = 5 + (-iY / (iH-oH)) * (h-sH)
		sBtn:setSize(false, sH)
		sBtn:setPosition(false, y)
	end
end

function Box:scrollY(delta)
	if not self.dead then
		local y = self.pnl:y() + (delta or 0)
		local h = self.pnl:h()
		local nY = math.min(0,math.max( y, - h + 10 + self.outerPnl:h() ))
		self.pnl:set_y( nY )
		self:updateElems()
		return nY==y
	end
end

function Box:autoSize(padding)
	if self.config.scroll then
		padding = padding or 20
	else
		padding = 0
	end
	local ww,hh = self.config.w, self.config.h
	for __, elem in ipairs(self.elems) do
		local x,y,w,h = elem.pnl:shape()
		ww = math.max(x+w, ww)
		hh = math.max(y+h, hh)
	end
	self.pnl:set_size(self.pnl:w(),hh + padding)
	self:updateElems()
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
