-- Menu manager
local ENV = PocoHud4.moduleBegin()
-- GLOBALS: Menu
local _ = ROOT.import('Common',ENV)
local Hook = ROOT.import('Hook')
local L = ROOT.import('Localizer')()

local menu
Menu = class()
function Menu:init(...)
  local aliveThunk = function()
    return self.current
  end
  self.hooks = {
    Hook(_G.PlayerStandard):block('_get_input', aliveThunk, {}),
    Hook(_G.MenuRenderer):block('mouse_moved', aliveThunk, true),
    Hook(_G.MenuInput):block('mouse_moved', aliveThunk, true),
    Hook(_G.MenuManager):block('toggle_menu_state', aliveThunk, callback(self,self,'hide',false))
  }
end

function Menu:show()
  local result,err = pcall(function()
    if self.fadingOut then
      return
    end
    if self.current then
      return self:hide(self.fadingIn)
    end
    managers.menu_component:post_event('menu_enter')
    local gui = ROOT.import('Components/Menu'):new(ROOT.ws)
    self.current = gui
    self:_draw(gui)
    self.fadingIn = true
    gui:fadeIn(function()
      self.fadingIn = nil
    end)
  end)
  if not result then
    _.c(_.s('Menu:show failed:',err))
  end
end

function Menu:_draw(gui)
  local tab
  tab = gui:add(L('_tab_about'))
  self:_drawAbout(tab, 400, 'alpha')

  tab = gui:add( 'Options' )
  self:_drawOptions(gui,tab)

  gui.gui:goTo(2)
end

Menu._drawOptions = ROOT.import('Menu/Options')
Menu._drawAbout = ROOT.import('Menu/About')

function Menu:hide(immediately)
  if self.current then
    if immediately then
      self.current:destroy()
      self.current = nil
      self.fadingOut = nil
    elseif not self.fadingOut then
      if ROOT._focused or (now() - (ROOT._lastFocusT or 0) < 0.2 ) then
        return
      end
      self.fadingOut = true
      self.current:fadeOut(function()
        self.current:destroy()
        self.current = nil
        self.fadingOut = nil
      end)
    end
  end
end

export = function (...)
  if not menu then
    menu = Menu:new(...)
  end
  return menu
end

PocoHud4.moduleEnd()
