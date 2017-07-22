local ENV = PocoHud4.moduleBegin()
local _ = ROOT.import('Common', ENV)
ROOT.import('Layout/Main/Const', ENV)
local Hook = ROOT.import('Hook')

local O = ROOT.import('Options')()
local L = ROOT.import('Localizer')()

-- GLOBALS: Icon, Label
export = function ( Tabs )

	local host_list, level_list, job_list, mask_list, weapon_list = tweak_data.achievement.job_list, tweak_data.statistics:statistics_table()
	local risks = { 'risk_pd', 'risk_swat', 'risk_fbi', 'risk_death_squad', 'risk_murder_squad'}
	local x = 10
	local font,fontSize = tweak_data.menu.pd2_small_font, tweak_data.menu.pd2_small_font_size*0.8

	-- [1] Per Heist
	local drawPerHeist = function (currBox)
		local pnl = currBox.pnl
		local y = 10
		local w, h, ww, hh = 0,0, pnl:size()
		local _rowCnt = 0
		local tbl = {}
		tbl[#tbl+1] = {{L('_word_broker'),cl.BlanchedAlmond},L('_word_job'),'',{Icon.Skull,cl.PaleGreen:with_alpha(0.3)},{Icon.Skull,cl.PaleGoldenrod},{Icon.Skull..Icon.Skull,cl.LavenderBlush},{string.rep(Icon.Skull,3),cl.Wheat},{string.rep(Icon.Skull,4),cl.Tomato},L('_word_heat')}
		local addJob = function(host,heist)
			local jobData = tweak_data.narrative:job_data(heist)
			if not jobData then
				return
			end
			if jobData and jobData.wrapped_to_job then
				jobData = tweak_data.narrative.jobs[jobData.wrapped_to_job]
			end
			local job_string =managers.localization:to_upper_text(jobData.name_id or heist) or heist
			job_string = job_string .. (string.find(heist, '_night') and ' '..L('_tab_stat_night') or '')
			local pro = jobData.professional
			if pro then
				job_string = {job_string, cl.Tomato}
			end
			local rowObj = {host:upper(),job_string,''}
			for i, name in ipairs( risks ) do
				--local c = managers.statistics:completed_job( heist, tweak_data:index_to_difficulty( i + 1 ) )
				local c = managers.statistics._global.sessions.jobs[(heist .. '_' .. tweak_data:index_to_difficulty( i + 1 ) .. '_completed'):gsub('_wrapper','')] or 0
				local f = managers.statistics._global.sessions.jobs[(heist .. '_' .. tweak_data:index_to_difficulty( i + 1 ) .. '_started'):gsub('_wrapper','')] or 0
				if i > 1 or not pro then
					table.insert(rowObj, {{c, c<1 and cl.Salmon or cl.White:with_alpha(0.8)},{' / '..f,cl.White:with_alpha(0.4)}})
				else
					table.insert(rowObj, {c > 0 and c or L('_word_na'), cl.Tan:with_alpha(0.4)})
				end
			end
			local multi = managers.job:get_job_heat_multipliers(heist)
			local color = multi >= 1 and math.lerp( cl.Khaki, cl.Chartreuse, 6*(multi - 1) ) or math.lerp( cl.Crimson, cl.OrangeRed, 3*(multi - 0.7) )
			table.insert(rowObj,{{_.f(multi*100)..'%',color},{' ('..(managers.job:get_job_heat(heist) or '?')..')',color:with_alpha(0.3)}})
			tbl[#tbl+1] = rowObj
		end
		for host,jobs in _.p(host_list) do
			for no,heist in _.p(job_list) do
				local jobData = tweak_data.narrative:job_data(heist)
				if jobData and jobData.contact:gsub('the_','') == host:gsub('the_','') then
					--[[if table.get_key(job_list,heist) then
						job_list[table.get_key(job_list,heist)] = nil
					end]]
					job_list[table.get_key(job_list,heist)] = nil
					addJob(host:gsub('the_',''),heist)
				end
			end
		end
		for no,heist in pairs(job_list) do
			addJob(L('_word_na'),heist) -- Just in case
		end
		local _lastHost = ''
		for row, _tbl in pairs(tbl) do
			if _lastHost == _tbl[1] then
				_tbl[1] = ''
			else
				_lastHost = _tbl[1]
			end
			_rowCnt = _rowCnt + 1
			y = ENV._drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
		end
		currBox:autoSize()
	end
	Tabs:addTab('perHeist',L('_tab_stat_perheist'), drawPerHeist)

		-- [2] Per day
	local drawPerDay = function (currBox)
		level_list, job_list, mask_list, weapon_list = tweak_data.statistics:statistics_table()
		local pnl = currBox.pnl
		local y = 10
		local descs = {}
		local tbl = {}
		tbl[#tbl+1] = {{L('_word_heist'),cl.BlanchedAlmond},{L('_word_day'),cl.Honeydew},'',{L('_word_started'),cl.LavenderBlush},{L('_word_completed'),cl.Wheat},L('_word_time')}
		local levels = _.g('managers.statistics._global.sessions.levels') or {}
		-- search JobsChain
		local addDay = function(val,prefix,suffix)
			if not level_list[table.get_key(level_list,val)] then return end
			if table.get_key(level_list,val) then
				level_list[table.get_key(level_list,val)] = nil
			end
			local level = levels[val]
			if not level then return end
			local isAlt = val:match('_night$') or val:match('_day$')
			local name = managers.localization:to_upper_text(tweak_data.levels[val].name_id)
			if type(prefix) == 'string' then
				if (prefix:find(val) or managers.localization:to_upper_text(prefix) == name ) and not val:find('_%d') then
					prefix = {Icon.DRC,cl.Gray}
				else
					prefix = managers.localization:to_upper_text(prefix)
				end
			end
			name = name .. (isAlt and ' '..L('_tab_stat'..isAlt) or '')
			local _c = function(n,color)
				return {n,n and n>0 and (color or cl.Lime) or cl.Gray }
			end
			local _s = function(...)
				local t = {}
				for i,v in pairs{...} do
					t[i] = _.s(v)
				end
				return table.concat(t)
			end
			local t = level.time / 60
			local avg = t / math.max(1,level.completed)
			local btnSize = fontSize * 1.5
			tbl[#tbl+1] = {
				prefix,
				Label:new(currBox,{color=cl.White,x=0,y=0,w=200,h=btnSize,align='left',text=name,hintText=suffix}),
				'',
				Label:new(currBox,{color=cl.White,x=0,y=0,w=95,h=btnSize,text=level.started,hintText={
					L('_desc_heist_count_started_1'),
					_c(level.from_beginning),'\n',
					L('_desc_heist_count_started_2'),
					_c(level.drop_in)
				}}),
				Label:new(currBox,{color=cl.White,x=0,y=0,w=95,h=btnSize,text=level.completed,hintText={L('_desc_heist_count_completed'), _c(level.quited,cl.Red)}}),
				Label:new(currBox,{color=cl.White,x=0,y=0,w=95,h=btnSize,text={
					t>0 and (
						t > 60 and L('_desc_heist_time_hm',{math.floor(t/60),math.floor(t%60)}) or L('_desc_heist_time_m',{_.f(t)} )
					) or {L('_word_na'),cl.Gray}
				},hintText={
					L('_desc_heist_time_average'),L('_desc_heist_time_ms',{math.floor(avg),math.floor(avg*60%60)})
				},avg>0 and cl.Lime or cl.Gray})
			}
		end
		for host,_jobs in _.p(host_list) do
			local jobs = deep_clone(_jobs)
			for no, heist in _.p(job_list) do
				local jobData = tweak_data.narrative:job_data(heist)

				if jobData and jobData.contact:gsub('the_','') == host:gsub('the_','') then
					local jobData = tweak_data.narrative.jobs[heist]
					local jobName
					if jobData.wrapped_to_job then
						jobName = tweak_data.narrative.jobs[jobData.wrapped_to_job].name_id
					else
						jobName = jobData.name_id
					end
					if jobData and jobData.job_wrapper then
						for k,realJobs in pairs(jobData.job_wrapper) do
							table.insert(jobs,realJobs)
						end
					end
					if jobData.chain then
						for day,level in pairs(jobData.chain) do
							local lID = level.level_id
							if lID then
								addDay(lID,jobName,L('_desc_heist_day',{day}))
							else -- alt Days
								for alt,_level in pairs(level) do
									addDay(_level.level_id,jobName,L('_desc_heist_dayalt',{day,alt}))
								end
							end
						end
					else
						_('no chain?',jobData.name_id)
					end
				end
			end
		end
		-- the rest
		tbl[#tbl+1] = {{L('_desc_heist_unlisted'),cl.DodgerBlue}}
		for key,val in _.p(level_list) do
			addDay(val,{Icon.Ghost,cl.DodgerBlue})
		end

		-- draw
		local _rowCnt, ww, _lastHost = 0, pnl:w()
		for row, _tbl in pairs(tbl) do
			if _lastHost == _tbl[1] then
				_tbl[1] = ''
			else
				_lastHost = _tbl[1]
				_tbl[1] = type(_tbl[1]) == 'string' and {_tbl[1],cl.BlanchedAlmond} or _tbl[1]
			end
			_rowCnt = _rowCnt + 1
			y = ENV._drawRow(pnl,fontSize,_tbl,x,y,ww-20, _rowCnt % 2 == 0,{1,_rowCnt == 1 and 1 or 0})
		end
		local __, lbl = _.l({color=cl.LightSteelBlue, alpha=0.9, font_size=fontSize, pnl = pnl, x = 10, y = y+10},L('_desc_heist_may_not_match'),true)
		currBox:autoSize()
	end
	Tabs:addTab('perDay',L('_tab_stat_perday'), drawPerDay)
end
PocoHud4.moduleEnd()
