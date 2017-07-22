-- PocoHud4 Config manager
local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common',ENV)
local scheme = ROOT.import('Defaults/Config')
local _vanity = ROOT.import('Defaults/Config-keywords')
local isNil = function(a)
	return a == nil
end

local JSONFileName = ROOT.savePath..'hud4_config.json'

local Option = class()
function Option:init()
	local mt = getmetatable(self)
	mt.__call = function(__,...)
		return self:get(...)
	end
	setmetatable(self,mt)

	self:default()
	self.scheme = scheme
  self:load()
end

function Option:reset()
	os.remove(JSONFileName)
end

function Option:default(category)
	if category then
		self.items[category] = nil
	else
		self.items = {}
	end
end

function Option:load()
	if not pcall(function ()
		self.items = _.j:fromFile(JSONFileName)
	end) then
		self.items = {};
	end
end

function Option:save()
	_.j:toFile(self.items,JSONFileName,true)
end


function Option:_type(category,name)
	return self:_get(true,category,name)[1]
end

function Option:_range(category,name)
	return self:_get(true,category,name)[3]
end

function Option:_hint(category,name)
	return self:_get(true,category,name)[4]
end

function Option:_vanity(category,name)
	local vanity = self:_get(true,category,name)[5]
	if vanity then
		vanity = _vanity[vanity] or vanity
	end
	return vanity
end

function Option:_step(category,name)
	return self:_get(true,category,name)[6]
end

function Option:_sort(category,name)
	return self:_get(true,category,name)[7]
end

function Option:set(category, name, value)
	self.items[category] = self.items[category] or {}
	self.items[category][name] = value
end

function Option:_get(isScheme, category,name)
	local o = isScheme and self.scheme or self.items
	local result = o and o[category] and o[category][name]
	if isNil(result) then
		if isScheme then
			_('Option:_get was Nil', category, name) -- this should NOT happen
		end
		result = isScheme and {} or nil
	end
	return result
end

function Option:get(category,name,raw)
	if not name then
		return self:getCategory(category,raw)
	end
	local result = self:_get(false,category,name)
	if result == nil then
		result = self:_default(category,name)
	end
	if not raw then
		local type = self:_type(category,name)
		if type == 'color' then
			return cl[result] or cl.White
		end
	end
	return result
end

function Option:getCategory(category,raw)
	local result = {}
	for name in pairs(self.scheme[category] or {}) do
		result[name] = self:get(category,name,raw)
	end
	return _.m({},result)
end

function Option:_default(category,name)
	return self:_get(true,category,name)[2]
end

function Option:isDefault(category,name,value)
	return value == self:_default(category,name)
end

function Option:isChanged(category,name,value)
	return value ~= self:get(category,name)
end

local option
export = function()
	if not option then
		option = Option:new()
	end
	return option
end

PocoHud4.moduleEnd()
