local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')
local PocoUIChooseValue = ROOT.import('Components/ChooseValue')

local PocoUIColorValue = class(PocoUIChooseValue)
function PocoUIColorValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(config.value or 'White')

	if not inherited then
		self:postInit(self)
	end
end

function PocoUIColorValue:selection()
	return cl
end

function PocoUIColorValue:val(set)
	local val = PocoUIValue.val(self,set)
	if set then
		local color = cl[val] or cl.White
		_.l(self.valLbl,{val,color})
	end
	return val
end

export = PocoUIColorValue

PocoHud4.moduleEnd()
