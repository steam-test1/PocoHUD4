PocoHud4.moduleBegin()
-- GLOBALS: Steam
local Internet = {}
function Internet._open (url)
	if shift() then
		os.execute('start '..url)
	else
		Steam:overlay_activate('url', url)
	end
	managers.menu:post_event(not shift() and 'camera_monitor_engage' or 'trip_mine_sensor_alarm')
end

function Internet._get (obj, url, cbk)
	if ROOT._busy then
		if obj then
			obj:sound('menu_error')
		end
		return false
	else
		ROOT._busy = true
		local _cbk = function(success,body)
			if obj then
				obj:sound(success and 'turret_alert' or 'trip_mine_sensor_alarm')
			end
			if success then
				Internet._getCache[url] = body
			end
			ROOT._busy = false
			cbk(success,body)
		end

		if obj then
			obj:setLabel('Loading...')
			obj:sound('ca`mera_monitor_engage')
		end
		Internet._getCache = Internet._getCache or {}
		if Internet._getCache[url] and not shift() then
			_cbk(true,Internet._getCache[url])
		else
			if rawget(_G,'dohttpreq') then
				_G.dohttpreq(url, function(data, id)
					_cbk(true,data)
				end)
			else
				Steam:http_request(url, _cbk)
			end
		end
		return true
	end
end

export = Internet

PocoHud4.moduleEnd()
