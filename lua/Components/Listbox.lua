local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Box = ROOT.import('Components/Box')
local Button = ROOT.import('Components/Button')
local Listbox = class(Box)

function Listbox:init(...) -- x,y,w,h[,font,fontSize] + items
	Listbox.super.init(self,  ...)
	self.name = 'Listbox'
	local conf = self.config

	if type(conf.items) == 'table' then
		local pad = 5
		local itemHeight, margin = conf.itemHeight or (conf.fontSize and conf.fontSize + pad) or 20, 0
		local y = 0
		for ind,itm in ipairs(conf.items) do
			-- itm == {itmName, itmCallback}
			local itmName, itmCallback = unpack(itm)
			local btn = Button:new(self,{
				x = 0, y = y, w = conf.w - 20, h = itemHeight, text = itmName, noBorder = true,
				fontSize = conf.fontSize
			})
			if itmCallback then -- itmCallback
				btn:on('click',function(b,...)
					if b==0 then
						itmCallback(b, ...)
						self:getRoot():setTaunt()
						return true, 'prompt_exit'
					end
				end)
			end
			y = y + itemHeight + margin
		end
		self:autoSize(10)
	end
	self._border = BoxGuiObject:new(self.outerPnl, {
		sides = {
			0,
			0,
			2,
			2
		}
	})
end

function Listbox:destroy()
	if self.outerPnl then
		self.pnl = self.outerPnl
		self.outerPnl = nil
	end
	Listbox.super.destroy(self)
end

export = Listbox
PocoHud4.moduleEnd()
