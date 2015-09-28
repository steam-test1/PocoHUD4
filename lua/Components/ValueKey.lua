local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ValueChoose = ROOT.import('Components/ValueChoose')

local ValueKey = class(ValueChoose)
function ValueKey:init(parent,config)
	config.noArrow = true
	ValueKey.super.init(self,parent,config,true)
	self:val(config.value or '')
	self:on('press',function(b,x,y)
		if b == 0 then
			if self._waiting then
				self:cancel()
				return true, 'menu_error'
			else
				self:setup()
				return true, 'prompt_enter'
			end
		end
	end):on('click',function(b,x,y)
		if b == 0 and not self:inside(x,y) then
			self:cancel()
			return true, 'menu_error'
		end
	end)
end

function ValueKey:setup()
	self._waiting = true
	ROOT._focused = self
	self:getRoot().ws:connect_keyboard(Input:keyboard())
	local onKeyPress = function(o, key)
		ROOT._stringFocused = now()
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

function ValueKey:cancel()
	self._waiting = nil
	self:getRoot().ws:disconnect_keyboard()
	ROOT._focused = nil
	self.valLbl:key_press(nil)
	self:val(self:val())
end

function ValueKey:val(set)
	local val = ValueKey.super.val(self,set)
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

export = ValueKey
PocoHud4.moduleEnd()
