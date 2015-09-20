local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local UI = class()
local Hook = ROOT.import('Hook')

local buttonStrings = {0,1,2,3,4,'mouse wheel down','mouse wheel up'}
function UI:init()
	self.name = 'UI';
	self.ws = managers.gui_data:create_fullscreen_workspace()
	self.ppnl = self.ws:panel()
	local w, h = self.ws:size()
	self.pnl = self.ppnl:panel({ name = 'UI', x=0, y=0, w = w, h = h, layer = tweak_data.gui.MENU_COMPONENT_LAYER})
	self.elems = {}

	self:_bakeMouseQuery('Press')
	self:_bakeMouseQuery('Release')
	self:_bakeMouseQuery('Click')
	self:_bakeMouseQuery('DblClick')

	local mouseThunk = function()
		return self._mouse_id
	end

	self.hooks = {
		Hook(_G.PlayerStandard):block('_get_input', mouseThunk, {}),
		Hook(_G.MenuRenderer):block('mouse_moved', mouseThunk, true),
		Hook(_G.MenuInput):block('mouse_moved', mouseThunk, true),
		-- Hook(_G.MenuManager):block('toggle_menu_state', mouseThunk, _.b(self,'hide',false))
	}

	self.buttonIDs = {}
	for k,v in ipairs(buttonStrings) do
		self.buttonIDs[Idstring(v):key()] = v
	end
end

function UI:visible()
	return self.pnl:visible()
end

function UI:draw(drawFunc)
	self.pnl:set_visible(true)
	return drawFunc(self)
end

function UI:hideAll()
	self.pnl:set_visible(false)
	self:useMouse(false)
end

function UI:registerElem(elem)
	if self.elems then
		table.insert(self.elems,elem)
	end
end

function UI:remove(elem)
	if self.elems then
		for k, foundElem in ipairs(_.m({},self.elems)) do
			elem:destroy()
			table.remove(self.elems,k)
		end
	end
end

function UI:bringToFront(elem)
	if self.elems then
		for k, foundElem in ipairs(self.elems) do
			if foundElem == elem then
				self.elems[1], self.elems[k] = elem, self.elems[1]
				break
			end
		end
	end
end

function UI:destroy()
	self.dead = true
	for k,elem in ipairs(self.elems) do
		elem:destroy()
	end
	self:useMouse(false)
	self.ppnl:remove(self.pnl)
	self.elems = nil
	self.buttonIDs = nil
	if alive(self.ws) then
		Overlay:gui():destroy_workspace(self.ws)
		self.ws = nil
	end
end

function UI:setTaunt(elem)
	if self.tauntElem and self.tauntElem ~= elem then
		self.tauntElem:destroy()
	end
	self.tauntElem = elem
end

function UI:focus(elem)
	if self.focusedElem then
		self.focusedElem:trigger('blur')
	end
	self.focusedElem = elem:trigger('focus')
end

function UI:onCancel()
	-- not implemented
end

function UI:queryMouseMove(o, ... ) -- x, y
	local tauntElem, stop, cursor, sound = self.tauntElem
	local process = function(_stop, _sound, _cursor)
		stop, sound, cursor = _stop, _sound or sound, _cursor or cursor
	end
	if tauntElem then
		process( tauntElem:queryMouseMove( ... ) )
	else
		for k,elem in ipairs(self.elems or {}) do
			if not stop then
				process( elem:queryMouseMove( ... ) )
			end
		end
	end
	if cursor then -- arrow, link, hand, grab
		managers.mouse_pointer:set_pointer_image( cursor)
	end
	if sound then
		--[[ menu_enter menu_exit highlight crime_net_startup zoom_in zoom_out
		loot_flip_card loot_fold_cards loot_gain_low loot_gain_med loot_gain_high
		Play_star_hit box_tick box_untick count_1 count_1_finished stinger_levelup
		selection_next selection_previous item_sell finalize_mask item_buy menu_error
		menu_skill_investment prompt_enter prompt_exit slider_grab slider_release
		sidejob_stinger_long sidejob_stinger_short job_appear
		]]
		managers.menu_component:post_event( sound )
	end
end

function UI:_bakeMouseQuery( typeName, ... )
	self['queryMouse'..typeName] = function ( __ , o, button, ... ) -- button, x, y
		local tauntElem, stop, sound = self.tauntElem
		local process = function(_stop, _sound)
			stop, sound = _stop, _sound or sound
		end
		button = self.buttonIDs[button:key()] or button
		if tauntElem then
			process( tauntElem['queryMouse'..typeName]( tauntElem, button, ... ) )
			if not stop and typeName == 'Click' then
				self:setTaunt(nil)
			end
		else
			for k,elem in ipairs(self.elems or {}) do
				if not stop then
					process( elem['queryMouse'..typeName]( elem, button, ... ) )
				end
			end
		end
		if sound then
			managers.menu_component:post_event( sound )
		end
	end
end

local currentUseMouseValue = false
function UI:useMouse(value)
	value = not not value
	if not currentUseMouseValue ~= not value then
		if value then
			self._mouse_id = managers.mouse_pointer:get_id()
			local data = {}
			data.mouse_move = _.b(self, 'queryMouseMove')
			data.mouse_press = _.b(self, 'queryMousePress')
			data.mouse_release = _.b(self, 'queryMouseRelease')
			data.mouse_click = _.b(self, 'queryMouseClick')
			data.mouse_double_click = _.b(self, 'queryMouseDblClick')
			data.id = self._mouse_id
			managers.mouse_pointer:use_mouse(data)
		else
			if self._mouse_id then
				managers.mouse_pointer:remove_mouse(self._mouse_id)
				self._mouse_id = nil
			end
		end
		currentUseMouseValue = value
	end
end

export = UI
PocoHud4.moduleEnd()
