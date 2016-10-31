if rawget(_G,'PocoHud4') then
  local _ = PocoHud4.import('Common')
  if PocoHud4._menuElem then
    PocoHud4:Menu(false)
  else
    PocoHud4:Menu(PocoHud4.import('Layout/Main/Index'))
  end
  -- @ debug state


  --do return end


else
  if (rawget(_G,'log')) then
    log('PocoHud4 Not instantiated')
  end
end
