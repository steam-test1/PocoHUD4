local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
local ThreadElem = ROOT.import('Components/ThreadElem')
local Button = ROOT.import('Components/Button')
local Box = ROOT.import('Components/Box')
local Tabs = class(ThreadElem)

function Tabs:init(...)
	Tabs.super.init(self, ...)
	self.config = _.m({tabW = 150, tabH=30, secH=20}, self.config)
	self:reset()
end

function Tabs:reset()
	local conf = self.config
	local m,tabW = conf.m or 10,conf.tabW
	self.leftBox = Box:new(self, {x=m,y=m,w=tabW,h=conf.h-2*m,scroll=true,noBlur=true} )
	self.leftBtnConf = {x=m,w=tabW-3*m,h=conf.tabH}
	self.rightBoxConf = {x=tabW+2*m,y=m,w=conf.w-3*m-tabW,h=conf.h-2*m,scroll=true,noBlur=true}
	self.tabTop = 0
	self.tabNames = {} -- table of name = button
	self.tabs = {} -- table of name = box
end

function Tabs:addTab(name, text)
	if self.tabs[name] then
		return self.tabs[name]
	end
	local newBox = Box:new(self, self.rightBoxConf):hide()
	self.tabs[name] = newBox
	self.tabNames[name] =	Button:new(self.leftBox,_.m({text=text or name,y=self.tabTop+5,fontSize=20}, self.leftBtnConf) )
		:on('click',function(b)
			if b == 0 then
				self:goto(name)
				return true, 'box_tick'
			end
		end)
	self.tabTop = self.tabTop + self.leftBtnConf.h + 2
	self.leftBox:autoSize()
	return newBox
end

function Tabs:goto(name)
	if self.currentTab then
		self.currentTab:hide()
	end
	self.currentTab = self.tabs[name]:show()
end

function Tabs:addSection(name)
	Button:new(self.leftBox, _.m({color=cl.White,text=name,y=self.tabTop+5,noBorder=true}, self.leftBtnConf) )
	self.tabTop = self.tabTop + self.leftBtnConf.h
	self.leftBox:autoSize()
end


function Tabs:clear()
	for __,v in pairs(self.tabs) do
		v:destroy()
	end
	self:reset()
end

export = Tabs
PocoHud4.moduleEnd()