--[[PocoHud4 Entrypoint]]
-- GLOBALS: RenderSettings
local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common',ENV)
local Hook = ROOT.import('Hook')
local O = ROOT.import('Config')()

_.c(ROOT._INSTANCE,_.s( 'PH4 Loaded') )

Hook(_G.MenuInput):header('update',function()
  if ROOT._kbd:pressed(28) and alt() then
    managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
  end
end)


PocoHud4.moduleEnd()
