module("BlackNameListData",package.seeall)


local cacheVoList = nil
local cacheIdList = nil
local cacheNameList = nil

local cache_tips_add_id_list = nil
local cache_tips_add_name_list = nil


local cache_last_del_id_list = nil
local cache_last_del_name_list = nil


local function updateCacheVoList()

	
	cacheVoList = {}

	local vo = nil
	local tmp_list_data = {}
    local tmp_name_list_data = {}

    local flag_exit = false
    local tmp_name = nil
    for k,v in pairs(cacheIdList) do 
        flag_exit = false
        tmp_name = ""
        for i = 1,#cacheNameList,2 do 
            if cacheNameList[i] == tonumber(v) and cacheNameList[i+1] ~= "" then 
                flag_exit = true
                tmp_name = cacheNameList[i+1]
                break
            end
        end
        if flag_exit then 
        	vo = {}
        	vo.userid = tonumber(v)
        	vo.name = tmp_name
        	table.insert(cacheVoList,vo)
        end
    end


end

local function requestNameListData()
	Net.send(GET_BLACK_LIST)
end

local function responeNameListData(data)
	config.dump(data)

	--如果获取到对应的name 为空 那对应id 也是无效的
	if data == cjson.null then 
		data = {}
	else
		data = cjson.decode(data)
	end

	
    if not data then data = {} end
    cacheNameList = data

    updateCacheVoList()


    

    if cache_tips_add_id_list and #cache_tips_add_id_list ~= 0 then

	    local uid = cache_tips_add_id_list[1]
	    local strName = ""
	    
	    for k,v in pairs(cacheVoList) do 
	        if v.userid == uid then 
	            strName = v.name
	        end
	    end
	    
	    if #cache_tips_add_id_list > 1 then 
	        strName = strName .. languagePack["list_and_so_on"]
	    end
	    alertLayer.create(errorTable[2028],{strName})
	    cache_tips_add_id_list = nil
	end


	if cache_tips_add_name_list and #cache_tips_add_name_list ~= 0 then 
		local strName = cache_tips_add_name_list[1]
		if #cache_tips_add_name_list > 1 then 
	        strName = strName .. languagePack["list_and_so_on"]
	    end
	    alertLayer.create(errorTable[2028],{strName})
	    cache_tips_add_name_list = nil
	end

	if UIRoleForcesDetail then 
		UIRoleForcesDetail.resetBlackNameState()
	end
end



local function initData()
	cacheIdList = userData.getUserBlackList()
	requestNameListData()
end


local function clearData()
	cacheVoList = nil
	cacheIdList = nil
	cacheNameList = nil
end


local function dbDataChanged(package)
	if package.black_list then 

		if cache_last_del_id_list and #cache_last_del_id_list >= 0 then 
			local uid = cache_last_del_id_list[1]
		    local strName = ""
		    
		    for k,v in pairs(cacheVoList) do 
		        if v.userid == uid then 
		            strName = v.name
		        end
		    end
		    
		    if #cache_last_del_id_list > 1 then 
		        strName = strName .. languagePack["list_and_so_on"]
		    end
		    alertLayer.create(errorTable[2029],{strName})
		    cache_last_del_id_list = nil
		end

		if cache_last_del_name_list and #cache_last_del_name_list > 0 then
			local strName = cache_last_del_name_list[1]
			if #cache_last_del_name_list > 1 then 
		        strName = strName .. languagePack["list_and_so_on"]
		    end
		    alertLayer.create(errorTable[2029],{strName})
		    cache_last_del_name_list = nil
		end

		initData()

	
	end
end


local function requestDelBlackList(uidList)
    Net.send(DEL_BLACK_LIST,uidList)
end

local function responeDelBlackList()
    
end


local function checkNameListCountLimit()
	-- TODOTK 500 这个值要跟服务端一致
	if #cacheVoList >= 500 then 
		alertLayer.create(errorTable[2030])
		return true
	end
	return false
end

local function requestAddBlackList(uidList)

    Net.send(ADD_BLACK_LIST,uidList)
end

local function responeAddBlackList()
    --
end



------------------- 对外接口

function remove()
	clearData()
	UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, dbDataChanged)
	netObserver.removeObserver(GET_BLACK_LIST)
	netObserver.removeObserver(ADD_BLACK_LIST)
    netObserver.removeObserver(DEL_BLACK_LIST)
end


function create()
	initData()

	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, dbDataChanged)
	netObserver.addObserver(GET_BLACK_LIST,responeNameListData)
	netObserver.addObserver(ADD_BLACK_LIST,responeAddBlackList)
    netObserver.addObserver(DEL_BLACK_LIST,responeDelBlackList)
end









function addUserByNameList(nameList)
	if checkNameListCountLimit() then return end
	local tmp_list = {}

	for k,v in pairs(nameList) do 
		table.insert(tmp_list,0)
		table.insert(tmp_list,v)
	end

	requestAddBlackList(tmp_list)

	if not cache_tips_add_name_list then 
		cache_tips_add_name_list = {}
	end

	for k,v in pairs(nameList) do 
		table.insert(cache_tips_add_name_list,v)
	end	
end



function addUserByIdList(uidList)
	if checkNameListCountLimit() then return end
	local tmp_list = {}

	

	for k,v in pairs(uidList) do 
		table.insert(tmp_list,1)
		table.insert(tmp_list,tonumber(v))
	end

	requestAddBlackList(tmp_list)

	if not cache_tips_add_id_list then 
		cache_tips_add_id_list = {}
	end

	for k,v in pairs(uidList) do 
		table.insert(cache_tips_add_id_list,tonumber(v))
	end	
end

function delUserByNameList(nameList)
	local tmp_list = {}
	
	for k,v in pairs(nameList) do 
		table.insert(tmp_list,0)
		table.insert(tmp_list,v)
	end
	requestDelBlackList(tmp_list)

	if not cache_last_del_name_list then cache_last_del_name_list = {} end
	for k,v in pairs(nameList) do 
		table.insert(cache_last_del_name_list,v)
	end

end

function delUserByIdList(uidList)
	local tmp_list = {}
	
	for k,v in pairs(uidList) do
		table.insert(tmp_list,1) 
		table.insert(tmp_list,tonumber(v))
	end
	requestDelBlackList(tmp_list)

	if not cache_last_del_id_list then cache_last_del_id_list = {} end
	for k,v in pairs(uidList) do 
		table.insert(cache_last_del_id_list,tonumber(v))
	end
end

function checkIsInListById(uid)
	if not cacheVoList then return false end
	for k,v in pairs(cacheVoList) do 
		if v.userid == uid then return true end
	end
	return false
end

function checkIsInListByName(uname)
	if not cacheVoList then return false end
	for k,v in pairs(cacheVoList) do 
		if v.name == uname then return true end
	end
	return false
end


function getBlackList()
	if not cacheVoList then return {} end
	return cacheVoList
end

