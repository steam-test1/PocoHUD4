local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Hook = ROOT.import('Hook')
local ModuleBase = ROOT.import('Modules/Base')
local ThreadElem = ROOT.import('Components/Base/Thread')
local DamagedElem = ROOT.import('Components/Lite/Damaged')

local DamagedModule = class(ModuleBase)
local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

local clBad = O('root','colorNegative')
local clGood = O('root','colorPositive')
local skillIcon = 'guis/textures/pd2/skilltree/icons_atlas'

function DamagedModule:postInit()
	local rootUI = ROOT.UI
	self.C = self.O('hit')
	if self.C.enable then
		local __, err = pcall(self.installHooks,self)
		if err then
			_.d('!!DamagedModuleErr: ',err)
		end
	end
	self.elems = {}
	self.mainElem = ThreadElem:new(rootUI,{x=0,y=0,w=rootUI.pnl:w(),h=rootUI.pnl:h()})
	:on('thread',function(dt, ...)
		local __, err = pcall(self.update,self,dt)
		if err then
			_.d('!!DamagedModuleErr: ',err)
		end
	end)
	self.pnl = self.mainElem.pnl
end

function DamagedModule:update(dt)
	local t = now()
	for k, v in pairs(self.elems) do
	end
end

function DamagedModule:Hit(that, result, data, isShield, rate)
-- TODO
end

function DamagedModule:installHooks()
	_('INSTALL HOOKS Start')

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
	Hook(_G.PlayerDamage)
		:body('_calc_armor_damage', function( org , this, attack_data )
			local valid = this:get_real_armor() > 0
			local result = org(this, attack_data)
			if valid then
				self:Hit(this,result,attack_data,true,this:get_real_armor() / this:_total_armor() )
			end
			return result
		end)
		:body('_calc_health_damage', function( org , this, attack_data )
			local valid = this:get_real_armor() > 0
			local result = org(this, attack_data)
			if valid then
				self:Hit(this,result,attack_data,false,self:health_ratio() )
			end
			return result
		end)


	_('INSTALL HOOKS DONE')
end

function DamagedModule:preDestroy()
	self.mainElem:destroy()
end

export = DamagedModule:new()

PocoHud4.moduleEnd()
