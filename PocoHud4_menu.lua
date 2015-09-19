local UI = PocoHud4.import('Compo/UI')
local Elem = PocoHud4.import('Compo/Elem')
if rawget(_G,'PocoHud4') then
  local x = Elem:new(PocoHud4.UI, {x=100,y=100+math.random(0,300),w=40,h=40})
  local y = Elem:new(x, {x=10,y=10,w=20,h=20})
  y:setCursor('grab')
  PocoHud4.UI:useMouse(true)
end
