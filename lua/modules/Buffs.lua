local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/Base')
local ThreadElem = ROOT.import('Components/Base/Thread')
local BuffElem = ROOT.import('Components/Lite/Buff')
local BuffModule = class(ModuleBase)
local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

local clBad = O('root','colorNegative')
local clGood = O('root','colorPositive')
local skillIcon = 'guis/textures/pd2/skilltree/icons_atlas'

function BuffModule:postInit()
	local rootUI = ROOT.UI
	self.C = self.O('buff')
	if self.C.enable then
		local __, err = pcall(self.installHooks,self)
		if err then
			_.d('!!BuffModuleErr: ',err)
		end
	end
	self.buffs = {}
	self.mainElem = ThreadElem:new(rootUI,{x=0,y=0,w=rootUI.pnl:w(),h=rootUI.pnl:h()})
	:on('thread',function(dt, ...)
		local __, err = pcall(self.update,self,dt)
		if err then
			_.d('!!BuffModuleErr: ',err)
		end
	end)
	self.pnl = self.mainElem.pnl

end

function BuffModule:getSlot(data)
	local key = data.key
	return O:get('buff','simpleBusyIndicator') and (key == 'transition' or key == 'reload' or key == 'charge') and 2 or 1
end

function BuffModule:Buff(data) -- {key='',icon=''||{},text={{},{}},st,et}
	if false == self.C[('show'.. ((data.key):gsub('^%l', string.upper)) )] then return end
	local buff = self.buffs[data.key]
	if buff and (buff.data.et ~= data.et or buff.data.good ~= data.good )then
		buff:destroy(1)
		buff = nil
	end
	if not buff then
		data.slot = self:getSlot(data)
		buff = BuffElem:new(self,data)
		self.buffs[data.key] = buff
	else
		buff:set(data)
	end
end

function BuffModule:_checkSkills(t)
	-- Check Another Buffs
	-- Berserker
	if managers.player:upgrade_value( 'player', 'melee_damage_health_ratio_multiplier', 0 )>0 then
		local health_ratio = _.g('managers.player:player_unit():character_damage():health_ratio()')
		if(health_ratio and health_ratio <= tweak_data.upgrades.player_damage_health_ratio_threshold ) then
			local damage_ratio = 1 - ( health_ratio / math.max( 0.01, tweak_data.upgrades.player_damage_health_ratio_threshold ) )
			local mMul =  1 + managers.player:upgrade_value( 'player', 'melee_damage_health_ratio_multiplier', 0 ) * damage_ratio
			local rMul =  1 + managers.player:upgrade_value( 'player', 'damage_health_ratio_multiplier', 0 ) * damage_ratio
			if mMul*rMul > 1 then
				local text = {{(mMul>1 and _.f(mMul)..'x' or '')..(rMul>1 and ' '.._.f(rMul)..'x' or ''),clBad}}
				self:Buff{
					key= 'berserker', good=true,
					icon=skillIcon,
					iconRect = { 2*64, 2*64,64,64 },
					text=text,
					color=cl.Red,
					st=O:get('buff','style')==2 and damage_ratio or 1-damage_ratio, et=1
				}
			end
		else
			self:removeBuff('berserker')
		end
	end
	-- Stamina
	local movement = _.g('managers.player:player_unit():movement()')
	if movement then
		local currSt = movement._stamina
		local maxSt = movement:_max_stamina()
		local thrSt = movement:is_above_stamina_threshold()
		if currSt < maxSt then
			self:Buff{
				key= 'stamina', good=false,
				icon=skillIcon,
				iconRect = { 7*64, 3*64,64,64 },
				text=thrSt and '' or L('_buff_exhausted'),
				st=(currSt/maxSt), et=1
			}
		else
			self:removeBuff('stamina')
		end
	end
	-- Suppression
	local supp = _.g('managers.player:player_unit():character_damage():effective_suppression_ratio()')
	if supp and supp > 0 then
		-- Not in effect as of now : local supp2 = math.lerp( 1, tweak_data.player.suppression.spread_mul, supp )
		self:Buff{
			key= 'suppressed', good=false,
			icon=skillIcon,
			iconRect = { 7*64, 0*64,64,64 },
			text='', --_.f(supp2)..'x',
			st=supp, et=1
		}
	else
		self:removeBuff('suppressed')
	end

	local melee = self.state and self.state._state_data.meleeing and self.state:_get_melee_charge_lerp_value( t ) or 0
	if melee > 0 then
		self:Buff({
			key= 'charge', good=true,
			icon=skillIcon,
			iconRect = { 4*64, 12*64,64,64 },
			text='',
			st=melee, et=1
		})
	else
		self:removeBuff('charge')
	end
end

function BuffModule:_lbl(lbl,txts)
	local result = ''
	if not alive(lbl) then
		if type(txts)=='table' then
			for __, t in pairs(txts) do
				result = result .. tostring(t[1])
			end
		else
			result = txts
		end
	else
		if type(txts)=='table' then
			local pos = 0
			local posEnd = 0
			local ranges = {}
			for _k,txtObj in ipairs(txts or {}) do
				txtObj[1] = tostring(txtObj[1])
				result = result..txtObj[1]
				local __, count = txtObj[1]:gsub('[^\128-\193]', '')
				posEnd = pos + count
				table.insert(ranges,{pos,posEnd,txtObj[2] or cl.White})
				pos = posEnd
			end
			lbl:set_text(result)
			for _,range in ipairs(ranges) do
				lbl:set_range_color( range[1], range[2], range[3] or cl.Green)
			end
		elseif type(txts)=='string' then
			result = txts
			lbl:set_text(txts)
		end
	end
	return result
end

function BuffModule:update(dt)
	local t = now()
	self:_checkSkills(t)
	if t - (self._lastBuff or 0) >= 1/O:get('buff','maxFPS') then
		self._lastBuff = t
		local buffO = O:get('buff')
		local style = buffO.style
		local vanilla = style == 2
		local align = buffO.justify
		local size = (vanilla and 40 or buffO.buffSize) + buffO.gap
		local count = 0
		for key,buff in pairs(self.buffs) do
			if not (buff.dead or buff.dying or self:getSlot(buff.data) == 2) then
				count = count + 1
			end
		end
		local x,y,move = self.pnl:size()
		x = x * buffO.xPosition/100 - size/2
		y = y * buffO.yPosition/100 - size/2
		local oX,oY = x,y
		if align == 1 then
			move = size
		elseif align == 2 then
			move = size
			if vanilla then
				y = y - count * size / 2
			else
				x = x - count * size / 2
			end
		else
			move = -size
		end
		for key,buff in _.p(self.buffs) do
			if not (buff.dead or buff.dying) then
				if self:getSlot(buff.data) == 2 then
					-- do not move
				elseif vanilla then
					y = y + move
				else
					x = x + move
				end
				buff:draw(t,x,y)
			elseif not buff.dying then
				buff:destroy()
			end
		end
	end
end

function BuffModule:removeBuff(key,immediately)
	if not key then return end
	local buff = self.buffs[key]
	if buff and not buff.dying then
		buff.dead = true
		buff:destroy(immediately)
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
	      module:Buff{
	        key='transition', good=false,
	        icon=skillIcon,
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
	  end)
		:footer('_check_action_primary_attack', function( __, self, t, ... )
			-- capture TriggerHappy
			local weap_base = self._equipped_unit:base()
			local weapon_category = weap_base:weapon_tweak_data().category
			if managers.player:has_category_upgrade(weapon_category, 'stacking_hit_damage_multiplier') then
				local stack = self._state_data and self._state_data.stacking_dmg_mul and self._state_data.stacking_dmg_mul[weapon_category]
				local thMaxTime = (module.__triggerHappyMaxTime or (stack and stack[1]) or 0)
				if thMaxTime and (t < thMaxTime) then
					local mul = 1 + managers.player:upgrade_value(weapon_category, 'stacking_hit_damage_multiplier') * stack[2]
					module:Buff{
						key='triggerHappy', good=true,
						icon=skillIcon, iconRect = {7*64, 11*64, 64, 64},
						text=_.f(mul)..'x',
						st=t, et=stack[1]
					}
				else
					module:removeBuff('triggerHappy')
				end
			end
		end)
		:footer('_do_melee_damage', function( __, self, t, ... )
			-- capture Close Combat
			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				local stack = self._state_data.stacking_dmg_mul.melee
				if stack and stack[1] and t < stack[1] then
					local mul = 1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier") * stack[2]
					module:Buff({
						key='triggerHappy', good=true,
						icon=skillIcon, iconRect = {4*64, 0*64, 64, 64},
						text=_.f(mul)..'x',
						st=t, et=stack[1]
					})
				else
					module:removeBuff('triggerHappy')
				end
			end
		end)

	Hook( _G.PlayerStandard)
		:header('TriggerHappy', function(player_manager, damage_bonus, max_stacks, max_time)
			-- feeds in TriggerHappy max-time
			module.__triggerHappyMaxTime = max_time
			return Run('Function*TrgHpy', player_manager, damage_bonus, max_stacks, max_time)
		end)


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
	Hook(_G.PlayerMovement)
		:footer('on_morale_boost', function( __, self, benefactor_unit )
			if self._morale_boost then
				local et = now() + tweak_data.upgrades.morale_boost_time
				module:Buff{
					key='boost', good=true,
					icon=skillIcon,
					iconRect = { 4*64, 9*64 ,64,64 },
					st=now(), et=et
				}
			end
		end)
	Hook(_G.PlayerDamage)
		:footer('set_regenerate_timer_to_max', function( __, self )
			local sd = self._supperssion_data and self._supperssion_data.decay_start_t
			if sd then
				sd = math.max(0,sd-now())
			end
			local et = now()+self._regenerate_timer+(sd or 0)
			if et then
				module:Buff{
					key='shield', good=false,
					icon=skillIcon,
					iconRect = { 6*64, 4*64,64,64 },
					text='',
					st=now(), et=et
				}
			end
		end)
	Hook(_G.ECMJammerBase)
		:footer( 'set_active', function( __, self, active )
			local et = self:battery_life() + now()
			if active and (module.__lastECM or 0 < et)then
				module.__lastECM = et
				module:Buff{
					key='ECM', good=true,
					icon=skillIcon,
					iconRect = { 1*64, 4*64,64,64 },
					text='',
					st=now(), et=et
				}
			end
		end)
		:footer('set_feedback_active', function( __, self )
			local et = self._feedback_duration
			if et then
				module:Buff{
					key='feedback', good=true,
					icon=skillIcon,
					iconRect = { 6*64, 2*64,64,64 },
					text='',
					st=now(), et=et+now()
				}
			end
		end)
	Hook(_G.SecurityCamera)
		:footer('_start_tape_loop', function( __, self , tape_loop_t)
			local et = tape_loop_t+6
			if et then
				module:Buff{
					key='tapeLoop', good=true,
					icon=skillIcon,
					iconRect = { 4*64, 2*64,64,64 },
					text='',
					st=now(), et=et+now()
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
