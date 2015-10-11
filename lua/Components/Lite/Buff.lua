local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local O = ROOT.import('Options')()
local buffO = O('buff')

local clGood, clBad = cl.Green, cl.Red

local BuffElem = class()

function BuffElem:init(owner,data)
	self.owner = owner
	self.ppnl = owner.pnl
	self:set(data)
	self.ww = owner.pnl:w()
	self.hh = owner.pnl:h()
end
function BuffElem:set(data)
	self.dead = false
	local st = self.data and self.data.st
	self.data = data
	if st and data.et ~= 1 then
		self.data.st = st
	end
end
function BuffElem:_make()
	local style = buffO.style
	local vanilla = style == 2
	local glowy = style == 3

	local size = style==2 and 40 or buffO.buffSize
	local data = self.data
	local simple = self.owner:getSlot(data) == 2
	self.created = true
	if simple then
		local simpleRadius = buffO.simpleBusySize
		local pnl = self.ppnl:panel({x = (self.ww or 0)/2-simpleRadius,y=(self.hh or 0)/2-simpleRadius, w=simpleRadius*2,h=simpleRadius*2})
		self.pnl = pnl
		-- pnl:rect{color=cl.Red}
		local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
		self.pie = _G.CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = simpleRadius, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
	elseif vanilla then
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		local __, lbl  = _.l({
			align='center', fontSize=size/2, color = data.color or data.good and clGood or clBad,
			x=1,y=1, layer=2, blend_mode = 'normal', pnl=pnl
	  }, '')
		self.lbl = lbl
		self.bg = _G.HUDBGBox_create( pnl, { w = size, h = size, x = 0, y = 0 }, { color = cl.White, blend_mode = 'normal' } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = 'add', layer=1, x=0,y=0, color=style==2 and cl.White or data.good and clGood or clBad } ) or nil
		local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
		if self.bmp then
			if self.bmp:width() > size then
				self.bmp:set_size(size,size)
			end
			self.bmp:set_center(5+size + size/2,size/2)
		end
		pnl:set_shape(0,0,size*2+5,size*1.25)
		pnl:set_position(-100,-100)
	else
		local pnl = self.ppnl:panel({x = 0,y=0, w=100,h=100})
		self.pnl = pnl
		local __, lbl = _.l({
			align='center', fontSize=size/4, color = data.color or data.good and clGood or clBad,
			x=1,y=1, layer=2, blend_mode = 'normal', rotation=360, pnl=pnl
		}, '')
		self.lbl = lbl
		self.bg = pnl:bitmap( { name='bg', texture= 'guis/textures/pd2/hud_tabs',texture_rect=  { 105, 34, 19, 19 }, color= cl.Black:with_alpha(0.2), layer=0, x=0,y=0 } )
		self.bmp = data.icon and pnl:bitmap( { name='icon', texture=data.icon, texture_rect=data.iconRect, blend_mode = 'add', layer=1, x=0,y=0, color=data.good and clGood or clBad } ) or nil
		if glowy then
			self.pie = _G.CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = 'guis/textures/pd2/specialization/progress_ring',
			radius = size/2*1.2, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
			self.pie:set_position( -size*0.1, -size*0.1)
		else
			local texture = data.good and 'guis/textures/pd2/hud_progress_active' or 'guis/textures/pd2/hud_progress_invalid'
			self.pie = _G.CircleBitmapGuiObject:new( pnl, { use_bg = false, x=0,y=0,image = texture, radius = size/2, sides = 64, current = 20, total = 64, blend_mode = 'add', layer = 0} )
			self.pie:set_position( 0, 0)
		end
		if self.bmp then
			if self.bmp:width() > 0.7*size then
				self.bmp:set_size(0.7*size,0.7*size)
			end
			self.bmp:set_center(size/2,size/2)
		end
		pnl:set_shape(0,0,size,size*1.25)
		self.bg:set_size(size,size)
		pnl:set_position(-100,-100)
	end
end
function BuffElem:draw(t,x,y)
	if not self.dead then
		if not self.created then
			self:_make()
		end
		local data = self.data
		local st,et = data.st,data.et or 0
		local prog = (now()-st)/(et-st)
		local style = O:get('buff','style')
		local vanilla = style == 2
		local glowy = style == 3
		local simple = self.owner:getSlot(data) == 2
		if (prog >= 1 or prog < 0) and et ~= 1 then
			self.dead = true
		elseif alive(self.pnl) then
			if et == 1 then
				prog = st
			end
			x = self.x and self.x + (x-self.x)/5 or x
			y = self.y and self.y + (y-self.y)/5 or y
			if not simple then
				self.pnl:set_center(x,y)
			end
			self.x = x
			self.y = y
			local txts
			if simple then

			elseif vanilla then
				local sTxt = self.owner:_lbl(nil,data.text)
				if et == 1 then -- Special
					sTxt = sTxt ~= '' and (sTxt or ''):gsub(' ','\n') or  _.f(prog*100,1)..'%'
				else
					sTxt = _.f(et-now(),1)..'s'
				end
				txts = {{sTxt,cl.White}}
			else
				if type(data.text)=='table' then
					txts = data.text
				else
					txts = {{data.text and data.text..' ' or '',data.color}}
					table.insert(txts,{_.f(et ~= 1 and et-now() or prog*100)..(et == 1 and '%' or 's'),data.good and clGood or clBad})
				end
			end
			if not simple and self.lbl then
				self.owner:_lbl(self.lbl,txts)
				local _x,_y,w,h = self.lbl:text_rect()
				self.lbl:set_size(w,h)
				if vanilla then
					local ww, hh = self.bg:size()
					self.lbl:set_center(ww/2,hh/2)
				else
					local ww, hh = self.pnl:size()
					self.lbl:set_center(ww/2,hh-h/2)
				end
			end
			if self.pie then
				if O:get('buff','mirrorDirection') then
					self.pie._circle:set_rotation(-(1-prog)*360)
				end
				self.pie:set_current(1-prog)
			end
			if not self.dying then
				self.pnl:set_alpha(1)
			end
		end
	end
end
function BuffElem:_fade(pnl, done_cb, seconds)
	local pnl = self.pnl
	if not pnl then return end
	pnl:set_visible( true )
	pnl:set_alpha( 1 )
	local t = seconds
	while alive(pnl) and t > 0 do
		if not self.dead then
			self.dying = false
			break
		end
		local dt = coroutine.yield()
		t = t - dt
		pnl:set_alpha((self.lastD or 1) * t/seconds )
	end
	if self.dying then
		pnl:set_visible( false )
		if done_cb then done_cb(pnl) end
	end
end
function BuffElem:destroy(skipAnim)
	local pnl = self.pnl
	if self.created and alive(self.ppnl) and alive(pnl) then
		if not skipAnim then
			if not self.dying then
				self.dying = true
				pnl:stop()
				pnl:animate( callback( self, self, '_fade' ), callback( self, self, 'destroy' , true), 0.25 )
			end
		else
			self.ppnl:remove(self.pnl)
			self.owner.buffs[self.data.key] = nil
		end
	end
end
export = BuffElem
PocoHud4.moduleEnd()
