--[[
PH4 entry point
]]
-- SETGLOBALFILE OFF
-- Shimming
local currModPath = rawget( _G, 'ModPath' ) or 'lib/Lua/base/'
currModPath = currModPath:gsub( 'base', 'PocoHud4' )
log = log or function( t ) io.stdout:write(tostring(t)..'\n') end

-- Module
local modules = {
  _INSTANCE = string.format('%06x', math.random()*0xffffff)
}
local payload = {}
if rawget(_G, 'PocoMods') then
  payload = PocoMods.payload
end
local PocoMods = {}
PocoMods.savePath = rawget(_G,'SavePath') or currModPath
PocoMods.currModPath = currModPath

PocoMods.moduleBegin = function()
    local org = debug.getinfo(2,'S').source:lower()
    local name = org:gsub('.+/lua/',''):gsub('\.luac?','')
    local moduleEnv = setmetatable({},{__index=_G})
    moduleEnv._name = name
    moduleEnv._modules = modules
    moduleEnv.ROOT = PocoMods
    local newEnv = modules[name] or setmetatable({},{__index=moduleEnv})
    modules[name] = newEnv
    setfenv(2,newEnv)
    return newEnv
  end
PocoMods.moduleEnd = function ()
    setfenv(2,_G)
  end
PocoMods.import = function (name, spread)
  name = name:lower()
  -- log(' import:'..name..' from '..debug.getinfo(2).short_src:lower())
  if not modules[name] then
    local fileName = currModPath..'lua/'..name..'.lua'
    local file = io.open( fileName, 'r' )
    if file ~= nil then
      pcall( dofile, fileName )
    end
  end
  if not modules[name] then
    return log('!Err:Module ['..tostring(name)..'] is not found.')
  end
  if type(spread) == 'table' then
    local newEnv = spread
    local newModule = modules[name] or {}
    for k,v in pairs(newModule) do
      newEnv[k] = v
    end
    return newModule.export or newModule
  else
    if modules[name] then
      return modules[name].export or modules[name]
    else
      return {}
    end
  end
end
PocoMods._kbd = Input:keyboard()
PocoMods.unload = function()
  if PocoMods.UI then
    PocoMods.UI:destroy()
    PocoMods.UI = nil
  end
  for name in pairs(modules) do
    if type(modules[name])=='table' and rawget(modules[name],'destroy') then
      modules[name].destroy()
    end
    modules[name] = nil
  end
  PocoMods.active = false

  -- TODO: Save payload to PocoMods.payload @ here
end
PocoMods.active = true
function PocoMods:sanitizeKey(key)
	local keyT = type(key)
	if keyT == 'number' then
		if key == 0 then
			key = 11
		elseif key < 10 then -- Number key
			--key = key + 1
		end
	elseif keyT == 'string' then
		key = string.lower(key)
		key = self._kbd:has_button( Idstring( key ) ) and self._kbd:button_index( Idstring( key ) )
		keyT = type(key)
	end
	if keyT ~= 'number' then
		return _('Poco:Bind err;invalid key:',key)
	else
		return key
	end
end
function PocoMods:addBind(event,name,key,cbk)
	-- event > {name,key,cbk}
	key = self:sanitizeKey(key)
	if key then
		self.binds[event] = self.binds[event] or {}
		local events = self.binds[event]
		table.insert(events,{name,key,cbk})
	end
end

function PocoMods:ignoreBind(t)
	self._ignoreT = TimerManager:game():time() + (t or 0.2)
end

function PocoMods:_runBinds(t,dt)
	if not (
		(managers.menu_component._blackmarket_gui and managers.menu_component._blackmarket_gui._renaming_item) or
		(managers.menu_component._skilltree_gui and managers.menu_component._skilltree_gui._renaming_skill_switch) or
		(managers.hud and managers.hud._chat_focus) or
		(managers.menu_component._game_chat_gui and managers.menu_component._game_chat_gui:input_focus()) or
		(self._ignoreT and self._ignoreT > TimerManager:game():time())
		) then
		for event,events in pairs(self.binds) do
			for __,obj in pairs(events) do
				local name, key, cbk = unpack(obj)
				local eventPass = false
				if event == 'down' then
					eventPass = self._kbd:pressed(key)
				elseif event == 'up' then
					eventPass = self._kbd:released(key)
				end
				if eventPass then
					cbk(t,dt,key)
				end
			end
		end
	end
end

function PocoMods:removeBind(event,name,key)
	if event and self.binds[event] then
		if name then
			local events = self.binds[event]
			for ind,obj in pairs(events) do
				if obj[1] == name then
					if not key or obj[2] == key then
						events[ind] = nil
					end
				end
			end
		else
			self.binds[event] = {}
		end
	end
end

function PocoMods:Bind(sender,key,downCbk,upCbk)
	local name = sender:name(1)
	if downCbk then
		self:addBind('down',name,key,downCbk)
	end
	if upCbk then
		self:addBind('up',name,key,upCbk)
	end
end

function PocoMods:Menu(drawFunc)
  if drawFunc then
  	self.UI:useMouse(true)
    self._menuElem = self.UI:draw(drawFunc)
    managers.menu_component:post_event('menu_enter')
  else
    if self._menuElem and ( not self._stringFocused or (TimerManager:game():time()-self._stringFocused > 0.1) ) then
      self.UI:setTaunt()
      self.UI:useMouse(false)
      self.UI:remove(self._menuElem)
      managers.menu_component:post_event('menu_exit')
      self._menuElem = nil
    end
  end
  return self.UI
end


PocoHud4 = setmetatable(PocoMods,{__index=modules})
PocoHud4.UI = PocoHud4.import('Components/UI'):new()
PocoMods.import('Entry')
