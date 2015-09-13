local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')
-- GLOBALS: Input

local PocoUIKeyValue = class(PocoUIValue)
function PocoUIKeyValue:init(parent,config,inherited)
	config.noArrow = true
	self.super.init(self,parent,config,true)
	self:val(config.value or '')
	self:_bind(PocoEvent.Pressed,function(self,x,y)
		self.mute = true
		if self._waiting then
			self:sound('menu_error')
			self:cancel()
		else
			self:sound('prompt_enter')
			self:setup()
		end
	end):_bind(PocoEvent.Click,function(self,x,y)
		if not self:inside(x,y) then
			self:sound('menu_error')
			self:cancel()
		end
	end)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIKeyValue:setup()
	self._waiting = true
	ROOT._focused = self
	ROOT.ws:connect_keyboard(Input:keyboard())
	local onKeyPress = function(o, key)
		ROOT._lastFocusT = now()
		local keyName = Input:keyboard():button_name_str(key)
		if key == Idstring('backspace') then
			self:sound('menu_error')
			self:val('')
			self:cancel()
			return
		end
		local ignore = ('enter,space,esc,num abnt c1,num abnt c2,@,ax,convert,kana,kanji,no convert,oem 102,stop,unlabeled,yen,mouse 8,mouse 9'):split(',')
		for __,iKey in pairs(ignore) do
			if key == Idstring(iKey) then
				if iKey ~= 'esc' then
					managers.menu:show_key_binding_forbidden({KEY = keyName})
				end
				self:sound('menu_error')
				self:cancel()
				return
			end
		end
		ROOT:ignoreBind()
		self:sound('menu_skill_investment')
		self:val(keyName)
		self:cancel()
	end
	_.l(self.valLbl,'_',true)
	self.valLbl:key_press(onKeyPress)
end

function PocoUIKeyValue:cancel()
	self._waiting = nil
	ROOT.ws:disconnect_keyboard()
	ROOT._focused = nil
	self.valLbl:key_press(nil)
	self:val(self:val())
end

function PocoUIKeyValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		if set == '' then
			set = {'NONE',cl.Silver}
		else
			set = set:upper()
		end
		_.l(self.valLbl,set,true)
	end
	return val
end



export = PocoUIKeyValue

PocoHud4.moduleEnd()
