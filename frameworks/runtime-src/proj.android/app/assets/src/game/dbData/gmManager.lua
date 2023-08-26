require("game/union/unionData")
module("gmManager", package.seeall)
local gm_show_layer = nil
local curent_build_id = 0
local curent_try_times = 0
local curent_build_index = 1
local upgrade_all_build_timer = nil
local gm_txt = nil 
function remove_self( )
	if gm_show_layer then
		gm_show_layer:removeFromParentAndCleanup(true)
		gm_show_layer = nil
		scrollView = nil
		gm_txt = nil
		uiManager.remove_self_panel(uiIndexDefine.GM_MANAGER)
	end
end

function dealwithTouchEvent(x,y)
	if not gm_show_layer then
		return false
	end

	local temp_widget = gm_show_layer:getWidgetByTag(999)

	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_first_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_widget = gm_show_layer:getWidgetByTag(999)
		local old_gm_panel = tolua.cast(temp_widget:getChildByName("old_gm"), "Layout")

		local temp_txt = nil
		local send_content = {}
		for i=1,5 do
			temp_txt = tolua.cast(old_gm_panel:getChildByName("txt_" .. i), "TextField")
			table.insert(send_content, tonumber(temp_txt:getStringValue()))
		end
		Net.send(TEST_CMD, {1,send_content})
	end
end
--请求建立分城
local function requestBuildBranchCity(wid)
	Net.send(WORLD_BUILD_BRANCH_CITY,{wid})
end
--请求建立要塞
local function requestNewFort( wid )
	Net.send(WORLD_BUILD_FORT,{wid})
end
function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
		break  
	   end  
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end



local dump_str = nil
local function gm_dump_value(value,prefix,default_prefix)
    if not prefix then 
        prefix = "" 
    end
    if not default_prefix then 
        default_prefix = ""
    end
    if type(value) == "number" then 
        dump_str = prefix .. dump_str .. tostring(value) .. ","
    elseif type(value) == "string" then 
        dump_str = prefix .. dump_str .. "\"" .. value .. "\"" .. ","
    elseif type(value) == "table" then 
        local prefix_next = prefix .. default_prefix
        dump_str = dump_str .. "\n" .. prefix_next .. "{\n"
        
        for k,v in pairs(value) do
            local key = ""
            if type(k) == "string" then 
                key = "\"" .. k .. "\"" 
            else
                key = tostring(k)
            end
            
            dump_str = dump_str .. prefix_next ..  "\t[" .. key .. "]="
            
            gm_dump_value(v,prefix_next,"\t")
            dump_str = dump_str .. "\n"
            
        end
        dump_str = dump_str .. prefix_next  .. "}\n"
    else
        --nothing
        dump_str = prefix .. dump_str .. tostring(value) .. ","
    end
    
end

local function gm_dump(value)
    dump_str = ""
    gm_dump_value(value)
    return dump_str
end

function getGMTableValueByPrimeKey(table_name,prime_key )
	return allTableData[dbTableDesList[table_name].name][tonumber(prime_key)]
end

function getGMTableValue(table_name )		
	return allTableData[dbTableDesList[table_name].name]
end




local function deal_with_second_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_widget = gm_show_layer:getWidgetByTag(999)
		local old_gm_panel = tolua.cast(temp_widget:getChildByName("old_gm"), "Layout")
		-- local gm_txt = tolua.cast(old_gm_panel:getChildByName("gm_txt"), "TextField")
		local text = gm_txt:getText()
		local cmdlist = Split(text, " ");
		print(text)
		local userid = 0
		if dbTableDesList.user and dbTableDesList.user.name and allTableData[dbTableDesList.user.name] then
			for k,v in pairs(allTableData[dbTableDesList.user.name]) do
				userid =  k
				break
			end
		end	

		--very chang yong de GM
		if cmdlist[1]=="f" then
			if not cmdlist[2] then
				requestGm("time-1 1")
			else 
				if cmdlist[3] then
					Net.send(TEST_CMD,{4,{tonumber(cmdlist[2]),tonumber(cmdlist[3])}})	
				end
			end
		elseif cmdlist[1]=="set" then
			--wangnengzhiling set table primekey key value
			if cmdlist[2] and cmdlist[3] and cmdlist[4] and cmdlist[5] then
				Net.send(TEST_CMD,{99,{"g10read","g10read",cmdlist[2],2,tonumber(cmdlist[3]),cmdlist[4],cmdlist[5]}})
			end
		elseif cmdlist[1]=="get" then
			--wangnengzhiling get table primekey 
			if cmdlist[2] then
				if cmdlist[3] then
					table_value = getGMTableValueByPrimeKey(cmdlist[2],tonumber(cmdlist[3]))	
					value=gm_dump(table_value)
					if value then
						CCMessageBox(value, "get "..cmdlist[2].." "..cmdlist[3])			
					end				
				else
					cmdlist[3] = ""
					table_value = getGMTableValue(cmdlist[2])
					value=gm_dump(table_value)
					table.insert(main_error, "tablevalue:"..tostring(value))
					local path = CCFileUtils:sharedFileUtils():getWritablePath()
				    local file = assert(io.open(path.."/tablevalue_"..os.date("%Y-%m-%d", os.time())..".txt","a+"))
				    file:write("---------------"..cmdlist[2]..os.date("%Y-%m-%d %H-%M-%S", os.time()).." ---------------------\n")
				    file:write(value .. "\n")
				    file:write("------------------------------------\n")
				    file:close()
				end
				
				
			end
		elseif cmdlist[1]=="buy" then
			if cmdlist[2] then
				Net.send(TEST_CMD,{11,{tonumber(cmdlist[2])}})	
			end
		elseif cmdlist[1]=="removeorder" then
			sdkMgr:sharedSkdMgr():removeAllOrders()
		elseif cmdlist[1]=="sendorder" then
			if cmdlist[2] and cmdlist[3] then
				local temp_data = {}
				local temp_table = {}
				temp_table["receipt-data"] = cmdlist[3]
				table.insert(temp_data,{cmdlist[2], temp_table})
			 	Net.send(PAY_DEAL_AFTER_PAY_DONE, temp_data)
			end
		elseif cmdlist[1]=="fast" then
			if cmdlist[2]=="on" then
				Net.send(TEST_CMD,{84,{1}})	
			elseif cmdlist[2]=="off" then
				Net.send(TEST_CMD,{84,{-1}})	
			end
		elseif cmdlist[1]=="energy" then
			local allTeamMsg = armyData.getAllTeamMsg()
			for i,army in pairs(allTeamMsg) do	
				for hi=1,4 do
					-- print(hi)
					local heroid_u =0
					if hi==1 and army.counsellor_heroid_u ~=0 then
						heroid_u = army.counsellor_heroid_u
					end
					if hi==2 and army.base_heroid_u ~=0 then
						heroid_u = army.base_heroid_u
					end
					if hi==3 and army.middle_heroid_u ~=0 then
						heroid_u = army.middle_heroid_u
					end
					if hi==4 and army.front_heroid_u ~=0 then
						heroid_u = army.front_heroid_u
					end
					if heroid_u ~=0 then
						local hero_info = heroData.getHeroInfo(heroid_u)
						if hero_info.energy < 200000 or hero_info.hurt_end_time ~=0 then
							Net.send(TEST_CMD,{99,{"g10read","g10read","hero",2,tonumber(heroid_u),"energy","1000000","hurt_end_time","0"}})
						end		
                    end						
				end						
			end
		elseif cmdlist[1]=="hero" then
			if  cmdlist[2] then
				if Tb_cfg_hero and Tb_cfg_hero[tonumber(cmdlist[2])] then
					Net.send(TEST_CMD,{120,{"command.HeroCardFunc","createHero",userid,tonumber(cmdlist[2])}})	
				end
			end	
		elseif cmdlist[1]=="exercise" then
			if  cmdlist[2] then
				if Tb_cfg_exercise and Tb_cfg_exercise[tonumber(cmdlist[2])] then
					Net.send(TEST_CMD,{120,{"command.ExerciseFunc","nextExercise",userid,tonumber(cmdlist[2])}})	
				end
			end
		elseif cmdlist[1]=="exp" then
			local allTeamMsg = armyData.getAllTeamMsg()
			for i,army in pairs(allTeamMsg) do	
				for hi=1,4 do
					-- print(hi)
					local heroid_u =0
					if hi==1 and army.counsellor_heroid_u ~=0 then
						heroid_u = army.counsellor_heroid_u
					end
					if hi==2 and army.base_heroid_u ~=0 then
						heroid_u = army.base_heroid_u
					end
					if hi==3 and army.middle_heroid_u ~=0 then
						heroid_u = army.middle_heroid_u
					end
					if hi==4 and army.front_heroid_u ~=0 then
						heroid_u = army.front_heroid_u
					end
					if heroid_u ~=0 then
						local hero_info = heroData.getHeroInfo(heroid_u)
						Net.send(TEST_CMD,{99,{"g10read","g10read","hero",2,tonumber(heroid_u),"exp","1432611904"}})
                    end						
				end						
			end
		elseif cmdlist[1]== "res" then
			Net.send(TEST_CMD,{3,{"1,10000;2,10000;3,10000;4,10000;"}})
		elseif cmdlist[1]== "bigres" then
			Net.send(TEST_CMD,{3,{"1,1000000;2,1000000;3,1000000;4,1000000;"}})
		elseif cmdlist[1]== "bigmoney" then
			Net.send(TEST_CMD,{3,{"99,100000;5,1000000"}})
		elseif cmdlist[1]== "money" then
			Net.send(TEST_CMD,{3,{"99,1000;5,10000"}})
		elseif cmdlist[1]=="land" then
			if cmdlist[2]=="get" and cmdlist[3] then
				Net.send(TEST_CMD,{120,{"command.WorldFunc","userGetLand",userid,tonumber(cmdlist[3]),0,0}})
			elseif cmdlist[2]=="abandom" and cmdlist[3] then
				Net.send(WORLD_DESERT_FIELD,{tonumber(cmdlist[3])})					
			end
		elseif cmdlist[1]=="getkey" then
			if cmdlist[2] then
				local value = CCUserDefault:sharedUserDefault():getStringForKey(cmdlist[2])
				if value then
					CCMessageBox(value, cmdlist[2])			
				end
			end
		elseif cmdlist[1]=="setkey" then
			if cmdlist[2] and cmdlist[3] then
				CCUserDefault:sharedUserDefault():setStringForKey(cmdlist[2],cmdlist[3])
			end
		end


		--bu zen me chang yong de

		if cmdlist[1]=="snapshot" then
			Net.send(TEST_CMD,{81,{}})	
		elseif cmdlist[1]=="pushserver" then
			if cmdlist[2] and cmdlist[3] and cmdlist[4] then
				Net.send(TEST_CMD,{120,{"command.PlatformNotify","push",tonumber(cmdlist[2]),cmdlist[3],cmdlist[4]}})
			end 
		elseif cmdlist[1]=="pushclient" then
			if cmdlist[2] and cmdlist[3] and cmdlist[4] then
				sdkMgr:sharedSkdMgr():setAlarmTimeOnce(tonumber(cmdlist[2] ), "fdfdf", cmdlist[3] , cmdlist[4] )
			end 
		elseif cmdlist[1]=="pushclient1" then
			if cmdlist[2] then
				sdkMgr:sharedSkdMgr():setAlarmTimeOnce(tonumber(cmdlist[2] ), "fdfdf", languagePack['alert_event'], languagePack['alert_event'] )
			end 
		elseif cmdlist[1]=="pushclient2" then
			if true then				
				sdkMgr:sharedSkdMgr():setAlarmTime(18, 00, "2jlgw", "", languagePack["alert_event"])
			end 
		elseif cmdlist[1]=="recover" then
			Net.send(TEST_CMD,{82,{}})		
		elseif cmdlist[1]=="bf" then
			if  cmdlist[2] and cmdlist[3] then
				Net.send(WORLD_BUILD_FORT,{tonumber(cmdlist[2]),cmdlist[3]})
			end
		elseif cmdlist[1]=="bc" then
			if  cmdlist[2] then
				Net.send(WORLD_BUILD_BRANCH_CITY,{tonumber(cmdlist[2])})
			end
		elseif cmdlist[1]=="rf" then
			if  cmdlist[2] then
				Net.send(WORLD_DELETE_FORT,{tonumber(cmdlist[2])})
			end
		elseif cmdlist[1]=="rc" then
			if  cmdlist[2] then
				Net.send(WORLD_DELETE_BRANCH_CITY,{tonumber(cmdlist[2])})
			end
		elseif cmdlist[1]=="ab" then
			if  cmdlist[2] then
				Net.send(ARMY_CALL_BACK,{tonumber(cmdlist[2])})
			end
		elseif cmdlist[1]=="ec" then
			if  cmdlist[2] and cmdlist[3] then
				Net.send(WORLD_EXTEND_CITY, {tonumber(cmdlist[2]), tonumber(cmdlist[3])})
			end
		elseif cmdlist[1]=="wf" then
			if  cmdlist[2] and cmdlist[3] and cmdlist[4] then
				Net.send(TEST_CMD,{99,{"user_city",2,tonumber(cmdlist[2])*10000+tonumber(cmdlist[3]),"extend_wids",""}})
				Net.send(TEST_CMD,{6,{tonumber(cmdlist[2]),tonumber(cmdlist[3]),cmdlist[4]}})	
			end
		elseif cmdlist[1]=="ub" then
			if  cmdlist[2] and cmdlist[3] and cmdlist[4] then
				for i=1,tonumber(cmdlist[4]) do
					Net.send(TEST_CMD,{3,{"99,100;1,500000;2,500000;3,500000;4,500000;"}})
					print("tonumber(cmdlist[2])*10+tonumber(cmdlist[3])" .. tonumber(cmdlist[2])*10+tonumber(cmdlist[3]))
					if allTableData[dbTableDesList.build.name][tonumber(cmdlist[2])*100+tonumber(cmdlist[3])] then
						Net.send(BUILDING_UPGRADE, {tonumber(cmdlist[2]), tonumber(cmdlist[3])})
					else
						Net.send(BUILDING_BUILD, {tonumber(cmdlist[2]), tonumber(cmdlist[3])})
					end 
					Net.send(BUILDING_FINISH_IMMEDIATELY,{tonumber(cmdlist[2])})
				end
			end
		elseif cmdlist[1] == "sz" then 
			if cmdlist[2] and cmdlist[3] then 
				local w = tonumber(cmdlist[2])
				local h = tonumber(cmdlist[3])
				if w > 0 and h > 0 then 
					CCEGLView:sharedOpenGLView():setFrameSize(math.floor(w),math.floor(h))
					configBeforeLoad.resize()
				end
			end
		elseif cmdlist[1]=="wc" then
			if  cmdlist[2] and cmdlist[3]then
				print("fuck")
				Net.send(TEST_CMD,{98,{cmdlist[2],tonumber(cmdlist[3])}})	
			end
		
		elseif cmdlist[1]=="cf" then
			if  cmdlist[2] and cmdlist[3]then
				Net.send(TEST_CMD,{99,{cmdlist[2],tonumber(cmdlist[3])}})	
			end
		elseif cmdlist[1]=="bt" then
			if  cmdlist[2] and cmdlist[3]then
				Net.send(CONQUER_FIELD_CMD, {tonumber(cmdlist[2]), tonumber(cmdlist[3])})
				--Net.send(TEST_CMD,{98,{cmdlist[2],tonumber(cmdlist[3])}})	
			end		
		elseif cmdlist[1]=="ar" then
			if  cmdlist[2] and cmdlist[3]then
				Net.send(ARMY_RECRUIT, {tonumber(cmdlist[2]), tonumber(cmdlist[3])})
				--Net.send(TEST_CMD,{98,{cmdlist[2],tonumber(cmdlist[3])}})	
			end		
		elseif cmdlist[1]=="reload" then
			if  cmdlist[2] then
				Net.send(TEST_CMD,{97,{cmdlist[2]}})
			end
		elseif cmdlist[1]=="sys" then
			-- if cmdlist[2] then
			 -- 0标题、1收件人id列表、2正文、 3附件（格式：资源id1,数量;资源id2,数量;)
				Net.send(TEST_CMD,{8,{"系统邮件",{userData.getUserId()},"XXXXXXXXXX",""}})
				--UnionData.requestJoinUnion(tonumber(cmdlist[2]))
			-- end	
			
		elseif cmdlist[1]=="ual" then
			if cmdlist[2] then
				Net.send(UNION_APPLICANT_LIST,{tonumber(cmdlist[2])})
			end		
		elseif cmdlist[1]=="jump2" then
			if cmdlist[2] and cmdlist[3]then
				mapController.jump(tonumber(cmdlist[2]),tonumber(cmdlist[3]))
			end		
		elseif cmdlist[1]=="jump" then
			if cmdlist[2]then
				mapController.jump(math.floor(tonumber(cmdlist[2])/10000),tonumber(cmdlist[2])%10000)
			end		
		elseif cmdlist[1]=="netoff" then
			Net.setEnable(false)
		elseif cmdlist[1]=="neton" then
			Net.setEnable(true)
		elseif cmdlist[1]=="db" then
			if cmdlist[2] and cmdlist[3] and cmdlist[4] and cmdlist[5] then
				Net.send(TEST_CMD,{99,{"g10read","g10read",cmdlist[2],2,tonumber(cmdlist[5]),cmdlist[3],cmdlist[4]}})
			end
		elseif cmdlist[1]=="dropland" then
			if cmdlist[2]then
				Net.send(WORLD_DESERT_FIELD,{tonumber(cmdlist[2])})
			end		
		elseif cmdlist[1]=="union" then
			--退出同盟 quit
			--同意加入同盟 agree $apply_id
			--申请加入同盟 join $union_id
			--建立同盟 create $union_name
			--解散同盟 dissolve
			if cmdlist[2]=="quit" then				
				Net.send(UNION_QUIT,{})
			elseif cmdlist[2]=="agree" then
				if cmdlist[3] then
					local temp = {}
					table.insert(temp, tonumber(cmdlist[3]))
					Net.send(UNION_DEAL_APPLICATION,{temp,1})
				end
			elseif cmdlist[2]=="join" then	
				if cmdlist[3] then			
					Net.send(UNION_APPLY,{tonumber(cmdlist[3])})
					--UnionData.requestJoinUnion(tonumber(cmdlist[3]))
				end	
			elseif cmdlist[2]=="create" then
				if cmdlist[3] then
					Net.send(UNION_CREATE,{cmdlist[3]})
				end
			elseif cmdlist[2]=="dissolve" then
				Net.send(UNION_DISSOLVE,{})
			elseif cmdlist[2]=="state" then
				Net.send(UNION_SWITCH_APPLY_STATE,{})
			elseif cmdlist[2]=="remove" then
				if cmdlist[3] then
					Net.send(UNION_REMOVE_MEMBER,{tonumber(cmdlist[3])})
				end
			elseif cmdlist[2]=="invite" then
				if cmdlist[3] then					
					Net.send(N_INVITE,{tonumber(cmdlist[3])})
				end
			elseif cmdlist[2]=="clean" then
				Net.send(TEST_CMD,{99,{"g10read","g10read","user",2,userid,"next_join_time","0"}})
			end

		elseif cmdlist[1]=="mail" then
			if cmdlist[2]=="reward" then
				if cmdlist[3] then
					Net.send(MAIL_REWARD,{tonumber(cmdlist[3])})
				end
			end
		
		elseif cmdlist[1]=="build" then
			--build $wid $build_id $level 
			--$wid: 表示指定城市id
			--$build_id：建筑id or all

			

			if cmdlist[2] and cmdlist[3] then				
				if cmdlist[3]=="all" then
					if upgrade_all_build_timer then
						remove_build_timer()
					end
					Net.send(TEST_CMD,{99,{"g10read","g10read","user_city",2,tonumber(cmdlist[2] ),"build_area_max","600"}})				
					Net.send(TEST_CMD,{3,{"99,1000000;1,100000000;2,100000000;3,100000000;4,100000000;5,1000000"}})
					upgrade_all_build_timer = scheduler.create(function  ()
							 		 	gm_up_action(tonumber(cmdlist[2] ))
							 		end,1)
				elseif cmdlist[3]=="fast" then
					if cmdlist[4] then
						Net.send(TEST_CMD,{120,{"command.BuildFunc","beginUpgrade",userid,tonumber(cmdlist[2]),tonumber(cmdlist[4]),1}})
					end	
				elseif cmdlist[3]=="remove" then
					if cmdlist[4] then
						Net.send(TEST_CMD,{120,{"command.BuildFunc","beginDegrade",userid,tonumber(cmdlist[2]),tonumber(cmdlist[4]),1}})
					end	
				else
					wid = tonumber(cmdlist[2])
					local build_id = tonumber(cmdlist[3])
					local curent_level = 0
					if allTableData[dbTableDesList.build.name][wid*100+build_id] then
						curent_level = allTableData[dbTableDesList.build.name][wid*100+build_id].level
					end
					
					if curent_level~=0 then
							Net.send(BUILDING_UPGRADE, {wid, build_id})
					else
							Net.send(BUILDING_BUILD, {wid, build_id})
					end
				end 
			end

		elseif cmdlist[1]=="resource" then
			--资源 quit

			--1234依次为：木石铁粮
			local RES_TYPE = {}
			RES_TYPE["stone"] = 2
			RES_TYPE["iron"] = 3
			RES_TYPE["food"] = 4
			RES_TYPE["wood"] = 1
			if cmdlist[2]=="exchange" then	
				if cmdlist[3] and cmdlist[4] and cmdlist[5] then
					if RES_TYPE[cmdlist[3]]	and RES_TYPE[cmdlist[5]] then
						Net.send(RESOURCE_EXCHANGE,{RES_TYPE[cmdlist[3]],tonumber(cmdlist[4]),RES_TYPE[cmdlist[5]]})
					end
				end
			elseif cmdlist[2]=="money" then
				if cmdlist[3] then
					Net.send(TEST_CMD,{3,{"5,"..cmdlist[3]}})
				end
			elseif cmdlist[2]=="setmoney" then
				if cmdlist[3] then
					local userid = 0
					if dbTableDesList.user and dbTableDesList.user.name and allTableData[dbTableDesList.user.name] then
						for k,v in pairs(allTableData[dbTableDesList.user.name]) do
							userid =  k
							break
						end
					end	
					Net.send(TEST_CMD,{99,{"g10read","g10read","user_res",2,userid,"money_cur",cmdlist[3]}})					
				end
			elseif cmdlist[2]=="gold" then
				if cmdlist[3] then
					Net.send(TEST_CMD,{3,{"99,"..cmdlist[3]}})
				end
			end

		elseif cmdlist[1]=="field" then
			if cmdlist[2]=="info" then
				if cmdlist[3] then
					Net.send(GET_FIELD_INFO_CMD, {math.floor(tonumber(cmdlist[3])/10000), tonumber(cmdlist[3])%10000})
				end
			end
		elseif cmdlist[1]=="city" then
			if cmdlist[2]=="get" and cmdlist[3] and cmdlist[4] then
				Net.send(TEST_CMD,{120,{"command.WorldFunc","unionGetCity",tonumber(cmdlist[3]),tonumber(cmdlist[4])}})					
			elseif cmdlist[2]=="lose" and cmdlist[3] then
				Net.send(TEST_CMD,{120,{"command.WorldFunc","unionLoseCity",tonumber(cmdlist[3])}})					
			end

			
			if cmdlist[2]=="build" then
				if cmdlist[3] and cmdlist[4] then
					Net.send(WORLD_BUILD_BRANCH_CITY, {tonumber(cmdlist[3]), cmdlist[4]})
				end
			end

		elseif cmdlist[1]=="army" then
			if cmdlist[2]=="chu" then
				if cmdlist[3] and cmdlist[4] then
					Net.send(CONQUER_FIELD_CMD, {tonumber(cmdlist[3]), tonumber(cmdlist[4])})
				end
			elseif cmdlist[2]=="yuan" then
				Net.send(REINFORCE_FIELD_CMD, {tonumber(cmdlist[3]), tonumber(cmdlist[4])})
			elseif cmdlist[2]=="back" then
				Net.send(ARMY_CALL_BACK, {tonumber(cmdlist[3])})
			elseif cmdlist[2]=="cancel" then
				Net.send(ARMY_MOVE_CANCEL, {tonumber(cmdlist[3])})
			elseif cmdlist[2]=="fastback" then
				Net.send(ARMY_BACK_IMMEDIATELY, {tonumber(cmdlist[3])})
			end


			
		
		elseif cmdlist[1] == "new_guide" then
			local new_guide_id = tonumber(cmdlist[2])
			if new_guide_id == 1001 then
				newGuideManager.start_guide()
			else
				newGuideInfo.set_guide_id(new_guide_id)
			end
			
			remove_self()

		elseif cmdlist[1] == "guide_tool" then
			require("game/guide/newGuide/simpleGuideTool")
			local new_state = tonumber(cmdlist[2])
			simpleGuideTool.set_state(new_state==1)
			remove_self()

		elseif cmdlist[1] == "testicon" then
			local icon_type = tonumber(cmdlist[2])
			local icon_id = tonumber(cmdlist[3])
			cardFrameInterface.test_icon_img(icon_type, icon_id)

		elseif cmdlist[1] == "task" then
			if cmdlist[2]=="award" then
				if cmdlist[3] then
					Net.send(TASK_AWARD,{tonumber(cmdlist[3])})
				end
			end
		elseif cmdlist[1] == "revenue" then
			Net.send(REVENUE)

		elseif cmdlist[1] == "fb" then
			Net.send(TEST_CMD,{80})

		elseif cmdlist[1] == "chat" then
			for i=1,9 do 
				Net.send(CHAT,{0,tostring(i),targetId})
			end
		elseif cmdlist[1] == "up" then
			if cmdlist[2] then
				if upgrade_all_build_timer then
					remove_build_timer()
				end
				Net.send(TEST_CMD,{99,{"g10read","g10read","user_city",2,tonumber(cmdlist[2] ),"build_area_max","600"}})				
				Net.send(TEST_CMD,{3,{"99,1000000;1,100000000;2,100000000;3,100000000;4,100000000;5,1000000"}})
				upgrade_all_build_timer = scheduler.create(function  ()
						 		 	gm_up_action(tonumber(cmdlist[2] ))
						 		end,1)
			end

		elseif cmdlist[1] == "effect_gain_gold" then 
			require("game/uiCommon/commonPopupManager")
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,10)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,20)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,30)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,40)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,50)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,60)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,70)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,80)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,90)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,100)
        elseif cmdlist[1] == "effect_gain_queue" then 
			require("game/uiCommon/commonPopupManager")
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,1)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,2)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,3)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,4)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,5)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,6)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,7)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,8)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,9)
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,10)
      	elseif cmdlist[1] == "effect_gain_hero" then 
      		require("game/uiCommon/commonPopupManager")
      		commonPopupManager.gainAwardItem(taskAwardType.TYPE_CARD_HERO,100089)
		elseif cmdlist[1] == "card" then
			-- if cmdlist[2]=="refresh" then
			-- 	if dbTableDesList.user_card_extract and dbTableDesList.user_card_extract.name and allTableData[dbTableDesList.user_card_extract.name] then
			-- 			for k,v in pairs(allTableData[dbTableDesList.user_card_extract.name]) do
			-- 				Net.send(TEST_CMD,{99,{"g10read","g10read","user_card_extract",3,v.extract_id_u}})							
			-- 			end
			-- 	end	
			-- 	for k,v in pairs(Tb_cfg_card_extract) do					
			-- 		Net.send(TEST_CMD,{99,{"g10read","g10read","user_card_extract",1,"userid",tostring(userid),"refresh_way_id",tostring(v.refresh_way_id),"got_time",tostring(os.time())}})
			-- 	end
			-- 		--
			-- end		
			Net.send(TEST_CMD,{9,{userid}})
			-- GIVE_USER_ALL_CARD_EXTRACT = 9; // 将所有配置的卡包，全部给指定用户
			-- 参数：用户id
		end


			
		if text == "1" then
			requestGm("time-1 1")
		elseif text == "delete_union" then
			Net.send(UNION_DISSOLVE,{})
		elseif string.sub(text,1,4) == "time" then
			local space = string.find(text," ")
			local string = string.sub(text,5,space-1)
			local string2 = string.sub(text,space+1, string.len(text))
			Net.send(TEST_CMD,{4,{tonumber(string),tonumber(string2)}})
		elseif string.sub(text,1) == "5" then
			Net.send(TEST_CMD,{5,{}})
		end
	end
end


function remove_build_timer()
	if upgrade_all_build_timer then
		scheduler.remove(upgrade_all_build_timer)
		upgrade_all_build_timer = nil
	end
end
function gm_finish_immediately( wid,curent_build_id )
	local state=0
	if allTableData[dbTableDesList.build.name][wid*100+curent_build_id] then
			state = allTableData[dbTableDesList.build.name][wid*100+curent_build_id].state
	end
	if state~=0 then				
		Net.send(BUILDING_FINISH_IMMEDIATELY,{wid})
	end
end
function gm_upgrade_all_build(wid)
	--城市内所有建筑列表，不包括4个高级地建筑
	--local test_table = {10, 13,20,21,22,23,24,25,61,63,64,65,43,31,32,33,34,42,35,40,52,54,51,53,36,30,44}
	--集市有BUG
	--local test_table = {10, 13,20,21,22,23,24,25,61,63,64,65,43,31,32,33,34,42,35,40,52,54,51,53,36,30,44}
	local test_table = {}
	local cityInfo = landData.get_world_city_info(wid)
	if cityInfo.city_type == 3 then
	 	test_table = {12,13,20,21,22,23,24,25,30,31,32,33,34,35,36,40,37,42,64,65,43,44,51,52,53,54,61,66,63,64,65}
	elseif cityInfo.city_type == 1 then 
		test_table = {10,13,20,21,22,23,24,25,30,31,32,33,34,35,36,40,37,42,64,65,43,44,51,52,53,54,61,66,63,64,65}
	elseif cityInfo.city_type ==4 then 
		test_table = {11}
	end

	curent_build_id = test_table[curent_build_index]
	
	if curent_build_id then
		local indeed_build_level = 0
		if allTableData[dbTableDesList.build.name][wid*100+curent_build_id] then
	 		indeed_build_level = allTableData[dbTableDesList.build.name][wid*100+curent_build_id].level
		end
		print("curent_build_id.."..curent_build_id.." indeed_build_level.."..indeed_build_level)
		if not Tb_cfg_build[curent_build_id] then
			print("unexist build id")
			return
		end
		max_build_level = Tb_cfg_build[curent_build_id].max_level 
		if(curent_try_times>=50) or (indeed_build_level>=max_build_level) then
			curent_build_index = curent_build_index+1
			curent_try_times = 0
			gm_upgrade_all_build(wid)
		else 
			local state=0
			if allTableData[dbTableDesList.build.name][wid*100+curent_build_id] then
	 			state = allTableData[dbTableDesList.build.name][wid*100+curent_build_id].state
			end	
			if state==0 then
				if indeed_build_level~=0 then			
					Net.send(BUILDING_UPGRADE, {wid, curent_build_id})
				else
					Net.send(BUILDING_BUILD, {wid, curent_build_id})							
				end 
				curent_try_times = curent_try_times+1		
			end

		end
	else
		print("end game")
		remove_build_timer()
	end
	-- for i,v in ipairs(test_table) do
	-- 	print(i,v)
	-- end
end
function gm_up_action(wid)
	local scene = cc.Director:getInstance():getRunningScene()
	local action  = animation.sequence({ cc.CallFunc:create(function ( )
		gm_upgrade_all_build(wid)
	end), cc.DelayTime:create(0.3), cc.CallFunc:create(function ( )
		if curent_build_id then
			gm_finish_immediately( wid,curent_build_id )	
		end
	end)})

	scene:runAction(action)
end
function requestGm( text )
	if text == "res" then
		Net.send(TEST_CMD,{3,{"99,10000;1,10000;2,10000;3,10000;4,10000;5,10000"}})
	elseif string.sub(text,1,4) == "time" then
		local space = string.find(text," ")
		local string = string.sub(text,5,space-1)
		local string2 = string.sub(text,space+1, string.len(text))
		Net.send(TEST_CMD,{4,{tonumber(string),tonumber(string2)}})
	elseif string.sub(text,1) == "5" then
		Net.send(TEST_CMD,{5,{}})
	end
end



local function deal_with_third_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_widget = gm_show_layer:getWidgetByTag(999)
		local new_gm_panel = tolua.cast(temp_widget:getChildByName("new_gm"), "Layout")
		-- local gm_txt = tolua.cast(new_gm_panel:getChildByName("gm_txt"), "TextField")
		--local gm_txt = "Net.send(CONQUER_FIELD_CMD, {7650643, 76506424})"
		--loadstring(gm_txt)()
		--print(gm_txt:getStringValue())
    	loadstring(gm_txt:getStringValue())
	end
end

function create()
	if not configBeforeLoad.getDebugEnvironment() then
		-- TODOTK 中文收集
        tipsLayer.create("敬请期待")
		return
	end

	if gm_show_layer then
		return
	end

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/gm_simple_version.json")
    temp_widget:setTag(999)
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5, 0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local old_gm_panel = tolua.cast(temp_widget:getChildByName("old_gm"), "Layout")
	local second_send_btn = tolua.cast(old_gm_panel:getChildByName("send_btn_2"), "Button")
	second_send_btn:setTouchEnabled(true)
	second_send_btn:addTouchEventListener(deal_with_second_click)

	

	local panel = tolua.cast(old_gm_panel:getChildByName("Panel_634352"),"Layout")
	local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(14,14,2,2)
    gm_txt = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("main_interface_of_city_information_base.png",rect))
    gm_txt:setAlignment(1)
    gm_txt:setFontName(config.getFontName())
    gm_txt:setFontSize(30*config.getgScale())
    gm_txt:setFontColor(ccc3(255,255,255))
    panel:addChild(gm_txt)
    gm_txt:setScale(1/config.getgScale())
    -- gm_txt:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    gm_txt:setAnchorPoint(cc.p(0,0))


	gm_show_layer = TouchGroup:create()
	gm_show_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(gm_show_layer, uiIndexDefine.GM_MANAGER)

	local scrollView = CCScrollView:create()
	local str = nil
	local layerHeight = 0
	-- for i,v in ipairs(main_error) do
		str = CCLabelTTF:create(main_error[#main_error] or "",config.getFontName(), 20, CCSize(config.getWinSize().width, 0), kCCTextAlignmentCenter)
		str:setAnchorPoint(cc.p(0,1))
		-- str:setPosition(cc.p(0, height-layerHeight))
		layerHeight = layerHeight + 23
	-- end
	local height = 23--23*#main_error
	if str then
		height = str:getContentSize().height
	end
	local layer = cc.LayerColor:create(cc.c4b(0,0,0,255),config.getWinSize().width, height)
		layer:addChild(str)
		str:setPositionY(height)
	local panel = tolua.cast(temp_widget:getChildByName("log_print"), "Layout")
	if nil ~= scrollView then
        scrollView:setViewSize(CCSizeMake(config.getWinSize().width,panel:getSize().height))
        scrollView:setContainer(layer)
        scrollView:updateInset()
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        scrollView:ignoreAnchorPointForPosition(false)
        scrollView:setAnchorPoint(cc.p(0.5,0))
        scrollView:setContentOffset(cc.p(0,-height+scrollView:getViewSize().height))
    end
    panel:addChild(scrollView)
    scrollView:setPosition(cc.p(panel:getContentSize().width/2, 0))
end
