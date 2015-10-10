local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/Base/Thread')
local Button = ROOT.import('Components/Button')
local Box = class(ThreadElem)
local scrollAmount, scrollFriction = 100, 3
local normalW, highlightW = 5, 8

function Box:init( ... ) -- x,y,w,h[,font,fontSize] + [noBorder]
	Box.super.init(self, ...)
	self.name = 'Box'
	if not self.config.noBlur then
		self.pnl:bitmap({
			name = 'blur',
			texture = 'guis/textures/test_blur_df',
			render_template = 'VertexColorTexturedBlur3D',
			layer = -10, w=self.config.w, h=self.config.h
		})
	end
	if not self.config.noBorder then
		if self._border then
			self._border:close()
		end
		self._border = BoxGuiObject:new(self.pnl, {
			sides = self.config.sides or {
				1,
				1,
				2,
				2
			}
		})
	end

	if self.config.scroll then
		self.outerPnl = self.pnl
		self.scrollBar = self.pnl:panel{x=self.config.w - 5 - normalW, y=5, w=normalW ,h=self.config.h-10,layer=1}
		self.scrollBarRect = self.scrollBar:rect{color=cl.White,w=10,h=self.config.h}
		self:on('move',_.b(self,'checkGripMove'))
			:on('press',_.b(self,'checkGripPress'))
			:on('release',_.b(self,'checkGripRelease'))
			:on('leave',_.b(self,'gripLeave'))
		table.insert(self.extraPnls, self.outerPnl)
		self.pnl = self.pnl:panel(_.m({},self.config,{x=0, y=0, w=self.config.w-normalW, layer=-1}))
		self
			:on('press',function(btn, x, y)
				if btn == 'mouse wheel down' and self.outerPnl:visible() then
					return true, self:scrollBy(-scrollAmount) and 'selection_next' or ''
				end
				if btn == 'mouse wheel up' and self.outerPnl:visible() then
					return true, self:scrollBy(scrollAmount) and 'selection_previous' or ''
				end
			end, 999999)
			:on('thread',_.b(self,'checkGripPos'))
			:on('thread',_.b(self,'checkGripAlpha'))
		-- self.pnl:rect{color=cl.Red:with_alpha(0.3), valign='grow', halign='grow'}
	end
end

function Box:checkGripPos()
	local sb = self.scrollBar
	local curr =  self.__scrollY or -1
	local target =  self.__scrollYTarget or 0
	if sb and curr ~= target then
		self.__scrollY = math.round( curr + (target-curr)/scrollFriction)
		if math.abs(target - self.__scrollY) > 0.5 then
			self.pnl:set_y( self.__scrollY )

			if self.scrollBar then
				local sb,sbR = self.scrollBar, self.scrollBarRect
				local iY, iH, oH, h = self.pnl:y(), self.pnl:h(), self.outerPnl:h(), self.config.h - 10
				local sH = math.round( math.max( math.min(h, h * oH / iH), 10) )
				local y = math.round( math.min(h - 10 , math.max(5, 5 + (-iY / (iH-oH)) * (h-sH)) ) )
				local sW = math.lerp(normalW, highlightW, self.__gripAlpha or 0)
				local x = self.pnl:w() - sW
				sb:set_size(sW,sH)
				sbR:set_h(sH)
				sb:set_position(x,y)
				-- sb:rect{color=cl.White}
			end
		else
			self.__scrollY = target
		end
	end
end

function Box:checkGripAlpha()
	local sb = self.scrollBar
	local a =  self.__gripAlpha or -1
	local t =  self.__gripAlphaTarget or (self.pnl:h() > self.config.h and 0.15 or 0)
	if sb and a ~= t then
		self.__gripAlpha = a + (t-a)/10
		if math.abs(t - self.__gripAlpha) > 0.01 then
			sb:set_alpha( math.max(0, self.__gripAlpha) )
		else
			self.__gripAlpha = t
		end
	end
end

function Box:checkGripPress(b, x, y)
	if b == 0 and self.scrollBar and self.scrollBar:inside(x,y) then
		self.grabbed = true
		self.grabY = y
		self.__gripAlphaTarget = 1
		return true, 'slider_grab'
	end
end

function Box:checkGripMove(x, y)
	if self.grabbed then
		local dY = (self.grabY or 0 ) - y
		dY = dY * self.pnl:h() / self.config.h
		self:scrollBy( dY * scrollFriction )
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
		self.__gripAlphaTarget = nil
	end
end

function Box:inside(x,y)
	local isVisible = not self.outerPnl and true or self.outerPnl:inside(x,y)
	return isVisible and Box.super.inside(self,x,y)
end

function Box:updateElems()
	if self.config.fade then
		local px, py = self.pnl:position()
		local ow, oh = self.outerPnl:size()
		local pad = 50
		for __, elem in ipairs(self.elems) do
			if elem ~= self.scrollBar then
				local x,y,w,h = elem.pnl:shape()
				local yy = y + py + h/2
				if yy <= 0  or yy > oh then
					elem:set_alpha(0)
				elseif yy < pad then
					elem:set_alpha(0.5 + (yy / pad)/2)
				elseif yy > oh - pad then
					elem:set_alpha(0.5 + ((oh - yy) / pad)/2)
				else
					elem:set_alpha(1)
				end
			end
		end
	end
end

function Box:scrollTo(y)
	self.__scrollYTarget = y
	self.__gripAlpha = math.max(self.__gripAlpha or 0, 0.5)
	self:updateElems()
end
function Box:scrollBy(delta)
	if not self.dead then
		local y = self.pnl:y() + (delta or 0)
		local h = self.pnl:h()
		local nY = math.min(0,math.max( y, - h + 10 + self.outerPnl:h() ))
		self:scrollTo(nY)
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
	for __, elem in ipairs(self.pnl:children()) do
		local x,y,w,h = elem:shape()
		ww = math.max(x+w, ww)
		hh = math.max(y+h + padding, hh)
	end
	self.pnl:set_h(math.ceil(hh))
	self.__scrollY = nil
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
