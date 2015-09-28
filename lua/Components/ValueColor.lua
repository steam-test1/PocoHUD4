local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ValueChoose = ROOT.import('Components/ValueChoose')

local ValueColor = class(ValueChoose)
function ValueColor:init(parent,config)
	ValueColor.super.init(self,parent,config)
	self:val(config.value or 'White')
end

function ValueColor:selection()
	return cl
end

function ValueColor:val(set)
	local val = ValueColor.super.val(self,set)
	if set then
		local color = cl[val] or cl.White
		_.l(self.valLbl,{val,color})
	end
	return val
end

export = ValueColor
PocoHud4.moduleEnd()
