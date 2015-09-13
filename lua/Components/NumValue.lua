local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoUIValue = ROOT.import('Components/Value')


local PocoUINumValue = class(PocoUIValue)
function PocoUINumValue:init(parent,config,inherited)
	self.super.init(self,parent,config,true)
	self:val(tonumber(config.value) or 0)

	if not inherited then
		self:postInit(self)
	end
end

function PocoUINumValue:next(predict)
	local tVal = self:val()+(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:prev(predict)
	local tVal = self:val()-(self.config.step or 1)
	if predict then
		return self:isValid(tVal,1)
	else
		return self:val(tVal)
	end
end

function PocoUINumValue:isValid(val,silent)
	local result = (type(val) == 'number') and (val <= (self.config.max or 100)) and (val >= (self.config.min or 0))
	if not silent then
		self.result = result
	end
	return result
end

function PocoUINumValue:val(set)
	local result = PocoUIValue.val(self,set)
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

export = PocoUINumValue

PocoHud4.moduleEnd()
