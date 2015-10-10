local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/Base')
local ThreadElem = ROOT.import('Components/Base/Thread')
local BuffElem = ROOT.import('Components/Lite/Buff')
local BuffModule = class(ModuleBase)
local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

function BuffModule:postInit()
	local rootUI = ROOT.UI
	self.C = self.O('buff')
	if self.C.enable then
		local __, err = pcall(self.installHooks,self)
		if err then
			_('!!BuffModuleErr: ',err)
		end
	end
	self.buffs = {}
	self.mainElem = ThreadElem:new(rootUI,{x=0,y=0,w=rootUI.pnl:w(),h=rootUI.pnl:h()})
	:on('thread',function(dt, ...)
		pcall(self.updatePos,self,dt)
	end)
end

function BuffModule:updatePos(dt)
	local indexes = {}
	for key,buffElem in pairs(self.buffs) do
		local slot = buffElem.config.slot or 1
		local origin = self:getOriginFromSlot(slot)
		local i = (indexes[slot] or 0) + 1
		buffElem.x = origin[1] + i * 100
		-- buffElem.y = origin[1] + i * 100
		indexes[slot] = i
	end
end

function BuffModule:getOriginFromSlot(slot)
	return ({
		{self.C.xPosition,self.C.yPosition},
		{90,22},
	})[slot or 1] or {50,50}
end

function BuffModule:getSlot(config)
	return 1
end

function BuffModule:Buff(config) -- {key='',icon=''||{},text={{},{}},st,et}
	if false == self.C[('show'.. ((config.key):gsub('^%l', string.upper)) )] then return end
	local buff = self.buffs[config.key]
	if buff and (buff.config.et ~= config.et or buff.config.good ~= config.good )then
		buff:destroy(1)
		buff = nil
	end
	if not buff then
		config.owner = self.mainElem
		config.slot = self:getSlot(config)
		local x, y = _.u(self:getOriginFromSlot(config.slot))
		config.x = self.mainElem.pnl:w() * x / 100
		config.y = self.mainElem.pnl:h() * y / 100
		config.w = 40
		config.h = 40
		buff = BuffElem:new(self,config):fadeIn()
		self.buffs[config.key] = buff
	else
		buff:set(config)
	end
end
function BuffModule:removeBuff(key,immediately)
	if not key then return end
	local target = self.buffs[key]
	self.buffs[key] = nil
	if target then
		if immediately then
			target:destroy()
		else
			target:fadeOut()
		end
	end
end

function BuffModule:installHooks()
	_('INSTALL HOOKS Start')
	local storage = {
		gadget = {}
	}
	local skillIcon = 'guis/textures/pd2/skilltree/icons_atlas'
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

	[]========================]======]--
	Hook( _G.PlayerStandard)
		-- :footer('_start_action_equip_weapon',function(__, self, ...)
		-- 	if O('game','rememberGadgetState') then
	  --     local wb = self._equipped_unit:base()
	  --     if wb and storage.gadget and storage.gadget[wb._name_id] then
	  --       if storage.gadget[wb._name_id] > 0 then
	  --         wb:set_gadget_on(storage.gadget[wb._name_id] )
	  --         local on = true or wb and wb.is_second_sight_on and wb:is_second_sight_on()
	  --         if on then
	  --           managers.enemy:add_delayed_clbk('gadget', function() module:_matchStance() end, now(1) + 0.01)
	  --         end
	  --       end
	  --     end
	  --   end
		-- end)
		:footer('_start_action_unequip_weapon', function(__, self, t ,data)
	    local alt = self._ext_inventory:equipped_unit()
	    for k,sel in pairs(self._ext_inventory._available_selections) do
	      if sel.unit ~= alt then
	        alt = sel.unit
	        break
	      end
	    end
	    local altTD = alt:base():weapon_tweak_data()
	    local multiplier = 1
	    multiplier = multiplier * managers.player:upgrade_value( 'weapon', 'swap_speed_multiplier', 1 )
	      * managers.player:upgrade_value( 'weapon', 'passive_swap_speed_multiplier', 1 )
	      * managers.player:upgrade_value( altTD[ 'category' ], 'swap_speed_multiplier', 1 )

	    local altT = (altTD.timers.equip or 0.7 ) / multiplier

	    local et = self._unequip_weapon_expire_t + altT
	    if et then
				_.c(_.s('st',t,'et',et))
	      module:Buff{
	        key='transition', good=false,
	        iconRect = { 0, 9*64,64,64 },
	        text='',
	        st=t, et=et
	      }
	    end
	  end)
		:footer('_end_action_running', function( __, self,t, input, complete  )
	    local et = self._end_running_expire_t
	    if not (self.RUN_AND_SHOOT or module.C.noSprintDelay) and et then
	      module:Buff{
	        key='transition', good=false,
	        icon=skillIcon,
	        iconRect = { 0, 9*64,64,64 },
	        text='',
	        st=now(), et=et
	      }
	    end
	  end)
		:footer('_interupt_action_use_item', function ( __, self,t, input, complete  )
	    local et = self._equip_weapon_expire_t
	    if et then
	      module:Buff{
	        key='transition', good=false,
	        icon=skillIcon,
	        iconRect = { 4*64, 3*64,64,64 },
	        text='',
	        st=now(), et=et
		    }
	    end
	  end)
		:footer('_start_action_reload', function( __, self,t  )
			local et = module.C.showReload and self._state_data.reload_expire_t
			if et then
				module:Buff{
					key='reload', good=false,
					icon=skillIcon,
					iconRect = { 0, 9*64,64,64 },
					text='',
					st=t, et=et
				}
			end
		end)
		:footer('_update_interaction_timers', function( __, self, t,... )
			local et = self._interact_expire_t
			if et then
				module:Buff{
					key='interaction', good=true,
					icon = 'guis/textures/pd2/pd2_waypoints',
					iconRect = {224, 32, 32, 32 },
					--icon = 'guis/textures/hud_icons',
					--iconRect = { 96, 144, 48, 48 },
					text='',
					st=t, et=et
				}
			end
		end)
		:footer('_interupt_action_interact', function( __, self, t, input, complete  )
			local et = self._equip_weapon_expire_t
	    if et then
	      module:removeBuff('interaction')
	      module:Buff{
	        key='transition', good=false,
	        icon=skillIcon,
	        iconRect = { 4*64, 3*64,64,64 },
	        text='',
	        st=now(), et=et
	      }
	    end
		end)
		:footer('_do_action_melee', function( __, self, t ,input )
	    local et = self._state_data.melee_expire_t
	    if et then
				module:Buff{
	        key='transition', good=false,
	        icon=skillIcon,
	        iconRect = { 1*64, 3*64,64,64 },
	        text='',
	        st=t, et=et
				}
	    end
	  end)
	  :header('_interupt_action_reload', function( __, self, t  )
	    if self:_is_reloading() then
	      module:removeBuff('reload')
	    end
	  end)
		:footer('_do_action_intimidate', function( __, self, t, interact_type, sound_name, skip_alert )
	    local et =_.g('managers.player:player_unit():movement()._current_state._intimidate_t')
	    if et and interact_type then
	      et = et + tweak_data.player.movement_state.interaction_delay
	      module:Buff{
	        key='interact', good=false,
	        icon=skillIcon,
	        iconRect = { 2*64, 8*64 ,64,64 },
	        st=t, et=et
	      }
	      local boost = self._ext_movement:rally_skill_data() and self._ext_movement:rally_skill_data().morale_boost_delay_t
	      if boost and boost > t then
	        module:Buff{
	          key='inspire', good=false,
	          icon=skillIcon,
	          iconRect = { 4*64, 9*64 ,64,64 },
	          st=t, et=boost
	        }
	      end
	    end
	    return r
	  end)
	local rectDict = {}
  -- rectDict.inner-skill-name = {Label, {iconX,iconY}, isPerkIcon, isDebuff }
  rectDict.combat_medic_damage_multiplier = {L('_buff_combatMedicDamageShort'), { 5, 7 }}
  rectDict.no_ammo_cost = {L('_buff_bulletStormShort'),{ 4, 5 }}
  rectDict.berserker_damage_multiplier = {L('_buff_swanSongShort'),{ 5, 12 }}

  rectDict.dmg_multiplier_outnumbered = {L('_buff_underdogShort'),{2,1}}
  rectDict.dmg_dampener_outnumbered = ''-- {'Def+',{2,1}} -- Dupe
  rectDict.dmg_dampener_outnumbered_strong = ''-- {'Def+',{2,1}} -- Dupe
  rectDict.overkill_damage_multiplier = {L('_buff_overkillShort'),{3,2}}
  rectDict.passive_revive_damage_reduction = {L('_buff_painkillerShort'), { 0, 10 }}

  rectDict.first_aid_damage_reduction = {L('_buff_first_aid_damage_reduction_upgrade'),{1,11}}
  rectDict.melee_life_leech = {L('_buff_lifeLeechShort'),{7,4},true,true}
  rectDict.dmg_dampener_close_contact = {L('_buff_first_aid_damage_reduction_upgrade'),{5,4},true}

  local _keys = { -- Better names for Option pnls
    BerserkerDamageMultiplier = 'SwanSong',
    PassiveReviveDamageReduction = 'Painkiller',
    FirstAidDamageReduction = 'FirstAid',
    DmgMultiplierOutnumbered = 'Underdog',
    CombatMedicDamageMultiplier = 'CombatMedic',
    OverkillDamageMultiplier = 'Overkill',
    NoAmmoCost = 'Bulletstorm',
    MeleeLifeLeech = 'LifeLeech',
    DmgDampenerCloseContact = 'CloseCombat'
  }
	Hook(_G.PlayerManager)
		:footer('drop_carry', function( __, self ,...)
	    module:Buff{
	      key='carryDrop', good=false,
	      icon=skillIcon, iconRect = {6*64, 0*64, 64, 64},
	      text='',
	      st=_G.Application:time(), et=managers.player._carry_blocked_cooldown_t
	    }
	  end)
		:footer('activate_temporary_upgrade', function( __, self, category, upgrade )
	    local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
	    if not et then return end
	    local rect = rectDict[upgrade]
	    if rect and rect ~= '' then
	      local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
	      local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
	      key = _keys[key] or key
	      module:Buff{
	        key=key, good=not rect[4],
	        icon=(rect2 and (rect[3] and 'guis/textures/pd2/specialization/icons_atlas' or skillIcon)) or 'guis/textures/pd2/lock_incompatible', iconRect = rect2,
	        text=rect and rect[1] or upgrade,
	        st=now(), et=et
	      }
	    end
	  end)
		:footer('activate_temporary_upgrade_by_level', function( __, self, category, upgrade, level )
	    local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
	    if not et then return end
	    local rect = rectDict[upgrade]
	    if rect ~= '' then
	      local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
	      local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
	      key = _keys[key] or key
	      module:Buff{
	        key=key, good=true,
	        icon=rect2 and skillIcon or 'guis/textures/pd2/lock_incompatible', iconRect = rect2,
	        text=rect and rect[1] or upgrade,
	        st=now(), et=et
	      }
	    end
	  end)

	_('INSTALL HOOKS DONE')
end

function BuffModule:preDestroy()
	self.mainElem:destroy()
end

export = BuffModule:new()

PocoHud4.moduleEnd()
