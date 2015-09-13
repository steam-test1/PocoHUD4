local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local PocoScrollBox = ROOT.import('Components/ScrollBox')
local PocoTab = class()

function PocoTab:init(parent,ppnl,tabName)
	self.parent = parent -- tabs
	self.ppnl = ppnl
	self.name = tabName
	self.hotZones = {}
	self.box = PocoScrollBox:new(self,{ pnl = ppnl, x=0, y=parent.config.th,w = ppnl:w(), h = ppnl:h()-parent.config.th, name = tabName})
	self.pnl = self.box.pnl

end

function PocoTab:insideTabHeader(x,y,noChildren)
	local result = self.bg and alive(self.bg) and self.bg:inside(x, y) and self
	if not result and not noChildren then
		if self._children then
			for name,child in pairs(self._children) do
				if child.currentTab and child.currentTab:insideTabHeader(x,y) then
					return child,false
				end
			end
		end
	end
	return result,true
end

function PocoTab:addHotZone(event,item)
	self.hotZones[event] = self.hotZones[event] or {}
	table.insert(self.hotZones[event],item)
end

function PocoTab:isHot(event, x, y, autoFire)
	if self.hotZones[event] and alive(self.pnl) and self.box.wrapper:inside(x,y) then
		for i,hotZone in pairs(self.hotZones[event]) do
			if hotZone:isHot(event, x,y) and (not ROOT._focused or ROOT._focused == hotZone) then
				if autoFire then
					local r = hotZone:fire(event, x, y)
					if r then
						return r
					end
				else
					return hotZone
				end
			end
		end
	end
	if self._children then
		for name,child in pairs(self._children) do
			local cResult = child.currentTab and child.currentTab:isHot(event,x,y,autoFire)
			if cResult then return cResult end
		end
	end
	return false
end

function PocoTab:scroll(val, force)
	return self.box:scroll(val,force)
--	return self.pnl:set_y(pVal)
end

function PocoTab:canScroll(down,x,y)
	return self.box:canScroll(down,x,y)
end

function PocoTab:set_h(h)
	self.box:set_h(h)
end

function PocoTab:children(child)
	if child then
		local children = self._children or {}
		children[#children+1] = child
		self._children = children
	end
end

function PocoTab:destroy()
	self.dead = true
	for name,child in pairs(self._children or {}) do
		child:destroy()
	end
end

export = PocoTab
PocoHud4.moduleEnd()
