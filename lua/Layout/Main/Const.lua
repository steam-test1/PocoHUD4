local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
w, h, m = 800, 600, 10
cbW = 150
UNKNOWN = 'UNKNOWN'
BaseElem = ROOT.import('Components/BaseElem')
Label = ROOT.import('Components/Label')
Box = ROOT.import('Components/Box')
Tabs = ROOT.import('Components/Tabs')
Handle = ROOT.import('Components/Handle')
Button = ROOT.import('Components/Button')
ListBox = ROOT.import('Components/ListBox')

function _drawRow(pnl, fontSize, texts, _x, _y, _w, bg, align, lineHeight)
	local _fontSize = fontSize * (lineHeight or 1.5)
	if bg then
		pnl:rect( { x=_x,y=_y,w=_w,h=_fontSize,color=cl.White, alpha=0.05, layer=0 } )
	end
	local count = #texts
	local iw = _w / count
	local isCenter = function(i)
		return align == true or (type(align)=='table' and align[i]~=0)
	end
	for i,text in pairs(texts) do
		if text and text ~= '' then
			if (type(text)=='table' or type(text)=='userdata') and text.set_y then
				text:set_y(_y)
				if isCenter(i) then
					text:set_center_x(math.round(_x + iw*(i-0.5)))
				else
					text:set_x(math.round(_x+iw*(i-1)))
				end
			else
				local mergedText, lbl = _.l(
					{	align = 'left', fontSize=fontSize,
					 align = isCenter(i) and 'center', vertical = 'center',
					 pnl = pnl, x = _x + iw*(i-0.5), y=math.floor(_y),
					 w=iw, h = _fontSize
				 },
					text, not isCenter(i)
				)
				lbl:set_center_y(math.floor(_y + _fontSize/2 ))
				--[[
				local res, lbl = _.l({
					pnl=pnl,color=cl.White, fontSize=fontSize, x=_x + iw*(i-0.5),
					y=math.floor(_y), w = iw, h = _fontSize, text='',
					align = isCenter(i) and 'center', vertical = 'center', blend_mode='add'},
					text, not isCenter(i)) ]]

				lbl:set_x(math.round(_x+iw*(i-1)))
				--[[if isCenter(i) then
					lbl:set_center_x(math.round(_x + iw*(i-0.5)))
				end]]

			end
		end
	end
	return _y + _fontSize
end

PocoHud4.moduleEnd()
