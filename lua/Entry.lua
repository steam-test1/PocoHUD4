--[[PocoHud4 Entrypoint]]
local ENV = PocoHud4.moduleBegin()
ROOT.import('Common',ENV)
local Hook = ROOT.import('Hook',ENV)

_.c(ROOT._INSTANCE,_.s( 'PH4 Loaded') )

-- Hook test start
local hook = Hook(PlayerStandard):header('set_running',function(self,...)
  _.c('SetRunning',_.s(ROOT._INSTANCE,...))
end)

-- MODDED SHOW START
local result,err = pcall(function()
  local sysMgr = managers.system_menu
  local text = _.s(
    'debugging..'
  )
  local data = { title = 'title', text = text, button_list = {},
                       id = tostring(math.random(0,0xFFFFFFFF)) }
  local DlgClass = ROOT.import('Dialogs/Generic')
  --
  if _G.setup and _G.setup:has_queued_exec() then
    return
  end
  local success = sysMgr:_show_class(data, DlgClass, DlgClass, data.force)
  sysMgr:_show_result(success, data)
end)
if not result then
  _.c(_.s('Test-Err:',err))
end
-- MODDED SHOW End

PocoHud4.moduleEnd()
