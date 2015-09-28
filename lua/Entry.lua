--[[PocoHud4 Entrypoint]]
-- GLOBALS: RenderSettings
local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common',ENV)
local Hook = ROOT.import('Hook')
local O = ROOT.import('Options')()


_.c(ROOT._INSTANCE,_.s( 'PH4 Loaded') )

Hook(_G.MenuManager):block('toggle_menu_state', function() return ROOT._menuElem end,_.b(ROOT,'Menu',false))
Hook(_G.MenuInput):header('update',function()
  if ROOT._kbd:pressed(28) and alt() then
    managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
  end
end)

O:load()
O:save()


PocoHud4.moduleEnd()
