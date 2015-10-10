local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local Value = ROOT.import('Components/Value/Index')

local ValueChoose = class(Value)

function ValueChoose:init(parent,config)
	ValueChoose.super.init(self,parent,config)
	-- Abstract!
end

function ValueChoose:selection()
	return self.config.selection or {}
end

function ValueChoose:go(delta)
	local val = self:val()
	local sel = self:selection()
	local keys = table.map_keys(sel)
	local ind = table.index_of(keys,val)
	self:val(keys[ind+delta] or delta>0 and keys[1] or keys[#keys] )
end

function ValueChoose:next()
	self:go(1)
end

function ValueChoose:prev()
	self:go(-1)
end

function ValueChoose:innerVal(set)
	if set then
		local key = table.get_key(self:selection(),set)
		if key then
			return self:val(key)
		end
	else
		return self:selection()[self:val()]
	end
end
export = ValueChoose

PocoHud4.moduleEnd()
