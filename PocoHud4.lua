--[[
PH4 entry point
]]

-- Shimming
local currModPath = rawget( _G, 'ModPath' ) or 'lib/Lua/base/'
currModPath = currModPath:gsub( 'base', 'PocoHud4' )
log = log or function( t ) io.stdout:write(tostring(t)..'\n') end

-- Module
local modules = {}
PocoMods = setmetatable({
  moduleBegin = function()
    local __,__, name = string.find(debug.getinfo(2).short_src, '/(%a+).lua')
    name = name:lower()
    local shell = setmetatable({},{__index=_G})
    shell._name = name
    shell._modules = modules
    local newEnv = modules[name] or setmetatable({},{__index=shell})
    modules[name] = newEnv
    setfenv(2,newEnv)
  end,
  moduleEnd = function ()
    setfenv(2,_G)
  end,
  import = function (name, spread)
    name = name:lower()
    if not modules[name] then
      local fileName = currModPath..'lua/'..name..'.lua'
      local file = io.open( fileName, 'r' )
      if file ~= nil then
        pcall( dofile, fileName )
      end
    else
      log('!PH4 Err: Module '..name..' not found.')
      return false
    end
    if spread then
      local newEnv = setmetatable({},{__index:getfenv(2)})
      local newModule = modules[name] or {}
      for k,v in pairs(newModule) do
        newEnv[k] = v
      end
      setfenv(2,newEnv)
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
      if rawget(modules[name],'destroy') then
        modules[name].destroy()
      end
      modules[name] = nil
    end
  end
}, {__index=modules} )
PocoHud4 = PocoMods

PocoMods.import('Entry')
