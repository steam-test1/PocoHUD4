local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common')
-- GLOBALS: Hook
local Hooks = {}
setmetatable(Hooks,{__mode='k'})
Hook = class()
function Hook:init(origin,...)
  self.origin = origin or {} -- Silent fails when Origin is invalid
  self.subscribers = {header={},body={},footer={}}
  self.originals = {}
  Hooks[self.origin] = self
end

function Hook:_impersonate(method)
  if not self.originals[method] then
    self.originals[method] = self.origin[method]
    self.origin[method] = self:__impersonate(method)
  end
end

function Hook:__impersonate(method)
  self:start()
  return function(...)
    local headers = self.subscribers.header[method]
    local body = self.subscribers.body[method]
    local footers = self.subscribers.footer[method]
    local valid = self:isValid()

    if valid and headers then
      for k,v in pairs(headers) do
        v({}, ...)
      end
    end
    local result
    if valid and body then
      result = {body(self.originals[method],...)}
    else
      result = {self.originals[method](...)}
    end
    if valid and footers then
      for k,v in pairs(footers) do
        v(result, ...)
      end
    end
    return _.u(result)
  end
end

function Hook:start()
  self.active = true
end

function Hook:header(method,fn)
  self:_impersonate(method)
  self.subscribers.header[method] = self.subscribers.header[method] or {}
  table.insert(self.subscribers.header[method],fn)
  return self
end

function Hook:body(method,fn)
  self:_impersonate(method)
  if self.subscribers.body[method] then
    _('!!HookErr: Duplicated Body @',method,'get your shit together!')
  end
  self.subscribers.body[method] = fn
  return self
end

function Hook:block(method, conditionThunk, blockedVal)
  return self:body(method, function( org, ...)
    if conditionThunk() then
      return type(blockedVal)=='function' and blockedVal( ... ) or blockedVal
    else
      return org ( ... )
    end
  end)
end

function Hook:footer(method,fn)
  self:_impersonate(method)
  self.subscribers.footer[method] = self.subscribers.footer[method] or {}
  table.insert(self.subscribers.footer[method],fn)
  return self
end

function Hook:isValid()
  return self.active and ROOT.active
end

function Hook:stop()
  self.active = false
end

export = function (origin,...)
  return Hooks[origin] or Hook:new(origin,...)
end

PocoHud4.moduleEnd()
