local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local BaseElem = ROOT.import('Components/Base/Base')
local Handle = class(BaseElem)

function Handle:init(...)
	Handle.super.init(self, ...)
	if self.config.text then
		local mergedText, lbl = _.l(
			_.m({	align = 'center', vertical = 'center', blend_mode='add'}, self.config, { pnl = self.pnl, x = 0, y = 0}),
			self.config.text or '', false
		)
	end
	if not self.config.noBorder then
		self._border = BoxGuiObject:new(self.pnl, {
			sides = {
				2,
				2,
				1,
				1
			}
		})
	end
	local target = self.owner
	target:on('press',function(b,x,y)
		if b == 0 and self:inside(x,y) then
			self.grabbed = true
			self._x = x
			self._y = y
		end
	end):on('move',function(x,y)
		if self.grabbed then
			local tPnl = target.outerPnl or target.pnl
			if not tPnl then
				return
			end
			local tX,tY = tPnl:x() + (x - self._x), tPnl:y() + (y - self._y)
			tPnl:set_x(tX)
			tPnl:set_y(tY)
			local wx,wy,ww,wh = tPnl:world_shape()
			local px,py,pw,ph = tPnl:parent():world_shape()
			if wx < px then
				tPnl:set_world_x(px)
			end
			if wy < py then
				tPnl:set_world_y(py)
			end
			if wx + ww > px + pw then
				tPnl:set_world_x(px + pw - ww)
			end
			if wy + wh > py + ph then
				tPnl:set_world_y(py + ph - wh)
			end

			self._x = x
			self._y = y
			if self:inside(x,y) then
				return true, false, 'grab'
			end
		else
			if self:inside(x,y) then
				return true, false, 'hand'
			end
		end
	end):on('release',function(b,x,y)
		if self.grabbed then
			self.grabbed = nil
			self._x = nil
			self._y = nil
		end
	end):on('leave',function(b,x,y)
		if self.grabbed then
			self.grabbed = nil
			self._x = nil
			self._y = nil
		end
	end)
end

export = Handle
PocoHud4.moduleEnd()
