local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/base')
local BuffModule = class(ModuleBase)
local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

function BuffModule:postInit()
	self.C = self.O('buff')
	if self.C.enable then
		local __, err = pcall(self.installHooks,self)
		if err then
			_('!!BuffModuleErr: ',err)
		end
	end
end

local _tempStanceDisable
function BuffModule:_matchStance(tempDisable)
	local r,err = pcall(function()
		_tempStanceDisable = tempDisable
		local crook = O:get('game','cantedSightCrook') or 0
		local state = _.g('managers.player:player_unit():movement():current_state()')
		if crook>1 and state and state._stance_entered then
			state:_stance_entered()
		end
		_tempStanceDisable = nil
	end)
	if not r then _(_.s('MatchStance:',err)) end
end

function BuffModule:installHooks()
	_('INSTALL HOOKS Start')
	local storage = {
		gadget = {}
	}
	local module = self
	self.storage = storage
	--[======[] Hook sample []======[]
	hook = Hook( _G.objName)
	  -- body : replace a function (unique)
		:body('methodName', function(org,self,...)
			-- manipulate things
			local result = {org(self, ...)}
			return _.u(result)
		end)
	  -- block : simply disable a function by conditionThunk (unique)
		:block('methodName', function () return math.random() > 0.1 end, function(a) return a + 1 end )
		-- header / footer : do things before / after body
		:header('methodName', function(orgResult,self,...)
			-- orgResult == {} @ header
			-- orgResult == {result,of,org,method} @ footer
		end)

	[]====================[][]======]--
	Hook( _G.PlayerStandard)
		:footer('_start_action_equip_weapon',function(__, self, ...)
			if O('game','rememberGadgetState') then
	      local wb = self._equipped_unit:base()
	      if wb and storage.gadget and storage.gadget[wb._name_id] then
	        if storage.gadget[wb._name_id] > 0 then
	          wb:set_gadget_on(storage.gadget[wb._name_id] )
	          local on = true or wb and wb.is_second_sight_on and wb:is_second_sight_on()
	          if on then
	            managers.enemy:add_delayed_clbk('gadget', function() module:_matchStance() end, now(1) + 0.01)
	          end
	        end
	      end
	    end
		end)

	_('INSTALL HOOKS End')
end

function BuffModule:preDestroy()

end

export = BuffModule:new()

PocoHud4.moduleEnd()
