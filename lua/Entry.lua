--[[PocoHud4 Entrypoint]]
-- GLOBALS: RenderSettings
local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common',ENV)
local Hook = ROOT.import('Hook')
local O = ROOT.import('Options')()
local Modules = ROOT.import('Modules/Index')

_.c(ROOT._INSTANCE,_.s( 'PH4 Loaded') )

Hook(_G.MenuManager):block('toggle_menu_state', function() return ROOT._menuElem end,_.b(ROOT,'Menu',false))
Hook(_G.MenuInput):header('update',function()
  if ROOT._kbd:pressed(28) and alt() then
    managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
  end
end)

local keybinds = _.j:fromFile(ROOT.savePath..'mod_keybinds.txt')
if keybinds and not keybinds.pocohud4_open then
  keybinds.pocohud4_open = 'backspace'
  _.j:toFile(keybinds, ROOT.savePath..'mod_keybinds.txt')
  local dialog_data = {}
  dialog_data.title = string.upper( 'PocoHud4 Keybind inserted' )
  dialog_data.text = [=[Press Backspace after the next session to open PocoHud4 config menu.
  You can customize this in [Options]-[MOD Keybinds].]=]
  local ok_button = {}
  ok_button.text = managers.localization:text("dialog_ok")
  dialog_data.button_list = {ok_button}
  managers.system_menu:show(dialog_data)
  me:Menu(true,true)
end

PocoHud4.moduleEnd()
