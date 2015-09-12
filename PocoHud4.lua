--[[
PH4 entry point
]]

-- Shimming
local currModPath = rawget( _G, 'ModPath' ) or 'lib/Lua/base/'
currModPath = currModPath:gsub( 'base', 'PocoHud4' )
log = log or function( t ) io.stdout:write(tostring(t)..'\n') end

-- Module
local modules = {
  _INSTANCE = string.format('%06x', math.random()*0xffffff)
}
PocoMods = setmetatable({
  moduleBegin = function()
    local __,__,parent,name = string.find(debug.getinfo(2).short_src:lower(), '/(%a+)/(%a+).lua')
    name = ( parent=='lua' and '' or parent .. '/' ) .. name
    local shell = setmetatable({},{__index=_G})
    shell._name = name
    shell._modules = modules
    local newEnv = modules[name] or setmetatable({},{__index=shell})
    modules[name] = newEnv
    setfenv(2,newEnv)
    return newEnv
  end,
  moduleEnd = function ()
    setfenv(2,_G)
  end,
  import = function (name, spread)
    name = name:lower()
    log(' import:'..name)
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
  end,
  unload = function()
    for name in pairs(modules) do
      if type(modules[name])=='table' and rawget(modules[name],'destroy') then
        modules[name].destroy()
      end
      modules[name] = nil
    end
  end
}, {__index=modules} )
PocoHud4 = PocoMods
log('--'..PocoHud4._INSTANCE..' PH4 Loaded on '.._VERSION..' --')
log('External CL:'..type(cl))
PocoMods.import('Entry')
