local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoScrollBox = class(ROOT.import('Components/BaseElem'))
-- GLOBALS: shift
function PocoScrollBox:init(parent,config,inherited)
	self.parent = parent
	self.config = config
	self.wrapper = config.pnl:panel(config)
	self.pnl = self.wrapper:panel{ x=0, y=0, w =self.wrapper:w(), h = self.wrapper:h(), name = 'content'}
	local m,sW = 10,4
	local sH = self.wrapper:h()-(2*m)
	local _matchScroll = function()
		local pH,wH = self.pnl:h(), self.wrapper:h()
		self.sPnl:set_y(m-self.pnl:y()*wH/pH)
		self.sPnl:set_h(self.wrapper:h()/self.pnl:h() * sH - m)
	end
	self._matchScroll = _matchScroll
	self.sPnl = self.wrapper:panel{ x=self.wrapper:w()-sW-m/2, y=m, w =sW, h = sH, name = 'scroll', visible = false}
	BoxGuiObject:new(self.sPnl, { sides = {2,2,0,0} }):set_aligns('scale', 'scale')
	self.sPnl:stop()
	self.sPnl:animate(function(p)
		while alive(p) do
			if p:visible() then
				local a = math.max(0.05,0.3-now()+(self._t or 0))*4
				if a ~= self._a then
					p:set_alpha(a)
					self._a = a
				end
			end
			coroutine.yield()
		end
	end)

	self.pnl:stop()
	self.pnl:animate(function(panel)
		while alive(panel) do
			if panel:visible() then
				local tY,cY = math.floor(self.y or 0),math.floor(panel:y())
				local rY = math.floor(cY + ((tY-cY)/5))
				if tY~=rY then
					if math.abs(tY - rY)<5 then
						rY = tY
					end
					rY = math.floor(rY + 1)
					self._t = now()
					panel:set_y(rY)
					_matchScroll()
				end
			end
			coroutine.yield()
		end
	end)

	local scrollStep = 60
	self:_bind(PocoEvent.WheelUp,function(_self,x,y)
		if not shift() and self:canScroll(false,x,y) then
			return true, self:scroll(scrollStep)
		end
	end):_bind(PocoEvent.WheelDown,function(_self,x,y)
		if not shift() and self:canScroll(true,x,y) then
			return true, self:scroll(-scrollStep)
		end
	end)
	if not inherited then
		self:postInit(self)
	end
end

function PocoScrollBox:set_h(_h)
	self.pnl:set_h(math.max(self.wrapper:h(),_h or 0))
	if self.pnl:h() > self.wrapper:h() then
		self.sPnl:set_visible(true)
	else
		self.sPnl:set_visible(false)
		self:scroll(0,true)
	end
	self:_matchScroll()
end

function PocoScrollBox:isLarge()
	return self.pnl:h() > self.wrapper:h()
end

function PocoScrollBox:canScroll(down,x,y)
	local result = self:isLarge() and self.wrapper:inside(x,y) and self
	if (self._errCnt or 0) > 1 then
		local pos = self.y or 0
		if (pos == 0) ~= down then
			result = false
		end
	end
	return result
end

function PocoScrollBox:scroll(val,force)
	local tVal = force and 0 or (self.y or 0) + val
	local pVal = math.clamp(tVal,self.wrapper:h()-self.pnl:h()-20,0)
	if pVal ~= tVal then
		self._errCnt = 1+ (self._errCnt or 0)
	else
		self._errCnt = 0
		if not force then
			managers.menu:post_event(val>0 and 'slider_increase' or 'slider_decrease')
		end
	end
	self.y = pVal
end
export = PocoScrollBox
PocoHud4.moduleEnd()
