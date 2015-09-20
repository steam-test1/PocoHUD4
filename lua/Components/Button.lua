local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/ThreadElem')
local Button = class(ThreadElem)

function Button:init(...) -- x,y,w,h[,font,fontSize] + [noBorder]
	Button.super.init(self,...)
	self.name = 'Button'
	local conf = self.config
	self:on('enter',function()
		self.lbl:set_color(conf.hColor or tweak_data.screen_colors.button_stage_2)
	end)
	:on('leave',function()
		self.lbl:set_color(conf.color or tweak_data.screen_colors.button_stage_3)
	end)

	if conf.noBorder then
		if self.bgRect then
			self:on('enter',function()
				self.bgRect:set_alpha(0.5)
			end)
			:on('leave',function()
				self.bgRect:set_alpha(0.3)
			end)
		end
	else
		self._border = BoxGuiObject:new(self.pnl, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._border:set_visible(false)
		self:on('enter',function() self._border:set_visible(true) end)
		:on('leave',function() self._border:set_visible(false) end)
	end
	local mergedText, lbl = _.l(
		_.m({	align = 'center', vertical = 'center', blend_mode='add'}, conf, { pnl = self.pnl, x = 0, y = 0}),
		conf.text, false
	)
	self:_refineText(lbl)
	self.lbl = lbl
end

function Button:_refineText(lbl)
	local x, y, w, h = lbl:text_rect()
	lbl:set_position(math.round(lbl:x()), math.round(lbl:y()))
	return w, h
end

function Button:destroy()
	if self.outerPnl then
		self.pnl = self.outerPnl
		self.outerPnl = nil
	end
	Button.super.destroy(self)
end

export = Button
PocoHud4.moduleEnd()
