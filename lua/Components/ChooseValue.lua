local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')

local PocoUIChooseValue = class(PocoUIValue)

function PocoUIChooseValue:init(parent,config,inherited)
	PocoUIValue.init(self,parent,config,true)
	-- abstract
end

function PocoUIChooseValue:selection()
	return self.config.selection or {}
end

function PocoUIChooseValue:go(delta)
	local val = self:val()
	local sel = self:selection()
	local keys = table.map_keys(sel)
	local ind = table.index_of(keys,val)
	self:val(keys[ind+delta] or delta>0 and keys[1] or keys[#keys] )
end

function PocoUIChooseValue:next()
	self:go(1)
end

function PocoUIChooseValue:prev()
	self:go(-1)
end

function PocoUIChooseValue:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()]
	end
end
export = PocoUIChooseValue

PocoHud4.moduleEnd()
