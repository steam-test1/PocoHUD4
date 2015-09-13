local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoTab = ROOT.import('Components/Tab')
local PocoTabs = class()

function PocoTabs:init(ws,config) -- name,x,y,w,th,h,alt[,ptab]
	if not ws then
		_('PocoTabs no WS!!!',debug.traceback())
	end
	self.scrollLeft = 0
	self._ws = ws
	self.config = _.m({fontSize=15},config)
	self.pTab = config.pTab
	if self.pTab then
		self.pTab:children(self)
	end
	self.alt = config.alt
	self.pnl = (self.pTab and self.pTab.pnl or ws:panel()):panel{
		name = config.name , x = config.x, y = config.y, w = config.w, h = config.h,
		layer = self.pTab and 0 or Layers.TabHeader
	}
	if not self.pTab then
		self.pnl:set_center(self._ws:panel():center())
	end
	self.pnl:rect{color = cl.Black:with_alpha(0.3),layer = 0, y = config.th}
	self.items = {} -- array of PocoTab
	self._children = {} -- array of PocoTabs
	self.sPnl = self.pnl:panel{ name = config.name , x = 0, y = config.th, w = config.w, h = config.h-config.th}
	if not self.alt then
		local scrBoxW = 50
		self.scrBoxLeft = self.pnl:panel{
			name = 'left', x=0,y=0,w=scrBoxW,h=config.th
		}
		self.scrBoxRight = self.pnl:panel{
			name = 'right', x=config.w-scrBoxW,y=0,w=scrBoxW,h=config.th
		}
		self.scrBoxLeft:gradient{
			orientation = 'horizontal',
			gradient_points = {
				0,
				tweak_data.screen_color_blue,
				1,
				tweak_data.screen_color_blue:with_alpha(0)
			}
		}
		self.scrBoxRight:gradient{
			orientation = 'horizontal',
			gradient_points = {
				0,
				tweak_data.screen_color_blue:with_alpha(0),
				1,
				tweak_data.screen_color_blue
			}
		}
		self._thread = self.pnl:animate(self._update, self)
		BoxGuiObject:new(self.sPnl, {
			sides = {
				1,
				1,
				2,
				1
			}
		})
	end
end

function PocoTabs._update(o, self)
	while true do
		local dt = coroutine.yield()
		local x,y = self.xx, self.yy
		if x and y then
			if self.scrBoxLeft and self.scrBoxLeft:inside(x,y) then
				self:scroll_left(0.06/dt)
				self:repaint()
			end
			if self.scrBoxRight and self.scrBoxRight:inside(x,y) then
				self:scroll_right(0.06/dt)
				self:repaint()
			end
		end
		if self.scrBoxLeft then
			self.scrBoxLeft:set_alpha(self.scrollLeft==0 and 0 or 1)
		end
		if self.scrBoxRight then
			self.scrBoxRight:set_alpha(( (self.ww or 0) + self.scrollLeft > self.config.w) and 1 or 0)
		end
	end
end

function PocoTabs:canScroll(down,x,y)
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:canScroll(down,x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end
	if self.currentTab then
		return self.currentTab:canScroll(down,x,y)
	end
end

function PocoTabs:insideTabHeader(x,y,noChildren)
	self.xx = x
	self.yy = y
	for ind,tab in pairs(self.items) do
		local tResult = {tab:insideTabHeader(x,y,true)}
		if tResult[1] and self.tabIndex ~= ind then
			return self, ind
		end
	end
	local cTC = self.currentTab and self.currentTab._children
	if cTC then
		for ind,tabs in pairs(cTC) do
			local cResult = {tabs:insideTabHeader(x,y)}
			if cResult[1] then
				return unpack(cResult)
			end
		end
	end

	local dY = y-self.pnl:world_y()
	if dY>0 and self.config.th >= dY then
		if self.currentTab then
			return self, 0
		end
	end
end

function PocoTabs:goTo(index)
	local cnt = #self.items
	if index < 1 or index > cnt then
		return
	end
	if index ~= self.tabIndex then
		managers.menu:post_event('slider_release' or 'Play_star_hit')
		self.tabIndex = index
		self:scroll_auto(index)
		self:repaint()
	end
end
function PocoTabs:move(delta)
	self:goTo((self.tabIndex or 1) + delta)
end
function PocoTabs:add(tabName)
	local item = PocoTab:new(self,self.pnl,tabName)
	table.insert(self.items,item)
	self.tabIndex = self.tabIndex or 1
	self:repaint()
	return item
end


function PocoTabs:scroll_auto(index)
	local itm = self.items[index]
	local sL = self.scrollLeft
	-- check left
	self.scrollLeft = math.max(-itm.x,self.scrollLeft)
	-- check Right
	self.scrollLeft = math.min(-(itm.x+itm.w-self.config.w+20),self.scrollLeft)
	if sL ~= self.scrollLeft then
		self:repaint()
	end
end
function PocoTabs:scroll_left(delta)
	self.scrollLeft = math.min(0,self.scrollLeft + delta)
end

function PocoTabs:scroll_right(delta)
	self.scrollLeft = math.min(0, math.max(- (self.ww or 0) + self.config.w - 20, self.scrollLeft - delta))
end

function PocoTabs:repaint()
	local cnt = #self.items
	local x = self.scrollLeft
	if cnt == 0 then return end
	local tabIndex = self.tabIndex or 1
	for key,itm in pairs(self.items) do
		local isSelected = key == tabIndex
		if isSelected then
			self.currentTab = itm
		end
		local hPnl = self.pnl:panel{w = 200, h = self.config.th, x = x, y = 0}
		if itm.hPnl then
			self.pnl:remove(itm.hPnl)
		end
		if not self.alt then
			local bg = hPnl:bitmap({
				name = 'tab_top',
				texture = 'guis/textures/pd2/shared_tab_box',
				w = self.config.w, h = self.config.th + 3,
				color = cl.White:with_alpha(isSelected and 1 or 0.1)
			})
			local _, lbl = _.l({
				pnl = hPnl,
				x = 10, y = 0, w = 400, h = self.config.th,
				name = 'tab_name',
				font_size = self.config.fontSize,
				color = isSelected and cl.Black or cl.White,
				layer = 1,
				align = 'center',
				vertical = 'center'
			}, itm.name, true)
			local xx,yy,w,h = lbl:text_rect()

			lbl:set_size(w,self.config.th)

			bg:set_w(w + 20)
			itm.x = x - self.scrollLeft
			itm.w = w + 20
			x = x + w + 22
			self.ww = x - self.scrollLeft
			itm.bg = bg
		end
		itm.hPnl = hPnl
		if itm.box then
			itm.box.wrapper:set_visible(isSelected)
		end
		itm.pnl:set_visible(isSelected)
	end
	if self.currentTab then
		self.currentTab:scroll(0,true)
	end
end

function PocoTabs:destroy(ws)
	for k,v in pairs(self.items) do
		v:destroy()
	end
	if self._thread then
		self.pnl:stop(self._thread)
		self._thread = nil
	end
	self._ws:panel():remove(self.pnl)
end

export = PocoTabs
PocoHud4.moduleEnd()
