-- PocoHud4 Config manager
local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local _defaultLocaleData = ROOT.import('Defaults/Localizer')
local Icon = ROOT.import('Icon')
local O = ROOT.import('Options')()
local Localizer = class()
local JSONFileName = ROOT.currModPath .. 'lua/Locales/$.json'

function Localizer:init()
	-- Shorthand L(o,c)
	local mt = getmetatable(self)
	mt.__call = function(__,...)
		return self:parse(...)
	end
	setmetatable(self,mt)

	self.parser = {
		string = function(str,context)
			if str == '##' then -- Special case: omit string instructor
				return ''
			end
			-- parse 'something {color|key|alpha} something'
			local p,exploded = 1,{}
			for s,tag,e in str:gmatch('(){(.-)}()') do
					table.insert(exploded,str:sub(p,s-1))
					if tag:find('|') then
						local key,color = tag:match('^(.-)|(.+)$')
						local alpha
						if color:find('|') then
							color, alpha = color:match('(.+)|(.+)')
							alpha = tonumber(alpha)
						end
						color = cl[color] or cl.White
						if alpha then
							color = color:with_alpha(alpha)
						end
						table.insert(exploded,{key,color})
					else
						table.insert(exploded,tag)
					end
					p = e
			end
			table.insert(exploded,str:sub(p,str:len()))
			if exploded[2] then
				return self:parse(exploded,context)
			else
				return str:find('^[_!]') and self:parse(self:get(str,context),context) or str
			end
		end,
		table = function(tbl,context)
			local r = {}
			for k,v in pairs(tbl) do
				r[k] = self:parse(v,context)
			end
			return r
		end
	}
	self.data = {}
	self._data = {}

	self:load()
end

function Localizer:get(key,context)
	local val = _defaultLocaleData[key] or self.data[key] or self._data[key] or Icon[key:gsub('_','')]
	if val and type(context)=='table' then
		for k,v in pairs(context) do
			val = val:gsub('%['..k..'%]',v)
		end
	end
	return val or _.s('?:',key)
end

function Localizer:load()
	local lang = O('root','language')
	local f,err = io.open(JSONFileName:gsub('%$',lang), 'r')
	if f then
		local t = f:read('*all')
		local o = _.j:decode(t)
		if type(o) == 'table' then
			self.data = o
		end
		f:close()
	else
			_('PH4: Locale',lang,'NOT loaded!')
	end

	f,err = io.open(JSONFileName:gsub('%$','EN'), 'r')
	if f then
		local t = f:read('*all')
		local o = _.j:decode(t)
		if type(o) == 'table' then
			self._data = o
		end
		f:close()
	end
end

function Localizer:parse(object,context)
	local t = type(object)
	return self.parser[t] and self.parser[t](object,context) or object
end

local localizer
export = function()
	if not localizer then
		localizer = Localizer:new()
	end
	return localizer
end

PocoHud4.moduleEnd()
