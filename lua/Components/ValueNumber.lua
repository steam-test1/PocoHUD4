local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ValueChoose = ROOT.import('Components/ValueChoose')

local ValueNumber = class(ValueChoose)
function ValueNumber:init(parent,config)
	ValueNumber.super.init(self,parent,config)
	self:val(tonumber(config.value) or 0)
end

function ValueNumber:next(predict)
	local tVal = self:val()+(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function ValueNumber:prev(predict)
	local tVal = self:val()-(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function ValueNumber:isValid(val,silent)
	local result = (type(val) == 'number') and (val <= (self.config.max or 100)) and (val >= (self.config.min or 0))
	return result
end

function ValueNumber:val(set)
	local result = ValueNumber.super.val(self,set)
	if set and self.config.vanity then
		_.l(self.valLbl,self.config.vanity[self:val()+1] or self:val(),true)
		self.valLbl:set_center_x(3*self.config.w/4)
		self.valLbl:set_x(math.floor(self.valLbl:x()))
	end
	if set and self.arrowLeft then
		self.arrowLeft:set_alpha(self:prev(1) and 1 or 0.1)
		self.arrowRight:set_alpha(self:next(1) and 1 or 0.1)
	end
	return result
end

export = ValueNumber
PocoHud4.moduleEnd()
